' =============================================================================
'                     Simple GUI Framework - BlitzMax NG
'                          INPUTBOX DEMO : Opaline UI
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
Local win:TWindow = New TWindow(50, 50, 700, 500, "TextInput Demo", False, True, True)
root.AddChild win

Local title:TLabel = New TLabel(20, 20, 660, 24, "Opaline GUI - TextInput Demonstration", LABEL_ALIGN_CENTER)
title.SetColor(100, 220, 180)
win.AddChild title

Local lbl1:TLabel = New TLabel(30, 70, 200, 20, "Name:")
win.AddChild lbl1
Local input1:TTextInput = New TTextInput(150, 68, 300, 32, "")
input1.SetPlaceholder("Enter your name...")
win.AddChild input1

Local lbl2:TLabel = New TLabel(30, 120, 200, 20, "Email:")
win.AddChild lbl2
Local input2:TTextInput = New TTextInput(150, 118, 300, 32, "")
input2.SetPlaceholder("example@domain.com")
win.AddChild input2

Local lbl3:TLabel = New TLabel(30, 170, 200, 20, "Password:")
win.AddChild lbl3
Local input3:TTextInput = New TTextInput(150, 168, 300, 32, "")
input3.SetPasswordMode(True)
input3.SetPlaceholder("••••••••")
win.AddChild input3

Local lbl4:TLabel = New TLabel(30, 220, 200, 20, "Code (max 8):")
win.AddChild lbl4
Local input4:TTextInput = New TTextInput(150, 218, 140, 32, "")
input4.SetMaxLength(8)
input4.SetPlaceholder("XXXX-XXXX")
win.AddChild input4

Local info:TPanel = New TPanel(30, 280, 640, 180, "Current values", PANEL_STYLE_RAISED)
win.AddChild info

Local val1:TLabel = New TLabel(20, 25, 600, 24, "Name: ")
val1.SetColor(220, 255, 180)
info.AddChild val1

Local val2:TLabel = New TLabel(20, 50, 600, 24, "Email: ")
info.AddChild val2

Local val3:TLabel = New TLabel(20, 75, 600, 24, "Password: ")
info.AddChild val3

Local status:TLabel = New TLabel(20, 100, 600, 24, "Press Enter to submit")
status.SetColor(180, 200, 255)
info.AddChild status

' =============================================================================
'                              MAIN LOOP
' =============================================================================
While Not KeyHit(KEY_ESCAPE)
    Cls()
	
	TBackground.Refresh()
    TWidget.GuiRefresh()

    If input1.TextChanged() Or input1.WasSubmitted()
        val1.SetText("Name: " + input1.GetText())
        If input1.WasSubmitted() Then status.SetText("Name validated!")
    EndIf

    If input2.TextChanged() Or input2.WasSubmitted()
        val2.SetText("Email: " + input2.GetText())
        If input2.WasSubmitted() Then status.SetText("Email validated!")
    EndIf

    If input3.TextChanged() Or input3.WasSubmitted()
        val3.SetText("Password: " + input3.GetText())
        If input3.WasSubmitted() Then status.SetText("Password validated!")
    EndIf

    If input4.TextChanged() Or input4.WasSubmitted()
        status.SetText("Code: " + input4.GetText())
        If input4.WasSubmitted() Then status.SetText("Code validated!")
    EndIf

    ClearAllEvents(root)
    SetColor 255, 145, 0
    DrawText "TextInput Demo  –  ESC to quit", 10, 10
    Flip
Wend

End
