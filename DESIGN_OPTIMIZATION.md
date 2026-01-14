# WatchNext 視覺設計優化

## 優化日期：2026-01-14

## 品牌元素

### 顏色
- **品牌主色 (BrandPrimary)**：珊瑚粉 RGB(249, 135, 132) / #F98784
- **品牌次色 (BrandSecondary)**：淺粉 RGB(252, 158, 158) / #FC9E9E
- **強調色 (AccentColor)**：與品牌主色一致，影響全域 UI 元素

### 字體
- **主要字體**：Avenir Light
- **字間距**：寬鬆設計（0.5 - 3pt tracking）

## 已實作的優化項目

### 1. 字體統一應用

#### ContentView
- 主標題「WatchNext」：Avenir Light 24pt, tracking 3
- 設定按鈕圖標：品牌珊瑚粉色
- 清除搜尋按鈕：品牌珊瑚粉色
- 內容類型 Picker：品牌珊瑚粉色 tint
- API Key Required 標題：Avenir Light 22pt, tracking 1.5
- Open Settings 按鈕：Avenir Light 16pt, tracking 1, 品牌色背景
- Retry 按鈕：Avenir Light 15pt, tracking 0.8, 品牌色邊框

#### CardViews
- 電影/節目標題：Avenir Light 14pt (iOS) / 13pt (macOS), tracking 0.5

#### DetailViews
- 電影/節目主標題：Avenir Light 24pt, tracking 1
- 「Ratings」標題：Avenir Light 18pt, tracking 1
- 「Overview」標題：Avenir Light 18pt, tracking 1
- Watch 按鈕：Avenir Light 17pt, tracking 0.8, 品牌色背景

#### SettingsView
- Settings 標題：Avenir Light 20pt, tracking 2
- API Key 標籤：Avenir Light 16pt, tracking 0.5
- TMDB 標題：Avenir Light 17pt, tracking 0.8
- Save/Cancel 按鈕：Avenir Light 15pt, tracking 0.8
- 確認勾選圖標：品牌珊瑚粉色

### 2. 品牌色融入

#### 互動元素
- AccentColor 設定為品牌珊瑚粉色，自動影響：
  - Picker 選中狀態
  - Toggle 開關
  - Slider 滑桿
  - ProgressView 進度條

#### 按鈕強調
- 主要操作按鈕使用 `.tint(Color.brandPrimary)`
- 狀態圖標（確認勾選）使用品牌色
- 清除/關閉按鈕使用品牌色

### 3. 深色模式適配

#### AccentColor 深色模式
- Light Mode：RGB(249, 135, 132) - 標準珊瑚粉
- Dark Mode：RGB(255, 153, 153) - 稍微提亮，更適合深色背景

#### BrandSecondary 深色模式
- Light Mode：RGB(252, 158, 158) - 淺粉
- Dark Mode：RGB(255, 153, 153) - 與深色模式 AccentColor 一致

## 新增的顏色擴展

在 `Constants.swift` 中新增：

```swift
// Brand color variants for different UI contexts
static var brandAccent: Color {
    Color.accentColor
}

static var brandSubtle: Color {
    brandSecondary.opacity(0.5)
}
```

這些輔助顏色可用於未來的細節優化。

## 設計一致性檢查

- [x] 主標題統一使用 Avenir Light
- [x] 按鈕文字使用 Avenir Light
- [x] 所有標題元素應用寬鬆字間距
- [x] 互動元素使用品牌珊瑚粉色
- [x] 深色模式下顏色自動適配
- [x] 狀態指示器使用品牌色

## 視覺效果預期

1. **整體風格**：簡潔、優雅、現代，與 App Icon 風格完全一致
2. **品牌識別度**：珊瑚粉色貫穿整個 app，強化品牌印象
3. **閱讀體驗**：Avenir Light + 寬鬆字距提供舒適的閱讀感受
4. **互動反饋**：按鈕和選中狀態使用品牌色，清晰易識別

## 未來可考慮的優化

1. 為卡片添加微妙的品牌色邊框或陰影
2. Loading 狀態動畫使用品牌色
3. 搜尋欄 focus 狀態使用品牌色高亮
4. 評分卡片添加品牌色點綴
5. 空狀態插圖使用品牌色調
