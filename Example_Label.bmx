' =============================================================================
' 					Simple GUI Framework - BlitzMax NG
' 						LABEL DEMO : Opaline UI
' 		By Creepy Cat (C)2025/2026 : https://github.com/BlackCreepyCat
' =============================================================================
SuperStrict

' Import required BlitzMax modules
Import BRL.GLMax2D
Import BRL.LinkedList

Include "opaline/gui_opaline.bmx"

Graphics 1024,768, 0

' Initialize the GUI
TWidget.GuiInit()

' Create root container
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

' =============================================================
' 							GUI BUILDING
' =============================================================
Local win:TWindow = New TWindow(50, 50, 700, 500, "Label Demo", False, True, True)
root.AddChild win

Local title:TLabel = New TLabel(20, 20, 660, 24, "Opaline GUI - Label Demonstration", LABEL_ALIGN_CENTER)
title.SetColor(220, 200, 120)
win.AddChild title

Local lblHeader:TLabel = New TLabel(30, 70, 400, 20, "Different label styles and alignments:")
win.AddChild lblHeader

' --- Label examples ---
Local lbl1:TLabel = New TLabel(30, 110, 600, 28, "Large centered title - Welcome!", LABEL_ALIGN_CENTER)
lbl1.SetColor(255, 220, 100)
win.AddChild lbl1

Local lbl2:TLabel = New TLabel(30, 160, 600, 24, "Left aligned (default)", LABEL_ALIGN_LEFT)
lbl2.SetColor(180, 255, 180)
win.AddChild lbl2

Local lbl3:TLabel = New TLabel(30, 200, 600, 24, "Right aligned", LABEL_ALIGN_RIGHT)
lbl3.SetColor(200, 180, 255)
win.AddChild lbl3

Local lbl4:TLabel = New TLabel(30, 240, 600, 24, "Custom colored label with long text that may be truncated if too wide", LABEL_ALIGN_LEFT)
lbl4.SetColor(255, 140, 100)
win.AddChild lbl4

Local lbl5:TLabel = New TLabel(30, 280, 600, 20, "Small discreet label", LABEL_ALIGN_CENTER)
lbl5.SetColor(140, 140, 160)
' lbl5.SetFontSize(16)   ' optional
win.AddChild lbl5

Local info:TPanel = New TPanel(30, 330, 640, 130, "Label features overview", PANEL_STYLE_RAISED)
win.AddChild info

Local info1:TLabel = New TLabel(20, 25, 600, 24, "• Supports alignments: Left / Center / Right")
info1.SetColor(220, 220, 255)
info.AddChild info1

Local info2:TLabel = New TLabel(20, 50, 600, 24, "• Customizable colors via SetColor(r,g,b)")
info2.SetColor(255, 220, 180)
info.AddChild info2

Local info3:TLabel = New TLabel(20, 75, 600, 24, "• Used everywhere: titles, status, captions...")
info3.SetColor(180, 255, 200)
info.AddChild info3

' =============================================================================
' 									MAIN LOOP
' =============================================================================
While Not KeyHit(KEY_ESCAPE)
    Cls()
    TWidget.GuiRefresh()

    info1.SetText(MouseX())   ' ← commented example - you can uncomment to test

    ClearAllEvents(root)

    SetColor 255, 191, 16
    DrawText "Label Demo – ESC to quit", 10, 10
   
    Flip
Wend
End