@echo off
REM Build script optimizado para reducir falsos positivos de antivirus
REM Default to Release if no argument is provided
SET CONFIG=Release
IF NOT "%1"=="" (
    IF /I "%1"=="debug" SET CONFIG=Debug
)

echo Building AndroidSideloader in %CONFIG% configuration with security optimizations...

REM Limpiar archivos temporales que pueden causar problemas
echo Cleaning temporary files...
if exist "bin" rmdir /s /q "bin" 2>nul
if exist "obj" rmdir /s /q "obj" 2>nul
if exist "C:\Sideloader" rmdir /s /q "C:\Sideloader" 2>nul

REM Buscar MSBuild
IF EXIST "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    SET MSBUILD="C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
) ELSE IF EXIST "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe" (
    SET MSBUILD="C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
) ELSE IF EXIST "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe" (
    SET MSBUILD="C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
) ELSE (
    echo MSBuild not found! Please check your Visual Studio installation.
    exit /b 1
)

REM Restaurar paquetes NuGet primero
echo Restoring NuGet packages...
%MSBUILD% AndroidSideloader.sln /t:restore /p:RestorePackagesConfig=true /p:Configuration=%CONFIG% /verbosity:minimal

REM Build con configuraciones optimizadas
echo Building solution...
%MSBUILD% AndroidSideloader.sln /t:AndroidSideloader /p:Configuration=%CONFIG% /p:Platform="Any CPU" /verbosity:minimal

REM Verificar que el build fue exitoso
if exist "bin\%CONFIG%\AndroidSideloader.exe" (
    echo.
    echo ✅ Build completed successfully!
    echo 📁 Output: bin\%CONFIG%\AndroidSideloader.exe
    echo 📊 File size: 
    dir "bin\%CONFIG%\AndroidSideloader.exe" | findstr AndroidSideloader.exe
    echo.
    echo 🛡️  Remember to add Windows Defender exceptions for this directory if needed.
    echo    Run: AddDefenderExceptions.ps1 as Administrator
) else (
    echo.
    echo ❌ Build failed! Please check the error messages above.
    exit /b 1
)
