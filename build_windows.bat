@echo off
set /p updatesPopup=?:Enable updates popup? [y/N]:
if /I "%updatesPopup%"=="y" goto buildPopups
goto buildNoPopups

:buildPopups
flutter --no-version-check --suppress-analytics build windows
exit
:buildNoPopups
flutter --no-version-check --suppress-analytics build windows --dart-define=UPDATES_POPUP_ENABLED=false
exit
