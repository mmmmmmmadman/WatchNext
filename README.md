# WatchNext

跨串流平台的電影與電視節目搜尋工具，支援 macOS 與 iOS。

## 功能特色

- 搜尋多個串流平台的內容（Apple TV、Netflix、Prime Video、Disney+）
- 顯示 TMDB、IMDb、Rotten Tomatoes 評分
- 支援多區域（台灣、美國、日本等）
- Genre 分類篩選
- 多維度排序（熱門度、評分等）
- 關鍵字搜尋（電影名稱、演員、導演）
- 無限滾動載入

## 系統需求

- macOS 14.0 或以上
- iOS 17.0 或以上

## 安裝方式

### 方式一：下載預編譯版本

1. 前往 [Releases](https://github.com/mmmmmmmadman/WatchNext/releases) 頁面
2. 下載最新版本的 `WatchNext-vX.X.X.zip`
3. 解壓縮後將 `WatchNext.app` 移至「應用程式」資料夾

### 方式二：從原始碼編譯

```bash
# 複製專案
git clone https://github.com/mmmmmmmadman/WatchNext.git
cd WatchNext

# 安裝 xcodegen（如尚未安裝）
brew install xcodegen

# 產生 Xcode 專案
xcodegen

# 開啟專案
open WatchNext.xcodeproj
```

在 Xcode 中選擇 scheme：
- `WatchNext` - macOS 版本
- `WatchNext-iOS` - iOS 版本

## API 金鑰設定

本應用程式需要 API 金鑰才能運作。首次開啟會提示設定。

### TMDB API Key（必須）

1. 前往 [TMDB](https://www.themoviedb.org/) 註冊帳號
2. 進入 [API 設定頁面](https://www.themoviedb.org/settings/api)
3. 申請 API Key（選擇 Developer）
4. 複製 API Key 貼入應用程式設定

### OMDb API Key（選用）

啟用 IMDb 和 Rotten Tomatoes 評分顯示。

1. 前往 [OMDb API](https://www.omdbapi.com/apikey.aspx)
2. 選擇 FREE 方案（每日 1,000 次請求）
3. 填寫表單並驗證 Email
4. 複製 API Key 貼入應用程式設定

## 支援的串流平台

| 平台 | 狀態 |
|------|------|
| Apple TV / Apple TV+ | 支援 |
| Netflix | 支援 |
| Prime Video | 支援 |
| Disney+ | 支援 |

## 支援的區域

台灣、美國、日本、韓國、香港、英國、加拿大、澳洲、德國、法國

## 截圖

### macOS
![macOS Screenshot](docs/macos.png)

### iOS
![iOS Screenshot](docs/ios.png)

## 技術堆疊

- Swift 5.9
- SwiftUI
- SwiftData
- TMDB API
- OMDb API

## 授權

MIT License

## 致謝

本應用程式使用 [TMDB API](https://www.themoviedb.org/)，但未獲得 TMDB 的認證或背書。

![TMDB Logo](https://www.themoviedb.org/assets/2/v4/logos/v2/blue_short-8e7b30f73a4020692ccca9c88bafe5dcb6f8a62a4c6bc55cd9ba82bb2cd95f6c.svg)
