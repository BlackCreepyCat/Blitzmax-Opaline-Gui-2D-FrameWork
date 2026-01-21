' =============================================================================
'                  Simple GUI Framework - BlitzMax NG
'                           MAIN FILE : Opaline UI
' =============================================================================
' By Creepy Cat (C)2025/2026
' https://github.com/BlackCreepyCat
'
' You can use this code:
' - However you wish, but you are prohibited from selling it...
' - You can convert it into another language! Do not hesitate!
' - Use it For paid/free apps/games, i don't care...
' - I'm just asking for a small citation somewhere! :)
' =============================================================================

SuperStrict
Import BRL.GLMax2D
Import BRL.LinkedList

' Import GUI framework modules
Include "gui_opaline.bmx"


Graphics 800, 600, 0

TWidget.GuiInit()
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

Local win:TWindow = New TWindow(100, 100, 600, 400, "Opaline Demo Radio (check console)", True, True, True)
root.AddChild win

' Radio group
Local group:TList = New TList

Local r1:TRadio = New TRadio(40, 180, 20, 20, "Easy", group)
Local r2:TRadio = New TRadio(40, 210, 20, 20, "Normal", group)
Local r3:TRadio = New TRadio(40, 240, 20, 20, "Hard", group)
r2.selected = True

win.AddChild(r1); win.AddChild(r2); win.AddChild(r3)

' Main loop
While Not KeyDown(KEY_ESCAPE)
    Cls
	
	' Refresh
    TWidget.GuiUpdate()   
    TWidget.GuiDraw()     
	
	' Events
    If r1.WasSelected()
        Print "Easy"
    EndIf
    
    If r2.WasSelected()
         Print "Normal"
    EndIf
    
    If r3.WasSelected()
         Print "Hard"
    EndIf

    ' Clear all pending events at the end of the frame
    ClearAllEvents(root)

    Flip
Wend