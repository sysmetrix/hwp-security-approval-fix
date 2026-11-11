@echo off
chcp 65001 >nul
echo.
echo  [설치 취소 - 이전 상태로 되돌립니다]
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Install-HwpApproval.ps1" -Remove
pause
