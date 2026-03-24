# dotnvim

基于 [LazyVim](https://www.lazyvim.org/) 的个人 Neovim 配置。

[English README](./README.md)

## 组成

- Neovim
- LazyVim
- Snacks UI
- 适合和 tmux 一起使用的终端工作流

## 依赖

- Neovim `>= 0.11.2`
- `git`
- `ripgrep`
- `fd`
- `fzf`
- `lazygit`
- `tree-sitter` CLI

当前脚本支持的包管理器：

- macOS 上的 Homebrew
- Ubuntu / Debian 上的 `apt`
- Arch 上的 `pacman`
- Fedora 上的 `dnf`

macOS 示例：

```bash
brew install neovim fd ripgrep fzf lazygit tree-sitter
```

## 安装

直接克隆到 Neovim 配置目录：

```bash
git clone https://github.com/soimy/dotnvim ~/.config/nvim
```

运行 bootstrap 脚本：

```bash
cd ~/.config/nvim
./bootstrap.sh
```

只预览、不真正改动系统：

```bash
./bootstrap.sh --dry-run
```

安装独立的 `mosh` 辅助脚本：

```bash
./scripts/install-global-mosh-config
```

打开 Neovim 后执行：

```vim
:checkhealth
```

## Mosh 辅助脚本

这个独立安装脚本会安装 `mosh`，并把 `mosh-connect` 部署到 `~/.local/bin/mosh-connect`。

示例：

```bash
mosh-connect user@example.com
mosh-connect user@example.com --ssh='ssh -p 2222'
```

远端主机也需要有 `mosh-server`，通常就是在远端同样安装 `mosh`。

## 说明

- 这套配置以 `Snacks` 作为主要的 picker / UI 路线。
- Ruby 和 Perl 的 Neovim provider 默认关闭。
- 某些图片预览能力依赖额外系统包，不影响日常编码。
- 在部分 Linux 发行版里，`lazygit` 可能不在默认仓库中；脚本会把它当作可选项处理。

## Agent 约束

这是一个个人配置云端化项目。对于智能体协作，请遵循：

- 优先直接、务实地修改，不要引入过重流程
- 简单的 shell、配置或文档改动，不要求重型 TDD
- 默认不要求使用 git worktree；除非明确要求隔离开发，否则可以直接在当前分支上工作
- 验证方式以轻量为主，按改动范围选择 shell 语法检查、smoke test 或针对性的手动验证

## Bazzite / 基于镜像的 Fedora

对于 Bazzite 以及类似的 `rpm-ostree` / `bootc` 系统，通常更推荐在 `distrobox` 里使用这套配置，而不是直接把所有开发工具叠到宿主层。

示例：

```bash
distrobox create --name dotnvim-fedora --image registry.fedoraproject.org/fedora:43 --yes
distrobox enter dotnvim-fedora
git clone https://github.com/soimy/dotnvim ~/.config/nvim
cd ~/.config/nvim
./bootstrap.sh
```

## 已验证的行为

我已经在 Fedora 43 容器里验证过这套 bootstrap 流程：

- `dnf` 主依赖安装正常
- `lazygit` 缺失时会降级为 warning，不会中断整体 bootstrap
- `npm` provider、`pynvim`、`LazyVim sync` 都可以跑通
- Mason 工具安装会等待到“成功或失败状态”再退出，不会像早期版本那样被提前中断

如果某些 Mason 工具依赖额外运行时，比如：

- `csharpier`
- `fantomas`

而你的系统里又没有 `dotnet`，脚本会把它们作为 warning 输出，而不是让整个安装流程失败。
