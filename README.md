# NTLMv1 SSO Temporary Compatibility Script

## 中文說明

此專案提供一個 PowerShell 腳本，讓 IT 管理員在 Windows 11 24H2 及更新版本中，暫時允許使用 NTLMv1-derived credentials 的 Single Sign-On（SSO）流程。

Microsoft 已逐步淘汰 NTLM，並在 Windows 11 24H2、Windows 11 25H2、Windows 11 26H2 及 Windows Server 2025 中移除完整的 NTLMv1 protocol。相關變更可能影響使用 MS-CHAPv2 的 Wi‑Fi、Ethernet 或 VPN，例如 PEAP-MSCHAPv2 及 EAP-MSCHAPv2。

### Registry 設定

腳本會新增或設定以下 Registry value：

```text
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0
BlockNtlmv1SSO    REG_DWORD    0
```

`BlockNtlmv1SSO` 的值：

- `0`：Audit mode。允許 NTLMv1-derived SSO，但記錄警告事件。
- `1`：Enforce mode。封鎖 NTLMv1-derived SSO。

此腳本設定值為 `0`，用途是作為臨時兼容措施。Microsoft 建議完成遷移後使用 Enforce mode，並逐步移除對 NTLM 的依賴。

### 腳本會做什麼

1. 檢查 `C:\deploy\ntlm V1.txt` 是否存在。
2. 如果識別檔已存在，腳本會直接結束，不再修改 Registry。
3. 如果不存在，建立 `C:\deploy` 資料夾。
4. 將現有相關 Registry 備份至 `C:\deploy\NTLMv1SSO-backup.reg`。
5. 建立 Registry key（如不存在）。
6. 新增或設定 `BlockNtlmv1SSO = 0`。
7. 成功後建立 `C:\deploy\ntlm V1.txt` 作為完成標記。

腳本只會修改 `BlockNtlmv1SSO`，不會刪除同一 Registry key 內的其他 values。

### Intune 建議設定

- Run this script using the logged on credentials：`No`
- Run script in 64-bit PowerShell host：`Yes`
- Assign to：Device group

PowerShell 腳本應以 SYSTEM 權限執行，因為它需要修改 `HKEY_LOCAL_MACHINE`。

### 事件記錄

事件記錄位置：

```text
Microsoft-Windows-NTLM/Operational
```

相關事件包括：

- Event ID `4024`：NTLMv1-derived credentials 被審核但獲准使用。
- Event ID `4025`：NTLMv1-derived credentials 被政策封鎖。

### 安全注意事項

NTLMv1 及其衍生加密方式較弱，可能增加認證被攻擊或重放的風險。此腳本只應用於已確認存在相容性問題的測試或生產設備，並應作為臨時例外。完成網絡、Wi‑Fi、VPN 或應用程式遷移後，應移除例外並改用較安全的認證方式。

此 Registry 設定不會重新安裝或恢復 Windows 11 24H2 以後已移除的完整 NTLMv1 protocol。

官方文件：[Manage changes to NTLMv1 and prevent network issues in Windows 11 and Windows Server 2025](https://support.microsoft.com/en-us/servicing/os/windows/docs/2025/08/upcoming-changes-to-ntlmv1-in-windows-11-version-24h2-and-windows-server-2025)

---

## English Description

This project provides a PowerShell script for IT administrators who need a temporary compatibility exception for Single Sign-On (SSO) flows that use NTLMv1-derived credentials on Windows.

Microsoft is deprecating NTLM and has removed the full NTLMv1 protocol from Windows 11 version 24H2 and later, and Windows Server 2025. The change can affect Wi‑Fi, Ethernet, and VPN configurations that use MS-CHAPv2, including PEAP-MSCHAPv2 and EAP-MSCHAPv2.

### Registry Setting

The script creates or configures the following registry value:

```text
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0
BlockNtlmv1SSO    REG_DWORD    0
```

Values supported by Microsoft:

- `0`: Audit mode. NTLMv1-derived SSO is allowed and warning events are logged.
- `1`: Enforce mode. NTLMv1-derived SSO is blocked.

This script sets the value to `0` as a temporary compatibility exception. Microsoft recommends moving to Enforce mode after the dependency has been remediated.

### What the Script Does

1. Checks whether `C:\deploy\ntlm V1.txt` exists.
2. If the marker exists, the script exits without changing the registry.
3. If the marker does not exist, it creates `C:\deploy`.
4. Backs up the relevant registry settings to `C:\deploy\NTLMv1SSO-backup.reg`.
5. Creates the registry key if it does not already exist.
6. Creates or sets `BlockNtlmv1SSO = 0`.
7. Creates `C:\deploy\ntlm V1.txt` only after the registry change succeeds.

The script changes only `BlockNtlmv1SSO`. Other values under the same registry key are preserved.

### Recommended Intune Settings

- Run this script using the logged on credentials: `No`
- Run script in 64-bit PowerShell host: `Yes`
- Assign to: Device group

The script should run in the SYSTEM context because it modifies `HKEY_LOCAL_MACHINE`.

### Event Log

Event log path:

```text
Microsoft-Windows-NTLM/Operational
```

Relevant events include:

- Event ID `4024`: NTLMv1-derived credentials were audited and allowed.
- Event ID `4025`: NTLMv1-derived credentials were blocked by policy.

### Security Notice

NTLMv1 and its derived cryptography are weak and may increase authentication attack and replay risks. Use this script only as a temporary exception for systems with a confirmed compatibility dependency. After migrating the affected Wi‑Fi, VPN, network, or application configuration, remove the exception and use a stronger authentication method.

This registry setting does not reinstall or restore the full NTLMv1 protocol removed from Windows 11 version 24H2 and later.

Official documentation: [Manage changes to NTLMv1 and prevent network issues in Windows 11 and Windows Server 2025](https://support.microsoft.com/en-us/servicing/os/windows/docs/2025/08/upcoming-changes-to-ntlmv1-in-windows-11-version-24h2-and-windows-server-2025)
