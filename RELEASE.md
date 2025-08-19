# 发布指南 (Release Guide)

本文档介绍如何发布网络监控程序的编译版本到GitHub Releases。

## 📦 发布流程

### 1. 准备发布版本

#### 更新版本信息
```bash
# 在 network_monitor.go 中添加版本常量
const VERSION = "v1.0.0"
```

#### 编译多平台版本
```bash
# Windows 64位 (无窗口版本)
go build -ldflags="-H windowsgui" -o network_monitor_windows_amd64.exe

# Windows 64位 (控制台版本，用于调试)
go build -o network_monitor_windows_amd64_console.exe

# Windows 32位 (如需要)
set GOARCH=386
go build -ldflags="-H windowsgui" -o network_monitor_windows_386.exe
```

### 2. 创建发布包

#### 创建发布目录结构
```
network_monitor_v1.0.0/
├── network_monitor.exe          # 主程序 (无窗口版本)
├── network_monitor_console.exe  # 控制台版本 (调试用)
├── config.ini                   # 配置文件模板
├── icon.ico                     # 系统托盘图标
├── README.md                    # 使用说明
└── LICENSE                      # 许可证文件
```

#### 打包命令
```bash
# 创建发布目录
mkdir network_monitor_v1.0.0

# 复制文件
copy network_monitor_windows_amd64.exe network_monitor_v1.0.0\network_monitor.exe
copy network_monitor_windows_amd64_console.exe network_monitor_v1.0.0\network_monitor_console.exe
copy config.ini network_monitor_v1.0.0\
copy icon.ico network_monitor_v1.0.0\
copy README.md network_monitor_v1.0.0\
copy LICENSE network_monitor_v1.0.0\

# 创建ZIP压缩包
Compress-Archive -Path network_monitor_v1.0.0 -DestinationPath network_monitor_v1.0.0_windows_amd64.zip
```

### 3. GitHub Releases 发布

#### 方法一：通过GitHub网页界面

1. **访问仓库页面**
   - 进入你的GitHub仓库
   - 点击右侧的 "Releases" 或 "Create a new release"

2. **创建新发布**
   - 点击 "Create a new release" 按钮
   - 填写标签版本：`v1.0.0`
   - 发布标题：`网络监控程序 v1.0.0`

3. **编写发布说明**
   ```markdown
   ## 🎉 网络监控程序 v1.0.0
   
   ### ✨ 新功能
   - 🔄 自动网络切换功能
   - 🎯 系统托盘集成
   - ⚙️ 配置文件驱动
   - 🎮 监控控制开关
   - 🖼️ 自定义图标支持
   
   ### 📋 系统要求
   - Windows 10/11 (x64)
   - 管理员权限
   
   ### 📥 下载说明
   - `network_monitor_v1.0.0_windows_amd64.zip` - 完整发布包
   - `network_monitor.exe` - 主程序（无窗口版本）
   - `network_monitor_console.exe` - 控制台版本（调试用）
   
   ### 🚀 快速开始
   1. 下载并解压 `network_monitor_v1.0.0_windows_amd64.zip`
   2. 根据需要修改 `config.ini` 配置文件
   3. 右键以管理员身份运行 `network_monitor.exe`
   
   ### 📝 更新日志
   - 初始版本发布
   - 实现双网自动切换核心功能
   - 完整的系统托盘用户界面
   - 灵活的配置文件系统
   ```

4. **上传文件**
   - 拖拽或选择以下文件上传：
     - `network_monitor_v1.0.0_windows_amd64.zip`
     - `network_monitor.exe`
     - `network_monitor_console.exe`

5. **发布设置**
   - ✅ 勾选 "Set as the latest release"
   - 如果是预发布版本，勾选 "This is a pre-release"
   - 点击 "Publish release"

#### 方法二：使用GitHub CLI

```bash
# 安装GitHub CLI
winget install GitHub.cli

# 登录GitHub
gh auth login

# 创建发布
gh release create v1.0.0 \
  --title "网络监控程序 v1.0.0" \
  --notes-file RELEASE_NOTES.md \
  network_monitor_v1.0.0_windows_amd64.zip \
  network_monitor.exe \
  network_monitor_console.exe
```

### 4. 自动化构建 (GitHub Actions)

创建 `.github/workflows/release.yml`：

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: windows-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Go
      uses: actions/setup-go@v3
      with:
        go-version: 1.21
    
    - name: Build Windows AMD64
      run: |
        go build -ldflags="-H windowsgui" -o network_monitor_windows_amd64.exe
        go build -o network_monitor_windows_amd64_console.exe
    
    - name: Build Windows 386
      run: |
        $env:GOARCH="386"
        go build -ldflags="-H windowsgui" -o network_monitor_windows_386.exe
    
    - name: Create Release Package
      run: |
        mkdir release
        copy network_monitor_windows_amd64.exe release\network_monitor.exe
        copy network_monitor_windows_amd64_console.exe release\network_monitor_console.exe
        copy config.ini release\
        copy icon.ico release\
        copy README.md release\
        copy LICENSE release\
        Compress-Archive -Path release -DestinationPath network_monitor_${{ github.ref_name }}_windows_amd64.zip
    
    - name: Create Release
      uses: softprops/action-gh-release@v1
      with:
        files: |
          network_monitor_${{ github.ref_name }}_windows_amd64.zip
          network_monitor_windows_amd64.exe
          network_monitor_windows_amd64_console.exe
          network_monitor_windows_386.exe
        body: |
          ## 🎉 网络监控程序 ${{ github.ref_name }}
          
          ### 📥 下载文件
          - `network_monitor_${{ github.ref_name }}_windows_amd64.zip` - 完整发布包 (64位)
          - `network_monitor_windows_amd64.exe` - 主程序 (64位)
          - `network_monitor_windows_386.exe` - 主程序 (32位)
          
          ### 🚀 使用方法
          1. 下载对应版本的程序
          2. 配置 config.ini 文件
          3. 以管理员权限运行程序
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## 🏷️ 版本管理

### 语义化版本控制

采用 [Semantic Versioning](https://semver.org/) 规范：

- **主版本号 (MAJOR)**：不兼容的API修改
- **次版本号 (MINOR)**：向下兼容的功能性新增
- **修订号 (PATCH)**：向下兼容的问题修正

示例：
- `v1.0.0` - 初始稳定版本
- `v1.1.0` - 新增功能
- `v1.1.1` - 修复bug
- `v2.0.0` - 重大更新

### 发布类型

- **Stable Release** - 稳定版本
- **Pre-release** - 预发布版本 (alpha, beta, rc)
- **Draft** - 草稿版本（未公开）

## 📋 发布检查清单

发布前请确认：

- [ ] 代码已合并到主分支
- [ ] 所有测试通过
- [ ] 更新了版本号
- [ ] 编写了发布说明
- [ ] 编译了所有目标平台
- [ ] 测试了编译后的程序
- [ ] 准备了完整的发布包
- [ ] 上传了必要的文件
- [ ] 标记了正确的发布类型

## 🔄 发布后续工作

1. **通知用户**：在相关社区或文档中宣布新版本
2. **监控反馈**：关注用户反馈和问题报告
3. **准备补丁**：如发现重要问题，及时发布修复版本
4. **更新文档**：确保文档与最新版本同步

---

通过以上流程，您可以专业地管理和发布网络监控程序的各个版本。