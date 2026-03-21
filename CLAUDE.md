# WatchNext

## 問題解決原則

當遇到問題時優先搜尋使用相關 Agent/Skill 解決，目的是一面除錯一面強化 Agent/Skill 的能力。

## 開發規範

- 使用繁體中文
- 禁止使用表情符號
- 極簡模式：對話中不顯示程式碼內容，僅描述做法
- 程式碼只在實際編輯檔案時寫入

## 專案概述

macOS 原生應用程式，搜尋多個串流平台的電影和電視節目。透過整合 TMDB 與 OMDb API，提供跨平台的內容檢索介面。

## 技術堆疊

- 語言：Swift
- 框架：SwiftUI
- 資料庫：SwiftData
- 最低版本：macOS 14.0

## 支援平台

- Apple TV / Apple TV+
- Netflix
- Prime Video
- Disney+

## 核心功能

1. 串接 TMDB API 的 Watch Providers 接口，檢索各串流平台內容
2. 整合 OMDb API 獲取 IMDb 與 Rotten Tomatoes 評分
3. 排序：Title、Release Date、TMDB Rating
4. Genre 過濾
5. 區域選擇（依平台自動過濾可用地區，最近使用地區置頂）

## API 金鑰配置

需要以下 API 金鑰：
- TMDB_API_KEY（從 themoviedb.org 申請）
- OMDB_API_KEY（從 omdbapi.com 申請，選用）

## 編譯注意事項

### App Icon 處理

專案使用 PNG 格式的 AppIcon.icns（位於 WatchNext/AppIcon.icns）。

重要事項：
1. **色彩深度**：icon 必須為 8-bit PNG，否則 Xcode 處理時可能丟失顏色（粉紅色會變成黑色）
2. **檔案位置**：AppIcon.icns 必須放在 WatchNext/ 目錄下（與 Assets.xcassets 同級），專案直接引用此檔案
3. **格式**：雖然副檔名是 .icns，實際上是 1024x1024 的 PNG 檔案

如果需要更新 icon：
```bash
# 確保 icon 為 8-bit
python3 -c "
from PIL import Image
img = Image.open('your_icon.png')
img.save('WatchNext/AppIcon.icns', 'PNG')
"
# 同時更新 Assets.xcassets 中的版本
cp WatchNext/AppIcon.icns WatchNext/Assets.xcassets/AppIcon.appiconset/AppIcon.icns
cp WatchNext/AppIcon.icns WatchNext/Assets.xcassets/AppIcon.appiconset/icon_1024.png
```

### 編譯指令

```bash
# 清除快取並編譯
rm -rf ~/Library/Developer/Xcode/DerivedData/WatchNext-*
xcodebuild -scheme WatchNext -configuration Debug build
```

## 已知問題與解決方案

### Watch 按鈕導向問題

問題：TMDB API 返回的 watch provider link 是 TMDB 網站連結，而非直接開啟串流平台 App。

解決方案：在 Constants.swift 中為 StreamingPlatform 實作 searchURL(for:) 方法，根據電影/節目標題直接生成各平台的搜尋連結：
- Apple TV: https://tv.apple.com/search?term={title}
- Netflix: https://www.netflix.com/search?q={title}
- Prime Video: https://www.primevideo.com/search?phrase={title}
- Disney+: https://www.disneyplus.com/search?q={title}

### CloudKit / iCloud Sync 閃退問題（v1.5.1 修復）

**根因**：iOS provisioning profile 沒有包含 CloudKit entitlement。即使 WatchNext-iOS.entitlements 檔案中有設定 CloudKit，build 出來的 app binary 實際上不包含 CloudKit entitlement。當 app 嘗試初始化 CKContainer 時，CloudKit framework 拋出無法攔截的 exception（iOS 上是 EXC_BREAKPOINT，macOS 上是 ObjC NSException），導致 crash。

**觸發路徑**：
1. ContentView.task → favoritesViewModel.setModelContext() → performSync() → CloudKitService.isAvailable → CKContainer 初始化 → crash
2. SettingsView.task → checkiCloudStatus() → CloudKitService.checkAccountStatus() → CKContainer 初始化 → crash

**解決方案**：暫時停用所有自動觸發的 CloudKit 操作：
- FavoritesViewModel.setModelContext() 中移除自動 sync
- FavoritesViewModel.saveAndReload() 中移除自動 sync
- SettingsView.checkiCloudStatus() 中不觸碰 CKContainer，直接顯示 "Not available"

**注意事項**：
- ObjC @try/@catch 無法攔截 iOS 上的 EXC_BREAKPOINT crash
- FileManager.default.ubiquityIdentityToken 檢查不可靠：使用者已登入 iCloud 時會回傳 non-nil，但 app 不一定有 CloudKit entitlement
- xcodegen 每次執行會清空 WatchNext.entitlements，需手動復原
- 要正確啟用 CloudKit，需在 Apple Developer Portal 為 app ID 啟用 iCloud/CloudKit capability，並重新產生 provisioning profile

### xcodegen 注意事項

xcodegen 每次執行都會覆蓋 WatchNext/WatchNext.entitlements 為空的 dict。執行 xcodegen 後必須手動還原 entitlements 內容（sandbox、network.client、CloudKit）。
