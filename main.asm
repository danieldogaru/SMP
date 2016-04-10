; Ionut-Daniel DOGARU
; Grupa 333 AA
; Dezvoltat utilizand MASM32
; Aprilie 2016

.386 ; Arhitectura Intel 
.model flat,stdcall
option casemap:none ;nume de functii, variabile - case sensitive

; Incarcarea librariilor specifice MASM32
include e:\masm32\include\windows.inc

include e:\masm32\include\user32.inc
includelib e:\masm32\lib\user32.lib

include e:\masm32\include\kernel32.inc
includelib e:\masm32\lib\kernel32.lib

; librarii pentru grafica: line, elipse etc.
include e:\masm32\include\gdi32.inc
includelib e:\masm32\lib\gdi32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

.DATA ; variabile initializate
	ClassName db "SimpleWinClass", 0
	AppName   db "Tema SMP", 0	;Titlul ferestrei
	OurText   db "Win32 assembly is great and easy!" ,0

.DATA? ;variabile neinitializate
	hInstance HINSTANCE ?

.CODE
	start:
		invoke GetModuleHandle, NULL ; obtinerea handlerului
		mov hInstance, eax
		invoke WinMain, hInstance, NULL, NULL, SW_SHOWDEFAULT
		invoke ExitProcess, eax

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
			LOCAL rect:RECT

			.IF uMsg == WM_DESTROY
				invoke PostQuitMessage, NULL

			.ELSEIF uMsg == WM_PAINT
				invoke BeginPaint, hWnd, ADDR ps
				mov hdc, eax
				invoke MoveToEx, hdc, 100, 100, NULL
				invoke LineTo, hdc, 200, 200
				invoke EndPaint, hWnd, ADDR ps
			.ELSE
				invoke DefWindowProc, hWnd, uMsg, wParam, lParam
				ret
			.ENDIF
			xor eax, eax
			ret
	    WndProc endp
end start