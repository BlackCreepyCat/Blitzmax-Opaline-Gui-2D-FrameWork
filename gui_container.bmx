' =============================================================================
'                           ROOT CONTAINER
' =============================================================================
' Top-level container that holds all windows
' =============================================================================

Type TContainer Extends TWidget
    Method New(w:Int, h:Int)
        Super.New(0, 0, w, h)
    End Method

    ' Draw all child windows
    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        
        For Local c:TWidget = EachIn children
            c.Draw(rect.x, rect.y)
        Next
    End Method

    ' Update all child windows (reverse order for proper z-order handling)
    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        
        Local rev:TList = New TList

        For Local c:TWidget = EachIn children
            rev.AddFirst(c)
        Next

    '   For Local c:TWidget = EachIn rev
' If c.Update(mx, my) Then Return True
    '    Next

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
End Type