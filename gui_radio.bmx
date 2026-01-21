' =============================================================================
'                          RADIO BUTTON WIDGET
' =============================================================================
' Mutually exclusive selection button with group support
' Supports custom colors for the selection indicator
' =============================================================================

Type TRadio Extends TWidget
    Field caption:String
    Field selected:Int = False
    Field hover:Int = False
    Field clickedOnMe:Int = False
    Field events:TList = New TList
    Field group:TList = Null

    ' Constructor - takes position, size, label and the shared group list
    Method New(x:Int, y:Int, w:Int, h:Int, Text:String, grp:TList)
        Super.New(x, y, w, h)
        caption = Text
        group = grp

        red = COLOR_RADIO_SELECTED_R
        green = COLOR_RADIO_SELECTED_G
        blue = COLOR_RADIO_SELECTED_B

        ' Automatically add this radio button to the group if provided
        If group Then group.AddLast(Self)
    End Method
    
    ' Set custom selection indicator color
    Method SetColor(r:Int, g:Int, b:Int)
        red = r
        green = g
        blue = b
    End Method
    
    ' Reset to default theme color
    Method ResetColor()
        red = COLOR_RADIO_SELECTED_R
        green = COLOR_RADIO_SELECTED_G
        blue = COLOR_RADIO_SELECTED_B
    End Method

    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y

        ' Draw radio button circle (brighter when hovered)
        ' Note: we use GuiDrawOval (assumed to exist in TWidget or elsewhere)
        If hover
            TWidget.GuiDrawOval(ax, ay, rect.w, rect.h, 2, 255, 255, 255)
        Else
           TWidget.GuiDrawOval(ax, ay, rect.w, rect.h, 2, COLOR_RADIO_OUTLINE_R, COLOR_RADIO_OUTLINE_G, COLOR_RADIO_OUTLINE_B)
        EndIf

        ' Draw filled circle if selected
        If selected
            TWidget.GuiDrawOval(ax + 4, ay + 4, rect.w - 8, rect.h - 8, 1, red, green, blue)
        EndIf

        ' Draw label text with shadow
        Local textX:Int = ax + rect.w + 8
        Local textY:Int = ay + (rect.h - TextHeight(caption)) / 2
        TWidget.GuiDrawText(textX, textY, caption, TEXT_STYLE_SHADOW, COLOR_RADIO_TEXT_R, COLOR_RADIO_TEXT_G, COLOR_RADIO_TEXT_B)
    End Method

    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        If Not enabled Then Return ContainsPoint(mx, my)
        
        ' Check if mouse is over this radio button
        Local over:Int = ContainsPoint(mx, my)
        hover = over
        
        Local down:Int = GuiMouse.Down()
        Local hit:Int = GuiMouse.Hit()

        ' Detect mouse press while over the widget (and no window is being dragged)
        If over And hit And draggedWindow = Null
            clickedOnMe = True
        EndIf

        ' On mouse release: if still over and was clicked → select this radio
        If clickedOnMe And Not down
            If over
                ' Deselect all other radios in the same group
                If group
                    For Local r:TRadio = EachIn group
                        r.selected = False
                    Next
                EndIf
                ' Select this one
                selected = True
                
                ' Create and store a "Click" event
                Local ev:TEvent = New TEvent
                ev.target = Self
                ev.eventType = "Click"
                events.AddLast(ev)
            EndIf
            clickedOnMe = False
        EndIf

        ' Return whether the mouse is over this widget (for potential parent handling)
        Return over
    End Method
    
    ' Check if this radio was just clicked (event-based)
    Method WasSelected:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "Click" Then Return True
        Next
        Return False
    End Method
    
    ' Get current selection state
    Method IsSelected:Int()
        Return selected
    End Method
    
    ' Clear all pending events for this radio button
    Method ClearEvents()
        events.Clear()
    End Method
End Type