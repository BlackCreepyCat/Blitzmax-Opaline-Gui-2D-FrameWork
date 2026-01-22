' =============================================================================
'                             SLIDER WIDGET
' =============================================================================
' Draggable slider for selecting values within a range
' Supports horizontal and vertical orientations
' Now with mouse wheel support!
' =============================================================================

Type TSlider Extends TWidget
    Field value:Float = 0.0
    Field minValue:Float = 0.0
    Field maxValue:Float = 1.0
    Field style:Int = SLIDER_STYLE_HORIZONTAL
    Field thumbSize:Int = 16
    Field dragging:Int = False
    Field hover:Int = False
    Field thumbHover:Int = False
    Field events:TList = New TList
    
    ' Mouse wheel settings
    Field wheelStep:Float = 0.05      ' Amount to change per wheel tick (5%)
    Field wheelEnabled:Int = True     ' Enable/disable wheel support
    
    ' Thumb colors (customizable)
    Field thumbR:Int = COLOR_SLIDER_THUMB_R
    Field thumbG:Int = COLOR_SLIDER_THUMB_G
    Field thumbB:Int = COLOR_SLIDER_THUMB_B

    ' Track background color (initially from constants)
    Field red:Int
    Field green:Int
    Field blue:Int

    ' Constructor - initializes slider with position, size, initial value and orientation
    Method New(x:Int, y:Int, w:Int, h:Int, initialValue:Float = 0.0, sliderStyle:Int = SLIDER_STYLE_HORIZONTAL)
        Super.New(x, y, w, h)
        style = sliderStyle
        value = Clamp(initialValue, minValue, maxValue)

        ' Set default track color from theme constants
        red   = COLOR_SLIDER_TRACK_R
        green = COLOR_SLIDER_TRACK_G
        blue  = COLOR_SLIDER_TRACK_B
    End Method

    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y
        
        ' Draw the track (background bar)
        If style = SLIDER_STYLE_HORIZONTAL
            TWidget.GuiDrawRect(ax-1, ay, rect.w+2, rect.h, 3, red, green, blue)
			thumbSize = rect.h - 2
        Else
            TWidget.GuiDrawRect(ax, ay-1, rect.w, rect.h+2, 3, red, green, blue)
			thumbSize = rect.w - 2
        EndIf

        ' Calculate thumb position based on current value
        Local thumbX:Int, thumbY:Int
        Local normalizedValue:Float = (value - minValue) / (maxValue - minValue)

        normalizedValue = Clamp(normalizedValue, 0.0, 1.0)
        
        If style = SLIDER_STYLE_HORIZONTAL
            thumbX = ax + Int((rect.w - thumbSize) * normalizedValue)
            thumbY = ay + (rect.h - thumbSize) / 2
        Else
            thumbX = ax + (rect.w - thumbSize) / 2
            thumbY = ay + rect.h - thumbSize - Int((rect.h - thumbSize) * normalizedValue)
        EndIf
        
        ' Adjust thumb color depending on state (pressed / hover / normal)
        Local tR:Int, tG:Int, tB:Int

        If dragging
            tR = thumbR / 2
            tG = thumbG / 2
            tB = thumbB / 2
        ElseIf thumbHover Or hover
            tR = Min(thumbR + 40, 255)
            tG = Min(thumbG + 40, 255)
            tB = Min(thumbB + 40, 255)
        Else
            tR = thumbR
            tG = thumbG
            tB = thumbB
        EndIf
        
        ' Draw the draggable thumb
        TWidget.GuiDrawRect(thumbX, thumbY, thumbSize, thumbSize, 2, tR, tG, tB)

        ' Draw children if any
        For Local c:TWidget = EachIn children
            c.Draw(ax, ay)
        Next
    End Method

    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        If Not enabled Then Return ContainsPoint(mx, my)
        
        ' Check if mouse is over the entire slider area
        Local over:Int = ContainsPoint(mx, my)
        hover = over
        
        ' Pre-calculate normalized value and thumb position for hover check
        Local normalizedValue:Float = (value - minValue) / (maxValue - minValue)
        normalizedValue = Clamp(normalizedValue, 0.0, 1.0)
        
        Local thumbX:Int, thumbY:Int
        If style = SLIDER_STYLE_HORIZONTAL
            thumbX = Int((rect.w - thumbSize) * normalizedValue)
            thumbY = (rect.h - thumbSize) / 2
        Else
            thumbX = (rect.w - thumbSize) / 2
            thumbY = rect.h - thumbSize - Int((rect.h - thumbSize) * normalizedValue)
        EndIf
        
        ' Check if mouse is directly over the thumb
        thumbHover = (mx >= thumbX And mx < thumbX + thumbSize And my >= thumbY And my < thumbY + thumbSize)
        
        Local down:Int = GuiMouse.Down()
        Local hit:Int = GuiMouse.Hit()
        
        ' Handle mouse wheel when hovering over slider
        If over And wheelEnabled And draggedWindow = Null
            Local wheelDelta:Int = GuiMouse.WheelIdle()
            If wheelDelta <> 0
                Local oldValue:Float = value
                Local StepA:Float = wheelStep * (maxValue - minValue)
                
                ' For vertical sliders, wheel up = increase, wheel down = decrease
                ' For horizontal sliders, same behavior
                If wheelDelta > 0
                    value = value + StepA
                Else
                    value = value - StepA
                EndIf
                
                value = Clamp(value, minValue, maxValue)
                
                ' Fire "Changing" event if value changed
                If value <> oldValue
                    Local ev:TEvent = New TEvent
                    ev.target = Self
                    ev.eventType = "Changing"
                    events.AddLast(ev)
                    
                    ' Also fire "Change" event for wheel (immediate feedback)
                    Local ev2:TEvent = New TEvent
                    ev2.target = Self
                    ev2.eventType = "Change"
                    events.AddLast(ev2)
                EndIf
                
                Return True
            EndIf
        EndIf
        
        ' Start dragging if clicked on the slider (and no window is being dragged)
        If over And hit And draggedWindow = Null
            dragging = True
            UpdateValueFromMouse(mx, my)
            Return True
        EndIf
        
        ' Handle ongoing drag
        If dragging
            If down
                UpdateValueFromMouse(mx, my)
                Return True
            Else
                ' Drag ended → fire "Change" event
                dragging = False
                Local ev:TEvent = New TEvent
                ev.target = Self
                ev.eventType = "Change"
                events.AddLast(ev)
            EndIf
        EndIf
        
        ' Update children (reverse order would be better for z-index, but kept as-is)
        For Local c:TWidget = EachIn children
            Local relX:Int = mx - c.rect.x
            Local relY:Int = my - c.rect.y
            If c.Update(relX, relY) Then Return True
        Next
        
        ' Return true if mouse interaction is still active on this slider
        Return over And dragging
    End Method
    
    ' Update value based on current mouse position during drag
    Method UpdateValueFromMouse(mx:Int, my:Int)
        Local oldValue:Float = value
        Local normalizedValue:Float
        
        If style = SLIDER_STYLE_HORIZONTAL
            normalizedValue = Float(mx - thumbSize / 2) / Float(rect.w - thumbSize)
        Else
            normalizedValue = 1.0 - Float(my - thumbSize / 2) / Float(rect.h - thumbSize)
        EndIf
        
        normalizedValue = Clamp(normalizedValue, 0.0, 1.0)
        value = minValue + (maxValue - minValue) * normalizedValue
        
        ' Fire "Changing" event only if value actually changed
        If value <> oldValue
            Local ev:TEvent = New TEvent
            ev.target = Self
            ev.eventType = "Changing"
            events.AddLast(ev)
        EndIf
    End Method

    ' ====================
    '   Public API
    ' ====================

    ' Set the current value (clamped to range)
    Method SetValue(newValue:Float)
        value = Clamp(newValue, minValue, maxValue)
    End Method
    
    ' Get current value
    Method GetValue:Float()
        Return value
    End Method
    
    ' Set value using percentage (0 to 100)
    Method SetPercent(percent:Float)
        value = minValue + (maxValue - minValue) * (percent / 100.0)
        value = Clamp(value, minValue, maxValue)
    End Method
    
    ' Get current value as percentage (0 to 100)
    Method GetPercent:Float()
        Return ((value - minValue) / (maxValue - minValue)) * 100.0
    End Method
    
    ' Change the allowed value range
    Method SetRange(minVal:Float, maxVal:Float)
        minValue = minVal
        maxValue = maxVal
        value = Clamp(value, minValue, maxValue)
    End Method
    
    ' Change thumb size (square side length)
    Method SetThumbSize(size:Int)
        thumbSize = size
    End Method
    
    ' Customize track background color
    Method SetTrackColor(r:Int, g:Int, b:Int)
        red = r
        green = g
        blue = b
    End Method
    
    ' Customize thumb base color
    Method SetThumbColor(r:Int, g:Int, b:Int)
        thumbR = r
        thumbG = g
        thumbB = b
    End Method
    
    ' Change slider orientation (horizontal / vertical)
    Method SetStyle(newStyle:Int)
        style = newStyle
    End Method
    
    ' Set wheel scroll step (0.0 - 1.0, as fraction of range)
    Method SetWheelStep(StepA:Float)
        wheelStep = StepA
    End Method
    
    ' Enable or disable mouse wheel support
    Method SetWheelEnabled(enabled:Int)
        wheelEnabled = enabled
    End Method
    
    ' ====================
    '   Event handling
    ' ====================

    ' Check if value is currently being changed (during drag)
    Method IsChanging:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "Changing" Then Return True
        Next
        Return False
    End Method
    
    ' Check if value has been confirmed changed (drag ended)
    Method ValueChanged:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "Change" Then Return True
        Next
        Return False
    End Method
    
    ' Clear all pending events
    Method ClearEvents()
        events.Clear()
    End Method
    
    ' Utility clamp function (same as BlitzMax Max/Min but kept for clarity)
    Function Clamp:Float(val:Float, minVal:Float, maxVal:Float)
        If val < minVal Then Return minVal
        If val > maxVal Then Return maxVal
        Return val
    End Function
End Type
