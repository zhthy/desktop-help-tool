@echo off
chcp 65001 >nul
cls

setlocal enabledelayedexpansion

:: 获取脚本所在目录的绝对路径
set "script_dir=%~dp0"
cd /d "%script_dir%"

:: 一言数组
set "quotes[0]=机会总是留给有准备的人。"
set "quotes[1]=越努力，越幸运。"
set "quotes[2]=坚持就是胜利。"
set "quotes[3]=天道酬勤。"
set "quotes[4]=每一天都是新的开始。"
set "quotes[5]=只要有梦想，就能实现。"
set "quotes[6]=凡事皆有可能。"

:: 生成一个随机数来选择一言
set /a "randomIndex=%random% %% 7"

:: 输出一言
echo     每日一言： !quotes[%randomIndex%]!
echo.


:menu
echo 请选择要执行的操作:
echo ----------====start====----------
echo    ID    NOTES
echo    1     批量安装脚本文件所在目录中的可执行程序
echo    2     修改计算机主机名
echo    3     激活win10系统
echo    4     查看当前IP地址
echo    5     刷新资源管理器状态---可用于解决 Windows Explorer 未响应的问题
echo    6     内存检测
echo    7     System file detection
echo    8     系统文件完整性检测
echo    9     DisableTouchpad
echo    10    查找并清理未使用的文件和快捷方式，并执行维护任务
echo    11    查找并解决在此版本的Windows上运行较旧程序的问题
echo    12    微信多开模块
echo    0     exit

set /p choice=请输入操作选项 (0-12):

if "%choice%"=="1" goto install_programs
if "%choice%"=="2" goto rename_computer
if "%choice%"=="3" goto windows
if "%choice%"=="4" goto ip
if "%choice%"=="5" goto explorer
if "%choice%"=="6" goto memory
if "%choice%"=="7" goto sys
if "%choice%"=="8" goto sfc
if "%choice%"=="9" goto DisableTouchpad
if "%choice%"=="10" goto MaintenanceDiagnostic
if "%choice%"=="11" goto PCWDiagnostic
if "%choice%"=="12" goto WeChat
if "%choice%"=="0" goto end

:install_programs
echo 正在批量安装脚本文件所在目录中的可执行程序...
for %%f in ("%script_dir%\*.msu" "%script_dir%\*.msi" "%script_dir%\*.exe" "%script_dir%\*.lnk") do (
    echo 安装 %%~nxf...
    start "" "%%f"
)
echo 安装完成。
pause
goto menu

:rename_computer
echo 当前的主机名：%COMPUTERNAME%
set /p new_name=请输入新的主机名：

:: 使用 PowerShell 修改主机名
powershell -Command Rename-Computer -NewName "%new_name%" -Force

if %errorlevel% equ 0 (
    echo 主机名修改完成。
) else (
    echo 主机名修改失败。
)

pause
goto menu

:windows

:: 检查是否以管理员身份运行
openfiles >nul 2>&1
if %errorlevel% NEQ 0 (
    echo 请以管理员身份运行此脚本。
    pause
    exit /b
)

:: 检查Windows版本
for /f "tokens=3" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID 2^>nul') do set "EditionID=%%A"

echo 检测到的Windows版本: %EditionID%

:: 检查Windows激活状态
for /f "tokens=2 delims=: " %%A in ('slmgr /xpr') do set "ActivationStatus=%%A"

if "%ActivationStatus%" EQU "The machine is permanently activated." (
    echo 系统已经激活，无需再次激活。
    pause
    exit /b
)

:: 设置KMS服务器地址
set KMS_SERVER=kms.03k.org

:: 根据Windows版本设置密钥
if /i "%EditionID%" EQU "Professional" (
    set "KEY=W269N-WFGWX-YVC9B-4J6C9-T83GX"
) else if /i "%EditionID%" EQU "Enterprise" (
    set "KEY=NPPR9-FWDCX-D2C8J-H872K-2YT43"
) else if /i "%EditionID%" EQU "Core" (
    set "KEY=TX9XD-98N7V-6WMQ6-BX7FG-H8Q99"
) else if /i "%EditionID%" EQU "CoreCountrySpecific" (
    set "KEY=YNMGQ-8RYV3-4PGQ3-C8XTP-7CFBY"
) else (
    echo 不支持的Windows版本: %EditionID%
    pause
    exit /b
)

:: 安装产品密钥
echo 安装产品密钥: %KEY%
slmgr /ipk %KEY%

:: 设置KMS服务器
echo 设置KMS服务器: %KMS_SERVER%
slmgr /skms %KMS_SERVER%

:: 激活Windows
echo 激活Windows...
slmgr /ato

echo 激活完成！
pause
goto menu

