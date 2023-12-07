@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

rem 函数：显示WiFi列表
:ShowWiFiList
echo.
echo 请选择以下其中一个WiFi名称:
echo -------------------------
set "counter=1"
for /f "tokens=*" %%a in ('netsh wlan show profile ^| findstr /R "^[ ]*所有用户配置文件 : ^|^[ ]*Profile on interface :" ^| findstr /v /c:"Profiles on interface WLAN" ^| findstr /v /c:"Group policy profiles (read only)" ^| findstr /v /c:"<None>"') do (
    set "line=%%a"
    set "line=!line:*: =!"
    if not "!line!" == "" (
        set "wifi_list[!counter!]=!line!"
        echo [!counter!] !line!
        set /a "counter+=1"
    )
)

rem 函数：获取WiFi密码并显示
:GetWiFiPassword
echo.
set /p "choice=选择一个WiFi（输入序号）: "

rem 验证用户输入是否为数字
set "is_number=true"
for /f "delims=0123456789" %%i in ("%choice%") do set "is_number=false"

if %is_number%==false (
    echo 无效的输入，请输入一个有效的数字。
    goto :ShowWiFiList
) else if %choice% geq 1 (
    set "selected_wifi=!wifi_list[%choice%]!"
) else (
    echo 无效的选择。
    goto :ShowWiFiList
)

if not "!selected_wifi!" == "" (
    echo 你选择了: !selected_wifi!

    setlocal DisableDelayedExpansion
    for /f "tokens=2 delims=:" %%a in ('netsh wlan show profile name^=%selected_wifi% key^=clear ^| find "Key Content"') do (
        echo.
        echo 密码是:%%a
        echo.
    )
    endlocal
) else (
    echo 无效的选择。
    goto :ShowWiFiList
)

pause
