@echo off
chcp 65001 >nul
setlocal ENABLEDELAYEDEXPANSION

:mainmenu
cls

echo ===============================
echo  Simple Tweak and Repair Toolkit
echo ===============================
echo.
echo 1. System File and Disk Repair
echo 2. Network Repairs
echo 3. Windows Update Repairs
echo 4. Windows Software Removal
echo 5. Miscellaneous Tweaks
echo 6. Exit
echo.
set /p choice=Select a group (1-6): 
if "%choice%"=="1" goto group1
if "%choice%"=="2" goto group2
if "%choice%"=="3" goto group3
if "%choice%"=="4" goto groupwsr
if "%choice%"=="5" goto group4
if "%choice%"=="6" exit

goto mainmenu

:group1
cls
echo --- System File and Disk Repair ---
echo 1. Run System File Checker (sfc /scannow)
echo 2. Run DISM Health Restore
echo 3. Check Disk (chkdsk)
echo 4. Run ALL in group
echo 5. Back
echo.
set /p g1choice=Select option (1-5): 
if "%g1choice%"=="1" sfc /scannow & echo Done, please press any button to return! & pause >nul & goto group1
if "%g1choice%"=="2" DISM /Online /Cleanup-Image /RestoreHealth & echo Done, please press any button to return! & pause >nul & goto group1
if "%g1choice%"=="3" chkdsk C: /F /R & echo Done, please press any button to return! & pause >nul & goto group1
if "%g1choice%"=="4" (
    sfc /scannow
    DISM /Online /Cleanup-Image /RestoreHealth
    chkdsk C: /F /R
    echo Done, please press any button to return!
    pause >nul
    goto group1
)
if "%g1choice%"=="5" goto mainmenu
goto group1

:group2
cls
echo --- Network Repairs ---
echo 1. Reset TCP/IP Stack
echo 2. Flush DNS Cache
echo 3. Release and Renew IP
echo 4. Reset Network Adapters (requires PowerShell)
echo 5. Run ALL in group
echo 6. Back
echo.
set /p g2choice=Select option (1-6): 
if "%g2choice%"=="1" (
    netsh int ip reset
    echo A restart is required for changes to take effect.
    goto group2
)
if "%g2choice%"=="2" ipconfig /flushdns & echo Done, please press any button to return! & pause >nul & goto group2
if "%g2choice%"=="3" ipconfig /release & ipconfig /renew & echo Done, please press any button to return! & pause >nul & goto group2
if "%g2choice%"=="4" powershell -Command "Get-NetAdapter | Restart-NetAdapter -Confirm:$false" & echo Done, please press any button to return! & pause >nul & goto group2
if "%g2choice%"=="5" (
    netsh int ip reset
    echo A restart is required for changes to take effect.
    ipconfig /flushdns
    ipconfig /release & ipconfig /renew
    powershell -Command "Get-NetAdapter | Restart-NetAdapter -Confirm:$false"
    echo Done, please press any button to return!
    pause >nul
    goto group2
)
REM End of multi-line if block for 2.5
if "%g2choice%"=="6" goto mainmenu
goto group2

:group3
cls
echo --- Windows Update Repairs ---
echo 1. Restart Windows Update Service
echo 2. Clear Windows Update Cache
echo 3. Re-register Windows Update DLLs
echo 4. Reset Windows Update Components
echo 5. Run ALL in group
echo 6. Back
echo.
set /p g3choice=Select option (1-6): 
if "%g3choice%"=="1" net stop wuauserv & net start wuauserv & echo Done, please press any button to return! & pause >nul & goto group3
if "%g3choice%"=="2" net stop wuauserv & del /q /s C:\Windows\SoftwareDistribution\Download\* & net start wuauserv & echo Done, please press any button to return! & pause >nul & goto group3
if "%g3choice%"=="3" call :registerdlls & echo Done, please press any button to return! & pause >nul & goto group3
if "%g3choice%"=="4" call :resetwu & echo Done, please press any button to return! & pause >nul & goto group3
if "%g3choice%"=="5" (
    net stop wuauserv & net start wuauserv
    net stop wuauserv & del /q /s C:\Windows\SoftwareDistribution\Download\* & net start wuauserv
    call :registerdlls
    call :resetwu
    echo Done, please press any button to return!
    pause >nul
    goto group3
)
if "%g3choice%"=="6" goto mainmenu
goto group3


