' =============================================================================
'                              BUTTON WIDGET
' =============================================================================
' Clickable button with hover and pressed states
' Supports both normal buttons and special title bar buttons (close, min, max)
' =============================================================================

Type TButton Extends TWidget
    Field caption:String
    Field id:String = ""
    Field buttonType:Int = BTN_TYPE_NORMAL
    Field pressed:Int = False
    Field hover:Int = False
    Field lastDown:Int = False
    Field events:TList = New TList
    Field clickedOnMe:Int = False
    Field isTitleButton:Int = False

    ' Constructor
    Method New(x:Int, y:Int, w:Int, h:Int, Text:String)
        Super.New(x, y, w, h)
        caption = Text

        ' Default color = normal state
        red = COLOR_BUTTON_NORMAL_R
        green = COLOR_BUTTON_NORMAL_G
        blue = COLOR_BUTTON_NORMAL_B
        
    End Method

    Method Draw(px:Int=0, py:Int=0)
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y

        Local style:Int = 2
        
        ' Determine colors and style based on state
        If pressed

            If buttonType = BTN_TYPE_CLOSE
                red = COLOR_BUTTON_CLOSE_PRESSED_R
                green = COLOR_BUTTON_CLOSE_PRESSED_G
                blue = COLOR_BUTTON_CLOSE_PRESSED_B
            Else
                red = COLOR_BUTTON_PRESSED_R  
                green = COLOR_BUTTON_PRESSED_G    
                blue = COLOR_BUTTON_PRESSED_B  
            EndIf

            style = 3   ' Pressed/clicked emboss style

        ElseIf hover

            If buttonType = BTN_TYPE_CLOSE
                red = COLOR_BUTTON_CLOSE_HOVER_R
                green = COLOR_BUTTON_CLOSE_HOVER_G
                blue = COLOR_BUTTON_CLOSE_HOVER_B
            Else
				red = COLOR_BUTTON_HOVER_R
				green = COLOR_BUTTON_HOVER_G
				blue = COLOR_BUTTON_HOVER_B
            EndIf

        Else

            If buttonType = BTN_TYPE_CLOSE
                red = COLOR_BUTTON_CLOSE_NORMAL_R
                green = COLOR_BUTTON_CLOSE_NORMAL_G
                blue = COLOR_BUTTON_CLOSE_NORMAL_B
            Else
				red = COLOR_BUTTON_NORMAL_R
				green = COLOR_BUTTON_NORMAL_G
				blue = COLOR_BUTTON_NORMAL_B
            EndIf

        EndIf

        ' Draw button background with current style and color
        TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, style, red, green, blue)

        ' Draw centered text with shadow
        Local textX:Int = ax + (rect.w - TextWidth(caption)) / 2
        Local textY:Int = ay + (rect.h - TextHeight(caption)) / 2 + 2

        TWidget.GuiDrawText(textX, textY, caption, TEXT_STYLE_SHADOW, COLOR_BUTTON_TEXT_R, COLOR_BUTTON_TEXT_G, COLOR_BUTTON_TEXT_B)

        ' Draw children (if any)
        For Local c:TWidget = EachIn children
            c.Draw(ax, ay)
        Next

    End Method

    Method Update:Int(mx:Int, my:Int)
        ' Check if mouse is over this button
        Local over:Int = ContainsPoint(mx, my)
        hover = over

        ' Update children first (reverse order for correct z-index)
        Local rev:TList = New TList
        For Local c:TWidget = EachIn children
            rev.AddFirst(c)
        Next
        For Local c:TWidget = EachIn rev
            Local relX:Int = mx - c.rect.x
            Local relY:Int = my - c.rect.y
            If c.Update(relX, relY) Then Return True
        Next

        Local down:Int = GuiMouse.Down()
        Local hit:Int = GuiMouse.Hit()

        ' Mouse button pressed while over the button (and no window is being dragged)
        If over And hit And draggedWindow = Null
            pressed = True
            clickedOnMe = True
            Local ev:TEvent = New TEvent
            ev.target = Self
            ev.eventType = "Pressed"
            events.AddLast(ev)
            Return True
        EndIf

        ' Keep pressed state while mouse button is held and still over button
        If down
            pressed = clickedOnMe And over
        EndIf

        ' Mouse button released
        If lastDown And Not down
            If over And clickedOnMe
                Local ev:TEvent = New TEvent
                ev.target = Self
                ev.eventType = "Click"
                events.AddLast(ev)
            EndIf
            pressed = False
            clickedOnMe = False
        EndIf

        lastDown = down
        
        ' Reset states when mouse button is no longer down
        If Not down
            lastDown = False
            clickedOnMe = False
        EndIf

        ' Return True if this widget is interacting with the mouse
        Return over And (hit Or (lastDown And Not down))
    End Method

    ' Check if a full click (press + release) occurred since last clear
    Method WasClicked:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "Click" Then Return True
        Next
        Return False
    End Method
    
    ' Check if the button was just pressed (down event)
    Method WasPressed:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "Pressed" Then Return True
        Next
        Return False
    End Method
    
    ' Remove all stored events (usually called after processing)
    Method ClearEvents()
        events.Clear()
    End Method
End Type
