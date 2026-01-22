' =============================================================================
' 					Simple GUI Framework - BlitzMax NG
' 						PANEL DEMO : Opaline UI
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
Local win:TWindow = New TWindow(50, 50, 700, 600, "Panel Demo", False, True, True)
root.AddChild win

Local title:TLabel = New TLabel(20, 20, 660, 24, "Opaline GUI - Panel Demonstration", LABEL_ALIGN_CENTER)
title.SetColor(200, 220, 140)
win.AddChild title

Local lbl:TLabel = New TLabel(30, 70, 400, 20, "Different panel styles and nesting:")
win.AddChild lbl

' Raised panel
Local panel1:TPanel = New TPanel(30, 110, 300, 140, "Raised Panel", PANEL_STYLE_RAISED)
win.AddChild panel1

Local btn1:TButton = New TButton(20, 40, 260, 35, "Action Button")
panel1.AddChild btn1

' Sunken panel
Local panel2:TPanel = New TPanel(350, 110, 300, 140, "Sunken Panel", PANEL_STYLE_SUNKEN)
win.AddChild panel2

Local lblInside:TLabel = New TLabel(20, 40, 260, 24, "Status: Ready", LABEL_ALIGN_CENTER)
lblInside.SetColor(150, 255, 150)
panel2.AddChild lblInside

' Nested panels demo
Local outer:TPanel = New TPanel(30, 270, 620, 180, "Nested Panels Example", PANEL_STYLE_RAISED)
win.AddChild outer

Local inner1:TPanel = New TPanel(20, 20, 280, 120, "Inner A", PANEL_STYLE_SUNKEN)
outer.AddChild inner1

Local inner2:TPanel = New TPanel(320, 20, 280, 120, "Inner B", PANEL_STYLE_RAISED)
outer.AddChild inner2

Local info:TPanel = New TPanel(30, 460, 640, 100, "Panel features", PANEL_STYLE_RAISED)
win.AddChild info

Local info1:TLabel = New TLabel(20, 20, 600, 24, "• Styles: Raised / Sunken")
info1.SetColor(220, 220, 255)
info.AddChild info1

Local info2:TLabel = New TLabel(20, 45, 600, 24, "• Can contain buttons, labels, other panels...")
info2.SetColor(255, 220, 180)
info.AddChild info2

' =============================================================================
' MAIN LOOP
' =============================================================================
While Not KeyHit(KEY_ESCAPE)
    Cls()
    TWidget.GuiRefresh()

    ClearAllEvents(root)

    SetColor 255, 191, 16
    DrawText "Panel Demo – ESC to quit", 10, 10
   
    Flip
Wend
End