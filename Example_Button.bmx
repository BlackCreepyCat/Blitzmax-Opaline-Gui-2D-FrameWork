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
Include "gui_constants.bmx"
Include "gui_core.bmx"
Include "gui_mouse.bmx"
Include "gui_container.bmx"
Include "gui_window.bmx"
Include "gui_button.bmx"
Include "gui_checkbox.bmx"
Include "gui_radio.bmx"
Include "gui_label.bmx"
Include "gui_panel.bmx"
Include "gui_progressbar.bmx"
Include "gui_slider.bmx"
Include "gui_textinput.bmx"
Include "gui_listbox.bmx"
Include "gui_combobox.bmx"
Include "gui_tabber.bmx"
Include "gui_events.bmx"


Graphics 800, 600, 0

TWidget.GuiInit()
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

Local win:TWindow = New TWindow(100, 100, 600, 400, "Opaline Demo Button (check console)", True, True, True)
root.AddChild win

Local btn:TButton = New TButton(20, 20, 200, 40, "Click me!")
win.AddChild btn

' Main loop
While Not KeyDown(KEY_ESCAPE)
    Cls
	
	' Refresh
    TWidget.GuiUpdate()   
    TWidget.GuiDraw()     
	
	' Events
	If btn.WasClicked() Then Print "Bouton clicked!"

    ' Clear all pending events at the end of the frame
    ClearAllEvents(root)

    Flip
Wend