' =============================================================================
'                     Simple GUI Framework - BlitzMax NG
'                          BOUTON DEMO : Opaline UI
'        By Creepy Cat (C)2025/2026 : https://github.com/BlackCreepyCat
' =============================================================================

SuperStrict

' Import required BlitzMax modules
Import BRL.GLMax2D
Import BRL.LinkedList

Include "opaline/gui_opaline.bmx"

Graphics 1024, 768, 0

' Init the GUI
TWidget.GuiInit()

' Creating the animated background
TBackground.Init()

' Create root container
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

' =============================================================
'                         GUI BUILDING
' =============================================================
Local win:TWindow = New TWindow(50, 50, 700, 500, "Button Demo", False, True, True)
root.AddChild win

Local title:TLabel = New TLabel(20, 20, 660, 24, "Opaline GUI - Button Demonstration", LABEL_ALIGN_CENTER)
title.SetColor(255, 220, 100)
win.AddChild title

' --- Standard buttons ---
Local lblNormal:TLabel = New TLabel(30, 70, 300, 20, "Standard buttons:")
win.AddChild lblNormal

Local btn1:TButton = New TButton(30, 100, 180, 38, "Click me")
win.AddChild btn1

Local btn2:TButton = New TButton(30, 150, 180, 38, "Danger")
btn2.SetColor(220, 60, 60)
win.AddChild btn2

Local btn3:TButton = New TButton(30, 200, 180, 38, "Disabled")
btn3.SetEnabled(False)
win.AddChild btn3

' --- Toggle-like buttons (via color) ---
Local lblToggle:TLabel = New TLabel(300, 70, 300, 20, "Toggle effect (color change):")
win.AddChild lblToggle

Local btnToggle:TButton = New TButton(300, 100, 180, 38, "ON / OFF")
btnToggle.SetColor(60, 180, 80)
win.AddChild btnToggle

' --- Info ---
Local info:TPanel = New TPanel(30, 280, 640, 180, "Events", PANEL_STYLE_RAISED)
win.AddChild info

Local status:TLabel = New TLabel(20, 35, 600, 24, "Click a button...")
status.SetColor(180, 220, 255)
info.AddChild status

Local countLabel:TLabel = New TLabel(20, 80, 600, 24, "Total clicks: 0")
countLabel.SetColor(255, 220, 140)
info.AddChild countLabel

Local lastBtn:TLabel = New TLabel(20, 125, 600, 24, "Last button: none")
info.AddChild lastBtn

Local clickCount:Int = 0
Local switch:Int
    
' =============================================================================
'                              MAIN LOOP
' =============================================================================
While Not KeyHit(KEY_ESCAPE)
    Cls()

	TBackground.Refresh()
    TWidget.GuiRefresh()

    If btn1.WasClicked()
        status.SetText("Standard button clicked!")
        status.SetColor(100, 255, 140)
        clickCount:+1
        countLabel.SetText("Total clicks: " + clickCount)
        lastBtn.SetText("Last button: standard")
    EndIf

    If btn2.WasClicked()
        status.SetText("Warning! Danger button activated")
        status.SetColor(255, 120, 100)
        clickCount:+1
        countLabel.SetText("Total clicks: " + clickCount)
        lastBtn.SetText("Last button: danger")
    EndIf

    If btnToggle.WasClicked()
        switch = 1-switch

        If switch=1
            btnToggle.SetColor(220, 60, 60)
            status.SetText("OFF mode activated")
        ElseIf switch=0
            btnToggle.SetColor(60, 180, 80)
            status.SetText("ON mode activated")
        EndIf

        status.SetColor(200, 200, 255)
        clickCount:+1
        countLabel.SetText("Total clicks: " + clickCount)
        lastBtn.SetText("Last button: toggle")
    EndIf

    ClearAllEvents(root)

    SetColor 220, 180, 100
    DrawText "Button Demo  –  ESC to quit", 10, 10

    Flip
Wend

End
