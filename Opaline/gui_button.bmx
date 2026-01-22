' =============================================================================
'                              BUTTON WIDGET
' =============================================================================
' Clickable button with hover and pressed states
' Supports both normal buttons and special title bar buttons (close, min, max)
' Supports custom colors that persist across states
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
	Field isSymbol:Int = False
	
    ' Base colors (user-defined, used as reference for state variations)
    Field baseR:Int = COLOR_BUTTON_NORMAL_R
    Field baseG:Int = COLOR_BUTTON_NORMAL_G
    Field baseB:Int = COLOR_BUTTON_NORMAL_B
    Field useCustomColor:Int = False  ' True if user set custom colors

    ' Constructor
    Method New(x:Int, y:Int, w:Int, h:Int, Text:String , symbol:Int=False)
        Super.New(x, y, w, h)
        caption = Text

        ' Default color = normal state
        baseR = COLOR_BUTTON_NORMAL_R
        baseG = COLOR_BUTTON_NORMAL_G
        baseB = COLOR_BUTTON_NORMAL_B


		isSymbol = symbol
        
        red = baseR
        green = baseG
        blue = baseB
    End Method
    
    ' Set custom button color (this color will be used as base for all states)
    Method SetColor(r:Int, g:Int, b:Int)
        baseR = r
        baseG = g
        baseB = b
        useCustomColor = True
    End Method
    
    ' Reset to default theme colors
    Method ResetColor()
        useCustomColor = False

        baseR = COLOR_BUTTON_NORMAL_R
        baseG = COLOR_BUTTON_NORMAL_G
        baseB = COLOR_BUTTON_NORMAL_B
    End Method

    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y

        Local style:Int = 2
        Local drawR:Int, drawG:Int, drawB:Int
        
        ' Determine colors and style based on state
        If pressed
            style = 3   ' Pressed/clicked emboss style
            
            If useCustomColor
                ' Darken custom color for pressed state
                drawR = Max(0, baseR - 30)
                drawG = Max(0, baseG - 30)
                drawB = Max(0, baseB - 30)
            Else
                drawR = COLOR_BUTTON_PRESSED_R  
                drawG = COLOR_BUTTON_PRESSED_G    
                drawB = COLOR_BUTTON_PRESSED_B  
            EndIf

        ElseIf hover
            If useCustomColor
                ' Lighten custom color for hover state
                drawR = Min(255, baseR + 20)
                drawG = Min(255, baseG + 20)
                drawB = Min(255, baseB + 20)
            Else
                drawR = COLOR_BUTTON_HOVER_R
                drawG = COLOR_BUTTON_HOVER_G
                drawB = COLOR_BUTTON_HOVER_B
           EndIf

        Else
            ' Normal state
            If useCustomColor
                drawR = baseR
                drawG = baseG
                drawB = baseB
            Else
                drawR = COLOR_BUTTON_NORMAL_R
                drawG = COLOR_BUTTON_NORMAL_G
                drawB = COLOR_BUTTON_NORMAL_B
            EndIf
        EndIf

        ' Store for external access if needed
        red = drawR
        green = drawG
        blue = drawB

        ' Draw button background with current style and color and restrict the viewport
        TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, style, drawR, drawG, drawB)
        TWidget.GuiSetViewport(ax + 2, ay, rect.w - 4, rect.h)

        ' Draw centered text with shadow
        Local textX:Int = ax + (rect.w - TWidget.GuiTextWidth(caption , isSymbol)) / 2 
        Local textY:Int = ay + (rect.h - TWidget.GuiTextHeight(caption , isSymbol)) / 2 + 1
		
		If isSymbol=True Then 
			TWidget.GuiDrawSymbol(textX, textY, caption, TEXT_STYLE_SHADOW, COLOR_BUTTON_TEXT_R, COLOR_BUTTON_TEXT_G, COLOR_BUTTON_TEXT_B)
		Else
			TWidget.GuiDrawText(textX, textY, caption, TEXT_STYLE_SHADOW, COLOR_BUTTON_TEXT_R, COLOR_BUTTON_TEXT_G, COLOR_BUTTON_TEXT_B)
		EndIf
		
        TWidget.GuiSetViewport(0, 0, GraphicsWidth(), GraphicsHeight()) ' Reset viewport
        
        ' Draw children (if any)
        For Local c:TWidget = EachIn children
            c.Draw(ax, ay)
        Next

    End Method

    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        If Not enabled Then Return ContainsPoint(mx, my)
        
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
