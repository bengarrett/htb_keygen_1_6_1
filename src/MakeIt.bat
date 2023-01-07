@echo off
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /nologo /machine:ix86 rsrc.res

if exist HTB_Keygen.obj del HTB_Keygen.obj
if exist HTB_Keygen.exe del HTB_Keygen.exe

\masm32\bin\ml /c /coff /nologo HTB_Keygen.asm
if errorlevel 1 goto errasm

\masm32\bin\Link /nologo /SUBSYSTEM:WINDOWS HTB_Keygen.obj rsrc.obj
if errorlevel 1 goto errlink

goto TheEnd

:errlink
pause
goto finito

:errasm
pause
goto finito

:TheEnd
del *.obj
del *.res
:finito