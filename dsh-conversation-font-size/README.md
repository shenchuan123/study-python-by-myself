# dsh-conversation-font-size

> 简体中文 · [English](./README.md)

为 **DeepSeek Harness**（`dsh`）Web 界面添加“可调节对话正文字号”的小插件。在**左侧栏最底部**提供一个**滑动条**，拖动即可连续调节对话正文（助手输出 + 你的输入气泡）的字号：默认 16px、可调 12–28px，按浏览器记忆、刷新后保留。

A small plugin that lets you **resize the conversation body text** of the **DeepSeek Harness** (`dsh`) web UI. A **slider** pinned at the **bottom of the left sidebar** continuously adjusts the transcript font (assistant output + your input bubbles): 12–28 px, default 16 px, remembered per browser across reloads.

> 本项目是对开源 [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness)（MIT）`0.1.1-rc.2` 的**两处 UI 改动 + 两个重建产物 bundle**，做成可 drop-in 安装的发布包。
> Derived from the MIT-licensed [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) `0.1.1-rc.2` — two UI changes plus two rebuilt bundles, shipped as a drop-in package.

---

## 目录 Table of Contents
- [中文](#功能与效果)
  - [功能与效果](#功能与效果)
  - [工作原理](#工作原理)
  - [仓库版本信息](#仓库版本信息)
  - [目录结构](#目录结构)
  - [前置条件](#前置条件)
  - [安装](#安装)
  - [部署 重启 验证](#部署--重启--验证)
  - [卸载 还原](#卸载--还原)
  - [从源码重新编译](#从源码重新编译)
- [English](#features)
  - [Features](#features)
  - [How it works](#how-it-works)
  - [Repo & versions](#repo--versions)
  - [Layout](#layout)
  - [Prerequisites](#prerequisites)
  - [Install](#install)
  - [Deploy · restart · verify](#deploy--restart--verify)
  - [Uninstall](#uninstall)
  - [Rebuild from source](#rebuild-from-source)
- [许可 License](#许可与致谢)

---

# 中文

## 功能与效果
- 左侧栏**展开**时，底部（设置图标下方）显示一行：`Aa ───●─── 16px`
- **拖动滑块**即可连续调整 12–28px（步进 1px）
- 同时作用于：**助手（AI）Markdown 输出正文** 与 **你发送的用户气泡文字**
- 界面其它部分（侧栏、输入框、标题、按钮）**不受影响**
- 默认 16px 与 Harness 原始排版一致；缩放值按浏览器记忆，刷新后保持
- 左侧栏收成 56px 窄轨时滑块自动隐藏（宽度不够），展开即恢复

## 工作原理
改动很小且相互解耦：
1. **正文字号由 CSS 变量驱动**（`ui-conversation`）：助手正文与用户气泡的 `font-size` 改为读取 `var(--ds-conv-font-size, 16px)`（默认回退 16px，无视觉变化）。助手输出使用 `MarkdownText`，其正文字号原由设计 token `--dsw-font-markdown-base` 写死（不继承），故在其作用域内用同一变量重新导出该 token，使正文跟随滑块。
2. **滑块放在左侧栏外壳**（`ui-sidebar`）：把所选值写入 `document.documentElement` 的 `--ds-conv-font-size`，所有会话正文即时缩放；用 `localStorage`（键 `ds.convFontSize`）记忆。因为是设全局 CSS 变量，滑块放哪儿都不影响缩放范围，所以能放左下角。

> 发布的是改好并重建过的两个客户端 bundle（`ui-conversation`、`ui-sidebar`），无需 Harness 源码即可直接安装覆盖运行。

## 仓库版本信息
| 项 | 值 |
|----|----|
| 上游 | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| 上游基线版本 | `0.1.1-rc.2` |
| 改动源码 | `ui-conversation`:`AssistantMarkdown.module.css`、`MessageItem.module.css`；`ui-sidebar`:`SidebarRoot.tsx`、`SidebarRoot.module.css` |
| 提交 | `8577cc8` slider · `0c0a0de` markdown scale · `1fa580e` css-var base |

## 目录结构
```
dsh-conversation-font-size/
├─ README.md
├─ LICENSE
├─ bundles/
│  ├─ ui-conversation/client.js
│  └─ ui-sidebar/client.js
├─ patch/deepseek-harness-0.1.1-rc.2-font-size.patch
└─ scripts/install.ps1 · uninstall.ps1
```

## 前置条件
- 装有 dsh (DeepSeek Harness) 的 Windows 电脑，能启动 Web 界面（`dsh web`，默认 `http://127.0.0.1:3080`）
- PowerShell（Windows 自带）
- 仅安装本插件**不需要**源码/git/pnpm；只有“从源码重编译”才需要

## 安装
安装脚本自动定位已装的 `@deepseek-ai/dsh` 下 `dsh-client-ui-conversation` 与 `dsh-client-ui-sidebar` 两个 bundle，先备份为 `client.js.bak` 再用产物覆盖。
```powershell
powershell -ExecutionPolicy Bypass -File .\dsh-conversation-font-size\scripts\install.ps1
```
若找不到目标（非标准安装或源码运行），见 `scripts/install.ps1` 内 `$Targets`/`-DshRoot` 手动指定。

## 部署 / 重启 / 验证
安装后必须重启并清缓存：
```powershell
$pidToKill = (Get-NetTCPConnection -LocalPort 3080 -State Listen -ErrorAction SilentlyContinue).OwningProcess
if ($pidToKill) { Stop-Process -Id $pidToKill -Force }
dsh web   # 在你平时启动它的方式
```
打开 `http://127.0.0.1:3080`，`Ctrl+F5` 强制刷新。展开左侧栏，底部出现滑块；拖到 18/22px，助手输出与你的气泡会明显变大，刷新后仍保持。

## 卸载 / 还原
安装已备份为 `client.js.bak`，卸载即还原：
```powershell
powershell -ExecutionPolicy Bypass -File .\dsh-conversation-font-size\scripts\uninstall.ps1
```
再重启 + `Ctrl+F5`。

## 从源码重新编译
1. 取得 `deepseek-harness`（建议 `0.1.1-rc.2`）源码并 `pnpm install`
2. 应用补丁（手动改 4 个文件，或 `git apply patch/deepseek-harness-0.1.1-rc.2-font-size.patch`）
3. 重建两个包：
   ```sh
   pnpm --filter @deepseek-ai/dsh-client-ui-conversation bundle
   pnpm --filter @deepseek-ai/dsh-client-ui-sidebar bundle
   ```
4. 用新 `lib/client.js` 更新你运行 GUI 所用产物（或从该源码 dev 树启动），重启即可。

---

# English

## Features
- When the left sidebar is **expanded**, a row appears at its foot (below the settings icon): `Aa ───●─── 16px`
- **Drag the slider** to adjust 12–28 px continuously (step 1 px)
- Affects both the **assistant (AI) Markdown output** and the **user input bubbles**
- Everything else (sidebar, input box, titles, buttons) is **untouched**
- Default 16 px matches the original Harness layout; the value is remembered per browser and persists across reloads
- When the sidebar collapses to the 56 px rail the slider hides (not enough width) and reappears on expand

## How it works
Small and decoupled:
1. **Transcript font is driven by a CSS variable** (`ui-conversation`): the assistant body and the user bubble read `font-size: var(--ds-conv-font-size, 16px)` (falls back to 16 px, so nothing changes by default). Assistant output is rendered by `MarkdownText`, whose prose size is normally pinned by the design token `--dsw-font-markdown-base` (it does not inherit); inside the assistant scope we re-derive that token from the same variable so the prose follows the slider.
2. **The slider lives in the sidebar shell** (`ui-sidebar`): it writes the chosen value into `--ds-conv-font-size` on `document.documentElement`, so every session's transcript scales live, and remembers it in `localStorage` (key `ds.convFontSize`). Because it only sets a global CSS variable, the control can sit anywhere — which is why it works at the bottom-left.

> Shipped are the two rebuilt client bundles (`ui-conversation`, `ui-sidebar`). No Harness source is required to install and run them.

## Repo & versions
| Field | Value |
|-------|-------|
| Upstream | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| Upstream baseline | `0.1.1-rc.2` |
| Changed sources | `ui-conversation`: `AssistantMarkdown.module.css`, `MessageItem.module.css`; `ui-sidebar`: `SidebarRoot.tsx`, `SidebarRoot.module.css` |
| Commits | `8577cc8` slider · `0c0a0de` markdown scale · `1fa580e` css-var base |

## Layout
```
dsh-conversation-font-size/
├─ README.md
├─ LICENSE
├─ bundles/
│  ├─ ui-conversation/client.js
│  └─ ui-sidebar/client.js
├─ patch/deepseek-harness-0.1.1-rc.2-font-size.patch
└─ scripts/install.ps1 · uninstall.ps1
```

## Prerequisites
- A Windows machine with dsh (DeepSeek Harness) installed and able to run the web UI (`dsh web`, default `http://127.0.0.1:3080`)
- PowerShell (bundled with Windows)
- Installing this plugin needs **no** source/git/pnpm — those are only needed to rebuild from source

## Install
The installer locates `dsh-client-ui-conversation` and `dsh-client-ui-sidebar` under the installed `@deepseek-ai/dsh`, backs the originals up as `client.js.bak`, and overwrites them with the bundled artifacts.
```powershell
powershell -ExecutionPolicy Bypass -File .\dsh-conversation-font-size\scripts\install.ps1
```
If targets aren't found (non-standard install or source run), point the script at the right dir with `-DshRoot <path>`.

## Deploy · restart · verify
Restart and clear the cache after installing:
```powershell
$pidToKill = (Get-NetTCPConnection -LocalPort 3080 -State Listen -ErrorAction SilentlyContinue).OwningProcess
if ($pidToKill) { Stop-Process -Id $pidToKill -Force }
dsh web   # launch the way you normally do
```
Open `http://127.0.0.1:3080` and hard-refresh (`Ctrl+F5`). Expand the left sidebar — the slider appears at the foot; drag to 18/22 px and the assistant output and your bubbles grow clearly; the value survives a reload.

## Uninstall
The installer kept `client.js.bak`; uninstall restores it:
```powershell
powershell -ExecutionPolicy Bypass -File .\dsh-conversation-font-size\scripts\uninstall.ps1
```
Then restart + `Ctrl+F5`.

## Rebuild from source
1. Get `deepseek-harness` (use `0.1.1-rc.2`) and run `pnpm install`
2. Apply the change (edit the 4 files, or `git apply patch/deepseek-harness-0.1.1-rc.2-font-size.patch`)
3. Rebuild the two packages:
   ```sh
   pnpm --filter @deepseek-ai/dsh-client-ui-conversation bundle
   pnpm --filter @deepseek-ai/dsh-client-ui-sidebar bundle
   ```
4. Use the new `lib/client.js` files where your GUI loads them (or run the GUI from that source dev tree), then restart.

---

## 许可与致谢 License & Credits
本项目源代码改编自 **deepseek-ai/deepseek-harness**（MIT License）。在未取得上游书面同意前，本包仅以“在 Harness 之上叠加的两处 UI 改动 + 产物”形式发布；源码补丁遵循上游 MIT 许可。本包的改动、文档与脚本以 **MIT License** 发布（见 `LICENSE`）。再分发时请保留上游许可声明与致谢。

This project's code is adapted from **deepseek-ai/deepseek-harness** (MIT License). Unless the upstream grants written consent, this package ships only as "two UI changes layered on Harness plus built artifacts"; the source patch follows the upstream MIT license. This package's changes, docs, and scripts are released under the **MIT License** (see `LICENSE`). Please retain the upstream license notice and credit on redistribution.
