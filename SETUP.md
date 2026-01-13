# Apple TV Search - Xcode 專案設定指南

## 建立 Xcode 專案步驟

### 步驟 1：開啟 Xcode 建立新專案

1. 開啟 Xcode
2. 選擇 File > New > Project
3. 選擇 Multiplatform > App
4. 填入專案資訊：
   - Product Name: AppleTVSearch
   - Team: 選擇你的開發者帳號
   - Organization Identifier: 你的 Bundle ID 前綴
   - Interface: SwiftUI
   - Language: Swift
   - Storage: SwiftData
5. 選擇儲存位置為 `/Users/madzine/Documents/apple-tv-search/`

### 步驟 2：匯入原始碼

建立專案後，將 `AppleTVSearch/` 資料夾中的所有檔案拖曳至 Xcode 專案導覽器中：

```
AppleTVSearch/
├── App/
│   └── AppleTVSearchApp.swift
├── Models/
│   ├── Movie.swift
│   ├── TVShow.swift
│   └── Rating.swift
├── Services/
│   ├── TMDBService.swift
│   ├── OMDbService.swift
│   └── CacheService.swift
├── ViewModels/
│   ├── SearchViewModel.swift
│   └── FilterViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── FilterView.swift
│   ├── CardViews.swift
│   ├── DetailViews.swift
│   └── SettingsView.swift
└── Utilities/
    ├── APIConfig.swift
    └── Constants.swift
```

### 步驟 3：專案設定

1. 選擇專案目標，前往 General 標籤
2. 設定 Minimum Deployments：
   - iOS: 17.0
   - macOS: 14.0
3. 前往 Signing & Capabilities，設定你的開發者團隊

### 步驟 4：申請 API 金鑰

#### TMDB API
1. 前往 https://www.themoviedb.org/
2. 註冊帳號並登入
3. 前往 Settings > API
4. 申請 API Key（選擇 Developer）
5. 複製 API Read Access Token (v4 auth)

#### OMDb API
1. 前往 https://www.omdbapi.com/apikey.aspx
2. 選擇免費方案（每日 1,000 次請求）
3. 填寫表單並提交
4. 從確認信中取得 API Key

### 步驟 5：執行測試

1. 選擇模擬器或連接實機
2. 按下 Command + R 執行
3. 首次開啟時點選設定圖示
4. 輸入 TMDB 和 OMDb API 金鑰
5. 儲存後開始搜尋

## 常見問題

### Q: 為什麼看不到評分資料？
A: 確認 OMDb API 金鑰已正確設定，且每日請求額度未超過限制。

### Q: 為什麼搜尋結果為空？
A: 確認 TMDB API 金鑰有效，且網路連線正常。

### Q: App Store 上架需要什麼？
A: 需要 Apple Developer Program 會員資格（年費 USD $99），並準備：
- App Icon（1024x1024）
- 螢幕截圖
- 隱私權政策頁面
- App 描述文字
