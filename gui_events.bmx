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
            Select btn.buttonType
                Case BTN_TYPE_CLOSE
                    Print "Closing window..."

                    ' Ferme la fenêtre parente
                    TWindow(widget.parent).Close()
                    btn.ClearEvents()
                    Return
                
                Case BTN_TYPE_MINIMIZE
                    Print "Minimize clicked (not implemented yet)"
                    ' Future: TWindow(widget.parent).Minimize()
                    ' À implémenter : minimisation de la fenêtre
                
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
    EndIf
    
    ' Recursively clear children events
    For Local c:TWidget = EachIn widget.children
        ClearAllEvents(c)
    Next
End Function
