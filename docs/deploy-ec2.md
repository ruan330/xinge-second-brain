# 在 AWS Learner Lab 上自己養一隻：EC2 + openab + Discord

這份文件是「利用 AWS 實現 AI 系統之概念」工作坊的回家作業。做完你會有一隻住在 AWS 上的 AI 助理，透過 Discord 讀你的第二大腦、幫你寫報告、把結果 commit 回 GitHub。

```
手機 Discord ⇄ (WebSocket) ⇄ EC2 [ openab ⇄ ACP ⇄ kiro-cli 或 Claude Code ] ⇄ GitHub
```

全程只需要 Learner Lab（免費）、一個 Discord 帳號、一個 GitHub 帳號。預設用 **Kiro CLI**，用 AWS Builder ID 登入就好，不需要任何付費訂閱。

---

## 0. 事前準備

| 東西 | 去哪裡拿 |
|---|---|
| 第二大腦 repo | Fork <https://github.com/ruan330/xinge-second-brain>，或用自己的 Obsidian vault（放上 GitHub） |
| Discord bot token | <https://discord.com/developers/applications> → New Application → Bot → **開啟 Message Content Intent** → Reset Token |
| 把 bot 加進你的 server | OAuth2 → URL Generator → scope 勾 `bot`，權限勾 Send Messages、Send Messages in Threads、Create Public Threads、Read Message History、Add Reactions、Manage Messages → 開啟產生的網址 |
| AWS Builder ID | <https://profile.aws.amazon.com/>，免費 |
| （選）GitHub PAT | 想讓 agent 能 push 才需要。Settings → Developer settings → Fine-grained tokens → 只選你的 repo、Contents 給 Read and write |

## 1. 在 Learner Lab 開一台 Ubuntu 24.04

Start Lab 之後進 AWS Console → EC2 → Launch instance：

- **AMI**：Ubuntu Server 24.04 LTS（Quick Start 裡有）。不要選 Amazon Linux，openab 的 binary 需要 glibc 2.39。
- **Instance type**：t3.small（Learner Lab 只允許 nano 到 large）
- **Key pair**：vockey
- **Network**：預設 VPC，Auto-assign public IP 開啟，安全群組用預設的就好（不需要任何 inbound）
- **Advanced details → IAM instance profile**：`LabInstanceProfile`（這樣才能用 Session Manager 進機器）
- **Storage**：20 GB gp3

或者用 CloudShell 一行開起來（AMI id 每個月會變，用 SSM 參數查最新）：

```bash
AMI=$(aws ssm get-parameter --name /aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id --query Parameter.Value --output text)
aws ec2 run-instances --image-id "$AMI" --instance-type t3.small --key-name vockey \
  --associate-public-ip-address --iam-instance-profile Name=LabInstanceProfile \
  --block-device-mappings 'DeviceName=/dev/sda1,Ebs={VolumeSize=20,VolumeType=gp3}' \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=my-second-brain-bot}]'
```

## 2. 進機器

EC2 → 選 instance → Connect → **Session Manager** → Connect。不用開 SSH port，也不用 key。

進去之後先切成 root：

```bash
sudo -i
```

## 3. 跑安裝腳本

```bash
curl -fsSL -o setup-ubuntu.sh https://raw.githubusercontent.com/ruan330/xinge-second-brain/main/docs/setup-ubuntu.sh
# 用自己 fork 的 repo 就改 REPO；想用 Claude Code 就改 AGENT=claude
REPO=https://github.com/<你的帳號>/xinge-second-brain.git AGENT=kiro bash setup-ubuntu.sh
```

腳本會裝 Node 22、Claude Code、claude-agent-acp、Kiro CLI、openab，建立 `agent` 使用者，clone 你的 repo 到 `/home/agent/`，寫好 `/etc/openab/config.toml` 跟 systemd 服務。大約 3 分鐘。

## 4. 登入 agent

**Kiro CLI（預設，免費）**：用 agent 這個使用者做 device flow 登入，會印一個網址跟代碼，用手機開網址、用 Builder ID 登入。

```bash
sudo -u agent -H kiro-cli login --use-device-flow
```

**Claude Code（要訂閱）**：在你自己的電腦上跑 `claude setup-token`，把印出的 token 填到下一步的 `CLAUDE_CODE_OAUTH_TOKEN`。

## 5. 填 token、啟動

```bash
nano /etc/openab/env        # 填 DISCORD_BOT_TOKEN；有的話再填 GITHUB_TOKEN、CLAUDE_CODE_OAUTH_TOKEN
systemctl start openab
journalctl -u openab -f     # 看到 Discord 連線成功的訊息就可以了，Ctrl+C 離開
```

到 Discord 的 server 裡 `@你的bot 我這兩週有什麼 deadline？`，它會開一個 thread 回答。

## 6. 用完記得停機

Learner Lab 的預算有限。session 結束時機器會被自動停掉，下次 Start Lab 會自動重開；不用的時候到 EC2 把 instance **Stop**，整個做完之後 **Terminate**。

---

## 常見問題

- **`openab: /lib64/libc.so.6: version GLIBC_2.39 not found`**：你用了 Amazon Linux。換 Ubuntu 24.04。
- **bot 上線了但不回話**：Developer Portal 的 Message Content Intent 沒開，或 bot 沒被邀進 server。
- **agent 說看不到檔案**：`/etc/openab/config.toml` 的 `working_dir` 要指到 clone 下來的資料夾。
- **`kiro-cli login` 之後服務還是說沒登入**：登入要用 `agent` 使用者做（`sudo -u agent -H`），token 才會存在 `/home/agent`。
- **想換 agent**：改 `config.toml` 的 `[agent]` 那幾行，`systemctl restart openab`。平台跟 agent 互相不知道對方是誰，這就是 ACP 的意義。

## 更好的架構（進階）

單機 EC2 適合個人用。想要高可用，看 openab 的 `oabctl`：可以把同一套部署到 ECS Fargate（跨 AZ、自動重排），token 放 Secrets Manager，登入狀態放 EFS。Learner Lab 也做得到，`oabctl bootstrap` 時指定既有的 `LabRole` 當 task role 跟 execution role 就好。
