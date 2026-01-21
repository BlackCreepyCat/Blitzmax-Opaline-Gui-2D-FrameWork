' =============================================================================
'                           ROOT CONTAINER
' =============================================================================
' Top-level container that holds all windows
' Supports MODAL windows with overlay rendering
' =============================================================================

Type TContainer Extends TWidget
    Method New(w:Int, h:Int)
        Super.New(0, 0, w, h)
    End Method

    ' Draw all child windows
    ' If a modal window is active, draw an overlay behind it
    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        
        ' Check if modal is active
        Local modalActive:Int = TWindow.IsAnyModalActive()
        Local modalWin:TWindow = TWindow.GetActiveModalWindow()
        
        ' Draw non-modal windows first
        For Local c:TWidget = EachIn children
            If TWindow(c)
                If Not TWindow(c).isModal
                    c.Draw(rect.x, rect.y)
                EndIf
            Else
                c.Draw(rect.x, rect.y)
            EndIf
        Next
        
        ' If modal is active, draw overlay then the modal window
        If modalActive And modalWin
            ' Draw semi-transparent overlay
            SetBlend(ALPHABLEND)
            SetAlpha(COLOR_MODAL_OVERLAY_ALPHA)
            SetColor(COLOR_MODAL_OVERLAY_R, COLOR_MODAL_OVERLAY_G, COLOR_MODAL_OVERLAY_B)
            DrawRect(0, 0, rect.w, rect.h)
            SetAlpha(1.0)
            SetColor(255, 255, 255)
            
            ' Draw modal window on top
            modalWin.Draw(rect.x, rect.y)
        EndIf
    End Method

    ' Update all child windows (reverse order for proper z-order handling)
    ' If a modal window is active, only update the modal window
    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        
        ' Check if modal is active
        Local modalActive:Int = TWindow.IsAnyModalActive()
        Local modalWin:TWindow = TWindow.GetActiveModalWindow()
        
        ' If modal is active, only update the modal window
        If modalActive And modalWin
            ' -------------------------------------------------
            ' BLOCK UPDATE FOR WIDGETS UNDER COMBOBOX POPUP
            ' (inside modal window)
            ' -------------------------------------------------
            If TComboBox.IsPopupActive()
                If modalWin = TWindow(g_ActiveComboBox.parent) Or IsChildOf(g_ActiveComboBox, modalWin)
                    ' ComboBox is in modal window, allow update
                    Return modalWin.Update(mx, my)
                Else
                    ' ComboBox is outside modal, block it
                    Return modalWin.Update(mx, my)
                EndIf
            EndIf
            
            Return modalWin.Update(mx, my)
        EndIf
        
        ' Normal update (no modal active)
        Local rev:TList = New TList

        For Local c:TWidget = EachIn children
            rev.AddFirst(c)
        Next

        For Local c:TWidget = EachIn rev

            ' -------------------------------------------------
            ' BLOCK UPDATE FOR WIDGETS UNDER COMBOBOX POPUP
            ' -------------------------------------------------
            If TComboBox.IsPopupActive()
                If c <> g_ActiveComboBox
                    ' Ne pas appeler Update → pas de hover, pas de highlight
                    Continue
                EndIf
            EndIf

            If c.Update(mx, my) Then Return True
        Next

        Return False
    End Method
    
    ' Helper function to check if a widget is a child of another widget
    Function IsChildOf:Int(widget:TWidget, potentialParent:TWidget)
        Local current:TWidget = widget.parent
        While current
            If current = potentialParent Then Return True
            current = current.parent
        Wend
        Return False
    End Function
End Type
