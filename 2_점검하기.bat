@echo off
chcp 65001 >nul
echo.
echo  [현재 상태 점검 - 아무것도 바꾸지 않습니다]
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Install-HwpApproval.ps1" -Check
echo.
echo  "파일 존재: True", "ASCII 경로: True"이면 정상입니다.
pause
