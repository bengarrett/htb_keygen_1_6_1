;
;HTBTEAM KEYGENERATOR 1.6
;Coder: Czajnick
;
;-----------------------------------------------------------------------------------------
;INSTRUCTIONS:
;1. Change AppName variable to your program name.
;2. In this file, find "place code here" and write your code there. Entered name is in
;   BufName, you must place serial in BufSerial
;3. Recompile the project using MakeIt.bat.
;
;4. If you don't like the music, use bin2db and change the file kg_xm.asm. Don't forget
;   to place valid XM size in KG_XM_LENGTH constant.
;5. If you don't like the icon, replace icon.ico.
;
;6. Use FSG to compress EXE file.
;-----------------------------------------------------------------------------------------

m2m MACRO M1, M2
    push M2
    pop  M1
ENDM

.386
.model flat, stdcall
option casemap :none

include    \masm32\include\windows.inc
include    \masm32\include\user32.inc
include    \masm32\include\kernel32.inc
include    \masm32\include\gdi32.inc
include    jpeglib.inc
include    minifmod\minifmod.inc
include    kg_xm.asm
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
includelib jpeglib.lib
includelib minifmod\minifmod.lib

DlgProc         PROTO :DWORD,:DWORD,:DWORD,:DWORD
DlgProc2        PROTO :DWORD,:DWORD,:DWORD,:DWORD
PrzyciskProc    PROTO :DWORD,:DWORD,:DWORD,:DWORD
Paint_Proc      PROTO :DWORD,:DWORD,:DWORD
Scroll_It       PROTO :DWORD
GenerateObsluga PROTO :DWORD

.const
EDT_NAME       EQU 11
EDT_NAME_TOP   EQU 57
EDT_SERIAL     EQU 12
EDT_SERIAL_TOP EQU 98
EDT_LEFT       EQU 20
EDT_HEIGHT     EQU 20
EDT_WIDTH      EQU 273
RAMKA_TOP      EQU 26
RAMKA_LEFT     EQU 8
RAMKA_WIDTH    EQU 294
RAMKA_HEIGHT   EQU 101
EDT_INFO       EQU 14
BTN_INFO       EQU 3
IDC_TIMER      EQU 15
BTN1_LEFT      EQU 8   ;pozycja napisu wewnatrz przycisku Generate
BTN2_LEFT      EQU 26  ;pozycja napisu wewnatrz przycisku Info
BTN3_LEFT      EQU 29  ;pozycja napisu wewnatrz przycisku Exit
BTN1_LFT       EQU 14
BTN2_LFT       EQU 113
BTN3_LFT       EQU 212
BTN_TOP        EQU 138
BTN_WIDTH      EQU 87
BTN_HEIGHT     EQU 21
IDD_BACKGROUND EQU 201
WND_WIDTH      EQU 312
WND_HEIGHT     EQU 191

.data
AppName      db "SomeApplication v. 1.50",0

ScrollText   db "HTBTeam Keygenerator ",0  ;to jest jednoczesnie ClassName
Btn1Txt      db "Generate",0
Btn2Txt      db "Info",0
Btn3Txt      db "Exit",0
Plik         db "Htbteam.nfo",0
Courier      db "Courier New",0
Verdana      db "Verdana",0
Terminal     db "Terminal",0
SansSerif    db "MS Sans Serif",0
Display      db "DISPLAY",0
Button       db "BUTTON",0
Edit         db "EDIT",0
Static       db "STATIC",0
Nazwa        db "Name:",0
Serial       db "Serial:",0

