# ============================================================================
# Bitwarden
#
# 密码存储方式：
#   PowerShell ConvertFrom-SecureString
#   → Windows DPAPI
#   → $env.USERPROFILE/.bw-cred.xml
#
# 使用方式：
#   bw-unlock
#
# 安全模型：
#   DPAPI 密文文件
#       ↓
#   PowerShell DPAPI 解密
#       ↓
#   临时明文密码（内存）
#       ↓
#   BW_PASSWORD → bw unlock
#       ↓
#   BW_SESSION → 当前 Nushell 会话
# ============================================================================
def --env bw-unlock [] {
    let cred_file = ($env.USERPROFILE | path join ".bw-cred.xml")

    if not ($cred_file | path exists) {
        print "未找到 Bitwarden DPAPI 凭据文件。"
        print "请执行以下命令生成："
        print "powershell -NoProfile -Command '$pwd = Read-Host "输入 Bitwarden 主密码" -AsSecureString; (ConvertFrom-SecureString $pwd) | Out-File -FilePath "$env:USERPROFILE\.bw-cred.xml" -Encoding utf8 -NoNewline'"
        return
    }

    let bw_info = (which bw)
    if ($bw_info | is-empty) {
        print "找不到 bw.exe，请确认 Bitwarden CLI 已加入 PATH。"
        return
    }
    let bw_path = $bw_info.0.path

    let session = (
        with-env { CRED_FILE: $cred_file, BW_PATH: $bw_path } {
            powershell.exe -NoProfile -NonInteractive -Command r#'
                $ErrorActionPreference = "Stop"

                try {
                    # 使用 .Trim() 强制剔除任何可能导致解析失败的换行符或空格
                    $raw = (Get-Content -Raw $env:CRED_FILE).Trim()
                    $ss = $raw | ConvertTo-SecureString
                    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($ss)

                    try {
                        $pw = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
                    }
                    finally {
                        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
                    }

                    $env:BW_PASSWORD = $pw

                    # 调用 Bitwarden CLI
                    & $env:BW_PATH unlock --passwordenv BW_PASSWORD --raw

                    if ($LASTEXITCODE -ne 0) {
                        exit $LASTEXITCODE
                    }
                }
            catch {
              [Console]::Error.WriteLine(
                  "Bitwarden unlock error: " + $_.Exception.Message
                  ) 
                exit 1
            }
            '#
        } | str trim
    )

      if ($session | is-empty) {
        print "Bitwarden 解锁失败。"
          print "请检查凭据密码是否正确，或者您是否已经登录 (bw status)。"
          return
      }

    $env.BW_SESSION = $session

      print "Bitwarden 已解锁。"
}
