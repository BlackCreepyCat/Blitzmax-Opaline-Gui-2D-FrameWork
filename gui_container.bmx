' =============================================================================
'                           ROOT CONTAINER
' =============================================================================
' Top-level container that holds all windows AND standalone widgets
' Supports MODAL windows with overlay rendering
' Standalone widgets (buttons, labels, etc.) can be added directly to root
' =============================================================================

Type TContainer Extends TWidget
    Method New(w:Int, h:Int)
        Super.New(0, 0, w, h)
    End Method

    ' =========================================================================
    '                              DRAW
    ' =========================================================================
    ' Draw order:
    ' 1. Non-window widgets (directly on screen, behind windows)
    ' 2. Non-modal windows
    ' 3. Modal overlay (if modal active)
    ' 4. Modal window (on top of everything)
    ' =========================================================================
    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        
        ' Check if modal is active
        Local modalActive:Int = TWindow.IsAnyModalActive()
        Local modalWin:TWindow = TWindow.GetActiveModalWindow()
        
        ' 1. Draw non-window widgets first (directly on screen, behind windows)
        For Local c:TWidget = EachIn children
            If Not TWindow(c)
                c.Draw(rect.x, rect.y)
            EndIf
        Next
        
        ' 2. Draw non-modal windows
        For Local c:TWidget = EachIn children
            If TWindow(c) And Not TWindow(c).isModal
                c.Draw(rect.x, rect.y)
            EndIf
        Next
        
        ' 3. If modal is active, draw overlay then the modal window
        If modalActive And modalWin
            ' Draw semi-transparent overlay
            SetBlend(ALPHABLEND)
            SetAlpha(COLOR_MODAL_OVERLAY_ALPHA)
            SetColor(COLOR_MODAL_OVERLAY_R, COLOR_MODAL_OVERLAY_G, COLOR_MODAL_OVERLAY_B)
            DrawRect(0, 0, rect.w, rect.h)
            SetAlpha(1.0)
            SetColor(255, 255, 255)
            
            ' 4. Draw modal window on top
            modalWin.Draw(rect.x, rect.y)
        EndIf
    End Method

    ' =========================================================================
    '                              UPDATE
    ' =========================================================================
    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        
        ' Check if modal is active
        Local modalActive:Int = TWindow.IsAnyModalActive()
        Local modalWin:TWindow = TWindow.GetActiveModalWindow()
        
        ' If modal is active, ONLY update the modal window
        If modalActive And modalWin
            If TComboBox.IsPopupActive()
                If IsChildOf(g_ActiveComboBox, modalWin)
                    Return modalWin.Update(mx, my)
                Else
                    g_ActiveComboBox.isOpen = False
                    g_ActiveComboBox = Null
                    Return modalWin.Update(mx, my)
                EndIf
            EndIf
            Return modalWin.Update(mx, my)
        EndIf
        
        ' -----------------------------------------------------------------
        ' Normal update (no modal active)
        ' -----------------------------------------------------------------
        
        ' PRIORITY 1: If a window is being dragged, update it regardless of mouse position
        If draggedWindow <> Null
            Return draggedWindow.Update(mx, my)
        EndIf
        
        ' PRIORITY 2: ComboBox popup has priority
        If TComboBox.IsPopupActive()
            ' Let the combobox owner window handle it
            For Local c:TWidget = EachIn children
                If TWindow(c) And IsChildOf(g_ActiveComboBox, c)
                    Return c.Update(mx, my)
                EndIf
            Next
        EndIf
        
        ' PRIORITY 3: Check if mouse is over any window (top to bottom in z-order)
        ' Build reverse list for z-order (last = top)
        Local rev:TList = New TList
        For Local c:TWidget = EachIn children
            rev.AddFirst(c)
        Next
        
        ' Check windows first - find if mouse is over any window
        For Local c:TWidget = EachIn rev
            If TWindow(c)
                Local win:TWindow = TWindow(c)
                ' Mouse is over this window?
                If mx >= win.rect.x And mx < win.rect.x + win.rect.w And my >= win.rect.y And my < win.rect.y + win.rect.h
                    ' Yes - this window gets the input
                    Return win.Update(mx, my)
                EndIf
            EndIf
        Next
        
        ' PRIORITY 4: Mouse is NOT over any window - check screen widgets
        For Local c:TWidget = EachIn rev
            If Not TWindow(c)
                ' For screen widgets, pass absolute mouse coords
                ' The widget's Update expects coords relative to parent (which is root at 0,0)
                Local lx:Int = mx - c.rect.x
                Local ly:Int = my - c.rect.y
                If c.Update(lx, ly) Then Return True
            EndIf
        Next

        Return False
    End Method
    
    ' Helper function to check if a widget is a child of another widget
    Function IsChildOf:Int(widget:TWidget, potentialParent:TWidget)
        If widget = Null Or potentialParent = Null Then Return False
        Local current:TWidget = widget.parent
        While current
            If current = potentialParent Then Return True
            current = current.parent
        Wend
        Return False
    End Function
End Type