.data?
hSansSerif   dd ?
hTerminal    dd ?
hEditName    dd ?
hEditSerial  dd ?
ptrbitPuste  dd ?
WND_LEFT     dd ?
WND_TOP      dd ?
hdcDisplay   dd ?
bmpDisplay   dd ?
ThreadEnd    db ?
ThreadActive db ?
KeyDown      db ?
hPrzycisk    dd ?
hwnd         dd ?
hPedzel      dd ?
hMem         dd ?
hPen         dd ?
hLightPen    dd ?
hVerdana     dd ?
hFile        dd ?
Temp         dd ?
hInstance    dd ?
hGenerate    dd ?
hInfo        dd ?
hExit        dd ?
BufName      db 100 dup (?)
BufSerial    db 100 dup (?)
ThreadID     dd ?
lMouseX0     dd ?
lMouseY0     dd ?
rect         RECT <?>
ps           PAINTSTRUCT <>
PusteDC      dd ?
Painted      db ?
bmi              BITMAPINFO <>
BMStruct         JPEG_STRUCTURE <>

.code
start:
  invoke GetModuleHandle,0
  mov    hInstance,eax
      
  invoke Res2BMP,eax,IDD_BACKGROUND,addr BMStruct
  push   esi
  push   edi
  xor    edi,edi
  invoke CreateSolidBrush,edi;000000h
  mov    hPedzel,eax
  invoke CreatePen,PS_SOLID,edi,0008000h
  mov    hPen,eax
  invoke CreatePen,PS_SOLID,edi,000FF00h
  mov    hLightPen,eax
  invoke CreateFont,16,8,edi,edi,FW_BOLD,edi,edi,edi,DEFAULT_CHARSET,edi,edi,edi,edi,addr Verdana
  mov    hVerdana,eax
  invoke CreateFont,12,6,edi,edi,FW_NORMAL,edi,edi,edi,DEFAULT_CHARSET,edi,edi,edi,edi,addr Terminal
  mov    hTerminal,eax
  invoke CreateFont,14,7,edi,edi,FW_NORMAL,edi,edi,edi,DEFAULT_CHARSET,edi,edi,edi,edi,addr SansSerif
  mov    hSansSerif,eax

  ;OBLICZANIE POZYCJI WND_LEFT I WND_TOP TAKICH, ABY OKNO BYLO NA SRODKU EKRANU  
  invoke GetSystemMetrics,SM_CXSCREEN
  shr    eax,1
  mov    ecx,WND_WIDTH
  shr    ecx,1
  sub    eax,ecx
  mov    WND_LEFT,eax
  invoke GetSystemMetrics,SM_CYSCREEN
  shr    eax,1
  mov    ecx,WND_HEIGHT
  shr    ecx,1
  sub    eax,ecx
  mov    WND_TOP,eax

  ;POBIERANIE KAWALKA EKRANU KTORY JEST POD OKNEM
  invoke CreateDC,addr Display,edi,edi,edi
  mov    esi,eax
  invoke CreateCompatibleDC,eax
  mov    hdcDisplay,eax
  mov    edi,eax
  invoke CreateBitmap,WND_WIDTH,WND_HEIGHT,1,32,0
  invoke SelectObject,edi,eax
  invoke BitBlt,edi,0,0,WND_WIDTH,WND_HEIGHT,esi,WND_LEFT,WND_TOP,SRCCOPY
  invoke DeleteDC,esi
  pop    edi
  pop    esi
  
  call   WinMain

  invoke Kill_JPEG,addr BMStruct
  invoke ExitProcess,eax

