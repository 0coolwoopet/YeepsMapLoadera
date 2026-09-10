@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "PROJECT_DIR=%SCRIPT_DIR%..\ExportedProject"

if not exist "%PROJECT_DIR%\Assets" (
    set "PROJECT_DIR=%SCRIPT_DIR%..\..\ExportedProject"
)

if not exist "%PROJECT_DIR%\Assets" (
    echo Could not find an "ExportedProject" folder next to this one.
    echo.
    echo If you downloaded this as a ZIP from GitHub, it extracts into an extra
    echo "YeepsMapLoader-main" folder. Move the "YeepsMapLoaderSetup" folder OUT
    echo of that wrapper folder so it sits directly next to "ExportedProject":
    echo.
    echo   AssetRipper_export_.../
    echo   +-- ExportedProject/
    echo   +-- YeepsMapLoaderSetup/   ^<- must be here, not nested deeper
    echo.
    pause
    exit /b 1
)

echo Copying script files into Assets\Scripts\Editor ...
if not exist "%PROJECT_DIR%\Assets\Scripts\Editor" mkdir "%PROJECT_DIR%\Assets\Scripts\Editor"
copy /y "%SCRIPT_DIR%YeepsMapLoader.cs" "%PROJECT_DIR%\Assets\Scripts\Editor\" >nul
copy /y "%SCRIPT_DIR%YeepsMapLoaderData.cs" "%PROJECT_DIR%\Assets\Scripts\Editor\" >nul

echo Updating Packages\manifest.json ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install_packages.ps1" -ProjectPath "%PROJECT_DIR%"

echo.
echo Done. Open the project in Unity, wait for it to finish importing/compiling,
echo then go to Window ^> TextMeshPro ^> Import TMP Essential Resources.
echo The tool is under Yeeps ^> Map Loader once that's done.
pause
