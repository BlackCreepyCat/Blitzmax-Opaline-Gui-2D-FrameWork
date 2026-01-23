' =============================================================================
'                          EVENT PROCESSING
' =============================================================================
' Process window control buttons (close, minimize, maximize)

' This is optional - you can handle events manually in your main loop
Function ProcessWindowControlEvents(widget:TWidget)
    If TButton(widget)
        Local btn:TButton = TButton(widget)
        
        ' Only handle window control buttons
        If TWindow(widget.parent) And btn.WasClicked()
            Local win:TWindow = TWindow(widget.parent)
            
            Select btn.buttonType
                Case BTN_TYPE_CLOSE
                    Print "Closing window: " + win.title
                    
                    ' Remove from taskbar if minimized
                    If g_TaskBar <> Null
                        g_TaskBar.RemoveWindow(win)
                    EndIf
                    
                    ' Ferme la fenêtre parente
                    win.Close()
                    btn.ClearEvents()
                    Return
                
                Case BTN_TYPE_MINIMIZE
                    Print "Minimizing window: " + win.title
                    
                    ' Minimize to taskbar
                    If g_TaskBar <> Null
                        TaskBarMinimizeWindow(win)
                    Else
                        ' Fallback: just hide the window
                        win.Hide()
                    EndIf
                    btn.ClearEvents()
                    Return
                
                Case BTN_TYPE_MAXIMIZE
                    Print "Maximize clicked (not implemented yet)"
                    ' Future: TWindow(widget.parent).Maximize()
                    ' À implémenter : maximisation de la fenêtre
            End Select
        EndIf
    EndIf

    ' Recursively process children
    For Local c:TWidget = EachIn widget.children
        ProcessWindowControlEvents(c)
    Next
End Function

' Clear all events in a widget tree
' Clear all events in a widget tree
Function ClearAllEvents(widget:TWidget)
    ' Clear events depending on widget type
    If TButton(widget)
        TButton(widget).ClearEvents()
    ElseIf TCheckBox(widget)
        TCheckBox(widget).ClearEvents()
    ElseIf TRadio(widget)
        TRadio(widget).ClearEvents()
    ElseIf TSlider(widget)
        TSlider(widget).ClearEvents()
    ElseIf TTextInput(widget)
        TTextInput(widget).ClearEvents()
    ElseIf TTextArea(widget)
        TTextArea(widget).ClearEvents()
    ElseIf TListBox(widget)
        TListBox(widget).ClearEvents()
    ElseIf TComboBox(widget)
        TComboBox(widget).ClearEvents()
    ElseIf TTreeView(widget)  
        TTreeView(widget).ClearEvents()
    EndIf
    
    ' Recursively clear children events
    For Local c:TWidget = EachIn widget.children
        ClearAllEvents(c)
    Next
End Function
