' =============================================================================
' 					Simple GUI Framework - BlitzMax NG
' 						IMAGEBOX DEMO : Opaline UI
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
Local win:TWindow = New TWindow(50, 50, 700, 500, "ImageBox Demo", False, True, True)
root.AddChild win

Local title:TLabel = New TLabel(20, 20, 660, 24, "Opaline GUI - ImageBox Demonstration", LABEL_ALIGN_CENTER)
title.SetColor(255, 180, 100)
win.AddChild title

Local lbl1:TLabel = New TLabel(30, 70, 400, 20, "Different ImageBox styles:")
win.AddChild lbl1

Local img1:TImageBox = New TImageBox(30, 110, 100, 100)
img1.SetBackgroundColor(60, 60, 80)
img1.LoadFromFile("image.jpg")
img1.SetShowBorder(True)
win.AddChild img1

Local img2:TImageBox = New TImageBox(160, 110, 100, 100)
img2.SetShowBorder(True)
img2.SetBorderStyle(IMAGEBOX_STYLE_RAISED)
win.AddChild img2

Local img3:TImageBox = New TImageBox(290, 110, 100, 100)
img3.SetShowBorder(True)
img3.SetBorderStyle(IMAGEBOX_STYLE_SUNKEN)
win.AddChild img3

Local img4:TImageBox = New TImageBox(420, 110, 100, 100)
img4.SetShowBorder(True)
img4.SetClickable(True)
img4.SetBorderColor(180, 100, 220)
win.AddChild img4

Local info:TPanel = New TPanel(30, 240, 640, 220, "ImageBox status", PANEL_STYLE_RAISED)
win.AddChild info

Local status:TLabel = New TLabel(20, 25, 600, 24, "Click on the purple bordered image")
status.SetColor(220, 200, 255)
info.AddChild status

Local hover:TLabel = New TLabel(20, 60, 600, 24, "Hover status: none")
info.AddChild hover

' =============================================================================
' 									MAIN LOOP
' =============================================================================
While Not KeyHit(KEY_ESCAPE)
    Cls()
    TWidget.GuiRefresh()

    If img4.WasClicked()
        status.SetText("Clickable ImageBox was clicked !")
        status.SetColor(120, 255, 140)
    EndIf

    If img4.IsHovered()
        hover.SetText("Hover status: over clickable image")
        hover.SetColor(255, 220, 100)
    Else
        hover.SetText("Hover status: none")
        hover.SetColor(180, 180, 180)
    EndIf

    ClearAllEvents(root)

    SetColor 255, 191, 16
    DrawText "ImageBox Demo – ESC to quit", 10, 10
   
    Flip
Wend
End