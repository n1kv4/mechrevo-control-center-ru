@echo off
chcp 866 >nul
REM Restores original files for MECHREVO Control Center from backups.

net session >nul 2>&1
if %errorlevel% NEQ 0 (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

setlocal EnableExtensions

for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "(Get-AppxPackage *CCU.WinUI*).InstallLocation"`) do set "PKG=%%i"
if not defined PKG ( echo [ОШИБКА] Приложение не найдено. & pause & exit /b 1 )

taskkill /im CCUWinUI.exe /f >nul 2>&1
taskkill /im SystrayComponent.exe /f >nul 2>&1
timeout /t 2 >nul

call :restore "%PKG%\Strings_Json\ru-ru.json" "ru-ru.json"
call :restore "%PKG%\Strings_Json\en-us.json" "en-us.json"
call :restore "%PKG%\resources.pri"           "resources.pri"

echo.
echo Готово. Оригинальные файлы восстановлены (где найдены резервные копии).
pause
endlocal
exit /b

:restore
set "TGT=%~1"
set "LBL=%~2"
set "BAK=%~dp0%LBL%.original.bak"
if not exist "%BAK%" ( echo %LBL%: резервная копия не найдена, пропуск. & exit /b )
takeown /f "%TGT%" >nul 2>&1
icacls "%TGT%" /grant *S-1-5-32-544:F >nul 2>&1
attrib -r "%TGT%" >nul 2>&1
copy /y "%BAK%" "%TGT%" >nul
echo %LBL% восстановлен.
exit /b