WinMain proc uses edi
        LOCAL wc   :WNDCLASSEX
        LOCAL msg  :MSG

        xor    eax,eax
        mov    wc.cbSize,      sizeof WNDCLASSEX
        mov    wc.style,       CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNWINDOW
        mov    wc.lpfnWndProc,    offset WndProc
        mov    wc.cbClsExtra,     eax
        mov    wc.cbWndExtra,     eax
        m2m    wc.hInstance,      hInstance
        mov    wc.hbrBackground,  eax
        mov    wc.lpszMenuName,   eax
        mov    wc.lpszClassName,  offset ScrollText
        mov    wc.hIcon,          eax
        mov    wc.hIconSm,        eax
        invoke LoadCursor,eax,IDC_ARROW
        mov    wc.hCursor,        eax
        invoke RegisterClassEx,addr wc

        invoke CreateWindowEx,WS_EX_TOPMOST,addr ScrollText,addr AppName,\
               WS_VISIBLE or WS_POPUP,WND_LEFT,WND_TOP,WND_WIDTH,WND_HEIGHT,0,0,hInstance,0
        mov    hwnd,eax

        lea    edi,msg
        StartLoop:
        invoke GetMessage,edi,0,0,0
        test   eax,eax
        jz     ExitLoop
        invoke TranslateMessage,edi
        invoke DispatchMessage,edi
        jmp    StartLoop
        ExitLoop:
        
        ret
WinMain endp

WndProc proc uses esi edi ebx hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
      LOCAL hdcOkno:DWORD

      mov   eax,uMsg
      mov   esi,hWnd
      mov   edi,lParam
      mov   ebx,wParam
      
      .IF eax==WM_CREATE
            invoke CreateRoundRectRgn,0,0,WND_WIDTH+1,WND_HEIGHT+1,48,48
            invoke SetWindowRgn,esi,eax,0
            
            invoke mfmPlay,offset muzax
      .ELSEIF eax==WM_DESTROY
            ;jmp    _total_wypad
            invoke SendMessage,hExit,WM_LBUTTONUP,0,0
      .ELSEIF eax==WM_MOUSEMOVE
            mov    ThreadEnd,1
            .IF KeyDown == TRUE
                invoke GetWindowRect,esi,addr rect
                movzx  ecx,di
                sub    ecx,lMouseX0
                add    ecx,rect.left
                shr    edi,16
                sub    edi,lMouseY0
                add    edi,rect.top
                cdq
                invoke SetWindowPos,esi,edx,ecx,edi,edx,edx,SWP_NOZORDER or SWP_NOSIZE
             .ENDIF
      .ELSEIF eax==WM_LBUTTONDOWN
             cmp    Painted,1
             jne    @f
             movzx  ecx,di
             shr    edi,16
             mov    lMouseY0,edi
             mov    lMouseX0,ecx
             mov    KeyDown,1
             invoke SetCapture,esi
             @@:
      .ELSEIF eax==WM_LBUTTONUP
            mov    KeyDown,0
            invoke ReleaseCapture
      .ELSEIF eax==WM_PAINT
         .if   Painted==0
            invoke BeginPaint,esi,addr ps
            mov    hdcOkno,eax
            invoke CreateCompatibleDC,eax
            mov    PusteDC,eax
            mov    edi,eax
            invoke CreateCompatibleBitmap,hdcDisplay,WND_WIDTH,WND_HEIGHT
            mov    bmpDisplay,eax

            lea    esi,bmi
            assume esi:ptr BITMAPINFO
            cdq
            mov    [esi].bmiHeader.biSize,sizeof BITMAPINFOHEADER
            mov    [esi].bmiHeader.biWidth,320
            mov    [esi].bmiHeader.biHeight,(not WND_HEIGHT)
            mov    [esi].bmiHeader.biPlanes,1
            mov    [esi].bmiHeader.biBitCount,32
            mov    [esi].bmiHeader.biCompression,BI_RGB
            mov    [esi].bmiHeader.biSizeImage,edx
            mov    [esi].bmiHeader.biXPelsPerMeter,edx
            mov    [esi].bmiHeader.biYPelsPerMeter,edx
            mov    [esi].bmiHeader.biClrUsed,edx
            mov    [esi].bmiHeader.biClrImportant,edx
            mov    [esi].bmiColors,edx
            assume esi:nothing
            invoke CreateDIBSection,edi,esi,edx,addr ptrbitPuste,edx,edx
            invoke SelectObject,edi,eax
            cdq
            invoke BitBlt,edi,edx,edx,WND_WIDTH,WND_HEIGHT,hdcDisplay,edx,edx,SRCCOPY

            mov    esi,255    ;ilosc powtorzen petli
            home:
            mov    ebx,BMStruct.lpBitMap
            mov    edx,ptrbitPuste
            mov    edi,320*191*4
            @@:
            mov    eax,[ebx+edi]
            mov    ecx,[edx+edi]

            shr    eax,16
            shr    ecx,16
            .if    al<235
            add    al,20
            .endif
            .if    cl<al;cl!=al
            inc    cl
            .elseif cl>al
            dec    cl
            .endif
            shl    ecx,16
            mov    ax,word ptr [ebx+edi]
            mov    cx,word ptr [edx+edi]
            .if    ch<ah;ch!=ah
            inc    ch
            .elseif ch>ah
            dec    ch
            .endif
            .if    cl<al;cl!=al
            inc    cl
            .elseif cl>al
            dec    cl
            .endif

            mov    [edx+edi],ecx
            sub    edi,4
            jnz    @B

            cdq
            invoke BitBlt,hdcOkno,edx,edx,312,191,PusteDC,edx,edx,SRCCOPY
            invoke Sleep,3
            dec    esi
            jnz    home

            invoke DeleteDC,hdcDisplay
            invoke EndPaint,hWnd,addr ps

            call   TworzObiekty
            xor    eax,eax
            invoke CreateThread,eax,eax,addr Scroll_It,eax,eax,addr ThreadID
            mov    Painted,1
            
          .else
            invoke BeginPaint,esi,addr ps
            cdq
            invoke BitBlt,eax,edx,edx,312,191,PusteDC,edx,edx,SRCCOPY
            invoke EndPaint,esi,addr ps
          .endif
            xor    eax,eax
      .ELSEIF  (eax==WM_CTLCOLORSTATIC) || (eax==WM_CTLCOLOREDIT)
            invoke SetBkColor,ebx,0h
            invoke SetTextColor,ebx,00FF00h
            mov    eax,hPedzel
            ret
        .ELSE
                invoke DefWindowProc,esi,eax,ebx,edi
                ret
        .ENDIF
        xor eax,eax
        ret
