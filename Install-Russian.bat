@echo off
chcp 866 >nul
REM ============================================================
REM  Russian translation installer for MECHREVO Control Center
REM  Keep ru-ru.json (and optional resources.pri) next to this .bat
REM ============================================================

net session >nul 2>&1
if %errorlevel% NEQ 0 (
    echo Запрашиваю права администратора...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

setlocal EnableExtensions
set "SRCJSON=%~dp0ru-ru.json"
set "SRCPRI=%~dp0resources.pri"

echo.
echo === MECHREVO Control Center - установка русского языка ===
echo.
if not exist "%SRCJSON%" ( echo [ОШИБКА] ru-ru.json не найден рядом со скриптом. & pause & exit /b 1 )

for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "(Get-AppxPackage *CCU.WinUI*).InstallLocation"`) do set "PKG=%%i"
if not defined PKG ( echo [ОШИБКА] Приложение MECHREVO Control Center не найдено. & pause & exit /b 1 )
echo Пакет : %PKG%
echo.

echo Закрываю приложение, если оно запущено...
taskkill /im CCUWinUI.exe /f >nul 2>&1
taskkill /im SystrayComponent.exe /f >nul 2>&1
timeout /t 2 >nul

call :installfile "%SRCJSON%" "%PKG%\Strings_Json\ru-ru.json" "ru-ru.json"
call :installfile "%SRCJSON%" "%PKG%\Strings_Json\en-us.json" "en-us.json"
if exist "%SRCPRI%" call :installfile "%SRCPRI%"  "%PKG%\resources.pri"           "resources.pri"

echo.
echo === ГОТОВО. Русский язык установлен. ===
echo.
echo Полностью закройте приложение (включая значок в трее),
echo затем откройте заново. Интерфейс будет на русском.
echo Язык в настройках оставьте на "en-us".
echo.
echo Откат: запустите Uninstall-Russian.bat
echo.
pause
endlocal
exit /b

:installfile
set "SRC=%~1"
set "TGT=%~2"
set "LBL=%~3"
echo Устанавливаю %LBL% ...
takeown /f "%TGT%" >nul 2>&1
icacls "%TGT%" /grant *S-1-5-32-544:F >nul 2>&1
attrib -r "%TGT%" >nul 2>&1
if not exist "%~dp0%LBL%.original.bak" (
    copy /y "%TGT%" "%~dp0%LBL%.original.bak" >nul 2>&1
    echo   копия: %LBL%.original.bak
)
copy /y "%SRC%" "%TGT%" >nul
if %errorlevel% NEQ 0 ( echo   [ОШИБКА] не удалось записать %LBL% - приложение закрыто? ) else ( echo   готово )
exit /b
