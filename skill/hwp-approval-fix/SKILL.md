---
name: hwp-approval-fix
description: 한글(HWP/HWPX) 자동화 중 "한글을 이용하여 위 파일에 접근하려는 시도(파일의 손상 또는 유출의 위험 등)가 있습니다. 접근 허용" 대화상자가 매번 뜨는 문제를 진단하고 해결한다. "한글 접근 허용 창", "RegisterModule False", "보안모듈" 요청에 사용.
---

# 한글 접근 허용 대화상자 해결

## 원인
한글은 `HKCU\Software\HNC\HwpAutomation\Modules`에 등록된 보안모듈 DLL이 승인해야 대화상자를 생략한다. DLL 경로에 한글·괄호 같은 비ASCII 문자가 있으면(예: `C:\보안모듈(Automation)\...`) 한글이 DLL을 읽지 못해 `RegisterModule`이 False가 되고 대화상자가 계속 뜬다. ASCII 경로 등록은 True가 됨(한글 2024, 13.0.0.3901에서 확인).

## 절차
1. 진단: `powershell -File scripts\Install-HwpApproval.ps1 -Check`
2. 설치는 레지스트리(보안 설정)를 바꾸므로 **사용자가 직접 실행**하도록 안내한다: `powershell -ExecutionPolicy Bypass -File scripts\Install-HwpApproval.ps1`
3. 열린 한글을 모두 닫은 뒤 `python scripts\hwp_approval.py`가 `module FilePathCheckerModule`을 출력하는지 확인한다.
4. 자동화 코드는 `from hwp_approval import open_hwp`로 시작하거나, 객체 생성 직후 `RegisterModule("FilePathCheckDLL","FilePathCheckerModule")`을 호출한다.

## 주의
- DLL은 한컴 배포물이라 이 저장소에 없다. 스크립트가 기존 등록 경로·`pyhwpx` 패키지·`C:\보안모듈(Automation)`에서 찾아 ASCII 경로로 복사한다.
- 한글이 32비트(`Hwp.exe` 0x14C)면 DLL도 32비트여야 한다.
- 등록 해제: `-Remove`. 사용자 HKCU만 바꾸며 관리자 권한은 필요 없다.