WndProc endp

DlgProc2 proc uses edi esi hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
      mov    edi,hWnd
      invoke GetDlgItem,edi,EDT_INFO
      mov    esi,eax
      mov    eax,uMsg
        .IF (eax==WM_CLOSE) || (eax==WM_HOTKEY)
            koniec_dlg2a:
            invoke UnregisterHotKey,edi,0
            invoke KillTimer,edi,IDC_TIMER
            koniec_dlg2:
            invoke EndDialog,edi,0
            xor    eax,eax
      .ELSEIF eax==WM_TIMER
            invoke SendMessage,esi,EM_SCROLL,SB_LINEDOWN,0
      .ELSEIF eax==WM_INITDIALOG
            invoke SendMessage,esi,WM_SETFONT,hTerminal,0
            cdq
            invoke CreateFile,addr Plik,GENERIC_READ,edx,edx,OPEN_EXISTING,edx,edx
            mov    hFile,eax
            inc    eax
            jz     koniec_dlg2
            invoke GetFileSize,eax,0
            push   eax
            invoke GlobalAlloc,GMEM_FIXED,eax
            mov    hMem,eax
            pop    ecx
            invoke ReadFile,hFile,eax,ecx,addr Temp,0
            invoke SetWindowText,esi,hMem
            invoke CloseHandle,hFile
            invoke GlobalFree,hMem
            invoke SetTimer,edi,IDC_TIMER,200,0
            invoke RegisterHotKey,edi,0,0,VK_ESCAPE
            invoke GetWindowLong,esi,GWL_STYLE
            or     eax,WS_DISABLED
            invoke SetWindowLong,esi,GWL_STYLE,eax
      .ELSEIF eax==WM_CTLCOLOREDIT
            invoke SetBkColor,wParam,0h
            invoke SetTextColor,wParam,008000h
            mov    eax,hPedzel
      .ELSE
            xor eax,eax
        .ENDIF
        ret
