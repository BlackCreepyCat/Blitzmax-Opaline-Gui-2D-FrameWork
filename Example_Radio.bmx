' =============================================================================
'                   Simple GUI Framework - BlitzMax NG
'                       RADIO DEMO : Opaline UI
'         By Creepy Cat (C)2025/2026 : https://github.com/BlackCreepyCat
' =============================================================================
SuperStrict

' Import required BlitzMax modules
Import BRL.GLMax2D
Import BRL.LinkedList

Include "opaline/gui_opaline.bmx"

Graphics 1024,768, 0

' Initialize the GUI
TWidget.GuiInit()

' Creating the animated background
TBackground.Init()

' Create root container
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

' =============================================================
'                           GUI BUILDING
' =============================================================
Local win:TWindow = New TWindow(50, 50, 700, 500, "Radio Demo", False, True, True)
root.AddChild win

Local title:TLabel = New TLabel(20, 20, 660, 24, "Opaline GUI - Radio Button Demonstration", LABEL_ALIGN_CENTER)
title.SetColor(180, 220, 180)
win.AddChild title

Local lbl:TLabel = New TLabel(30, 70, 400, 20, "Choose one option (grouped radios):")
win.AddChild lbl

' Create a radio group (shared list)
Local radioGroup:TList = New TList

Local r1:TRadio = New TRadio(30, 110, 20, 20, "Option A - Default", radioGroup)
r1.selected = True
win.AddChild r1

Local r2:TRadio = New TRadio(30, 150, 20, 20, "Option B - Alternative", radioGroup)
win.AddChild r2

Local r3:TRadio = New TRadio(30, 190, 20, 20, "Option C - Advanced", radioGroup)
win.AddChild r3

Local r4:TRadio = New TRadio(30, 230, 20, 20, "Option D - Expert", radioGroup)
win.AddChild r4

Local info:TPanel = New TPanel(30, 280, 640, 170, "Current selection", PANEL_STYLE_RAISED)
win.AddChild info

Local selected:TLabel = New TLabel(20, 35, 600, 24, "Selected: Option A - Default")
selected.SetColor(220, 255, 180)
info.AddChild selected

Local status:TLabel = New TLabel(20, 80, 600, 24, "Only one option can be selected at a time")
status.SetColor(180, 200, 255)
info.AddChild status

' =============================================================================
'                                   MAIN LOOP
' =============================================================================
While Not KeyHit(KEY_ESCAPE)
    Cls()

	TBackground.Refresh()
    TWidget.GuiRefresh()

    If r1.WasSelected()
        selected.SetText("Selected: " + r1.Caption)
    EndIf
    If r2.WasSelected()
        selected.SetText("Selected: " + r2.Caption)
    EndIf
    If r3.WasSelected()
        selected.SetText("Selected: " + r3.Caption)
    EndIf
    If r4.WasSelected()
        selected.SetText("Selected: " + r4.Caption)
    EndIf

    ClearAllEvents(root)

    SetColor 255, 191, 16
    DrawText "Radio Demo – ESC to quit", 10, 10
   
    Flip
Wend

End
