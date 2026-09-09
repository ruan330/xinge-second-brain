#!/bin/bash
# 在 Ubuntu 24.04 的 EC2 上安裝 openab + Claude Code + Kiro CLI，並把這個第二大腦 clone 進來。
# 用法（以 root 執行）：
#   AGENT=kiro   bash setup-ubuntu.sh   # 預設：用 Kiro CLI（Builder ID 免費登入）
#   AGENT=claude bash setup-ubuntu.sh   # 用 Claude Code（需要 Claude 訂閱）
#   REPO=https://github.com/<你>/<你的vault>.git bash setup-ubuntu.sh   # 換成自己的筆記
set -euxo pipefail
AGENT="${AGENT:-kiro}"
REPO="${REPO:-https://github.com/ruan330/xinge-second-brain.git}"
OPENAB_VER="0.10.0-beta.4"
KIRO_VER="2.13.0"
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y git jq unzip curl xz-utils ca-certificates

# Node.js 22（官方 tarball，不跑遠端安裝腳本）
NODE_TGZ=$(curl -fsSL https://nodejs.org/dist/latest-v22.x/SHASUMS256.txt | grep -o 'node-v22[0-9.]*-linux-x64\.tar\.xz' | head -1)
curl -fsSL -o /tmp/node.tar.xz "https://nodejs.org/dist/latest-v22.x/${NODE_TGZ}"
tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1
npm install -g @anthropic-ai/claude-code@2.1.212 @agentclientprotocol/claude-agent-acp@0.59.0

# Kiro CLI（免費，用 AWS Builder ID 登入）
curl -fsSL -o /tmp/kirocli.zip "https://prod.download.cli.kiro.dev/stable/${KIRO_VER}/kirocli-x86_64-linux.zip"
rm -rf /tmp/kirocli && unzip -q /tmp/kirocli.zip -d /tmp
cp /tmp/kirocli/bin/* /usr/local/bin/ && chmod +x /usr/local/bin/kiro-cli*

# openab（預編譯 binary 需要 glibc 2.39，所以要用 Ubuntu 24.04，Amazon Linux 2023 不行）
curl -fsSL -o /tmp/openab.tgz "https://github.com/openabdev/openab/releases/download/openab-${OPENAB_VER}/openab-${OPENAB_VER}-linux-x64.tar.gz"
mkdir -p /tmp/openab && tar -xzf /tmp/openab.tgz -C /tmp/openab
install -m 755 "$(find /tmp/openab -type f -name openab | head -1)" /usr/local/bin/openab
openab --version

# 專門跑 agent 的使用者 + 第二大腦
id agent >/dev/null 2>&1 || useradd -m -s /bin/bash agent
DIR=/home/agent/$(basename "$REPO" .git)
[ -d "$DIR" ] || sudo -u agent git clone "$REPO" "$DIR"
sudo -u agent git -C "$DIR" config user.name "AI 助理"
sudo -u agent git -C "$DIR" config user.email "ai-assistant@users.noreply.github.com"
sudo -u agent git config --global credential.helper '!f() { echo username=x-access-token; echo password=$GITHUB_TOKEN; }; f'
sudo -u agent mkdir -p /home/agent/.claude /home/agent/.kiro

# openab 設定
mkdir -p /etc/openab
if [ "$AGENT" = "claude" ]; then
  AGENT_BLOCK='command = "claude-agent-acp"'
else
  AGENT_BLOCK='command = "kiro-cli"
args = ["acp", "--trust-all-tools"]'
fi
cat > /etc/openab/config.toml <<EOF
[discord]
bot_token = "\${DISCORD_BOT_TOKEN}"
allow_dm = true
allow_bot_messages = "off"
allow_user_messages = "multibot-mentions"

[agent]
${AGENT_BLOCK}
working_dir = "${DIR}"
inherit_env = ["HOME", "PATH", "USER", "LANG", "CLAUDE_CODE_OAUTH_TOKEN", "CLAUDE_CODE_EXECUTABLE", "GITHUB_TOKEN"]

[pool]
max_sessions = 5
session_ttl_hours = 24
EOF

cat > /etc/openab/env <<EOF
# 填好之後：sudo systemctl restart openab
DISCORD_BOT_TOKEN=
CLAUDE_CODE_OAUTH_TOKEN=
GITHUB_TOKEN=
CLAUDE_CODE_EXECUTABLE=/usr/local/bin/claude
LANG=C.UTF-8
PATH=/usr/local/bin:/usr/bin:/bin
EOF
chown root:agent /etc/openab/env && chmod 640 /etc/openab/env

cat > /etc/systemd/system/openab.service <<'EOF'
[Unit]
Description=openab (Discord <-> ACP agent)
After=network-online.target
Wants=network-online.target

[Service]
User=agent
Group=agent
WorkingDirectory=/home/agent
EnvironmentFile=/etc/openab/env
Environment=HOME=/home/agent
ExecStart=/usr/local/bin/openab run -c /etc/openab/config.toml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload && systemctl enable openab
echo "=== 安裝完成。接下來：登入 agent、填 /etc/openab/env、systemctl start openab"
