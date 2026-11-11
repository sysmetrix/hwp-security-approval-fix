"""한글(HWP) COM 객체를 만든 직후 보안모듈을 등록해 '파일 접근 허용' 대화상자를 막는다.

사용:
    from hwp_approval import open_hwp
    hwp = open_hwp()            # 보안모듈 등록 + 메시지박스 자동응답까지 처리
    hwp.Open(path, "", "forceopen:true")

단독 실행하면 등록이 되는지 점검한다:  python hwp_approval.py
"""
import sys

MODULE_NAMES = ("FilePathCheckerModule", "FilePathCheckerModuleExample")  # 앞의 것이 ASCII 경로 권장 이름


def register(hwp):
    """등록 성공한 모듈 이름을 반환, 모두 실패하면 None."""
    for name in MODULE_NAMES:
        try:
            if hwp.RegisterModule("FilePathCheckDLL", name):
                return name
        except Exception:
            pass
    return None


def open_hwp(visible=False):
    import win32com.client as w
    hwp = w.gencache.EnsureDispatch("HWPFrame.HwpObject")
    name = register(hwp)
    print("module", name or False)  # False 이면 Install-HwpApproval.ps1 먼저 실행
    # 보안모듈이 없을 때를 대비한 보조 수단: 메시지박스 자동 응답
    try:
        hwp.SetMessageBoxMode(0x00020000 | 0x1 | 0x10 | 0x100)
    except Exception:
        pass
    try:
        hwp.XHwpWindows.Item(0).Visible = visible
    except Exception:
        pass
    return hwp


if __name__ == "__main__":
    h = open_hwp()
    ok = register(h) is not None
    try:
        h.Quit()
    except Exception:
        pass
    sys.exit(0 if ok else 1)
