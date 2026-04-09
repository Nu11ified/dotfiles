;;; early-init.el --- Early init -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil)

(setq gc-cons-threshold most-positive-fixnum)
(setq read-process-output-max (* 1024 1024)) ; 1mb

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq frame-inhibit-implied-resize t)

(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message user-login-name)
(setq initial-scratch-message nil)

(setq-default cursor-in-non-selected-windows nil)
(setq use-dialog-box nil)
(setq ring-bell-function #'ignore)