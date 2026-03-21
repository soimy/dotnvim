# tmux AI 工作台

这套 `tmux` 配置既支持仓库内独立运行，也支持安装成当前用户的全局配置。

## 安装为全局配置

```bash
cd /Users/sym/.config/nvim
./scripts/install-global-tmux-config
```

脚本会：

- 写入 `~/.config/tmux/tmux.conf`
- 备份旧配置到同目录下的时间戳 `.bak`
- 安装插件到 `~/.config/tmux/plugins`

安装完成后，直接运行：

```bash
tmux
```

## 启动

```bash
cd /Users/sym/.config/nvim
./scripts/tmux-ai
```

首次运行会自动准备本地插件目录：`/Users/sym/.config/nvim/.tmux/plugins`

## 设计目标

- 适合 AI coding：编辑器、测试、日志、代理 shell 并排工作
- 不改你现有的 Neovim `Ctrl-h/j/k/l` 习惯
- 用单独 socket 和 session，避免和你其他 tmux 会话互相污染
- 新 pane 和 popup 默认走登录态 `zsh`，能正常加载 `~/.zshrc` / Powerlevel10k

## 常用按键

- `Ctrl-a`：前缀键
- `prefix + -`：纵向分屏，继承当前目录
- `prefix + |`：横向分屏，继承当前目录
- `prefix + h/j/k/l`：切换 pane
- `prefix + H/J/K/L`：调整 pane 大小
- `Alt-h/j/k/l`：无前缀切换 pane
- `Alt-H/J/K/L`：无前缀调整 pane 大小
- `prefix + e`：新开一个 `nvim` 窗口
- `prefix + g`：弹出 `lazygit`
- `prefix + Enter`：弹出临时 shell
- `prefix + s`：切换同步输入，适合并排 agent 或多面板批量执行命令
- `prefix + r`：重载配置

## 插件

- `tmux-sensible`
- `tmux-yank`
- `tmux-resurrect`
- `tmux-continuum`

## 手动安装/更新插件

```bash
./scripts/tmux-ai --install
```

tmux 内：

- `prefix + I`：安装新插件
- `prefix + U`：更新插件
