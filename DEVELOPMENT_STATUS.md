# WatchNext 開發進度

## 專案概述

macOS 原生應用程式，用於搜尋多個串流平台的電影和電視節目。整合 TMDB 與 OMDb API，提供跨平台內容檢索與評分顯示。

## 技術堆疊

- 語言：Swift
- 框架：SwiftUI
- 資料庫：SwiftData（本地快取）
- 最低版本：macOS 14.0
- 專案生成：xcodegen

## 已完成功能

### 核心功能
- [x] TMDB API 整合（Discover、Search、Watch Providers）
- [x] OMDb API 整合（IMDb、Rotten Tomatoes 評分）
- [x] 多平台支援：Apple TV、Netflix、Prime Video、Disney+
- [x] 多區域支援：台灣、美國、日本等
- [x] 電影/電視節目切換
- [x] Genre 篩選
- [x] 多維度排序：TMDB、IMDb、RT 評分（升序/降序）
- [x] 關鍵字搜尋（支援多語言、演員、導演）
- [x] 無限滾動載入
- [x] 詳情頁面與「Watch on Apple TV」連結

### UI/UX
- [x] 主視窗：搜尋欄、平台/區域選擇、Genre/排序篩選
- [x] 電影/電視卡片：海報、標題、評分（TMDB、IMDb、RT）
- [x] 設定視窗：API 金鑰配置
- [x] App Icon：黑底白字圓形設計

### 已修復問題
- [x] 評分由低到高排序：nil 評分排在最後
- [x] 滾動跳動問題：移除評分載入時的自動排序
- [x] 設定視窗寬度問題：minWidth 500, padding 20

## 專案結構

```
WatchNext/
├── WatchNext/
│   ├── App/
│   │   └── WatchNextApp.swift
│   ├── Models/
│   │   ├── Movie.swift
│   │   ├── TVShow.swift
│   │   └── ...
│   ├── Services/
│   │   ├── TMDBService.swift
│   │   ├── OMDbService.swift
│   │   └── CacheService.swift
│   ├── ViewModels/
│   │   └── SearchViewModel.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── SettingsView.swift
│   │   ├── MovieDetailView.swift
│   │   └── ...
│   ├── Utilities/
│   │   ├── APIConfig.swift
│   │   └── Constants.swift
│   └── Assets.xcassets/
├── project.yml
├── WatchNext.xcodeproj (由 xcodegen 生成)
└── WatchNext.app (編譯後的應用程式)
```

## App Icon 設計參數

```bash
# 當前設計（透明底、珊瑚粉漸層圓框、黑色字體、Avenir Light）
magick -size 1024x1024 xc:none \
  \( -size 1024x1024 gradient:'#FFB5B5-#FF6B6B' -rotate 45 \) \
  \( -size 1024x1024 xc:none -stroke white -strokewidth 40 -fill none \
     -draw "circle 512,512 512,30" \) \
  -compose DstIn -composite \
  -stroke none -fill black \
  -font "Avenir-Light" -pointsize 144 -kerning 58 \
  -gravity center -annotate +0-44 "WATCH" \
  -annotate +0+112 "NEXT" \
  icon_1024.png
```

## 編譯指令

```bash
cd /Users/madzine/Documents/WatchNext
xcodegen
xcodebuild -project WatchNext.xcodeproj -scheme WatchNext -configuration Release -derivedDataPath build ONLY_ACTIVE_ARCH=NO
cp -R build/Build/Products/Release/WatchNext.app .
```

## API 金鑰

需要在 Settings 中配置：
- **TMDB API Key**：從 https://www.themoviedb.org/settings/api 申請
- **OMDb API Key**（選用）：從 https://www.omdbapi.com/apikey.aspx 申請

## 串流平台 Provider IDs

| 平台 | Provider IDs |
|------|-------------|
| Apple TV / Apple TV+ | 350, 2 |
| Netflix | 8 |
| Prime Video | 9, 119 |
| Disney+ | 337 |

## 待辦事項

- [ ] App Store 上架準備
- [ ] Privacy Policy 頁面
- [ ] 更多區域支援
- [ ] 離線快取優化

## 已知限制

- IMDb/RT 評分排序為本地排序（僅對已載入的內容有效）
- macOS 圖標會自動套用圓角遮罩和陰影

---

最後更新：2026-01-14
