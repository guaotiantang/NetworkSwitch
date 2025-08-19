# 网络监控程序发布构建脚本
# Network Monitor Release Build Script

param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    
    [switch]$SkipZip,
    [switch]$OpenFolder
)

# 设置错误处理
$ErrorActionPreference = "Stop"

Write-Host "🚀 开始构建网络监控程序 $Version" -ForegroundColor Green

# 检查Go环境
try {
    $goVersion = go version
    Write-Host "✅ Go环境检查通过: $goVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ 错误: 未找到Go环境，请先安装Go" -ForegroundColor Red
    exit 1
}

# 清理旧的构建文件
Write-Host "🧹 清理旧的构建文件..." -ForegroundColor Yellow
Get-ChildItem -Path "." -Filter "network_monitor*.exe" | Remove-Item -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path "." -Filter "network_monitor*.zip" | Remove-Item -Force -ErrorAction SilentlyContinue
if (Test-Path "release") {
    Remove-Item -Path "release" -Recurse -Force
}

# 创建发布目录
Write-Host "📁 创建发布目录..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "release" -Force | Out-Null

# 构建Windows 64位版本（无窗口）
Write-Host "🔨 构建Windows 64位版本（无窗口）..." -ForegroundColor Yellow
$env:GOOS = "windows"
$env:GOARCH = "amd64"
$env:CGO_ENABLED = "1"
go build -ldflags="-H windowsgui -s -w" -o "network_monitor_windows_amd64.exe"
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 构建失败: Windows 64位版本（无窗口）" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Windows 64位版本（无窗口）构建完成" -ForegroundColor Green

# 构建Windows 64位版本（控制台）
Write-Host "🔨 构建Windows 64位版本（控制台）..." -ForegroundColor Yellow
go build -ldflags="-s -w" -o "network_monitor_windows_amd64_console.exe"
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 构建失败: Windows 64位版本（控制台）" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Windows 64位版本（控制台）构建完成" -ForegroundColor Green

# 构建Windows 32位版本（无窗口）
Write-Host "🔨 构建Windows 32位版本（无窗口）..." -ForegroundColor Yellow
$env:GOARCH = "386"
go build -ldflags="-H windowsgui -s -w" -o "network_monitor_windows_386.exe"
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 构建失败: Windows 32位版本（无窗口）" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Windows 32位版本（无窗口）构建完成" -ForegroundColor Green

# 复制文件到发布目录
Write-Host "📦 准备发布包..." -ForegroundColor Yellow
Copy-Item "network_monitor_windows_amd64.exe" "release\network_monitor.exe"
Copy-Item "network_monitor_windows_amd64_console.exe" "release\network_monitor_console.exe"
Copy-Item "config.ini" "release\"
Copy-Item "icon.ico" "release\"
Copy-Item "README.md" "release\"
Copy-Item "LICENSE" "release\"

# 创建ZIP压缩包
if (-not $SkipZip) {
    Write-Host "🗜️ 创建ZIP压缩包..." -ForegroundColor Yellow
    $zipName = "network_monitor_${Version}_windows_amd64.zip"
    Compress-Archive -Path "release\*" -DestinationPath $zipName -Force
    Write-Host "✅ ZIP压缩包创建完成: $zipName" -ForegroundColor Green
}

# 显示构建结果
Write-Host "`n🎉 构建完成！" -ForegroundColor Green
Write-Host "📁 发布文件:" -ForegroundColor Cyan
Get-ChildItem -Path "." -Filter "network_monitor*.exe" | ForEach-Object {
    $size = [math]::Round($_.Length / 1MB, 2)
    Write-Host "   📄 $($_.Name) ($size MB)" -ForegroundColor White
}

if (-not $SkipZip) {
    Get-ChildItem -Path "." -Filter "network_monitor*.zip" | ForEach-Object {
        $size = [math]::Round($_.Length / 1MB, 2)
        Write-Host "   📦 $($_.Name) ($size MB)" -ForegroundColor White
    }
}

Write-Host "`n📋 发布包内容:" -ForegroundColor Cyan
Get-ChildItem -Path "release" | ForEach-Object {
    Write-Host "   📄 $($_.Name)" -ForegroundColor White
}

# 生成发布说明
$releaseNotes = @"
## 🎉 网络监控程序 $Version

### ✨ 主要功能
- 🔄 自动网络切换：智能检测内外网连通性，自动切换网络接口
- 🎯 系统托盘集成：完全集成到Windows系统托盘，支持右键菜单操作
- ⚙️ 配置文件驱动：通过config.ini文件灵活配置所有参数
- 🎮 监控控制：支持启动/暂停双网检测功能
- 🖼️ 自定义图标：支持自定义系统托盘图标

### 📋 系统要求
- Windows 10/11
- 管理员权限（用于网络接口控制）

### 📥 下载文件说明
- **network_monitor_${Version}_windows_amd64.zip** - 完整发布包（推荐）
- **network_monitor_windows_amd64.exe** - 64位主程序（无窗口版本）
- **network_monitor_windows_amd64_console.exe** - 64位控制台版本（调试用）
- **network_monitor_windows_386.exe** - 32位主程序（兼容性版本）

### 🚀 快速开始
1. 下载并解压完整发布包
2. 根据网络环境修改 `config.ini` 配置文件
3. 右键以管理员身份运行 `network_monitor.exe`
4. 程序将在系统托盘显示图标

### ⚙️ 配置说明
请参考压缩包内的 `README.md` 文件获取详细的配置和使用说明。
"@

$releaseNotes | Out-File -FilePath "RELEASE_NOTES_$Version.md" -Encoding UTF8
Write-Host "`n📝 发布说明已生成: RELEASE_NOTES_$Version.md" -ForegroundColor Cyan

# 显示下一步操作提示
Write-Host "`n🔄 下一步操作:" -ForegroundColor Yellow
Write-Host "1. 测试构建的程序是否正常工作" -ForegroundColor White
Write-Host "2. 创建Git标签: git tag $Version" -ForegroundColor White
Write-Host "3. 推送标签: git push origin $Version" -ForegroundColor White
Write-Host "4. 或者手动上传到GitHub Releases" -ForegroundColor White

# 打开发布文件夹
if ($OpenFolder) {
    Write-Host "`n📂 打开发布文件夹..." -ForegroundColor Yellow
    Start-Process explorer.exe -ArgumentList (Get-Location).Path
}

Write-Host "`n✨ 发布构建脚本执行完成！" -ForegroundColor Green