' =============================================================================
' 						Simple GUI Framework - BlitzMax NG
' 							COMBOBOX DEMO : Opaline UI
' 		By Creepy Cat (C)2025/2026 : https://github.com/BlackCreepyCat
' =============================================================================
SuperStrict

' Import required BlitzMax modules
Import BRL.GLMax2D
Import BRL.LinkedList

Include "opaline/gui_opaline.bmx"

Graphics 1024,768, 0

' Init the GUI
TWidget.GuiInit()

' Creating the animated background
TBackground.Init()

' Create root container
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

' =============================================================
' 						GUI BUILDING
' =============================================================
Local win:TWindow = New TWindow(50, 50, 700, 500, "ComboBox Demo", False, True, True)
root.AddChild win

Local title:TLabel = New TLabel(20, 20, 660, 24, "Opaline GUI - ComboBox Demonstration", LABEL_ALIGN_CENTER)
title.SetColor(180, 220, 140)
win.AddChild title

Local lbl1:TLabel = New TLabel(30, 70, 400, 20, "Select your difficulty:")
win.AddChild lbl1

Local combo1:TComboBox = New TComboBox(30, 110, 280, 32)
combo1.AddItem("Very Easy")
combo1.AddItem("Easy")
combo1.AddItem("Normal")
combo1.AddItem("Hard")
combo1.AddItem("Nightmare")
combo1.SetSelectedIndex(2)
win.AddChild combo1

Local lbl2:TLabel = New TLabel(30, 170, 400, 20, "Choose resolution:")
win.AddChild lbl2

Local combo2:TComboBox = New TComboBox(30, 210, 280, 32)
combo2.AddItem("1920 × 1080")
combo2.AddItem("1600 × 900")
combo2.AddItem("1366 × 768")
combo2.AddItem("1280 × 720")
combo2.AddItem("1024 × 768")
combo2.SetPlaceholder("Select resolution...")
win.AddChild combo2

Local info:TPanel = New TPanel(30, 280, 640, 170, "Current selection", PANEL_STYLE_RAISED)
win.AddChild info

Local sel1:TLabel = New TLabel(20, 25, 600, 24, "Difficulty: Normal")
sel1.SetColor(220, 255, 180)
info.AddChild sel1

Local sel2:TLabel = New TLabel(20, 60, 600, 24, "Resolution: ---")
info.AddChild sel2

Local status:TLabel = New TLabel(20, 110, 600, 24, "Click on the combo to open the list")
status.SetColor(180, 200, 255)
info.AddChild status

' =============================================================================
' 									MAIN LOOP
' =============================================================================
While Not KeyHit(KEY_ESCAPE)
    Cls()
	
	TBackground.Refresh()
    TWidget.GuiRefresh()

    If combo1.SelectionChanged()
        sel1.SetText("Difficulty: " + combo1.GetSelectedText())
        status.SetText("Difficulty changed !")
    EndIf

    If combo2.SelectionChanged()
        sel2.SetText("Resolution: " + combo2.GetSelectedText())
        status.SetText("Resolution changed !")
    EndIf

    ClearAllEvents(root)

    SetColor 255, 191, 16
    DrawText "ComboBox Demo – ESC to quit", 10, 10
   
    Flip
Wend

End