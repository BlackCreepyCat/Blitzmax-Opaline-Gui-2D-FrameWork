' =============================================================================
'                       Simple GUI Framework - BlitzMax NG
'                           TEXTAREA DEMO : Opaline UI
'       By Creepy Cat (C)2025/2026 : https://github.com/BlackCreepyCat
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
'                           GUI BUILDING
' =============================================================
Local win:TWindow = New TWindow(50, 50, 700, 500, "TextArea Demo", False, True, True)
root.AddChild win

Local title:TLabel = New TLabel(20, 20, 660, 24, "Opaline GUI - TextArea Demonstration", LABEL_ALIGN_CENTER)
title.SetColor(140, 200, 255)
win.AddChild title

Local text:TTextArea = New TTextArea(30, 70, 640, 220, "Welcome to TextArea~n" + "You can write multi-line text here.~n" + "Copy / Paste / Select with mouse or keyboard.~n" + "Line numbers can be toggled.~n" + "Try to type something!")
    
text.SetShowLineNumbers(True)
win.AddChild text

Local info:TPanel = New TPanel(30, 310, 640, 150, "Cursor & document info", PANEL_STYLE_RAISED)
win.AddChild info

Local cursor:TLabel = New TLabel(20, 25, 600, 24, "Line: 1   Col: 1")
cursor.SetColor(220, 255, 180)
info.AddChild cursor

Local total:TLabel = New TLabel(20, 55, 600, 24, "Total lines: 5")
info.AddChild total

Local readonlyChk:TCheckBox = New TCheckBox(20, 90, 200, 24, "Read-only mode", False)
info.AddChild readonlyChk

' =============================================================================
'                                   MAIN LOOP
' =============================================================================
While Not KeyHit(KEY_ESCAPE)
    Cls()
    TWidget.GuiRefresh()

    cursor.SetText("Line: " + (text.cursorLine+1) + "   Col: " + (text.cursorCol+1))
    total.SetText("Total lines: " + text.GetLineCount())

    If readonlyChk.StateChanged()
        text.SetReadOnlyMode(readonlyChk.IsChecked())
    EndIf

    ClearAllEvents(root)

    SetColor 255, 191, 16
    DrawText "TextArea Demo – ESC to quit", 10, 10
   
    Flip
Wend

End