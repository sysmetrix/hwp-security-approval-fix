# 한글 "파일 접근 허용" 창 없애기

한글(HWP) 문서를 자동화 도구(파이썬 등)로 열 때마다 아래 창이 뜨면서 작업이 멈추나요?

> **한글을 이용하여 위 파일에 접근하려는 시도(파일의 손상 또는 유출의 위험 등)가 있습니다.**
> [접근 허용] [모두 허용] [허용 안 함] [모두 허용 안 함]

이 도구를 **한 번만 설치**하면 창이 더 이상 뜨지 않습니다.

## 설치 (3단계, 1분)

1. 이 페이지 위쪽 초록색 **Code → Download ZIP**을 눌러 받고, 압축을 풉니다.
2. **열려 있는 한글을 모두 닫습니다.**
3. 압축 푼 폴더의 **`1_설치하기.bat`을 더블클릭**합니다.
   검은 창에 **"등록 완료"**가 보이면 끝입니다.

> 관리자 권한은 필요 없습니다. 내 계정의 설정만 바뀌고, 언제든 `3_해제하기.bat`으로 되돌릴 수 있습니다.

## 잘 됐는지 확인

`2_점검하기.bat`을 더블클릭해서 아래처럼 나오면 정상입니다.

```
파일 존재: True
ASCII 경로: True
비트: x86
```

## 설치 후 사용법

**설치는 한 번이면 끝입니다.** 그 뒤로는 평소처럼 쓰면 됩니다. 따로 켜거나 누를 것이 없습니다.

### 1. 그냥 한글 쓰는 분
아무것도 안 해도 됩니다. 자동화 도구가 한글 문서를 열 때 "접근 허용" 창이 더 이상 뜨지 않습니다.

### 2. pyhwpx를 쓰는 분
설치만 하면 됩니다. pyhwpx가 같은 이름(`FilePathCheckerModule`)으로 보안모듈을 등록하므로 코드를 고칠 필요가 없습니다.

```python
from pyhwpx import Hwp
hwp = Hwp()
hwp.open(r"C:\문서\보고서.hwpx")
```

### 3. win32com으로 직접 만든 코드
객체를 만든 직후 한 줄을 넣습니다.

```python
import win32com.client as wc
hwp = wc.Dispatch("HWPFrame.HwpObject")
print(hwp.RegisterModule("FilePathCheckDLL", "FilePathCheckerModule"))  # True가 나와야 정상
hwp.Open(r"C:\문서\보고서.hwpx", "", "forceopen:true")
```

또는 이 저장소의 `scripts\hwp_approval.py`를 내 코드 옆에 두고 아래처럼 씁니다.

```python
from hwp_approval import open_hwp
hwp = open_hwp()
```

### 4. 새 컴퓨터로 옮겼을 때
그 컴퓨터에서 `1_설치하기.bat`을 한 번 더 실행합니다. 설정은 컴퓨터(계정)마다 따로 저장됩니다.

### 5. 문제가 생기면
| 증상 | 해야 할 일 |
|---|---|
| 코드에서 `RegisterModule`이 `False` | `1_설치하기.bat`을 다시 실행하고 한글을 닫았다 켭니다 |
| 창이 다시 뜸 | `2_점검하기.bat`으로 "파일 존재: True"인지 확인합니다. False면 설치를 다시 합니다 |
| 이 기능을 끄고 싶음 | `3_해제하기.bat` |

## 파이썬으로 한글을 자동화하는 분

```python
from hwp_approval import open_hwp   # scripts 폴더의 파일
hwp = open_hwp()                    # "module FilePathCheckerModule"이 출력되면 정상
hwp.Open(r"C:\문서\보고서.hwpx", "", "forceopen:true")
```

직접 만든 코드라면 객체를 만든 직후 이 한 줄만 넣어도 됩니다.

```python
hwp.RegisterModule("FilePathCheckDLL", "FilePathCheckerModule")   # True면 성공
```

## 자주 묻는 질문

**"DLL을 찾지 못함"이라고 나와요.**
한컴의 보안모듈 파일(`FilePathCheckerModule.dll`)이 필요합니다. 터미널에서 `pip install pyhwpx`를 실행한 뒤 `1_설치하기.bat`을 다시 누르면 자동으로 찾아 씁니다. 파일이 이미 있다면 `scripts\Install-HwpApproval.ps1 -Dll "파일경로"`로 지정할 수 있습니다.

**설치했는데도 창이 떠요.**
한글을 모두 닫았다가 다시 켠 뒤 시도하세요. 그래도 같으면 `2_점검하기.bat` 결과를 이슈로 남겨 주세요.

**왜 이런 일이 생기나요?**
한글은 "보안모듈"이 허락하면 이 창을 건너뜁니다. 그런데 보안모듈 파일이 `C:\보안모듈(Automation)`처럼 **한글·괄호가 든 폴더**에 있으면 한글이 읽지 못해 등록이 실패합니다. 이 도구는 파일을 영문 경로(`%LOCALAPPDATA%\hwp-approval`)로 옮겨 등록합니다. (한글 2024 13.0.0.3901에서 확인)

**안전한가요?**
이 도구는 파일 접근 확인을 자동으로 허용하게 만듭니다. 직접 만든 자동화나 믿을 수 있는 프로그램만 쓰는 PC에서 사용하세요. 한컴 DLL은 이 저장소에 포함하지 않습니다.

## Claude Code 스킬

`skill/hwp-approval-fix` 폴더를 `.claude/skills/`에 복사하면 Claude가 이 문제를 진단·안내합니다.
