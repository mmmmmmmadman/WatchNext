# WatchNext

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
3. 多維度排序：TMDB、IMDb、RT 評分
4. Genre 過濾
5. 區域選擇

## API 金鑰配置

需要以下 API 金鑰：
- TMDB_API_KEY（從 themoviedb.org 申請）
- OMDB_API_KEY（從 omdbapi.com 申請，選用）
