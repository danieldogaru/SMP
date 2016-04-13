; Ionut-Daniel DOGARU
; Grupa 333 AA
; Dezvoltat utilizand MASM32
; Aprilie 2016

; Am folosit apeluri de functii din WIN32 API
; Nu am comentat secvente repetititve

.386 ; Arhitectura Intel 
.model flat, stdcall, C
option casemap:none

include e:\masm32\include\kernel32.inc
includelib e:\masm32\lib\kernel32.lib

include e:\masm32\include\windows.inc

include e:\masm32\include\user32.inc
includelib e:\masm32\lib\user32.lib

;librarii pentru grafica: line, elipse etc.
include e:\masm32\include\gdi32.inc
includelib e:\masm32\lib\gdi32.lib

;include e:\masm32\include\masm32rt.inc

RGB MACRO red, green, blue
    EXITM % blue SHL 16 + green SHL 8 + red
ENDM

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

.DATA ; variabile initializate
	ClassName db "SimpleWinClass", 0
	AppName   db "Tema SMP", 0	;Titlul ferestrei
	OurText   db "Win32 assembly is great and easy!", 0
	mUnit	  DWORD 40 ; unitatea de masura - in acest caz, echivalentul pentru un centimetru
					; necesar pentru scalare

	refX DWORD 20  ; referinta pe axa X
	refY DWORD 500 ; referinta pe axa Y


.DATA? ;variabile neinitializate
	hInstance HINSTANCE ?
	lastX DWORD ?
	lastY DWORD ?

.CODE
	start:
		invoke GetModuleHandle, NULL ; obtinerea handlerului
		mov hInstance, eax
		invoke WinMain, hInstance, NULL, NULL, SW_SHOWDEFAULT
		invoke ExitProcess, eax
		
		; procedura standard pentru crearea ferestrei de tip Windows OS
		WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, \
		CmdLine:LPSTR, CmdShow:DWORD
			LOCAL wc:WNDCLASSEX
			LOCAL msg:MSG
			LOCAL hwnd:HWND
			mov wc.cbSize, SIZEOF WNDCLASSEX
			mov wc.style, CS_HREDRAW or CS_VREDRAW
			mov wc.lpfnWndProc, OFFSET WndProc
			mov wc.cbClsExtra,NULL
			mov wc.cbWndExtra,NULL
			push hInstance
			pop wc.hInstance
			mov wc.hbrBackground, COLOR_WINDOW+1
			mov wc.lpszMenuName, NULL
			mov wc.lpszClassName, OFFSET ClassName
			invoke LoadIcon, NULL, IDI_APPLICATION
			mov wc.hIcon, eax
			mov wc.hIconSm, eax

			invoke LoadCursor, NULL, IDC_ARROW
			mov wc.hCursor, eax
			invoke RegisterClassEx, addr wc
			invoke CreateWindowEx, NULL,\
			ADDR ClassName,\
			ADDR AppName,\
			WS_OVERLAPPEDWINDOW,\
			CW_USEDEFAULT,\
			CW_USEDEFAULT,\
			CW_USEDEFAULT,\
			CW_USEDEFAULT,\
			NULL,\
			NULL,\
			hInst,\
			NULL
			mov hwnd, eax
			invoke ShowWindow, hwnd,CmdShow
			invoke UpdateWindow, hwnd
			.WHILE TRUE
			invoke GetMessage, ADDR msg, NULL, 0, 0
			.BREAK .IF (!eax)
			invoke TranslateMessage, ADDR msg
			invoke DispatchMessage, ADDR msg
			.ENDW
			mov eax, msg.wParam
			ret
	    WinMain endp

		WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
			LOCAL hdc:HDC
			LOCAL ps:PAINTSTRUCT
			LOCAL pen:DWORD
			

			.IF uMsg == WM_DESTROY
				invoke PostQuitMessage, NULL

			.ELSEIF uMsg == WM_PAINT
				invoke BeginPaint, hWnd, ADDR ps

				;invoke CreatePen, PS_SOLID, 3, RGB(255, 0, 0) ; Rosu
				;mov    pen, eax
				mov hdc, eax
				
				; segmentul AB
				invoke MoveToEx, hdc, refX, refY, NULL ; setare in origine - punct sursa (A)

				mov eax, mUnit ; seteaza unitatea de scalare 
				mov ecx, 8	   ; numar aleatoriu de unitati - pentru a genera forma patratica

				mul ecx		   ; multiplica mUint cu 8, rezultat stocat in registrul eax

				mov ebx, eax   ; pastreaza valoarea lui registrului eax in registrul ebx
 
				invoke LineTo, hdc, ebx, refY ; trasare segment pana la destinatie - punct destinatie B
				
				;segmentul BC
				invoke MoveToEx, hdc, ebx, refY, NULL  ; folosesc ebx - coordonata pe X a punctului B, calculata anterior
													   ; coordonata Y a punctul B este referinta setata			
	
				;stabilirea coordonatei X - punctul C
				mov eax, mUnit 
				mov ecx, 12
				
				mul ecx
				add eax, refX ; deplasare fata de x = 0 in functie de punctul de referinta setat
				
				mov lastX, eax  ; stocare pozitie pe axa X in registrul ebx

				;stabilire coordonatei Y - punctul C
				mov eax, mUnit
				mov ecx, 4

				mul ecx
				
				mov ecx, refY 
				sub ecx, eax ; scad coordonata calculata din referinta pe axa Y

				mov lastY, ecx ; stocare pozitie e axa Y in registrul edx
		
				invoke LineTo, hdc, lastX, lastY

				;segmentul CD
				invoke MoveToEx, hdc, lastX, lastY, NULL ;coordonata punctului C - calculata anterior
				
				;stabilirea coordonatei X a punctului D
				mov eax, mUnit
				mov ecx, 4

				mul ecx
				add eax, refX
				mov lastX, eax

				;coordonata pe axa Y a lui D coincide cu cea a lui C, calculata anterior
				
				invoke LineTo, hdc, lastX, lastY

				;segmentul AD
				invoke MoveToEx, hdc, lastX, lastY, NULL ; coordonatele lui D
				invoke LineTo, hdc, refX, refY			 ; coordonatele lui A sunt in referinta

				invoke EndPaint, hWnd, ADDR ps
			.ELSE
				invoke DefWindowProc, hWnd, uMsg, wParam, lParam
				ret
			.ENDIF
			xor eax, eax
			ret
	    WndProc endp
	end start