DlgProc2 endp

PrzyciskProc proc uses edi esi hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
      mov   eax,uMsg
      mov   esi,hWnd
      .IF eax==WM_PAINT
          invoke BeginPaint,esi,addr ps
          mov    edi,eax
          invoke SelectObject,edi,hPen
          invoke SelectObject,edi,hPedzel
          invoke RoundRect,edi,0,0,87,21,5,5
          invoke SelectObject,edi,hVerdana
          invoke SetBkColor,edi,0
          invoke SetTextColor,edi,0808000h
          call   UstawPrzycisk
          movzx  edx,ah
          push   ecx
          push   edx
          invoke lstrlen,ecx
          pop    edx
          pop    ecx
          invoke TextOut,edi,edx,2,ecx,eax
          invoke EndPaint,esi,addr ps
      .elseif eax==WM_LBUTTONUP
          .if    esi==hGenerate
                 invoke GetWindowText,hEditName,addr BufName,sizeof BufName

                 ;place code here

                 invoke SetWindowText,hEditSerial,addr BufSerial
          .elseif esi==hInfo
                 invoke DialogBoxParam,hInstance,101,hwnd,addr DlgProc2,0
          .else
                 invoke mfmPlay,0
                 invoke DeleteDC,PusteDC
                 invoke PostQuitMessage,eax
          .endif
      .elseif eax==WM_MOUSEMOVE
          cmp    esi,hPrzycisk
          je     @F
          mov    ThreadEnd,1
          @@:
          .if    ThreadActive==0
                 mov    hPrzycisk,esi
                 call   UstawPrzycisk
                 mov    ThreadEnd,0
                 mov    ThreadActive,ah
                 invoke CreateThread,0,0,addr GenerateObsluga,ecx,0,addr ThreadID
          .endif
      .else
          invoke DefWindowProc,esi,eax,wParam,lParam
          ret
      .endif
      xor   eax,eax
      ret
PrzyciskProc endp

Scroll_It PROC uses edi esi ebx smiec:DWORD
 ;edi - hdc2 w ktorym przygotowuje grafe do wyswietlenia (edi)
 ;esi - xpos - aktualna pozycja tesktu
 ;ebx - hdc - hdc okna

 invoke GetDC,hwnd
 mov    ebx,eax
 invoke CreateCompatibleBitmap,eax,312,17
 push   eax

 invoke CreateCompatibleDC,ebx
 mov    edi,eax
 pop    ecx
 invoke SelectObject,eax,ecx
 invoke SetTextColor,edi,000FFFFh
 invoke SetBkMode,edi,TRANSPARENT;1
 cdq
 invoke CreateFont,edx,10,edx,edx,FW_ULTRABOLD,TRUE,edx,edx,DEFAULT_CHARSET,\
        edx,edx,edx,edx,addr Courier
 invoke SelectObject,edi,eax

Petla0:
 mov    esi,312

Petla:
 cdq
 invoke BitBlt,edi,edx,edx,312,17,PusteDC,edx,edx,SRCCOPY
 invoke TextOut,edi,esi,0,ADDR ScrollText,sizeof ScrollText-1
 cdq
 invoke BitBlt,ebx,edx,edx,312,17,edi,edx,edx,SRCCOPY
 invoke Sleep,15
 dec    esi
 cmp    esi,-312
 jnz    Petla
 jmp    Petla0
Scroll_It  endp

