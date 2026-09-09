---
tags: [讀書筆記, line, api, 專題]
created: 2026-07-08
---

# LINE Messaging API 筆記

專題用的。

## 兩種訊息

- **Reply**：使用者傳訊息來，我們在 webhook 裡回，免費。
- **Push**：我們主動推，免費額度每月 200 則（Communication Plan），超過要錢。

⚠️ 專題的到站提醒是 Push，200 則很快就用完。期中 demo 前要注意額度，或是申請 Developer 的測試帳號。

## Webhook

- LINE 會 POST 到我們的 URL，要驗證 `X-Line-Signature`。
- 要在 10 秒內回 200，不然 LINE 會重送。Lambda 冷啟動 1 秒多還好。

## Rich Menu

- [[吳芷萱]] 設計的，四個按鈕：訂閱、取消、查詢、設定。
- 圖片要 2500x1686。

## 相關

- [[專題技術架構]]
