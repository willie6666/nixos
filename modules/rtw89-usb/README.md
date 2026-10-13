# Realtek USB Wi-Fi

此機的 AX3000 USB 網卡在光碟模式為 `0bda:1a2b`；以
`usb_modeswitch` 的 standard eject 切換後為 `0bda:c832`，對應
RTL8832CU／RTL8852CU 系列。光碟模式的 `lsusb` 名稱不能用來判斷晶片。

`default.nix` 啟用 NixOS 的 USB 自動模式切換及可重新散布韌體。
kernel 6.19 之前，使用固定 commit 的 morrownr/rtw89 backport，
隨 NixOS 選定的 kernel 重新編譯；kernel 6.19 起使用原生
`rtw89_8852cu`。沒有修改 Intel 網卡設定。

Backport 與原生 rtw89 共用符號，因此在使用 backport 時將整個
原生 rtw89 系列列入 blacklist，並提供完整 backport 模組系列。
這只影響 Realtek rtw89；Intel `iwlwifi` 不受影響。
所需的 `rtw89/rtw8852c_fw-2.bin` 由 NixOS 的 linux-firmware 提供。

## 套用及確認

```sh
sudo nixos-rebuild switch --flake /etc/nixos#nixos
nmcli device status
iw dev
```

若網卡仍停在光碟模式，可重新插入 USB 網卡，讓新增的 udev 規則生效。
不需要手動執行 DKMS 或上游的 `make install`。

## 連線與分享

在 Noctalia／NetworkManager 的 Wi-Fi 清單選擇外接網卡連線。
Wi-Fi 必須開啟，網卡才會從 `unavailable` 變為可用。

2026-10-13 的此機介面名稱是 `wlp0s20f0u3`，內建網卡為 `wlo1`。
USB 介面名稱與插入位置有關，換孔後請重新確認。

Wi-Fi Hotspot 插件的「進階設定 → 熱點網卡」選外接 USB 介面，
「分享來源」選 `enp44s0` 可分享有線，選已連線的 `wlo1` 可分享內建
Intel 的 Wi-Fi。使用兩張網卡時，上游與熱點不必使用相同頻段。
單張 USB 網卡同時連線與開 AP，仍依驅動宣告的有效介面組合與頻道限制。

## 上游

- https://github.com/morrownr/rtw89
- 固定 commit：`8bbbacadf6fa73c3a3195aefbd4b2ec2422ae356`
- https://github.com/torvalds/linux/blob/master/drivers/net/wireless/realtek/rtw89/rtw8852cu.c

打包時檢查模組 vermagic 必須吻合選定 kernel，且模組 alias 包含
`0bda:c832`。這些靜態檢查不代表已完成實際 Wi-Fi 關聯或手機連線測試。

2026-10-13 已針對 kernel 6.18.55 編譯並暫時載入驅動，確認：

- 網卡從光碟模式切換為 `0bda:c832`，並自動進入 USB 3.0 / 5000 Mbps。
- `rtw8852c_fw-2.bin` 載入成功，NetworkManager 與 Noctalia 插件可偵測。
- 驅動宣告 managed、AP，以及同頻道 managed + AP 同時使用能力。
- Wi-Fi 保持原本的關閉狀態；實際連線與開熱點留給使用者測試。
- 完整 NixOS 系統建置成功，已檢查自動模式切換規則、systemd 服務、
  開機載入模組及模組依賴；永久設定尚未套用，由使用者自行執行 switch。
