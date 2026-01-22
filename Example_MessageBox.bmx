' =============================================================================
'                   Simple GUI Framework - BlitzMax NG
'                       MESSAGEBOX DEMO : Opaline UI
'       By Creepy Cat (C)2025/2026 : https://github.com/BlackCreepyCat
' =============================================================================
SuperStrict

' Import required BlitzMax modules
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
'                           GUI BUILDING
' =============================================================
Local win:TWindow = New TWindow(50, 50, 700, 500, "MessageBox Demo", False, True, True)
root.AddChild win

Local title:TLabel = New TLabel(20, 20, 660, 24, "Opaline GUI - MessageBox Demonstration", LABEL_ALIGN_CENTER)
title.SetColor(255, 180, 140)
win.AddChild title

Local lbl:TLabel = New TLabel(30, 80, 640, 40, "Click the buttons below to show different MessageBox types", LABEL_ALIGN_CENTER)
win.AddChild lbl

Local btnOK:TButton = New TButton(70, 150, 180, 40, "Show OK Message")
win.AddChild btnOK

Local btnYesNo:TButton = New TButton(270, 150, 180, 40, "Yes / No Question")
win.AddChild btnYesNo

Local btnYesNoCancel:TButton = New TButton(470, 150, 180, 40, "Yes / No / Cancel")
win.AddChild btnYesNoCancel

Local info:TPanel = New TPanel(30, 220, 640, 220, "MessageBox Result", PANEL_STYLE_RAISED)
win.AddChild info

Global result:TLabel = New TLabel(20, 35, 600, 24, "No message shown yet")
result.SetColor(220, 255, 180)
info.AddChild result

Local detail:TLabel = New TLabel(20, 80, 600, 24, "MessageBox blocks input until closed")
detail.SetColor(180, 200, 255)
info.AddChild detail

' Callback function for results
Function OnMsgResult:Int(res:Int)
    Select res
        Case MSGBOX_RESULT_OK
		    result.SetText("Result: OK")

        Case MSGBOX_RESULT_YES      
			result.SetText("Result: YES")
        Case MSGBOX_RESULT_NO       
			result.SetText("Result: NO")
        Case MSGBOX_RESULT_CANCEL  
			 result.SetText("Result: CANCEL")
        Default                    
		 	result.SetText("Result: Unknown (" + res + ")")
    End Select

    result.SetColor(255, 220, 140)

    Return 0
End Function

' =============================================================================
'                                   MAIN LOOP
' =============================================================================
While Not KeyHit(KEY_ESCAPE)
    Cls()

	TBackground.Refresh()
    TWidget.GuiRefresh()

    If btnOK.WasClicked()
        TMessageBox.ShowOK("Information", "This is a simple OK message box.", OnMsgResult)
    EndIf

    If btnYesNo.WasClicked()
        TMessageBox.ShowYesNo("Confirm", "Do you want to continue?", OnMsgResult)
    EndIf

    If btnYesNoCancel.WasClicked()
        TMessageBox.ShowYesNoCancel("Warning", "Save changes before closing?", OnMsgResult)
    EndIf

    ClearAllEvents(root)

    SetColor 255, 191, 16
    DrawText "MessageBox Demo – ESC to quit", 10, 10
   
    Flip
Wend
End