# Apple TV 全域內容檢索與評分系統

## 開發規範

- 使用繁體中文
- 禁止使用表情符號
- 極簡模式：對話中不顯示程式碼內容，僅描述做法
- 程式碼只在實際編輯檔案時寫入

## 專案概述

可上架 App Store 的 iOS/macOS 原生應用程式，解決 Apple TV 分類顯示不完整的問題。透過整合 TMDB 與 OMDb API，提供全量索引能力的檢索介面。

## 技術堆疊

- 語言：Swift
- 框架：SwiftUI（多平台）
- 資料庫：SwiftData
- 最低版本：iOS 17.0 / macOS 14.0

## 核心功能

1. 串接 TMDB API 的 Watch Providers 接口，檢索所有 Apple TV 平台內容
2. 整合 OMDb API 獲取 IMDb 與 Rotten Tomatoes 評分
3. 多維度排序：英文名稱、年份、評分
4. Genre ID 過濾，確保類別完整性
5. 本地資料快取，支援離線瀏覽

## API 金鑰配置

需要以下 API 金鑰：
- TMDB_API_KEY（從 themoviedb.org 申請）
- OMDB_API_KEY（從 omdbapi.com 申請）