:ip
REM 获取IP地址
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| find "IPv4 Address"') do (
    set ip=%%i
    set ip=!ip:~1!
)
REM 输出信息
if not defined ip (
    echo 无法获取IP地址
) else (
    echo IP地址: %ip%
)
pause
goto menu

:explorer
echo 正在刷新资源管理器状态请稍后
taskkill /f /im explorer.exe
start explorer.exe
pause
goto menu

:memory
MdSched.exe
pause
goto menu

:sys
echo 正在扫描系统文件并与官方系统文件对比...
Dism /Online /Cleanup-Image /ScanHealth
echo 扫描完毕，检查系统文件健康状态...
Dism /Online /Cleanup-Image /CheckHealth
echo 如果有系统文件损坏，正在修复中...
Dism /Online /Cleanup-image /RestoreHealth
echo 修复完成。请稍候重新启动计算机，重启后使用检查系统文件完整性模块
pause
goto menu

:sfc
sfc /SCANNOW
pause
goto menu

:DisableTouchpad
:: 检查是否以管理员权限运行
openfiles >nul 2>&1
if '%errorlevel%' neq '0' (
    echo 当前脚本未以管理员权限运行。
    echo 正在尝试以管理员权限重新启动...
    :: 以管理员权限重新启动脚本文件
    powershell -Command "Start-Process cmd.exe -ArgumentList '/c %~f0' -Verb runAs"
    exit /b
)

:: 设置 PowerShell 脚本的路径
set "psScript=%~dp0DisableTouchpad.ps1"

:: 检查 PowerShell 脚本是否存在
if not exist "%psScript%" (
    echo 错误: 找不到 PowerShell 脚本 "%psScript%"
    exit /b 1
)

:: 执行 PowerShell 脚本
echo 正在运行 PowerShell 脚本 "%psScript%"...
powershell -NoProfile -ExecutionPolicy Bypass -File "%psScript%"

:: 完成
echo 完成
pause
goto menu

:MaintenanceDiagnostic
REM 定义下载URL和保存路径
set "URL=https://download.microsoft.com/download/F/E/7/FE74974A-9029-41A0-9EB2-9CCE3FC20B99/MaintenanceDiagnostic.diagcab"
set "FILENAME=MaintenanceDiagnostic.diagcab"

REM 检查文件是否已存在
if exist "%FILENAME%" (
    echo 文件 "%FILENAME%" 已经存在，跳过下载。
    echo 正在运行 "%FILENAME%"
    start "" "%FILENAME%"
) else (
    echo 文件 "%FILENAME%" 不存在，正在下载...
    powershell -Command "Invoke-WebRequest -Uri %URL% -OutFile %FILENAME%"
    
    REM 检查下载是否成功
    if exist "%FILENAME%" (
        echo 下载完成，正在运行 "%FILENAME%"
        start "" "%FILENAME%"
    ) else (
        echo 下载失败
    )
)

endlocal
pause
goto menu

:PCWDiagnostic
REM 定义下载URL和保存路径
set "URL=https://download.microsoft.com/download/F/E/7/FE74974A-9029-41A0-9EB2-9CCE3FC20B99/PCWDiagnostic.diagcab"
set "FILENAME=PCWDiagnostic.diagcab"

REM 检查文件是否已存在
if exist "%FILENAME%" (
    echo 文件 "%FILENAME%" 已经存在，跳过下载。
    echo 正在运行 "%FILENAME%"
    start "" "%FILENAME%"
) else (
    echo 文件 "%FILENAME%" 不存在，正在下载...
    powershell -Command "Invoke-WebRequest -Uri %URL% -OutFile %FILENAME%"
    
    REM 检查下载是否成功
    if exist "%FILENAME%" (
        echo 下载完成，正在运行 "%FILENAME%"
        start "" "%FILENAME%"
    ) else (
        echo 下载失败
    )
)

endlocal
pause
goto menu

:WeChat
:: 提示用户输入微信安装路径
set /p wechatPath=请输入微信安装路径 (例如 C:\Program Files (x86)\Tencent\WeChat\WeChat.exe): 
:: 检查路径是否为空
if "%wechatPath%"=="" (
    echo 安装路径不能为空！
    exit /b 1
)

:: 提示用户输入要启动的微信实例数量
set /p numInstances=请输入要启动的微信实例数量: 
:: 检查输入是否为有效数字
for /f "delims=0123456789" %%a in ("%numInstances%") do (
    echo 输入的实例数量无效，请输入一个正整数。
    exit /b 1
)

:: 启动指定数量的微信实例
for /l %%i in (1,1,%numInstances%) do (
    echo 启动微信实例 %%i...
    start "" "%wechatPath%"
)

echo 所有微信实例已启动。
pause
goto menu

:end
echo 退出脚本。
pause
