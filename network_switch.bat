@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo           网络自动切换脚本（BAT版本）
echo ========================================
echo.

:: 配置IP地址
set "INTERNAL_IP=188.5.106.1"   :: 内网检测IP
set "EXTERNAL_IP=192.168.33.1"  :: 外网检测IP

set "INTERNAL_CONN=OSS"  :: 内网连接名称
set "EXTERNAL_CONN=NET"  :: 外网连接名称

:: 检测网络连通性
ping -n 1 -w 1000 %INTERNAL_IP% >nul 2>&1
set "INTERNAL_OK=!errorlevel!"
ping -n 1 -w 1000 %EXTERNAL_IP% >nul 2>&1
set "EXTERNAL_OK=!errorlevel!"

:: 判断当前网络并切换
if !INTERNAL_OK! == 0 (
    if !EXTERNAL_OK! == 0 (
        echo 检测到内外网均可访问，当前为内网环境
        set "TARGET=EXTERNAL"
    ) else (
        echo 检测到内网环境，切换到外网
        set "TARGET=EXTERNAL"
        echo.
    )
) else (
    if !EXTERNAL_OK! == 0 (
        echo 检测到外网环境，切换到内网
        set "TARGET=INTERNAL"
        echo.
    ) else (
        echo 错误：内外网均无法访问，请检查网络连接
        pause
        exit /b 1
    )
)

:: 执行网络切换
if "!TARGET!" == "EXTERNAL" (
    echo 正在启用外网连接...
    netsh interface set interface "!INTERNAL_CONN!" disable
    timeout /t 2 /nobreak >nul
    netsh interface set interface "!EXTERNAL_CONN!" enable
) else (
    echo 正在启用内网连接...
    netsh interface set interface "!EXTERNAL_CONN!" disable
    timeout /t 2 /nobreak >nul
    netsh interface set interface "!INTERNAL_CONN!" enable
)

echo.
echo 网络切换完成！
pause