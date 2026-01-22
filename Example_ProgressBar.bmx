' =============================================================================
' 					Simple GUI Framework - BlitzMax NG
' 						PROGRESSBAR DEMO : Opaline UI
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

' Create root container
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

' =============================================================
' 							GUI BUILDING
' =============================================================
Local win:TWindow = New TWindow(50, 50, 700, 500, "ProgressBar Demo", False, True, True)
root.AddChild win

Local title:TLabel = New TLabel(20, 20, 660, 24, "Opaline GUI - ProgressBar Demonstration", LABEL_ALIGN_CENTER)
title.SetColor(100, 200, 255)
win.AddChild title

Local lbl1:TLabel = New TLabel(30, 70, 400, 20, "Horizontal progress bars:")
win.AddChild lbl1

Local pb1:TProgressBar = New TProgressBar(30, 110, 300, 28,1)
pb1.SetFillColor(60, 200, 80)
win.AddChild pb1

Local pb2:TProgressBar = New TProgressBar(30, 160, 300, 28, 0.68)
pb2.SetFillColor(220, 80, 60)
win.AddChild pb2

Local lbl2:TLabel = New TLabel(30, 220, 400, 20, "Vertical progress bars:")
win.AddChild lbl2

Local vpb1:TProgressBar = New TProgressBar(380, 110, 38, 180, 0.45)
vpb1.SetStyle(PROGRESSBAR_STYLE_VERTICAL)
vpb1.SetFillColor(80, 140, 220)
win.AddChild vpb1

Local vpb2:TProgressBar = New TProgressBar(440, 110, 38, 180, 0.82)
vpb2.SetStyle(PROGRESSBAR_STYLE_VERTICAL)
vpb2.SetFillColor(200, 180, 60)
win.AddChild vpb2

Local info:TPanel = New TPanel(30, 320, 640, 160, "Current values", PANEL_STYLE_RAISED)
win.AddChild info

Local val1:TLabel = New TLabel(20, 25, 600, 24, "Bar 1: 35%")
val1.SetColor(150, 255, 150)
info.AddChild val1

Local val2:TLabel = New TLabel(20, 50, 600, 24, "Bar 2: 68%")
val2.SetColor(255, 140, 100)
info.AddChild val2

Local val3:TLabel = New TLabel(20, 75, 600, 24, "Vertical 1: 45%")
info.AddChild val3

Local val4:TLabel = New TLabel(20, 100, 600, 24, "Vertical 2: 82%")
val4.SetColor(255, 220, 100)
info.AddChild val4

' =============================================================================
' 									MAIN LOOP
' =============================================================================
While Not KeyHit(KEY_ESCAPE)
    Cls()
    TWidget.GuiRefresh()

    Local t:Float = (MilliSecs() Mod 5000) / 5000.0
	Local mousePercent:Float = Float(GuiMouse.x) / Float(GraphicsWidth())

	pb1.SetValue(mousePercent)
    pb2.SetValue(1.0 - t)
    vpb1.SetValue(t * 0.7 + 0.15)
    vpb2.SetValue((t + 0.3) Mod 1.0)

    val1.SetText("Bar 1: " + Int(pb1.GetValue()*100) + "%")
    val2.SetText("Bar 2: " + Int(pb2.GetValue()*100) + "%")
    val3.SetText("Vertical 1: " + Int(vpb1.GetValue()*100) + "%")
    val4.SetText("Vertical 2: " + Int(vpb2.GetValue()*100) + "%")

    ClearAllEvents(root)

    SetColor 255, 191, 16
    DrawText "ProgressBar Demo – ESC to quit", 10, 10
   
    Flip
Wend

End