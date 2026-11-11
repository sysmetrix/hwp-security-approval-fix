@echo off
chcp 65001 >nul
echo.
echo  [한글 "파일 접근 허용" 창 없애기 - 설치]
echo  열려 있는 한글 프로그램은 먼저 모두 닫아 주세요.
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Install-HwpApproval.ps1"
echo.
echo  위에 "등록 완료"가 보이면 성공입니다. 한글을 다시 켜서 쓰세요.
pause
