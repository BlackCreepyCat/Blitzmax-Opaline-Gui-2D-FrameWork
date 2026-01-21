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

Include "gui_opaline.bmx"

Graphics 1280, 720, 0

TWidget.GuiInit()

Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

' Créer une fenêtre avec bouton
Local win:TWindow = New TWindow(100, 100, 300, 200, "Hello Opaline")
Local btn:TButton = New TButton(50, 50, 200, 40, "Click Me!")
Local lbl:TLabel = New TLabel(50, 100, 200, 30, "Status: Ready")

win.AddChild(btn)
win.AddChild(lbl)
root.AddChild(win)

While Not AppTerminate()
    Cls
    TWidget.GuiRefresh()
    
    If btn.WasClicked()
        lbl.SetText("Status: Clicked!")
        btn.ClearEvents()
    EndIf
    
    Flip
Wend