:groupwsr
cls
echo --- Windows Software Removal ---
echo 1. Disable/Remove OneDrive
echo 2. Disable/Remove Xbox Game Bar and Xbox apps
echo 3. Disable/Remove 'Your Phone'
echo 4. Back
echo.
set /p gwsrchoice=Select option (1-4): 
if "%gwsrchoice%"=="1" call :remove_onedrive & echo Done, please press any button to return! & pause >nul & goto groupwsr
if "%gwsrchoice%"=="2" call :remove_xbox & echo Done, please press any button to return! & pause >nul & goto groupwsr
if "%gwsrchoice%"=="3" call :remove_yourphone & echo Done, please press any button to return! & pause >nul & goto groupwsr
if "%gwsrchoice%"=="4" goto mainmenu
goto groupwsr

:group4
cls
echo --- Miscellaneous Tweaks ---
echo 1. Clear Temp Files
echo 2. Open Disk Cleanup
echo 3. Restart Explorer

echo 5. Open Event Viewer
echo 6. Open Device Manager
echo 7. Optimize Drives (Defrag/Trim, requires PowerShell)
echo 8. Back
echo.
set /p g4choice=Select option (1-8): 
if "%g4choice%"=="1" del /q /s "%TEMP%\*" & echo Done, please press any button to return! & pause >nul & goto group4
if "%g4choice%"=="2" cleanmgr & goto group4
if "%g4choice%"=="3" taskkill /f /im explorer.exe & start explorer.exe & echo Done, please press any button to return! & pause >nul & goto group4

if "%g4choice%"=="5" eventvwr & goto group4
if "%g4choice%"=="6" devmgmt.msc & goto group4
if "%g4choice%"=="7" powershell -Command "Optimize-Volume -DriveLetter C -ReTrim -Verbose" & echo Done, please press any button to return! & pause >nul & goto group4
if "%g4choice%"=="8" goto mainmenu
goto group4

goto :eof

REM --- Windows Software Removal Scripts ---
:remove_onedrive
REM Uninstall OneDrive (Windows 10/11)
if exist "%SystemRoot%\System32\OneDriveSetup.exe" (
    %SystemRoot%\System32\OneDriveSetup.exe /uninstall
)
reg delete "HKCU\Software\Microsoft\OneDrive" /f >nul 2>&1
reg delete "HKLM\Software\Microsoft\OneDrive" /f >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\OneDrive" /f >nul 2>&1
rd "%UserProfile%\OneDrive" /Q /S >nul 2>&1
exit /b

:remove_xbox
REM Remove Xbox Game Bar and Xbox related apps
powershell -Command "Get-AppxPackage *Xbox* | Remove-AppxPackage"
powershell -Command "Get-AppxPackage *GamingApp* | Remove-AppxPackage"
powershell -Command "Get-AppxPackage *Microsoft.XboxGameOverlay* | Remove-AppxPackage"
powershell -Command "Get-AppxPackage *Microsoft.XboxIdentityProvider* | Remove-AppxPackage"
powershell -Command "Get-AppxPackage *Microsoft.XboxSpeechToTextOverlay* | Remove-AppxPackage"
powershell -Command "Get-AppxPackage *Microsoft.Xbox.TCUI* | Remove-AppxPackage"
powershell -Command "Get-AppxPackage *Microsoft.GamingApp* | Remove-AppxPackage"
exit /b

:remove_yourphone
REM Remove 'Your Phone' app
powershell -Command "Get-AppxPackage *Microsoft.YourPhone* | Remove-AppxPackage"
exit /b

REM --- Helper for registering DLLs ---
:registerdlls
for %%d in (atl.dll urlmon.dll mshtml.dll shdocvw.dll browseui.dll jscript.dll vbscript.dll scrrun.dll msxml.dll msxml3.dll msxml6.dll actxprxy.dll softpub.dll wintrust.dll dssenh.dll rsaenh.dll gpkcsp.dll sccbase.dll slbcsp.dll cryptdlg.dll oleaut32.dll ole32.dll shell32.dll initpki.dll wuapi.dll wuaueng.dll wuaueng1.dll wucltui.dll wups.dll wups2.dll wuweb.dll qmgr.dll qmgrprxy.dll wucltux.dll muweb.dll wuwebv.dll) do regsvr32 /s %%d
exit /b

REM --- Helper for resetting Windows Update ---
:resetwu
net stop wuauserv
net stop cryptSvc
net stop bits
net stop msiserver
ren C:\Windows\SoftwareDistribution SoftwareDistribution.old
ren C:\Windows\System32\catroot2 catroot2.old
net start wuauserv
net start cryptSvc
net start bits
net start msiserver
exit /b
