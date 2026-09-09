---
tags: [讀書筆記, docker, 容器]
created: 2026-08-18
---

# Docker 入門

實習第二週被要求把服務容器化，惡補。

## 觀念

- Image 是模板，Container 是跑起來的實例。
- Dockerfile 描述怎麼建 image。
- 容器是無狀態的，資料要放 volume。

## 常用

```
docker build -t myapp .
docker run -p 8080:8080 myapp
docker ps
docker logs -f <id>
docker compose up -d
```

## 跟 AWS 的關係

- ECR 放 image。
- ECS 跑容器，Fargate 是不用管機器的模式。
- [[AWS Cloud Practitioner 筆記]] 有提到。
- 實習的服務就是跑在 Fargate 上，見 [[實習週報-第2週]]。

## 坑

- `COPY . .` 前要有 `.dockerignore`，不然 node_modules 全進去。
- Alpine image 小但缺很多東西，Python 套件常裝不起來。