GenerateObsluga proc uses edi esi ebx smiec:DWORD
 invoke GetDC,hPrzycisk
 mov    edi,eax
 invoke SetBkMode,edi,1
 invoke SelectObject,edi,hVerdana
 invoke SelectObject,edi,hLightPen
 invoke SelectObject,edi,hPedzel
 invoke RoundRect,edi,0,0,87,21,5,5

 xor    esi,esi
 mov    bl,80h
 inc    si
 gen_pocz:
 .if    si==0
        dec    bl
        cmp    bl,80h
        ja     @F
        mov    si,1
 .else
        inc    bl
        cmp    bl,253
        jb     @F
        mov    si,0
 .endif
 @@:
 xor    eax,eax
 mov    ah,bl
 shl    eax,8
 mov    ah,bl
 invoke SetTextColor,edi,eax
 invoke lstrlen,smiec
 movzx  ecx,ThreadActive
 invoke TextOut,edi,ecx,2,smiec,eax
 invoke Sleep,3
 
 cmp    ThreadEnd,1
 jne    gen_pocz

 invoke SelectObject,edi,hPen
 invoke RoundRect,edi,0,0,87,21,5,5
 invoke SetTextColor,edi,0808000h
 invoke lstrlen,smiec
 movzx  ecx,ThreadActive
 invoke TextOut,edi,ecx,2,smiec,eax
 invoke ReleaseDC,hGenerate,edi
 mov    ThreadActive,0
 invoke ExitThread,0
 ret
GenerateObsluga endp

UstawPrzycisk proc
 .if    esi==hGenerate
    mov  ecx,offset Btn1Txt
    mov  ah,BTN1_LEFT
 .elseif esi==hInfo
    mov  ecx,offset Btn2Txt
    mov  ah,BTN2_LEFT
 .else
    mov  ecx,offset Btn3Txt
    mov  ah,BTN3_LEFT
 .endif
 ret
UstawPrzycisk endp

TworzObiekty proc
  mov    esi,BTN1_LFT
  lea    edi,hGenerate
  mov    ebx,offset TworzPrzycisk
  call   ebx
  call   ebx
  call   ebx
  mov    esi,hInstance
  mov    edi,hwnd
  invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr Edit,0,WS_CHILD or WS_VISIBLE or ES_CENTER or ES_AUTOHSCROLL,EDT_LEFT,EDT_NAME_TOP,EDT_WIDTH,EDT_HEIGHT,edi,4,esi,0
  mov    hEditName,eax
  call   WybierzCzcionke
  invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr Edit,0,ES_READONLY or WS_CHILD or WS_VISIBLE or ES_CENTER or ES_AUTOHSCROLL,EDT_LEFT,EDT_SERIAL_TOP,EDT_WIDTH,EDT_HEIGHT,edi,5,esi,0
  mov    hEditSerial,eax
  call   WybierzCzcionke
  invoke CreateWindowEx,0,addr Button,addr AppName,WS_CHILD or WS_VISIBLE or BS_GROUPBOX or BS_CENTER,RAMKA_LEFT,RAMKA_TOP,RAMKA_WIDTH,RAMKA_HEIGHT,edi,6,esi,0
  call   WybierzCzcionke
  invoke CreateWindowEx,0,addr Static,addr Serial,WS_CHILD or WS_VISIBLE,18,83,30,13,edi,6,esi,0
  call   WybierzCzcionke
  invoke CreateWindowEx,0,addr Static,addr Nazwa,WS_CHILD or WS_VISIBLE,18,42,33,13,edi,6,esi,0
  call   WybierzCzcionke
  ret
TworzObiekty endp

TworzPrzycisk proc
  invoke CreateWindowEx,0,addr Button,0,WS_CHILD or WS_VISIBLE or BS_OWNERDRAW,esi,BTN_TOP,BTN_WIDTH,BTN_HEIGHT,hwnd,esi,hInstance,0
  mov    [edi],eax
  add    edi,4
  add    esi,99
  invoke SetWindowLong,eax,GWL_WNDPROC,offset PrzyciskProc
  ret
TworzPrzycisk endp

WybierzCzcionke proc
  invoke SendMessage,eax,WM_SETFONT,hSansSerif,TRUE
  ret
WybierzCzcionke endp

end start