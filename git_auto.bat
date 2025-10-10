@echo off
:: Single-window Git push script
title Git Auto-Pusher

:: Run everything in the original window
cmd /c "git add . && git commit -m "save" && git push"

:: Keep window open to see results
pause