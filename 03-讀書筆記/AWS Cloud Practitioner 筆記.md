---
tags: [aws, 證照, 讀書筆記]
created: 2026-07-05
updated: 2026-09-06
progress: 60%
---

# AWS Certified Cloud Practitioner (CLF-C02) 筆記

目標：寒假前（2027/01）考過。見 [[長期目標]]。
教材：AWS Skill Builder 免費課程 + [[許承翰]] 學長給的筆記。

## 考試資訊

- 65 題，90 分鐘，100 USD，繁中可選。
- 四個 domain：雲端概念 24%、安全與合規 30%、技術與服務 34%、帳單與定價 12%。

## Domain 1：雲端概念 ✅

- 六大優勢：用變動成本取代資本支出、規模經濟、不用猜容量、速度與敏捷、不用花錢維運資料中心、幾分鐘內全球部署。
- **Region / AZ / Edge Location**：
  - Region 是地理區域，AZ 是 Region 內獨立的資料中心群，Edge Location 是 CDN 節點。
  - 高可用 = 跨 AZ。災難復原 = 跨 Region。
- Well-Architected Framework 六大支柱：卓越營運、安全、可靠、效能、成本、永續。

## Domain 2：安全 🔶 讀到一半

- 共同責任模型：AWS 負責「雲端本身」的安全，客戶負責「雲端內」的安全。
- IAM：使用者、群組、角色、政策。**最小權限原則**。
- Root 帳號要開 MFA 然後鎖起來不要用。
- 還沒讀：KMS、Shield、WAF、GuardDuty。

## Domain 3：技術與服務 🔶

### 運算
- EC2：虛擬機。instance type 命名 t3.micro = 家族 t、第 3 代、大小 micro。
- Lambda：無伺服器，最長跑 15 分鐘，用多少付多少。專題在用。
- ECS / Fargate：容器。Fargate 不用管機器。
- Elastic Beanstalk：PaaS。

### 儲存
- S3：物件儲存，11 個 9 的耐久性。可以直接架靜態網站。
- EBS：EC2 的硬碟。
- EFS：多台 EC2 共用的檔案系統。

### 資料庫
- RDS：關聯式，MySQL/PostgreSQL 等。
- DynamoDB：NoSQL，專題在用。
- Aurora：AWS 自己的高效能關聯式。

### 網路
- VPC、子網路、安全群組（有狀態）、NACL（無狀態）。
- ELB：負載平衡。ALB 是第 7 層。
- CloudFront：CDN。
- Route 53：DNS。

### AI/ML（09/06 補）
- SageMaker：訓練與部署自己的模型。
- Bedrock：直接呼叫基礎模型（Claude、Titan 等）的 API，不用自己訓練。
- Rekognition、Comprehend、Textract：現成的 AI 服務。

## Domain 4：帳單 ❌ 還沒讀

- 知道的：On-Demand、Reserved、Spot、Savings Plans。
- Free Tier：12 個月免費、永遠免費、試用三種。

## 弱點

- 安全類的服務名稱一堆記不起來。
- 帳單完全沒讀。
- 沒有做過模擬考。

## 讀書進度

| 週 | 進度 |
|---|---|
| 07/05 | 開始，Domain 1 |
| 07/20 | Domain 1 完 |
| 08/10 | Domain 3 運算與儲存 |
| 09/06 | Domain 3 補 AI/ML，Domain 2 讀一半 |
