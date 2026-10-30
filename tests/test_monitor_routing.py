#!/usr/bin/env python3
"""Exercise the real routing script against a stateful AeroSpace transport."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


def fake_transport():
    path = Path(os.environ["MONITOR_FIXTURE"])
    state = json.loads(path.read_text())
    args = sys.argv[1:]
    state["calls"].append(args)
    command = args[0]
    if command not in ("enable", "--query") and not state["server_enabled"]:
        path.write_text(json.dumps(state))
        sys.exit(2)
    if command == "--query":
        print(json.dumps(state["displays"]))
    elif command == "list-monitors":
        for display in state["displays"]:
            print(f'{display["monitor"]}|{display["DirectDisplayID"]}')
    elif command == "list-workspaces":
        if "--focused" in args:
            print(state["focused"])
        else:
            key = "layout" if "workspace-root-container-layout" in args[-1] else "monitor"
            for name, workspace in state["workspaces"].items():
                print(f'{name}|{workspace[key]}')
    elif command == "move-workspace-to-monitor":
        state["workspaces"][args[2]]["monitor"] = int(args[3])
        state["focused"] = args[2]
    elif command == "layout":
        state["workspaces"][args[2]]["layout"] = args[-1]
    elif command == "balance-sizes":
        pass
    elif command == "enable":
        state["server_enabled"] = args[1] == "on"
    elif command == "workspace":
        state["focused"] = args[1]
    elif command == "list-windows":
        for window, workspace in state["windows"].items():
            if workspace == args[2]:
                print(window)
    elif command == "move-node-to-workspace":
        state["windows"][args[2]] = args[3]
    else:
        raise RuntimeError(f"Unexpected command: {args}")
    path.write_text(json.dumps(state))


def display(monitor, direct, uuid, x, y, width, height):
    return dict(monitor=monitor, DirectDisplayID=direct, UUID=uuid,
                frame=dict(x=x, y=y, w=width, h=height))


class MonitorRoutingTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        self.fixture = self.directory / "state.json"
        self.transport = self.directory / "transport"
        shutil.copyfile(__file__, self.transport)
        self.transport.chmod(0o755)
        self.environment = dict(os.environ, MONITOR_FIXTURE=str(self.fixture),
                                XDG_STATE_HOME=str(self.directory / "runtime"),
                                AEROSPACE_QUERY_BIN=str(self.transport),
                                SKETCHYBAR_BIN=str(self.transport))
        self.script = Path(__file__).resolve().parents[1] / "config/aerospace/scripts/assign-monitors"
        self.windows = {str(100 + number): str(number) for number in range(1, 12)}
        self.state = dict(calls=[], focused="5", windows=self.windows.copy(), displays=[], server_enabled=True,
                          workspaces={str(n): dict(monitor=1, layout="h_tiles")
                                      for n in range(1, 12)})

    def run_routing(self, displays):
        self.state["displays"] = displays
        self.state["calls"] = []
        self.fixture.write_text(json.dumps(self.state))
        subprocess.run(["/bin/bash", str(self.script)], env=self.environment,
                       check=True, capture_output=True, text=True, timeout=15)
        self.state = json.loads(self.fixture.read_text())
        self.assertEqual(self.state["windows"], self.windows)
        self.assertEqual(self.state["focused"], "5")
        self.assertFalse(any(call[0] == "move-node-to-workspace" for call in self.state["calls"]))

    def test_disconnect_and_reconnect_preserve_workspace_membership(self):
        portrait = display(1, 3, "portrait", -1080, -1080, 1080, 1920)
        landscape = display(2, 2, "landscape", 0, -1080, 1920, 1080)
        laptop = display(3, 1, "laptop", 0, 0, 1512, 982)
        for displays, owners in [
            ([laptop, landscape, portrait], [1] * 3 + [2] * 3 + [3] * 3),
            ([display(1, 1, "laptop", 0, 0, 1512, 982)], [1] * 9),
            ([portrait, laptop], [1] * 5 + [3] * 4),
            ([landscape, laptop], [2] * 5 + [3] * 4),
            ([laptop, landscape, portrait], [1] * 3 + [2] * 3 + [3] * 3),
        ]:
            with self.subTest(displays=len(displays), owners=owners):
                # macOS/AeroSpace may reassign whole workspaces on disconnect.
                for workspace in self.state["workspaces"].values():
                    workspace["monitor"] = displays[0]["monitor"]
                self.run_routing(displays)
                for number, owner in enumerate(owners, 1):
                    workspace = self.state["workspaces"][str(number)]
                    self.assertEqual(workspace["monitor"], owner)
                    screen = next(d for d in displays if d["monitor"] == owner)
                    expected = "v_tiles" if screen["frame"]["h"] > screen["frame"]["w"] else "h_tiles"
                    self.assertEqual(workspace["layout"], expected)

    def test_manual_layout_and_size_survive_unchanged_screen(self):
        screens = [display(1, 1, "laptop", 0, 0, 1512, 982)]
        self.run_routing(screens)
        self.state["workspaces"]["5"]["layout"] = "v_tiles"
        self.run_routing(screens)
        self.assertEqual(self.state["workspaces"]["5"]["layout"], "v_tiles")
        self.assertFalse(any(c[0] in ("layout", "balance-sizes") for c in self.state["calls"]))

    def test_changing_direct_display_id_does_not_reset_manual_layout(self):
        self.run_routing([display(1, 1, "laptop", 0, 0, 1512, 982)])
        self.state["workspaces"]["5"]["layout"] = "v_tiles"
        self.run_routing([display(1, 9, "laptop", 0, 0, 1512, 982)])
        self.assertEqual(self.state["workspaces"]["5"]["layout"], "v_tiles")

    def test_disabled_routing_does_not_query_or_move_windows(self):
        enabled = self.directory / "runtime/aerospace/enabled"
        enabled.parent.mkdir(parents=True)
        enabled.write_text("off\n")
        self.state["server_enabled"] = False
        self.run_routing([display(1, 1, "laptop", 0, 0, 1512, 982)])
        self.assertEqual(self.state["calls"], [])
        self.assertFalse(self.state["server_enabled"])

    def test_running_but_disabled_server_is_reenabled(self):
        self.state["server_enabled"] = False
        self.run_routing([display(1, 1, "laptop", 0, 0, 1512, 982)])
        self.assertTrue(self.state["server_enabled"])


if __name__ == "__main__":
    if "MONITOR_FIXTURE" in os.environ:
        fake_transport()
    else:
        unittest.main()
