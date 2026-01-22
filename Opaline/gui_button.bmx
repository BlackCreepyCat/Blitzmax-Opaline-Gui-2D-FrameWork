' =============================================================================
'                              BUTTON WIDGET
' =============================================================================
' Clickable button widget with hover and pressed visual feedback
' Supports normal buttons and title-bar buttons (close, minimize, maximize)
' Allows custom base colors that are automatically adjusted for states
' =============================================================================

Type TButton Extends TWidget
    
    ' Properties
    Field caption:String               ' Text displayed on the button
    Field id:String = ""               ' Optional identifier for the button
    Field buttonType:Int = BTN_TYPE_NORMAL
    
    ' State tracking
    Field pressed:Int = False          ' Is the button currently being pressed?
    Field hover:Int = False            ' Is the mouse hovering over the button?
    Field lastDown:Int = False         ' Previous mouse button state (for edge detection)
    
    ' Event handling
    Field events:TList = New TList     ' List of pending button events
    Field clickedOnMe:Int = False      ' Did the press start on this button?
    
    ' Special button flags
    Field isTitleButton:Int = False    ' Is this a window title bar control?
    Field isSymbol:Int = False         ' Should we draw symbol instead of text?
    
    ' Color system
    Field baseR:Int = COLOR_BUTTON_NORMAL_R    ' Base color reference (normal state)
    Field baseG:Int = COLOR_BUTTON_NORMAL_G
    Field baseB:Int = COLOR_BUTTON_NORMAL_B
    Field useCustomColor:Int = False           ' Did user define a custom color?
    

    ' ===============================
    '          Constructor
    ' ===============================
    Method New(x:Int, y:Int, w:Int, h:Int, text:String, symbol:Int = False)
        Super.New(x, y, w, h)
        caption = text
        isSymbol = symbol
        
        ' Initialize with default theme colors
        baseR = COLOR_BUTTON_NORMAL_R
        baseG = COLOR_BUTTON_NORMAL_G
        baseB = COLOR_BUTTON_NORMAL_B
        
        ' Apply initial color
        red   = baseR
        green = baseG
        blue  = baseB
    End Method
    
    
    ' ===============================
    '       Color Management
    ' ===============================
    
    ' Set a custom base color (will be used for all states with variations)
    Method SetColor(r:Int, g:Int, b:Int)
        baseR = r
        baseG = g
        baseB = b
        useCustomColor = True
    End Method
    
    
    ' Restore default theme colors
    Method ResetColor()
        useCustomColor = False
        baseR = COLOR_BUTTON_NORMAL_R
        baseG = COLOR_BUTTON_NORMAL_G
        baseB = COLOR_BUTTON_NORMAL_B
    End Method
    
    
    ' ===============================
    '           Rendering
    ' ===============================
    Method Draw(px:Int = 0, py:Int = 0)
        If Not visible Then Return
        
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y
        
        Local style:Int = 4
        Local drawR:Int, drawG:Int, drawB:Int
        
        ' === Determine appearance based on current state ===
        If pressed
            style = 5  ' Pressed style (usually inset/embossed down)
            
            If useCustomColor
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
        
        ' Store current draw color for possible external use
        red   = drawR
        green = drawG
        blue  = drawB
        
        ' Draw button background
        TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, style, drawR, drawG, drawB)
        
        ' Restrict drawing area for content
        TWidget.GuiSetViewport(ax + 2, ay + 1, rect.w - 4, rect.h - 2)
        
        ' Center the text/symbol
        Local textW:Int = TWidget.GuiTextWidth(caption, isSymbol)
        Local textH:Int = TWidget.GuiTextHeight(caption, isSymbol)
        
        Local textX:Int = ax + (rect.w - textW) / 2
        Local textY:Int = ay + (rect.h - textH) / 2 + 1
        
        ' Draw text or symbol with shadow
        If isSymbol
            TWidget.GuiDrawSymbol(textX, textY, caption, TEXT_STYLE_SHADOW, COLOR_BUTTON_TEXT_R, COLOR_BUTTON_TEXT_G, COLOR_BUTTON_TEXT_B)
        Else
            TWidget.GuiDrawText(textX, textY, caption, TEXT_STYLE_SHADOW, COLOR_BUTTON_TEXT_R, COLOR_BUTTON_TEXT_G, COLOR_BUTTON_TEXT_B)
        EndIf
        


        ' Restore full viewport
        TWidget.GuiSetViewport(0, 0, GUI_GRAPHICSWIDTH, GUI_GRAPHICSHEIGHT)
        
        ' Draw any child widgets
        For Local child:TWidget = EachIn children
            child.Draw(ax, ay)
        Next
    End Method
    
    
    ' ===============================
    '         Interaction / Logic
    ' ===============================
    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        If Not enabled Then Return ContainsPoint(mx, my)
        
        Local over:Int = ContainsPoint(mx, my)
        hover = over
        
        ' Update children first (reverse order = correct event priority)
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
        Local hit:Int  = GuiMouse.Hit()
        
        ' === Press started on this button ===
        If over And hit And draggedWindow = Null
            pressed = True
            clickedOnMe = True
            
            Local ev:TEvent = New TEvent
            ev.target = Self
            ev.eventType = "Pressed"
            events.AddLast(ev)
            
            Return True
        EndIf
        
        ' Keep pressed state only if mouse still over button while held
        If down
            pressed = clickedOnMe And over
        EndIf
        
        ' === Release detected ===
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
        
        ' Clean up when button is no longer held
        If Not down
            clickedOnMe = False
        EndIf
        
        ' Did we interact with this widget?
        Return over And (hit Or (lastDown And Not down))
    End Method
    
    
    ' ===============================
    '         Event Queries
    ' ===============================
    
    ' Returns True if a complete click occurred since last ClearEvents()
    Method WasClicked:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "Click" Then Return True
        Next
        Return False
    End Method
    
    
    ' Returns True if button was just pressed (not released yet)
    Method WasPressed:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "Pressed" Then Return True
        Next
        Return False
    End Method
    
    
    ' Clear all pending events (usually called after handling them)
    Method ClearEvents()
        events.Clear()
    End Method
    
End Type