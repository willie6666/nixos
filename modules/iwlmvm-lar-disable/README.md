# NixOS 的 Intel iwlmvm LAR 補丁

此目錄將 linux-wifi-hotspot 的社群補丁包成 NixOS 額外核心模組。
僅適用 `iwlmvm`；沒有修改 `iwlwifi`、`iwlmld` 或 `iwldvm`。
設定會啟用 wireless-regdb，並使用台灣 `TW` 法規資料庫。
這是非官方驅動修改；成功編譯不代表韌體一定接受 5 GHz AP。

## 來源

- [上游說明](https://github.com/lakinduakash/linux-wifi-hotspot/blob/21be8d8a88dd425ecbfb2c73b8523b696f71cee9/docs/howto/intel-5ghz-lar.md)
- [原始補丁](https://github.com/lakinduakash/linux-wifi-hotspot/blob/21be8d8a88dd425ecbfb2c73b8523b696f71cee9/util/iwlwifi-lar-disable/dkms/patches/lar_disable.patch)
- 固定 revision：`21be8d8a88dd425ecbfb2c73b8523b696f71cee9`
- 本地補丁 SHA-256：`710635eda0c8afcfe264e9a6a122e3716220c0ea1f5e426a33d8b5ceb417fda3`

補丁未修改；Nix derivation 使用 `config.boot.kernelPackages` 的來源、原有補丁、工具鏈與建置標頭。
只將新 `iwlmvm.ko` 安裝至模組樹的 `updates/`，由 depmod 優先選用。
不覆寫 `/nix/store`，不使用上游針對其他發行版的 install.sh 或 DKMS。

## 安裝到本機的 /etc/nixos

先複製整個目錄，包含補丁與 package.nix：

```sh
cp -r /home/willie/.local/share/noctalia/plugins/wifi-hotspot/nix/iwlmvm-lar-disable /etc/nixos/modules/
```

在 `/etc/nixos/configuration.nix` 現有 `imports` 清單中加入：

```nix
./modules/iwlmvm-lar-disable
```

並在最外層設定區加入：

```nix
hardware.intelWifiLarDisable.enable = true;
```

本機 `/etc/nixos` 是 Git repository，flake 需要新檔案先納入 Git 索引，無需先 commit：

```sh
git -C /etc/nixos add modules/iwlmvm-lar-disable
sudo nixos-rebuild boot --flake /etc/nixos#nixos
```

`boot` 只安排下次開機使用新設定，不會即時卸載 Wi-Fi 驅動。
成功後，在方便中斷工作的時候自行重新開機。不要同時套用獨立 hostapd 範例；現有 NetworkManager 與 Noctalia 插件可繼續使用。

本機檢查時 Secure Boot 為 disabled。如果之後啟用 Secure Boot／核心強制模組簽章，這個未簽章的模組需要配合該系統的可信簽章機制，不能直接沿用此流程。

## 重新開機後驗證

```sh
modinfo -n iwlmvm
cat /sys/module/iwlmvm/parameters/lar_disable
iw reg get
iw phy phy0 info
```

確認模組路徑位於 `updates/iwlmvm.ko`、參數為 `Y`，並檢查台灣允許的非 DFS 頻道是否解除 `no IR`。
先以有線上游測試 5 GHz 熱點。若仍失敗，需檢查驅動／hostapd 紀錄，不能只憑參數載入成功認定 AP 成功。
同張網卡連 Wi-Fi 並分享仍須同頻道；此補丁不增加 DFS 偵測能力，也不解除硬體的單頻道限制。

## 回復與核心更新

將 `hardware.intelWifiLarDisable.enable` 改成 `false`，再執行 `nixos-rebuild boot` 並重新開機，即會回到原版模組且移除補丁參數。
如果新設定造成開機或 Wi-Fi 問題，可以在 systemd-boot 選擇先前的 NixOS generation。

更新核心時會重新建置模組；若補丁不再適用，建置應失敗，需更新補丁或停用此選項。
此版本使用 `TW`，若移到其他國家使用，需依實際所在地調整 country code。

## 本機驗證紀錄（2026-10-04）

- 對 NixOS 26.05 鎖定的 Linux `6.18.54` 完成實際編譯。
- `modinfo` 顯示新增的 `lar_disable`，vermagic 與原版模組相同。
- 337 個強制匯入符號均存在於該核心的 `Module.symvers`。
- 已用本機完整 NixOS 設定加上此模組求值，沒有失敗的 assertions。
- 已建置完整核心模組集合，`modprobe --show-depends` 確認優先選用 `updates/iwlmvm.ko`，其餘相依項仍用原版模組。
- 尚未安裝至 `/etc/nixos`、切換系統、重啟或載入修改過的模組；尚未實測 5 GHz 熱點。
