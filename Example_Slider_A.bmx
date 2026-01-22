' =============================================================================
' 						Simple GUI Framework - BlitzMax NG
' 							SLIDER DEMO : Opaline UI
' 		By Creepy Cat (C)2025/2026 : https://github.com/BlackCreepyCat
' =============================================================================
SuperStrict

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
'                         GUI BUILDING
' =============================================================
Local win:TWindow = New TWindow(50, 50, 700, 500, "Slider Demo", False, True, True)
root.AddChild win

Local title:TLabel = New TLabel(20, 20, 660, 24, "Opaline GUI - Slider Demonstration", LABEL_ALIGN_CENTER)
title.SetColor(220, 200, 100)
win.AddChild title

Local lbl1:TLabel = New TLabel(30, 70, 400, 20, "Horizontal sliders + value display:")
win.AddChild lbl1

Local slider1:TSlider = New TSlider(30, 110, 300, 24, 0.5, SLIDER_STYLE_HORIZONTAL)
win.AddChild slider1

Local slider2:TSlider = New TSlider(30, 160, 300, 24, 0.75, SLIDER_STYLE_HORIZONTAL)
slider2.SetThumbColor(220, 140, 60)
win.AddChild slider2

Local lbl2:TLabel = New TLabel(30, 220, 400, 20, "Vertical sliders:")
win.AddChild lbl2

Local vslider1:TSlider = New TSlider(380, 110, 24, 180, 0.3, SLIDER_STYLE_VERTICAL)
vslider1.SetRange(-1000, 1000)
win.AddChild vslider1

Local vslider2:TSlider = New TSlider(440, 110, 24, 180, 0.65, SLIDER_STYLE_VERTICAL)
vslider2.SetThumbColor(80, 180, 220)
vslider2.SetRange(0, 1000)
win.AddChild vslider2

Local info:TPanel = New TPanel(30, 320, 640, 160, "Current values", PANEL_STYLE_RAISED)
win.AddChild info

Local val1:TLabel = New TLabel(20, 25, 600, 24, "Horizontal 1: 50%")
val1.SetColor(220, 255, 180)
info.AddChild val1

Local val2:TLabel = New TLabel(20, 50, 600, 24, "Horizontal 2: 75%")
val2.SetColor(255, 220, 140)
info.AddChild val2

Local val3:TLabel = New TLabel(20, 75, 600, 24, "Vertical 1: 30%")
info.AddChild val3

Local val4:TLabel = New TLabel(20, 100, 600, 24, "Vertical 2: 65%")
val4.SetColor(180, 220, 255)
info.AddChild val4

' =============================================================================
'                              MAIN LOOP
' =============================================================================
While Not KeyHit(KEY_ESCAPE)
    Cls()

	TBackground.Refresh()
    TWidget.GuiRefresh()

    val1.SetText("Horizontal 1: " + Int(slider1.GetPercent()) + "%")
    val2.SetText("Horizontal 2: " + Int(slider2.GetPercent()) + "%")
    val3.SetText("Vertical 1:   " + Int(vslider1.GetPercent()) + "%"+ " / Value: " + vslider1.GetValue())
    val4.SetText("Vertical 2:   " + Int(vslider2.GetPercent()) + "%" + " / Value: " + vslider2.GetValue())

    ClearAllEvents(root)

    SetColor 255, 191, 16
    DrawText "Slider Demo – ESC to quit", 10, 10
   
    Flip
Wend

End
