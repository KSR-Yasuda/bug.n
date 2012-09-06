/**
 *	bug.n - tiling window management
 *	Copyright (c) 2010-2012 joten
 *
 *	This program is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 *	@version 8.3.0
 */

Bar_init(m) {
	Local appBarMsg, GuiN, h1, h2, i, text, titleWidth, trayWndId, w, wndId, wndTitle, wndWidth, x1, x2, y1, y2
	
	If (SubStr(Config_barWidth, 0) = "%") {
		StringTrimRight, wndWidth, Config_barWidth, 1
		wndWidth := Round(Monitor_#%m%_width * wndWidth / 100)
	} Else
		wndWidth := Config_barWidth
	Monitor_#%m%_barWidth := wndWidth
	titleWidth := wndWidth
	h1 := Bar_ctrlHeight
	x1 := 0
	x2 := wndWidth
	y1 := 0
	y2 := (Bar_ctrlHeight - Bar_textHeight) / 2
	h2 := Bar_ctrlHeight - 2 * y2
	
	; Create the GUI window
	wndTitle := "bug.n_BAR_" m
	GuiN := (m - 1) + 1
	Log_dbg_msg(6, "Bar_init(): Gui, " . GuiN . ": Default")
	Gui, %GuiN%: Default
	IfWinExist, %wndTitle%
		Gui, Destroy
	Gui, +AlwaysOnTop -Caption +LabelBar_Gui +LastFound +ToolWindow
	Gui, Color, %Config_normBgColor1%
	Gui, Font, c%Config_normFgColor1% s%Config_fontSize%, %Config_fontName%
	
	; tags
	Loop, % Config_viewCount {
		i := A_Index
		text := " " Config_viewNames_#%i% " "
		w := Bar_getTextWidth(text)
		Gui, Add, Text, x%x1% y%y1% w%w% h%h1% BackgroundTrans vBar_#%m%_#%i%_view gBar_GuiClick, 
		If (w <= h1)
			Gui, Add, Progress, x%x1% y%y1% w%w% h%h1% Background%Config_normBgColor1% Vertical vBar_#%m%_#%i%_tagged
		Else
			Gui, Add, Progress, x%x1% y%y1% w%w% h%h1% Background%Config_normBgColor1% vBar_#%m%_#%i%_tagged
		Gui, Add, Text, x%x1% y%y2% w%w% h%h2% -Wrap Center BackgroundTrans vBar_#%m%_#%i%, %text%
		titleWidth -= w
		x1 += w
	}
	; layout
	i := Config_viewCount + 1
	text := " 1x9|=- "
	w := Bar_getTextWidth(text)
    Gui, Add, Text, x%x1% y%y1% w%w% h%h1% BackgroundTrans vBar_#%m%_#%i%_layout gBar_GuiClick, 
    Gui, Add, Progress, x%x1% y%y1% w%w% h%h1% Background%Config_normBgColor2%
	Gui, Font, c%Config_normFgColor2%
	Gui, Add, Text, x%x1% y%y2% w%w% h%h2% -Wrap Center BackgroundTrans vBar_#%m%_#%i%, %text%
	titleWidth -= w
	x1 += w
	
	; The x-position and width of the sub-windows right of the window title are set from the right.
	Loop, 4 {
		i := Config_viewCount + 7 - A_Index
		w := 0
		If (i = Config_viewCount + 6) {															; command gui
			Gui, -Disabled
			w := Bar_getTextWidth(" ?? ")
			x2 -= w
			titleWidth -= w
                        Gui, Add, Text, x%x2% y%y1% w%w% h%h1% BackgroundTrans vBar_#%m%_#%i% gBar_toggleCommandGui, 
                        Gui, Add, Progress, x%x2% y%y1% w%w% h%h1% Background%Config_normBgColor2%
			Gui, Add, Text, x%x2% y%y2% w%w% h%h2% Center BackgroundTrans, #!
		} Else If (i = Config_viewCount + 5) And Config_readinTime {							; time
			w  := Bar_getTextWidth(" ??:?? ")
			x2 -= w
			titleWidth -= w
			If Config_readinAny() Or Config_readinBat {
				Gui, Font, c%Config_normFgColor1%
				Gui, Add, Text, x%x2% y%y1% w%w% h%h1%, 
			}
			Gui, Add, Text, x%x2% y%y2% w%w% h%h2% BackgroundTrans Center vBar_#%m%_#%i%, ??:??
		} Else If (i = Config_viewCount + 4) And Config_readinAny() {							; any
			text := Config_readinAny()
			w := Bar_getTextWidth(text)
			x2 -= w
			titleWidth -= w
            Gui, Add, Progress, x%x2% y%y1% w%w% h%h1% Background%Config_normBgColor2%
			Gui, Font, c%Config_normFgColor2%
			Gui, Add, Text, x%x2% y%y2% w%w% h%h2% Center BackgroundTrans vBar_#%m%_#%i%, %text%
		} Else If (i = Config_viewCount + 3) And Config_readinBat {								; battery level
			w := Bar_getTextWidth(" BAT: ???% ")
			x2 -= w
			titleWidth -= w
			Gui, Add, Progress, x%x2% y%y1% w%w% h%h1% Background%Config_normBgColor2% c%Config_normFgColor3% vBar_#%m%_#%i%_tagged
			Gui, Font, c%Config_normFgColor2%
			Gui, Add, Text, x%x2% y%y2% w%w% h%h2% BackgroundTrans Center vBar_#%m%_#%i%, BAT: ???`%
		}
	}
	
	; window title (remaining space)
	Gui, Add, Text, x%x1% y%y1% w%titleWidth% h%h1%, 
	If Not Config_singleRowBar {
		titleWidth := wndWidth
		x1 := 0
		y1 += h1
		y2 += h1
	}
	i := Config_viewCount + 2
	Gui, Font, c%Config_normFgColor1%
	Gui, Add, Text, x%x1% y%y1% w%titleWidth% h%h1%, 
	Gui, Add, Text, x%x1% y%y2% w%titleWidth% h%h2% BackgroundTrans Center vBar_#%m%_#%i%, 
	
	If (Config_horizontalBarPos = "left")
		x1 := 0
	Else If (Config_horizontalBarPos = "right")
		x1 := Monitor_#%m%_width - wndWidth
	Else If (Config_horizontalBarPos = "center")
		x1 := (Monitor_#%m%_width - wndWidth) / 2
	Else If (Config_horizontalBarPos => 0)
		x1 := Config_horizontalBarPos
	Else If (Config_horizontalBarPos < 0)
		x1 := Monitor_#%m%_width - wndWidth + Config_horizontalBarPos
	If Not (Config_verticalBarPos = "tray" And m = Manager_taskBarMonitor)
		x1 += Monitor_#%m%_x
	
	Bar_#%m%_titleWidth := titleWidth
	Monitor_#%m%_barX := x1
	y1 := Monitor_#%m%_barY
	
	If Monitor_#%m%_showBar
		Gui, Show, NoActivate x%x1% y%y1% w%wndWidth% h%Bar_height%, %wndTitle%
	Else
		Gui, Show, NoActivate Hide x%x1% y%y1% w%wndWidth% h%Bar_height%, %wndTitle%
	wndId := WinExist(wndTitle)
	If (Config_verticalBarPos = "tray" And m = Manager_taskBarMonitor) {
		trayWndId := WinExist("ahk_class Shell_TrayWnd")
		DllCall("SetParent", "UInt", wndId, "UInt", trayWndId)
	} Else {
		appBarMsg := DllCall("RegisterWindowMessage", Str, "AppBarMsg")
		
		; appBarData: http://msdn2.microsoft.com/en-us/library/ms538008.aspx
		VarSetCapacity(Bar_appBarData, 36, 0)
		offset := NumPut(        36, Bar_appBarData)
		offset := NumPut(     wndId, offset+0)
		offset := NumPut( appBarMsg, offset+0)
		offset := NumPut(         1, offset+0)
		offset := NumPut(        x1, offset+0)
		offset := NumPut(        y1, offset+0)
		offset := NumPut(  wndWidth, offset+0)
		offset := NumPut(Bar_height, offset+0)
		offset := NumPut(         1, offset+0)
		
		DllCall("Shell32.dll\SHAppBarMessage", "UInt", (ABM_NEW := 0x0)     , "UInt", &Bar_appBarData)
		DllCall("Shell32.dll\SHAppBarMessage", "UInt", (ABM_QUERYPOS := 0x2), "UInt", &Bar_appBarData)
		DllCall("Shell32.dll\SHAppBarMessage", "UInt", (ABM_SETPOS := 0x3)  , "UInt", &Bar_appBarData)
		; SKAN: Crazy Scripting : Quick Launcher for Portable Apps (http://www.autohotkey.com/forum/topic22398.html)
	}
    
    Bar_hDrive := DllCall("CreateFile", "Str", "\\.\PhysicalDrive0", "UInt", 0, "UInt", 3, "UInt", 0, "UInt", 3, "UInt", 0, "UInt", 0)
    Bar_getNetworkInterface()
}

Bar_initCmdGui() {	
	Global Bar_#0_#0, Bar_#0_#0H, Bar_#0_#0W, Bar_cmdGuiIsVisible, Config_fontName, Config_fontSize, Config_normBgColor1, Config_normFgColor1
	
	Bar_cmdGuiIsVisible := False
	wndTitle := "bug.n_BAR_0"
	Gui, 99: Default
	Gui, +LabelBar_cmdGui
	IfWinExist, %wndTitle%
		Gui, Destroy
	Gui, +LastFound -Caption +ToolWindow +AlwaysOnTop
	Gui, Color, Default
	Gui, Font, s%Config_fontSize%, %Config_fontName%
	Gui, Add, TreeView, x0 y0 r23 w300 Background%Config_normBgColor1% c%Config_normFgColor1% -ReadOnly vBar_#0_#0 gBar_cmdGuiEnter
	GuiControl, -Redraw, Bar_#0_#0
	itemId10 := TV_Add("Window")
	  itemId11 := TV_Add("set tag", itemId10)
	    TV_Add("all", itemId11)
	    TV_Add("Press <F2> to enter a number.", itemId11)
	  itemId12 := TV_Add("toggle tag", itemId10)
	    TV_Add("Press <F2> to enter a number.", itemId12)
	  TV_Add("move to top", itemId10)
	  TV_Add("move up", itemId10)
	  TV_Add("move down", itemId10)
	  TV_Add("toggle floating", itemId10)
	  TV_Add("toggle decor", itemId10)
	  TV_Add("close", itemId10)
	  TV_Add("maximize", itemId10)
	  TV_Add("move by key", itemId10)
	  TV_Add("resize by key", itemId10)
	  TV_Add("activate next", itemId10)
	  TV_Add("activate prev", itemId10)
	  TV_Add("move to next monitor", itemId10)
	  TV_Add("move to prev monitor", itemId10)
	itemId20 := TV_Add("Layout")
	  TV_Add("set last", itemId20)
	  TV_Add("set 1st (tile)", itemId20)
	  TV_Add("set 2nd (monocle)", itemId20)
	  TV_Add("set 3rd (floating)", itemId20)
	  TV_Add("rotate layout axis", itemId20)
	  TV_Add("rotate master axis", itemId20)
	  TV_Add("rotate stack axis", itemId20)
	  TV_Add("mirror tile layout", itemId20)
	  TV_Add("increase master X", itemId20)
	  TV_Add("decrease master X", itemId20)
	  TV_Add("increase master Y", itemId20)
	  TV_Add("decrease master Y", itemId20)
	  TV_Add("increase master factor", itemId20)
	  TV_Add("decrease master factor", itemId20)
	itemId30 := TV_Add("View")
	  itemId31 := TV_Add("activate", itemId30)
	    TV_Add("last", itemId31)
	    TV_Add("Press <F2> to enter a number.", itemId31)
	  TV_Add("move to next monitor", itemId30)
	  TV_Add("move to prev monitor", itemId30)
	itemId40 := TV_Add("Monitor")
	  TV_Add("toggle bar", itemId40)
	  TV_Add("toggle task bar", itemId40)
	  TV_Add("activate next", itemId40)
	  TV_Add("activate prev", itemId40)
	;itemId50 := TV_add("Log")
	;  TV_Add("increment debug level", itemId50)
	;  TV_Add("decrement debug level", itemId50)
	;  TV_Add("log help info", itemId50)
	;  TV_Add("log view window info", itemId50)
	;  TV_Add("log managed window info", itemId50)
	TV_Add("Reload")
	TV_Add("Quit")
	GuiControl, +Redraw, Bar_#0_#0
	Gui, Add, Button, Y0 Hidden Default gBar_cmdGuiEnter, OK
	GuiControlGet, Bar_#0_#0, Pos
	Gui, Show, Hide w%Bar_#0_#0W% h%Bar_#0_#0H%, %wndTitle%
}

Bar_cmdGuiEscape:
	Bar_cmdGuiIsVisible := False
	Gui, Cancel
	WinActivate, ahk_id %Bar_aWndId%
Return

Bar_cmdGuiEnter:
	If (A_GuiControl = "OK") Or (A_GuiControl = "BAR_#0_#0" And A_GuiControlEvent = "DoubleClick") {
		Bar_selItemId_#1 := TV_GetSelection()
		If Not TV_GetChild(Bar_selItemId_#1) {
			Bar_selItemId_#2 := TV_GetParent(Bar_selItemId_#1)
			Bar_selItemId_#3 := TV_GetParent(Bar_selItemId_#2)
			TV_GetText(Bar_command_#1, Bar_selItemId_#1)
			TV_GetText(Bar_command_#2, Bar_selItemId_#2)
			TV_GetText(Bar_command_#3, Bar_selItemId_#3)
		} Else
			Bar_command_#1 := ""
		Bar_cmdGuiIsVisible := False
		Gui, Cancel
		WinActivate, ahk_id %Bar_aWndId%
		Bar_evaluateCommand()
	}
Return

Bar_evaluateCommand() {
	Global Bar_command_#1, Bar_command_#2, Bar_command_#3, Config_viewCount
	
	If (Bar_command_#1) {
		If (Bar_command_#2 = "Run")
			Run, %Bar_command_#1%
		Else If (Bar_command_#3 = "Window") {
			If (Bar_command_#2 = "set tag") {
				If (Bar_command_#1 = "all")
					Monitor_setWindowTag(0)
				Else If (RegExMatch(Bar_command_#1, "[0-9]+") And Bar_command_#1 <= Config_viewCount)
					Monitor_setWindowTag(Bar_command_#1)
			} Else If (Bar_command_#2 = "toggle tag")
				If (RegExMatch(Bar_command_#1, "[0-9]+") And Bar_command_#1 <= Config_viewCount)
					Monitor_toggleWindowTag(Bar_command_#1)
		} Else If (Bar_command_#2 = "Window") {
			If (Bar_command_#1 = "move to top")
				View_shuffleWindow(0)
			Else If (Bar_command_#1 = "move up")
				View_shuffleWindow(-1)
			Else If (Bar_command_#1 = "move down")
				 View_shuffleWindow(+1)
			Else If (Bar_command_#1 = "toggle floating")
				 View_toggleFloating()
			Else If (Bar_command_#1 = "toggle decor")
				 Manager_toggleDecor()
			Else If (Bar_command_#1 = "close")
				 Manager_closeWindow()
			Else If (Bar_command_#1 = "move by key")
				 Manager_moveWindow()
			Else If (Bar_command_#1 = "resize by key")
				 Manager_sizeWindow()
			Else If (Bar_command_#1 = "maximize")
				 Manager_maximizeWindow()
			Else If (Bar_command_#1 = "activate next")
				 View_activateWindow(+1)
			Else If (Bar_command_#1 = "activate prev")
				 View_activateWindow(-1)
			Else If (Bar_command_#1 = "move to next monitor")
				 Manager_setWindowMonitor(+1)
			Else If (Bar_command_#1 = "move to prev monitor")
				 Manager_setWindowMonitor(-1)
		} Else If (Bar_command_#2 = "Layout") {
			If (Bar_command_#1 = "set last")
				View_setLayout(-1)
			Else If (Bar_command_#1 = "set 1st (tile)")
				View_setLayout(1)
			Else If (Bar_command_#1 = "set 2nd (monocle)")
				View_setLayout(2)
			Else If (Bar_command_#1 = "set 3rd (floating)")
				View_setLayout(3)
			Else If (Bar_command_#1 = "rotate layout axis")
				View_rotateLayoutAxis(1, +1)
			Else If (Bar_command_#1 = "rotate master axis")
				View_rotateLayoutAxis(2, +1)
			Else If (Bar_command_#1 = "rotate stack axis")
				View_rotateLayoutAxis(3, +1)
			Else If (Bar_command_#1 = "mirror tile layout")
				View_rotateLayoutAxis(1, +2)
			Else If (Bar_command_#1 = "increase master X")
				View_setMX(+1)
			Else If (Bar_command_#1 = "decrease master X")
				View_setMX(-1)
			Else If (Bar_command_#1 = "increase master Y")
				View_setMY(+1)
			Else If (Bar_command_#1 = "decrease master Y")
				View_setMY(-1)
			Else If (Bar_command_#1 = "increase master factor")
				View_setMFactor(+0.05)
			Else If (Bar_command_#1 = "decrease master factor")
				View_setMFactor(-0.05)
		} Else If (Bar_command_#3 = "View") {
			If (Bar_command_#2 = "activate") {
				If (Bar_command_#1 = "last")
					Monitor_activateView(-1)
				Else If (RegExMatch(Bar_command_#1, "[0-9]+") And Bar_command_#1 <= Config_viewCount)
					Monitor_activateView(Bar_command_#1)
			}
		} Else If (Bar_command_#2 = "View") {
			If (Bar_command_#1 = "move to next monitor")
				Manager_setViewMonitor(+1)
			Else If (Bar_command_#1 = "move to prev monitor")
				Manager_setViewMonitor(-1)
		} Else If (Bar_command_#2 = "Monitor") {
			If (Bar_command_#1 = "toggle bar")
				Monitor_toggleBar()
			Else If (Bar_command_#1 = "toggle task bar")
				Monitor_toggleTaskBar()
			Else If (Bar_command_#1 = "activate next")
				Manager_activateMonitor(+1)
			Else If (Bar_command_#1 = "activate prev")
				Manager_activateMonitor(-1)
		} Else If (Bar_command_#2 = "Log") {
			If (Bar_command_#1 = "increment debug level")
				Log_incDebugLevel()
			If (Bar_command_#1 = "decrement debug level")
				Log_decDebugLevel()
			If (Bar_command_#1 = "log help info")
				Manager_logHelp()
			If (Bar_command_#1 = "log view window info")
				Manager_logViewWindowList()
			If (Bar_command_#1 = "log managed window info")
				Manager_logManagedWindowList()
		} Else If (Bar_command_#1 = "Reload")
			Main_reload()
		Else If (Bar_command_#1 = "Quit")
			ExitApp
		
		Bar_command_#1 := ""
		Bar_command_#2 := ""
		Bar_command_#3 := ""
	}
}

Bar_getBatteryStatus(ByRef batteryLifePercent, ByRef acLineStatus) {
	VarSetCapacity(powerStatus, (1 + 1 + 1 + 1 + 4 + 4))
	success := DllCall("GetSystemPowerStatus", "UInt", &powerStatus)
	If (ErrorLevel != 0 Or success = 0) {
		MsgBox 16, Power Status, Can't get the power status...
		Return
	}
	acLineStatus	   := NumGet(powerStatus, 0, "Char")
	batteryLifePercent := NumGet(powerStatus, 2, "Char")

	If acLineStatus = 0
		acLineStatus = off
	Else If acLineStatus = 1
		acLineStatus = on
	Else If acLineStatus = 255
		acLineStatus = ?

	If batteryLifePercent = 255
		batteryLifePercent = ???
}
; PhiLho: AC/Battery status (http://www.autohotkey.com/forum/topic7633.html)

Bar_getDiskLoad(ByRef readLoad, ByRef writeLoad) {
    Global Bar_hDrive
    Static oldReadCount, oldWriteCount
    
    dpSize := 5 * 8 + 4 + 4 + 4 + 4 + 8 + 4 + 8 * (A_IsUnicode ? 2 : 1) + 12    ; 88?
    VarSetCapacity(dp, dpSize)
	DllCall("DeviceIoControl", "UInt", Bar_hDrive, "UInt", 0x00070020, "UInt", 0, "UInt", 0, "UInt", &dp, "UInt", dpSize, "UIntP", nReturn, "UInt", 0)    ; IOCTL_DISK_PERFORMANCE
    
	newReadCount  := NumGet(dp, 40)
	newWriteCount := NumGet(dp, 44)
    readLoad  := SubStr("  " Round((1 - 1 / (1 +  newReadCount -  oldReadCount)) * 100), -2)
    writeLoad := SubStr("  " Round((1 - 1 / (1 + newWriteCount - oldWriteCount)) * 100), -2)
    oldReadCount  := newReadCount
    oldWriteCount := newWriteCount
}
; fures: System + Network monitor - with net history graph (http://www.autohotkey.com/community/viewtopic.php?p=260329)
; SKAN: HDD Activity Monitoring LED (http://www.autohotkey.com/community/viewtopic.php?p=113890&sid=64d9824fdf252697ff4d5026faba91f8#p113890)

Bar_getHeight() {
	Global Bar_#0_#1, Bar_#0_#1H, Bar_#0_#2, Bar_#0_#2H, Bar_ctrlHeight, Bar_height, Bar_textHeight
	Global Config_fontName, Config_fontSize, Config_singleRowBar, Config_spaciousBar, Config_verticalBarPos
	
	wndTitle := "bug.n_BAR_0"
	Gui, 99: Default
	Gui, Font, s%Config_fontSize%, %Config_fontName%
	Gui, Add, Text, x0 y0 vBar_#0_#1, |
	GuiControlGet, Bar_#0_#1, Pos
	Bar_textHeight := Bar_#0_#1H
	If Config_spaciousBar {
		Gui, Add, ComboBox, r9 x0 y0 vBar_#0_#2, |
		GuiControlGet, Bar_#0_#2, Pos
		Bar_ctrlHeight := Bar_#0_#2H
	} Else
		Bar_ctrlHeight := Bar_textHeight
	Gui, Destroy
	
	Bar_height := Bar_ctrlHeight
	If Not Config_singleRowBar
		Bar_height *= 2
	If (Config_verticalBarPos = "tray") {
		WinGetPos, , , , buttonH, Start ahk_class Button
		WinGetPos, , , , barH, ahk_class Shell_TrayWnd
		If (buttonH < barH)
			Bar_height := buttonH
		Else
			Bar_height := barH
		Bar_ctrlHeight := Bar_height
		If Not Config_singleRowBar
			Bar_ctrlHeight := Bar_height / 2
	}
}

Bar_getMemoryUsage() {
    VarSetCapacity(memoryStatus, 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4)
    DllCall("kernel32.dll\GlobalMemoryStatus", "UInt", &memoryStatus)
    Return, SubStr("  " Round(*(&memoryStatus + 4)), -2)    ; LS byte is enough, 0..100
}
; fures: System + Network monitor - with net history graph (http://www.autohotkey.com/community/viewtopic.php?p=260329)

Bar_getNetworkInterface() {
    Global Bar_networkInterface, Bar_networkInterfaceTable
    
    DllCall("iphlpapi\GetNumberOfInterfaces", "UIntP", n)
    nSize := 4 + 860 * n + 8
    VarSetCapacity(Bar_networkInterfaceTable, nSize)
    If Not DllCall("iphlpapi\GetIfTable", "UInt", &Bar_networkInterfaceTable, "UIntP", nSize, "Int", False) {
        Loop, 2 {
            i := 0
            j := A_Index
            Loop, % NumGet(Bar_networkInterfaceTable) {
                If NumGet(Bar_networkInterfaceTable, 4 + 860 * (A_Index - 1) + 544) < 4
                || NumGet(Bar_networkInterfaceTable, 4 + 860 * (A_Index - 1) + 516) = 24
                    Continue
                i += 1
                dn_#%i%_#%j% := NumGet(Bar_networkInterfaceTable, 4 + 860 * (A_Index - 1) + 552)
                up_#%i%_#%j% := NumGet(Bar_networkInterfaceTable, 4 + 860 * (A_Index - 1) + 576)
            }
            If (A_Index < 2)
                RunWait, %Comspec% /c ping -n 1 127.0.0.1, , hide
        }
        
        Loop, % i
            If (dn_#%i%_#2 > dn_#%i%_1) {
                Bar_networkInterface := i
                Break
            }
    }
}
; fures: System + Network monitor - with net history graph (http://www.autohotkey.com/community/viewtopic.php?p=260329)

Bar_getNetworkLoad(ByRef upLoad, ByRef dnLoad) {
    Global Bar_networkInterface, Bar_networkInterfaceTable
    Static dn_#0, t_#0, up_#0

    DllCall("iphlpapi\GetIfEntry", "UInt", &Bar_networkInterfaceTable + 4 + 860 * (Bar_networkInterface - 1))
    dn_#1 := NumGet(Bar_networkInterfaceTable, 4 + 860 * (Bar_networkInterface - 1) + 552)    ; Total Incoming Bytes
    up_#1 := NumGet(Bar_networkInterfaceTable, 4 + 860 * (Bar_networkInterface - 1) + 576)    ; Total Outgoing Bytes
    tDiff := (A_TickCount - t_#0) / 1000
    t_#0  := A_TickCount
    
    dnLoad := SubStr("   " Round((dn_#1 - dn_#0) / 1024 / tDiff), -3)
    upLoad := SubStr("   " Round((up_#1 - up_#0) / 1024 / tDiff), -3)
    
    dn_#0 := dn_#1
    up_#0 := up_#1
}
; fures: System + Network monitor - with net history graph (http://www.autohotkey.com/community/viewtopic.php?p=260329)
; Sean: Network Download/Upload Meter (http://www.autohotkey.com/community/viewtopic.php?t=18033)

Bar_getSystemTimes() {	; Total CPU Load
	Static oldIdleTime, oldKrnlTime, oldUserTime
	Static newIdleTime, newKrnlTime, newUserTime

	oldIdleTime := newIdleTime
	oldKrnlTime := newKrnlTime
	oldUserTime := newUserTime

	DllCall("GetSystemTimes", "Int64P", newIdleTime, "Int64P", newKrnlTime, "Int64P", newUserTime)
	sysTime := SubStr("  " . Round((1 - (newIdleTime - oldIdleTime) / (newKrnlTime - oldKrnlTime+newUserTime - oldUserTime)) * 100), -2)
	Return, sysTime		; system time in percent
}
; Sean: CPU LoadTimes (http://www.autohotkey.com/forum/topic18913.html)

Bar_getTextWidth(x, reverse=False) {
	Global Config_fontSize
	
	If reverse {		; "reverse" calculates the number of characters to a given width.
		w := x
		i := w / (Config_fontSize - 1)
		If (Config_fontSize = 7 Or (Config_fontSize > 8 And Config_fontSize < 13))
			i := w / (Config_fontSize - 2)
		Else If (Config_fontSize > 12 And Config_fontSize < 18)
			i := w / (Config_fontSize - 3)
		Else If (Config_fontSize > 17)
			i := w / (Config_fontSize - 4)
		textWidth := i
	} Else {			; "else" calculates the width to a given string.
		textWidth := StrLen(x) * (Config_fontSize - 1)
		If (Config_fontSize = 7 Or (Config_fontSize > 8 And Config_fontSize < 13))
			textWidth := StrLen(x) * (Config_fontSize - 2)
		Else If (Config_fontSize > 12 And Config_fontSize < 18)
			textWidth := StrLen(x) * (Config_fontSize - 3)
		Else If (Config_fontSize > 17)
			textWidth := StrLen(x) * (Config_fontSize - 4)
	}
	
	Return, textWidth
}

Bar_GuiClick:
	Manager_winActivate(Bar_aWndId)
	If (A_GuiEvent = "Normal") {
		If Not (SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_#", False, 0) - 6) = Manager_aMonitor)
			Manager_activateMonitor(SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_#", False, 0) - 6) - Manager_aMonitor)
		If (SubStr(A_GuiControl, -6) = "_layout")
			View_setLayout(-1)
		Else If (SubStr(A_GuiControl, -4) = "_view")
			Monitor_activateView(SubStr(A_GuiControl, InStr(A_GuiControl, "_#", False, 0) + 2, 1))
	}
Return

Bar_GuiContextMenu:
	Manager_winActivate(Bar_aWndId)
	If (A_GuiEvent = "RightClick") {
		If (SubStr(A_GuiControl, -6) = "_layout") {
			If Not (SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_#", False, 0) - 6) = Manager_aMonitor)
				Manager_activateMonitor(SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_#", False, 0) - 6) - Manager_aMonitor)
			View_setLayout(">")
		} Else If (SubStr(A_GuiControl, -4) = "_view") {
			If Not (SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_#", False, 0) - 6) = Manager_aMonitor)
				Manager_setWindowMonitor(SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_#", False, 0) - 6) - Manager_aMonitor)
			Monitor_setWindowTag(SubStr(A_GuiControl, InStr(A_GuiControl, "_#", False, 0) + 2, 1))
		}
	}
Return

Bar_loop:
	Bar_updateStatus()
Return

Bar_move(m) {
	Local wndTitle, x, y
	
	x := Monitor_#%m%_barX
	y := Monitor_#%m%_barY
	
	wndTitle := "bug.n_BAR_" m
	WinMove, %wndTitle%, , %x%, %y%
}

Bar_toggleCommandGui:
	If Not Bar_cmdGuiIsVisible
		If Not (SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_#", False, 0) - 6) = Manager_aMonitor)
			Manager_activateMonitor(SubStr(A_GuiControl, 6, InStr(A_GuiControl, "_#", False, 0) - 6) - Manager_aMonitor)
	Bar_toggleCommandGui()
Return

Bar_toggleCommandGui() {
	Local wndId, x, y
	
	Gui, 99: Default
	If Bar_cmdGuiIsVisible {
		Bar_cmdGuiIsVisible := False
		Gui, Cancel
		Manager_winActivate(Bar_aWndId)
	} Else {
		Bar_cmdGuiIsVisible := True
		x := Monitor_#%Manager_aMonitor%_barX + Monitor_#%Manager_aMonitor%_barWidth - Bar_#0_#0W
		If (Config_verticalBarPos = "top") Or (Config_verticalBarPos = "tray" And Not Manager_aMonitor = Manager_taskBarMonitor)
			y := Monitor_#%Manager_aMonitor%_y
		Else
			y := Monitor_#%Manager_aMonitor%_y + Monitor_#%Manager_aMonitor%_height - Bar_#0_#0H
		Gui, Show
		WinMove, bug.n_BAR_0, , %x%, %y%
		WinGet, wndId, ID, bug.n_BAR_0
		Manager_winActivate(wndId)
		GuiControl, Focus, % Bar_#0_#0
	}
}

Bar_toggleVisibility(m) {
	Local GuiN
	
	GuiN := (m - 1) + 1
	If Monitor_#%m%_showBar {
		If Not (GuiN = 99) Or Bar_cmdGuiIsVisible
			Gui, %GuiN%: Show
	} Else
		Gui, %GuiN%: Cancel
}

Bar_updateLayout(m) {
	Local aView, GuiN, i
	
	aView := Monitor_#%m%_aView_#1
	i := Config_viewCount + 1
	GuiN := (m - 1) + 1
	GuiControl, %GuiN%: , Bar_#%m%_#%i%, % View_#%m%_#%aView%_layoutSymbol
}

Bar_updateStatus() {
	Local anyContent, anyText, b1, b2, b3, GuiN, i, m
	
	Loop, % Manager_monitorCount {
		m := A_Index
		GuiN := (m - 1) + 1
		Log_dbg_msg(6, "Bar_updateStatus(): Gui, " . GuiN . ": Default")
		Gui, %GuiN%: Default
		If Config_readinBat {
			Bar_getBatteryStatus(b1, b2)
			b3 := SubStr("  " b1, -2)
			i := Config_viewCount + 3
			If (b1 < 10) And (b2 = "off") {				; change the color, if the battery level is below 10%
				GuiControl, +Background%Config_normBgColor4% +c%Config_normBgColor2%, Bar_#%m%_#%i%_tagged
				GuiControl, +c%Config_selFgColor6%, Bar_#%m%_#%i%
			} Else If (b2 = "off") {					; change the color, if the pc is not plugged in
				GuiControl, +Background%Config_normBgColor2% +c%Config_normFgColor5%, Bar_#%m%_#%i%_tagged
				GuiControl, +c%Config_normFgColor4%, Bar_#%m%_#%i%
			} Else {
				GuiControl, +Background%Config_normBgColor3% +c%Config_normFgColor3%, Bar_#%m%_#%i%_tagged
				GuiControl, +c%Config_normFgColor2%, Bar_#%m%_#%i%
			}
			GuiControl, , Bar_#%m%_#%i%_tagged, %b3%
			GuiControl, , Bar_#%m%_#%i%, % " BAT: " b3 "% "
		}
		anyText := Config_readinAny()
		If anyText {
			i := Config_viewCount + 4
			GuiControlGet, anyContent, , Bar_#%m%_#%i%
			If Not (anyText = anyContent)
				GuiControl, , Bar_#%m%_#%i%, % anyText
		}
		If Config_readinTime {
			i := Config_viewCount + 5
			GuiControl, , Bar_#%m%_#%i%, % " " A_Hour ":" A_Min " "
		}
	}
}

Bar_updateTitle(debugMsg = "") {
	Local aWndId, aWndTitle, content, GuiN, i, title
	
	If debugMsg
		aWndTitle := debugMsg
	Else {
		WinGet, aWndId, ID, A
		WinGetTitle, aWndTitle, ahk_id %aWndId%
		If InStr(Bar_hideTitleWndIds, aWndId ";") Or (aWndTitle = "bug.n_BAR_0")
			aWndTitle := ""
		If Manager_#%aWndId%_isFloating
			aWndTitle := "~ " aWndTitle
		If (Manager_monitorCount > 1)
			aWndTitle := "[" Manager_aMonitor "] " aWndTitle
	}
	title := " " . aWndTitle . " "
	
	If (Bar_getTextWidth(title) > Bar_#%Manager_aMonitor%_titleWidth) {		; shorten the window title if its length exceeds the width of the bar
		i := Bar_getTextWidth(Bar_#%Manager_aMonitor%_titleWidth, True) - 6
		StringLeft, title, aWndTitle, i
		title := " " . title . " ... "
	}
	
	i := Config_viewCount + 2
	Loop, % Manager_monitorCount {
		GuiN := (A_Index - 1) + 1
		Log_dbg_msg(6, "Bar_updateTitle(): Gui, " . GuiN . ": Default")
		Gui, %GuiN%: Default
		GuiControlGet, content, , Bar_#%A_Index%_#%i%
		If (A_Index = Manager_aMonitor) {
			If Not (content = title)
				GuiControl, , Bar_#%A_Index%_#%i%, % title
		} Else If Not (content = "")
			GuiControl, , Bar_#%A_Index%_#%i%, 
	}
	Bar_aWndId := aWndId
}

; Update the view portion of the status bar.
Bar_updateView(m, v) {
	Local IdsLen, ViewIdsLen
	
	GuiN := (m - 1) + 1
	Log_dbg_msg(6, "Bar_updateView(): m: " . m . "; Gui, " . GuiN . ": Default")
	Gui, %GuiN%: Default
	
	IdsLen := StrLen(Manager_managedWndIds)
	
	If (v = Monitor_#%m%_aView_#1) {
		; Set foreground/background colors if the view is the current view.
		GuiControl, +Background%Config_selBgColor1% +c%Config_selFgColor2%, Bar_#%m%_#%v%_tagged
		GuiControl, +c%Config_selFgColor1%, Bar_#%m%_#%v%
	} Else If StrLen(View_#%m%_#%v%_wndIds) > 0 {
		; Set foreground/background colors if the view contains windows.
		GuiControl, +Background%Config_normBgColor5% +c%Config_normFgColor8%, Bar_#%m%_#%v%_tagged
		GuiControl, +c%Config_normFgColor7%, Bar_#%m%_#%v%
	} Else {
		; Set foreground/background colors if the view is empty.
		GuiControl, +Background%Config_normBgColor1% +c%Config_normFgColor8%, Bar_#%m%_#%v%_tagged
		GuiControl, +c%Config_normFgColor1%, Bar_#%m%_#%v%
	}
	
	Loop, %Config_viewCount% {
		ViewIdsLen := StrLen( View_#%m%_#%A_Index%_wndIds )
		; Update the percentage fill for the view.
		GuiControl, , Bar_#%m%_#%A_Index%_tagged, % ViewIdsLen / IdsLen * 100
		; Refresh the number on the bar.
		GuiControl, , Bar_#%m%_#%A_Index%, % Config_viewNames_#%A_Index%
	}
}
