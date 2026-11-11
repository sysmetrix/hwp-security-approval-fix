<#
.SYNOPSIS
  한글(HWP) 자동화 때마다 뜨는 "파일 접근 허용" 보안 대화상자를 없앤다.

.DESCRIPTION
  원인: 한글은 레지스트리 HKCU\Software\HNC\HwpAutomation\Modules 에 등록된
  보안모듈(DLL)이 접근을 승인해 주면 대화상자를 띄우지 않는다.
  DLL 경로에 한글·괄호 등 비ASCII 문자가 있으면 한글이 DLL을 못 읽어
  RegisterModule 이 False 를 돌려주고, 그래서 대화상자가 계속 뜬다.
  이 스크립트는 DLL을 ASCII 경로로 복사해 FilePathCheckerModule 이름으로 등록한다.

  -Check  : 현재 상태만 점검(변경 없음)
  (기본)  : 설치(현재 사용자 HKCU만 변경, 관리자 권한 불필요)
  -Remove : 등록 해제
#>
[CmdletBinding()]
param(
  [switch]$Check,
  [switch]$Remove,
  [string]$Dll,                     # 원본 DLL 경로를 직접 지정할 때
  [string]$Target                   # 복사해 둘 ASCII 폴더(기본: %LOCALAPPDATA%\hwp-approval)
)
$ErrorActionPreference = 'Stop'
$RegPath = 'HKCU:\Software\HNC\HwpAutomation\Modules'
$Name    = 'FilePathCheckerModule'
$DllName = 'FilePathCheckerModule.dll'

function Test-Ascii([string]$s){ return ($s -cmatch '^[\x20-\x7E]+$') }
function Get-Arch([string]$f){
  $b=[IO.File]::ReadAllBytes($f); $o=[BitConverter]::ToInt32($b,0x3C)
  switch ([BitConverter]::ToUInt16($b,$o+4)) { 0x14C {'x86'} 0x8664 {'x64'} default {'?'} }
}

if ($Check -or $Remove) {
  $cur = if (Test-Path $RegPath) { (Get-ItemProperty $RegPath).$Name } else { $null }
}
if ($Check) {
  "레지스트리 값($Name): $cur"
  if ($cur) {
    "  파일 존재: $(Test-Path -LiteralPath $cur)"
    "  ASCII 경로: $(Test-Ascii $cur)"
    if (Test-Path -LiteralPath $cur) { "  비트: $(Get-Arch $cur)" }
  } else { '  미등록 → 인자 없이 다시 실행하면 설치됨' }
  return
}
if ($Remove) {
  if (Test-Path $RegPath) { Remove-ItemProperty $RegPath -Name $Name -ErrorAction SilentlyContinue }
  '등록 해제함(복사해 둔 DLL 폴더는 남겨 둠).'; return
}

# 1) 원본 DLL 찾기 (한컴 공식 보안모듈 예제. 이 저장소는 DLL을 재배포하지 않음)
$cands = @()
if ($Dll) { $cands += $Dll }
if (Test-Path $RegPath) { (Get-ItemProperty $RegPath).PSObject.Properties |
  Where-Object { $_.Value -is [string] -and $_.Value -like '*.dll' } | ForEach-Object { $cands += $_.Value } }
$cands += 'C:\보안모듈(Automation)\FilePathCheckerModuleExample.dll'
$cands += 'C:\보안모듈(Automation)\FilePathCheckerModule.dll'
foreach ($py in 'py','python') {
  try { $p = & $py -c "import pyhwpx,os;print(os.path.dirname(pyhwpx.__file__))" 2>$null
        if ($p) { $cands += (Join-Path $p $DllName) } } catch {}
}
$src = $cands | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
if (-not $src) {
  throw "보안모듈 DLL을 찾지 못함. 한컴 개발자 자료실의 '한글 오토메이션 보안모듈(FilePathCheckerModuleExample.dll)'을 받거나 'pip install pyhwpx' 후 다시 실행하거나, -Dll 로 경로를 지정하세요."
}

# 2) ASCII 경로로 복사 (사용자 이름이 비ASCII면 C:\hwp-approval 사용)
if (-not $Target) { $Target = Join-Path $env:LOCALAPPDATA 'hwp-approval' }
if (-not (Test-Ascii $Target)) { $Target = 'C:\hwp-approval' }
New-Item -ItemType Directory -Force $Target | Out-Null
$dst = Join-Path $Target $DllName
Copy-Item -LiteralPath $src -Destination $dst -Force
"DLL 복사: $src -> $dst ($(Get-Arch $dst))"

# 3) 레지스트리 등록
New-Item -Path $RegPath -Force | Out-Null
New-ItemProperty -Path $RegPath -Name $Name -Value $dst -PropertyType String -Force | Out-Null
"등록 완료: $RegPath\$Name = $dst"
'열려 있는 한글을 모두 닫고 다시 실행하면 적용됨. 확인: scripts\Test-HwpApproval.py'
