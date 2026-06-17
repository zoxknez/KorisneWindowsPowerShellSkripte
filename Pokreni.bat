@echo off
title Windows Utility Toolkit
chcp 65001 > nul
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "Start-Menu.ps1"
pause
