' =============================================================================
'                            CHECKBOX WIDGET
' =============================================================================
' Toggleable checkbox with label and hover state
' Supports custom colors that persist across states
' =============================================================================

Type TCheckBox Extends TWidget
    Field caption:String
    Field checked:Int = False
    Field pressed:Int = False
    Field hover:Int = False
    Field clickedOnMe:Int = False
    Field events:TList = New TList
    Field lastDown:Int = False
    
    ' Base colors (user-defined, used as reference for state variations)
    Field baseR:Int = COLOR_CHECKBOX_NORMAL_R
    Field baseG:Int = COLOR_CHECKBOX_NORMAL_G
    Field baseB:Int = COLOR_CHECKBOX_NORMAL_B
    Field useCustomColor:Int = False

    ' Constructor - initializes position, size, label and initial checked state
    Method New(x:Int, y:Int, w:Int, h:Int, Text:String, initialState:Int = False)
        Super.New(x, y, w, h)
        caption = Text
        checked = initialState

        baseR = COLOR_CHECKBOX_NORMAL_R
        baseG = COLOR_CHECKBOX_NORMAL_G
        baseB = COLOR_CHECKBOX_NORMAL_B
        
        red = baseR
        green = baseG
        blue = baseB
    End Method
    
    ' Set custom checkbox color
    Method SetColor(r:Int, g:Int, b:Int)
        baseR = r
        baseG = g
        baseB = b
        useCustomColor = True
    End Method
    
    ' Reset to default theme colors
    Method ResetColor()
        useCustomColor = False
        baseR = COLOR_CHECKBOX_NORMAL_R
        baseG = COLOR_CHECKBOX_NORMAL_G
        baseB = COLOR_CHECKBOX_NORMAL_B
    End Method

    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y

        ' Determine current visual style and color based on state
        Local style:Int = 2
        Local drawR:Int, drawG:Int, drawB:Int
        
        If pressed
            style = 3
            If useCustomColor
                drawR = Max(0, baseR - 30)
                drawG = Max(0, baseG - 30)
                drawB = Max(0, baseB - 30)
            Else
                drawR = COLOR_CHECKBOX_PRESSED_R
                drawG = COLOR_CHECKBOX_PRESSED_G
                drawB = COLOR_CHECKBOX_PRESSED_B
            EndIf
        ElseIf hover
            If useCustomColor
                drawR = Min(255, baseR + 20)
                drawG = Min(255, baseG + 20)
                drawB = Min(255, baseB + 20)
            Else
                drawR = COLOR_CHECKBOX_HOVER_R
                drawG = COLOR_CHECKBOX_HOVER_G
                drawB = COLOR_CHECKBOX_HOVER_B
            EndIf
        Else
            If useCustomColor
                drawR = baseR
                drawG = baseG
                drawB = baseB
            Else
                drawR = COLOR_CHECKBOX_NORMAL_R
                drawG = COLOR_CHECKBOX_NORMAL_G
                drawB = COLOR_CHECKBOX_NORMAL_B
            EndIf
        EndIf
        
        ' Store for external access
        red = drawR
        green = drawG
        blue = drawB
 
        ' Draw the checkbox background/rectangle
        TWidget.GuiDrawRect(ax, ay, rect.h, rect.h, style, drawR, drawG, drawB)

        ' Draw check mark if checked
        If checked
            TWidget.GuiDrawLine(ax + 4, ay + 4, ax + rect.h - 4, ay + rect.h - 4, 2, COLOR_CHECKBOX_MARK_R, COLOR_CHECKBOX_MARK_G, COLOR_CHECKBOX_MARK_B)
            TWidget.GuiDrawLine(ax + rect.h - 4, ay + 4, ax + 4, ay + rect.h - 4, 2, COLOR_CHECKBOX_MARK_R, COLOR_CHECKBOX_MARK_G, COLOR_CHECKBOX_MARK_B)
        EndIf

        ' Draw label text with shadow
        Local textX:Int = ax + rect.h + 8
        Local textY:Int = ay + (rect.h - TextHeight(caption)) / 2

        TWidget.GuiDrawText(textX, textY, caption, TEXT_STYLE_SHADOW, COLOR_CHECKBOX_TEXT_R, COLOR_CHECKBOX_TEXT_G, COLOR_CHECKBOX_TEXT_B)

        ' Draw all child widgets (recursive)
        For Local c:TWidget = EachIn children
            c.Draw(ax, ay)
        Next
    End Method

    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        If Not enabled Then Return ContainsPoint(mx, my)
        
        ' Check if mouse is currently over this widget
        Local over:Int = ContainsPoint(mx, my)
        hover = over

        ' Update children first (reverse order = topmost widgets first)
        Local rev:TList = New TList
        For Local c:TWidget = EachIn children
            rev.AddFirst(c)
        Next
        For Local c:TWidget = EachIn rev
            Local relX:Int = mx - c.rect.x
            Local relY:Int = my - c.rect.y
            If c.Update(relX, relY) Then Return True
        Next

        ' Get current mouse button states
        Local down:Int = GuiMouse.Down()
        Local hit:Int = GuiMouse.Hit()

        ' Mouse press started over this widget
        If over And hit And draggedWindow = Null
            pressed = True
            clickedOnMe = True
            Return True
        EndIf

        ' While mouse button is held down, keep pressed state only if still over
        If down
            pressed = clickedOnMe And over
        EndIf

        ' Mouse button was released
        If lastDown And Not down
            If over And clickedOnMe
                ' Toggle checked state and generate change event
                checked = Not checked
                Local ev:TEvent = New TEvent
                ev.target = Self
                ev.eventType = "Change"
                events.AddLast(ev)
            EndIf
            pressed = False
            clickedOnMe = False
        EndIf

        lastDown = down
        
        ' Reset states when mouse button is no longer down
        If Not down
            pressed = False
            clickedOnMe = False
            lastDown = False
        EndIf

        ' Return True if this widget is being interacted with
        Return over Or pressed
    End Method

    ' Returns current checked state
    Method IsChecked:Int()
        Return checked
    End Method

    ' Programmatically set the checked state
    Method SetChecked(state:Int)
        checked = state
    End Method
    
    ' Check if a "Change" event occurred since last clear
    Method StateChanged:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "Change" Then Return True
        Next
        Return False
    End Method
    
    ' Remove all stored events for this widget
    Method ClearEvents()
        events.Clear()
    End Method
End Type