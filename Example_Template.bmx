' =============================================================================
' 						Simple GUI Framework - BlitzMax NG
' 							COMBOBOX DEMO : Opaline UI
' 		By Creepy Cat (C)2025/2026 : https://github.com/BlackCreepyCat
' =============================================================================

Strict

Include "opaline/gui_opaline.bmx"

Graphics 1920,1080,0

' Init the GUI
TWidget.GuiInit()

' Create root container
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

' =============================================================
'                         GUI BUILDING
' =============================================================
Local win:TWindow = New TWindow(50, 50, 700, 500, "Button Demo", False, True, True)
root.AddChild win

Local title:TLabel = New TLabel(20, 20, 660, 24, "Opaline GUI - Empty template", LABEL_ALIGN_CENTER)
title.SetColor(255, 220, 100)
win.AddChild title

Local btn1:TButton = New TButton(20, 20, 180, 38, "Quit Opaline")
btn1.SetEnabled(True)
win.AddChild btn1


While Not KeyDown(KEY_ESCAPE)
	
	Cls

	' Important	
	TWidget.GuiRefresh()
	
	' -----------------------
	' GUI Widget testing here
	' -----------------------
    If btn1.WasClicked()
        Exit
    EndIf

	' Important
	ClearAllEvents(root)

	Flip
Wend
End
