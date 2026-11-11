# hwp-security-approval-fix

한글(HWP) 자동화 때마다 뜨는 **"파일 접근 허용"** 보안 대화상자를 없애는 도구와 Claude 스킬.

## 원인
한글은 `HKCU\Software\HNC\HwpAutomation\Modules`에 등록된 보안모듈 DLL이 승인해야 대화상자를 생략한다. DLL 경로에 한글·괄호 등 비ASCII 문자가 있으면 한글이 DLL을 읽지 못해 `RegisterModule`이 False를 돌려주고 대화상자가 계속 뜬다. ASCII 경로에 복사해 등록하면 True가 된다(한글 2024 13.0.0.3901, 32비트 DLL로 확인).

## 사용
```powershell
# 점검(변경 없음)
powershell -File scripts\Install-HwpApproval.ps1 -Check
# 설치(현재 사용자 HKCU만 변경, 관리자 권한 불필요)
powershell -ExecutionPolicy Bypass -File scripts\Install-HwpApproval.ps1
# 해제
powershell -File scripts\Install-HwpApproval.ps1 -Remove
```
한글을 모두 닫은 뒤 `python scripts\hwp_approval.py`가 `module FilePathCheckerModule`을 출력하면 적용된 것이다.

자동화 코드:
```python
from hwp_approval import open_hwp
hwp = open_hwp()
hwp.Open(path, "", "forceopen:true")
```

## Claude 스킬
`skill/hwp-approval-fix`를 `.claude/skills/`에 복사한다.

## 참고
- 보안모듈 DLL은 한컴 배포물이라 포함하지 않는다. 스크립트가 기존 등록 경로, `pyhwpx` 패키지, `C:\보안모듈(Automation)`에서 찾아 복사한다. 없으면 한컴 개발자 자료실 또는 `pip install pyhwpx`.
- 이 도구는 파일 접근 승인을 자동화하므로 신뢰하는 자동화 환경에서만 쓴다.
