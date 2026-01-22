' =============================================================================
'              Simple GUI Framework - BlitzMax NG (By Eagle54 2026)
' 							SLIDER DEMO 2 : Opaline UI
' =============================================================================
' Opaline UI - Simple GUI Framework
' https://github.com/BlackCreepyCat
' =============================================================================

SuperStrict

Import BRL.GLMax2D
Import BRL.LinkedList

Include "opaline/gui_opaline.bmx"

' Declare vars
Global pos_x:Int = 10, pos_y:Int = 10
Global frame:Int = 0, xtimes:Int = 0
Global anim:TImage
Global max_xtime:Int = 10
Global max_scale:Int = 4

Const MAX_FRAME:Int = 5
Const SIZEIMG:Int = 512
 
Graphics 1280, 720, 0

' Initialize the GUI
TWidget.GuiInit()

' Create root container
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

' =============================================================
'                         GUI BUILDING
' =============================================================
Local win:TWindow = New TWindow(530, 10, 300, 480, "Slider Demo 2", False, True, True)
root.AddChild win

Local vslider1:TSlider = New TSlider(10, 10, 24, 180, 1.0, SLIDER_STYLE_VERTICAL)
vslider1.SetRange(5, 20)
vslider1.SetValue(max_xtime)
win.AddChild vslider1

Local vslider2:TSlider = New TSlider(150, 10, 24, 180, 1.0, SLIDER_STYLE_VERTICAL)
vslider2.SetRange(1, 4)
vslider2.SetValue(max_scale)
win.AddChild vslider2

Local title1:TLabel = New TLabel(10, 200, 100, 24, "Delay", LABEL_ALIGN_LEFT)
title1.SetColor(220, 200, 100)
win.AddChild title1

Local title2:TLabel = New TLabel(150, 200, 100, 24, "Scale", LABEL_ALIGN_LEFT)
title2.SetColor(220, 200, 100)
win.AddChild title2

Local val1:TLabel = New TLabel(50, 80, 150, 24, "Delay:", LABEL_ALIGN_LEFT)
val1.SetColor(220, 255, 180)
win.AddChild val1

Local val2:TLabel = New TLabel(190, 80, 250, 24, "Scale:", LABEL_ALIGN_LEFT)
val2.SetColor(255, 220, 140)
win.AddChild val2


' =============================================================================
'                         SETUP IMAGE
' =============================================================================

SetMaskColor(255, 255, 255) ' White

' anti-aliasing OFF (pixel art READY!)
AutoImageFlags(MASKEDIMAGE)

' load anim image
anim = LoadAnimImage("zombie_walking.png", 128, 128, 0, MAX_FRAME)
If anim = Null Then
  Print "Image could Not load - Check path And filename"
  End
End If
 
' Draw empty rectangle Func
Function DrawEmptyRect(x:Int, y:Int, w:Int, h:Int)
	DrawLine x, y, x + w, y
	DrawLine x, y + h, x + h, y + h
	DrawLine x, y, x, y + h
	DrawLine  x + w, y,  x + w, y + h
End Function

' =============================================================================
'                              MAIN LOOP
' =============================================================================

While Not KeyHit(KEY_ESCAPE)

    Cls()

    SetScale(1,1)
	
    TWidget.GuiRefresh()

    ' update value of sliders
    val1.SetText("Delay: " + Int(vslider1.GetValue()))
    val2.SetText("Scale: " + Int(vslider2.GetValue()))
    max_xtime = Int(vslider1.GetValue())
    max_scale = Int(vslider2.GetValue())

    ClearAllEvents(root)

    SetColor 255, 191, 16
    DrawText "Slider Demo 2 – ESC to quit", 1000, 10

    ' draw rectangles
    SetColor 255, 220, 140
    DrawEmptyRect(pos_x, pos_x, SIZEIMG, SIZEIMG)
    SetColor 30, 30, 60
    DrawRect(pos_x + 5, pos_y + 5, SIZEIMG - 10, SIZEIMG - 10)

    ' scale and draw image
    SetScale(max_scale, max_scale)
    SetColor 255, 255, 255
    DrawImage(anim, pos_x + 1, pos_y + 1, frame)

    ' compute delay between frames
    xtimes:+1
    If xtimes > max_xtime Then
        xtimes = 0
        frame:+1
        If frame = MAX_FRAME Then
            frame = 0
        End If 
    End If 
 
    Flip

Wend

End
