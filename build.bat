@echo off
setlocal
echo Building the game...
lime build hl
echo Done!
:PROMPT
set /P ays=Would you like to clean up the bin folder (Y/[N])? 
if /I "%ays%" NEQ "Y" (
echo Skipping the cleanup...
) else (
echo Cleaning up the bin folder...
haxe --run Postbuild.hx --cleanup
echo Done cleaning up!
)
:END
endlocal
pause