---
tags: [讀書筆記, git, github, 工具]
created: 2026-07-10
---

# Git 與 GitHub 工作流

## 基本流程

```
git checkout -b feature/xxx
# 改東西
git add -A
git commit -m "新增：xxx"
git push -u origin feature/xxx
# 開 PR，請人 review，merge
```

## 實習學到的規矩（[[雲杉科技]]）

- main 不能直接 push，一定要 PR。
- commit 訊息要說「為什麼」不只是「做了什麼」。
- PR 要小，300 行以內。
- 每個 PR 要有測試。

## 專題的規矩（我定的）

- 分支：`main`、`dev`、`feature/*`
- [[陳冠宇]] 老是直接 push main，要再講一次。

## 常用但常忘

- `git stash` 暫存
- `git rebase -i HEAD~3` 整理 commit
- `git log --oneline --graph`
- 誤 commit 到 main：`git reset --soft HEAD~1`

## 這個 vault 也用 git

- 每天寫完日記 commit 一次。
- 用私人 repo，因為有日記。
