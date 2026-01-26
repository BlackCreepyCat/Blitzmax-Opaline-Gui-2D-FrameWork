' =============================================================================
'                           ROTARY KNOB WIDGET
' =============================================================================
' Circular rotary knob control (like volume knobs on audio equipment)
' Supports mouse drag rotation, mouse wheel, and visual tick marks
' Returns normalized value (0.0 to 1.0) and angle
' =============================================================================



Type TRotaryKnob Extends TWidget
    ' Value and range
    Field value:Float = 0.0             ' Current value (0.0 to 1.0)
    Field minValue:Float = 0.0          ' Minimum value
    Field maxValue:Float = 1.0          ' Maximum value
    
    ' Visual dimensions
    Field radius:Float                  ' Radius of the knob
    Field innerRadius:Float             ' Radius of inner circle (for depth effect)
    Field indicatorLength:Float         ' Length of value indicator line
    
    ' Rotation angle constraints (in degrees)
    Field minAngle:Float = ROTARY_DEFAULT_MIN_ANGLE   ' Minimum rotation (-135° default)
    Field maxAngle:Float = ROTARY_DEFAULT_MAX_ANGLE   ' Maximum rotation (+135° default)
    Field currentAngle:Float = 0.0      ' Current rotation angle in degrees
    
    ' Interaction state
    Field dragging:Int = False          ' Is user dragging the knob?
    Field hover:Int = False             ' Is mouse hovering over knob?
    Field dragStartY:Int = 0            ' Y position when drag started (vertical drag controls value)
    Field dragStartValue:Float = 0.0   ' Value when drag started (for relative changes)
    
    ' Behavior settings
    Field sensitivity:Float = 1.0       ' Mouse drag sensitivity (0.5 = slower, 2.0 = faster)
    Field snapToTicks:Int = False       ' Snap to tick mark positions when adjusting
    Field wheelEnabled:Int = True       ' Enable mouse wheel control
    Field wheelStep:Float = 0.05        ' Mouse wheel step size (5% by default)
    
    ' Visual options
    Field showTicks:Int = True          ' Show tick marks around edge
    Field showValue:Int = True          ' Show numeric value in center
    Field showIndicator:Int = True      ' Show pointer/indicator line

    Field tickCount:Int = ROTARY_TICK_COUNT  ' Number of tick marks to display
    
    ' Colors - Knob body
    Field knobR:Int = COLOR_ROTARY_BG_R
    Field knobG:Int = COLOR_ROTARY_BG_G
    Field knobB:Int = COLOR_ROTARY_BG_B
    Field knobAlpha:Float = 1.0         ' Knob transparency (0.0 = invisible, 1.0 = opaque)
    
    ' Colors - Indicator line
    Field indicatorR:Int = COLOR_ROTARY_INDICATOR_R
    Field indicatorG:Int = COLOR_ROTARY_INDICATOR_G
    Field indicatorB:Int = COLOR_ROTARY_INDICATOR_B
    
    ' Colors - Ticks
    Field tickR:Int = COLOR_ROTARY_TICK_R
    Field tickG:Int = COLOR_ROTARY_TICK_G
    Field tickB:Int = COLOR_ROTARY_TICK_B
    
    ' Colors - Value text
    Field textR:Int = COLOR_ROTARY_TEXT_R
    Field textG:Int = COLOR_ROTARY_TEXT_G
    Field textB:Int = COLOR_ROTARY_TEXT_B
    
    ' Events
    Field events:TList = New TList
    
    ' =========================================================================
    '                         CONSTRUCTOR
    ' =========================================================================
    ' Creates a new rotary knob widget
    ' Parameters:
    '   x, y         - Position on screen
    '   size         - Diameter of the knob in pixels (default: ROTARY_DEFAULT_SIZE)
    '   initialValue - Starting value 0.0 to 1.0 (default: 0.5)
    '   Count        - Number of tick marks, 0 = use default (default: 0)
    Method New(x:Int, y:Int, size:Int = ROTARY_DEFAULT_SIZE, initialValue:Float = 0.5,  Count:Int = 0)
        ' Size is the diameter of the knob (square bounding box)
        Super.New(x, y, size, size)

        ' Set tick count (use default if 0, otherwise use provided value)
        If Count = 0 Then
            tickCount = ROTARY_TICK_COUNT
        Else
            tickCount = Count
        EndIf
        
        ' Calculate visual dimensions based on size
        radius = Float(size) / 2.0
        innerRadius = radius * 0.7      ' Inner circle is 70% of radius
        indicatorLength = radius * 0.7  ' Indicator line is 70% of radius
        
        ' Initialize value and sync angle
        value = Clamp(initialValue, 0.0, 1.0)
        UpdateAngleFromValue()
        
        ' Set default colors (copied to base widget color for consistency)
        red = knobR
        green = knobG
        blue = knobB
    End Method
    
    ' =========================================================================
    '                         VALUE <-> ANGLE CONVERSION
    ' =========================================================================
    
    ' Convert current value to rotation angle
    ' Maps value range (minValue to maxValue) to angle range (minAngle to maxAngle)
    Method UpdateAngleFromValue()
        Local normalizedValue:Float = (value - minValue) / (maxValue - minValue)
        currentAngle = minAngle + normalizedValue * (maxAngle - minAngle)
    End Method
    
    ' Convert current angle to value
    ' Maps angle range (minAngle to maxAngle) to value range (minValue to maxValue)
    Method UpdateValueFromAngle()
        Local normalizedAngle:Float = (currentAngle - minAngle) / (maxAngle - minAngle)
        value = minValue + normalizedAngle * (maxValue - minValue)
        value = Clamp(value, minValue, maxValue)
    End Method
    
    ' =========================================================================
    '                         DRAWING
    ' =========================================================================
    Method Draw(px:Int = 0, py:Int = 0)
        If Not visible Then Return
        
        ' Calculate absolute screen position
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y
        
        ' Center of the knob
        Local centerX:Float = Float(ax) + radius
        Local centerY:Float = Float(ay) + radius
        
        ' Draw tick marks if enabled (drawn first, behind knob)
        If showTicks
            DrawTickMarks(centerX, centerY)
        EndIf
        
        ' Draw outer knob circle (main body)
        Local knobDiameter:Int = Int(radius * 2.0)
        Local knobDrawR:Int = knobR
        Local knobDrawG:Int = knobG
        Local knobDrawB:Int = knobB
        
        ' Visual feedback: Brighten on hover
        If hover
            knobDrawR = Min(255, knobR + 30)
            knobDrawG = Min(255, knobG + 30)
            knobDrawB = Min(255, knobB + 30)
        EndIf
        
        ' Visual feedback: Darken when dragging
        If dragging
            knobDrawR = Max(0, knobR - 20)
            knobDrawG = Max(0, knobG - 20)
            knobDrawB = Max(0, knobB - 20)
        EndIf
        
        ' Draw main knob body with 3D effect (style 3 = with border)
        TWidget.GuiDrawOval(Int(ax), Int(ay), knobDiameter, knobDiameter, 3, knobDrawR, knobDrawG, knobDrawB, knobAlpha)
        
        ' Draw inner circle (gives depth/3D appearance)
        Local innerDiameter:Int = Int(innerRadius * 2.0)
        Local innerX:Int = Int(centerX - innerRadius)
        Local innerY:Int = Int(centerY - innerRadius)

        ' Inner circle is darker (50% brightness) and slightly transparent
        TWidget.GuiDrawOval(innerX, innerY, innerDiameter, innerDiameter, 3, knobDrawR / 2, knobDrawG / 2, knobDrawB / 2, knobAlpha * 0.8)
        
        ' Draw value indicator line (pointer showing current value)
        If showIndicator
            DrawIndicator(centerX, centerY)
        EndIf
        
        ' Draw value text in center (percentage display)
        If showValue
            DrawValueText(centerX, centerY)
        EndIf
        
        ' Draw children widgets (if any attached to knob)
        For Local c:TWidget = EachIn children
            c.Draw(ax, ay)
        Next
    End Method
    
    ' Draw tick marks around the knob edge
    ' Ticks are evenly distributed around the rotation arc
    Method DrawTickMarks(centerX:Float, centerY:Float)
        Local angleRange:Float = maxAngle - minAngle
        Local tickRadius:Float = radius + 8  ' Ticks extend 8px beyond knob edge
        
        ' Draw each tick mark
        For Local i:Int = 0 Until tickCount
            ' Calculate position along the arc (0.0 to 1.0)
            Local t:Float = Float(i) / Float(tickCount - 1)
            Local tickAngle:Float = minAngle + t * angleRange
            
            ' Convert to radians with angle inversion (same as indicator)
            ' Negative angle reverses rotation direction to match visual expectation
            Local rad:Float = -tickAngle         
            
            ' Calculate tick line endpoints (inner and outer points)
            Local tickX1:Float = centerX + Cos(rad) * (radius - 2)    ' Inner point
            Local tickY1:Float = centerY + Sin(rad) * (radius - 2)
            Local tickX2:Float = centerX + Cos(rad) * tickRadius      ' Outer point
            Local tickY2:Float = centerY + Sin(rad) * tickRadius
            
            ' Highlight tick if it's close to current value position
            Local isActive:Int = False
            
            ' Active if within 15 degrees of current position
            If Abs(currentAngle - tickAngle) < 15.0 Then isActive = True
            
            ' Draw tick line (active ticks are brighter and thicker)
            If isActive
                TWidget.GuiDrawLine(Int(tickX1), Int(tickY1), Int(tickX2), Int(tickY2), 2, 255, 200, 100)
            Else
                TWidget.GuiDrawLine(Int(tickX1), Int(tickY1), Int(tickX2), Int(tickY2), 1, tickR, tickG, tickB)
            EndIf
        Next
    End Method
    
    ' Draw the indicator line showing current value
    ' The indicator is a line from center pointing to current value position
    Method DrawIndicator(centerX:Float, centerY:Float)
        Local rad:Float = currentAngle 

        ' Invert rotation direction: clockwise → counter-clockwise becomes clockwise
        ' This makes the visual rotation match user expectation
        Local endX:Float = centerX + Cos(-rad) * indicatorLength  
        Local endY:Float = centerY + Sin(-rad) * indicatorLength  
        
        ' Draw indicator line from center to end point
        TWidget.GuiDrawLine(Int(centerX), Int(centerY), Int(endX), Int(endY), 2, indicatorR, indicatorG, indicatorB)
       
        ' Draw indicator dot at the end (visual enhancement)
        Local dotSize:Int = 12
        ' Dot is brighter than line for better visibility
        TWidget.GuiDrawOval(Int(endX - dotSize/2), Int(endY - dotSize/2), dotSize, dotSize, 1, indicatorR + 50, indicatorG + 50, indicatorB + 50)

    End Method
    
    ' Draw value text in center
    ' Displays current value as a percentage
    Method DrawValueText(centerX:Float, centerY:Float)
        ' Format value as percentage
        Local percent:Int = Int(GetPercent())
        Local valueText:String = percent + "%"
        
        ' Calculate text position (centered)
        Local textW:Int = TWidget.GuiTextWidth(valueText)
        Local textH:Int = TWidget.GuiTextHeight(valueText)
        Local textX:Int = Int(centerX) - textW / 2
        Local textY:Int = Int(centerY) - textH / 2
        
        ' Draw with shadow for better readability
        TWidget.GuiDrawText(textX, textY, valueText, TEXT_STYLE_SHADOW, textR, textG, textB)
    End Method
    
    ' =========================================================================
    '                         UPDATE / INPUT HANDLING
    ' =========================================================================
    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        If Not enabled Then Return ContainsPoint(mx, my)
        
        ' Check if mouse is over the knob (circular hit detection)
        Local centerX:Float = Float(rect.w) / 2.0
        Local centerY:Float = Float(rect.h) / 2.0

        Local dx:Float = Float(mx) - centerX
        Local dy:Float = Float(my) - centerY

        Local dist:Float = Sqr(dx * dx + dy * dy)
        
        ' Mouse is over if within radius
        Local over:Int = (dist <= radius)
        hover = over
        
        Local down:Int = GuiMouse.Down()
        Local hit:Int = GuiMouse.Hit()
        
        ' Start dragging: mouse clicked on knob, no window being dragged
        If hit And over And draggedWindow = Null
            dragging = True
            dragStartY = GuiMouse.y        ' Store Y position for vertical drag
            dragStartValue = value         ' Store starting value for relative changes
            FireEvent("KnobPress")
            Return True
        EndIf
        
        ' Handle dragging (vertical mouse movement changes value)
        ' Moving mouse UP increases value, DOWN decreases value
        If dragging And down
            Local deltaY:Int = dragStartY - GuiMouse.y  ' Inverted: up = increase
            Local valueRange:Float = maxValue - minValue
            
            ' Convert pixel movement to value change
            ' Sensitivity controls how fast the value changes per pixel
            Local dragSensitivity:Float = sensitivity * 0.005  ' Pixels to value ratio
            Local valueChange:Float = Float(deltaY) * dragSensitivity * valueRange
            
            ' Apply change relative to starting value
            value = dragStartValue + valueChange
            value = Clamp(value, minValue, maxValue)
            
            ' Snap to ticks if enabled
            If snapToTicks
                SnapToNearestTick()
            EndIf
            
            ' Update visual angle and fire change event
            UpdateAngleFromValue()
            FireEvent("KnobChange")
            Return True
        EndIf
        
        ' Stop dragging: mouse button released
        If dragging And Not down
            dragging = False
            FireEvent("KnobRelease")
            Return True
        EndIf
        
        ' Mouse wheel control (only when hovering, not dragging a window)
        If over And wheelEnabled And draggedWindow = Null
            Local wheel:Int = GuiMouse.WheelIdle()
            If wheel <> 0
                Local oldValue:Float = value
                Local valueRange:Float = maxValue - minValue
                
                ' Wheel up = increase, wheel down = decrease
                If wheel > 0
                    value = value + wheelStep * valueRange
                Else
                    value = value - wheelStep * valueRange
                EndIf
                
                ' Clamp to valid range
                value = Clamp(value, minValue, maxValue)
                
                ' Apply snap to ticks if enabled
                If snapToTicks
                    SnapToNearestTick()
                EndIf
                
                ' Update angle representation
                UpdateAngleFromValue()
                
                ' Fire event only if value actually changed
                If value <> oldValue
                    FireEvent("KnobChange")
                EndIf
                
                Return True
            EndIf
        EndIf
        
        ' Return True if mouse is over (for input capture)
        Return over
    End Method
    
    ' =========================================================================
    '                         SNAP TO TICKS
    ' =========================================================================
    ' Snaps the current value to the nearest tick mark position
    ' Used when snapToTicks is enabled
    Method SnapToNearestTick()
        If tickCount <= 1 Then Return
        
        ' Convert value to normalized position (0.0 to 1.0)
        Local normalizedValue:Float = (value - minValue) / (maxValue - minValue)
        
        ' Find nearest tick index (0.5 added for rounding)
        Local tickIndex:Int = Int(normalizedValue * Float(tickCount - 1) + 0.5)
        tickIndex = Max(0, Min(tickIndex, tickCount - 1))
        
        ' Convert tick index back to normalized value
        Local snappedValue:Float = Float(tickIndex) / Float(tickCount - 1)
        
        ' Apply snapped value
        value = minValue + snappedValue * (maxValue - minValue)
    End Method
    
    ' =========================================================================
    '                         PUBLIC API - GET/SET VALUES
    ' =========================================================================
    
    ' Set value (0.0 to 1.0 by default, or within custom range)
    Method SetValue(newValue:Float)
        value = Clamp(newValue, minValue, maxValue)
        UpdateAngleFromValue()
    End Method
    
    ' Get current value
    Method GetValue:Float()
        Return value
    End Method
    
    ' Set value as percentage (0 to 100)
    Method SetPercent(percent:Float)
        value = minValue + (maxValue - minValue) * (percent / 100.0)
        value = Clamp(value, minValue, maxValue)
        UpdateAngleFromValue()
    End Method
    
    ' Get value as percentage (0 to 100)
    Method GetPercent:Float()
        If maxValue = minValue Then Return 0.0
        Return ((value - minValue) / (maxValue - minValue)) * 100.0
    End Method
    
    ' Set value range (min and max bounds)
    Method SetRange(minVal:Float, maxVal:Float)
        minValue = minVal
        maxValue = maxVal
        value = Clamp(value, minValue, maxValue)
        UpdateAngleFromValue()
    End Method
    
    ' Get current angle in degrees (for custom visualizations)
    Method GetAngle:Float()
        Return currentAngle
    End Method
    
    ' =========================================================================
    '                         PUBLIC API - SETTINGS
    ' =========================================================================
    
    ' Set rotation angle range in degrees
    ' Example: SetAngleRange(-135.0, 135.0) for 270° total rotation
    Method SetAngleRange(minAng:Float, maxAng:Float)
        minAngle = minAng
        maxAngle = maxAng
        UpdateAngleFromValue()
    End Method
    
    ' Set drag sensitivity (how fast value changes with mouse movement)
    ' Range: 0.1 to 5.0 (clamped)
    ' 0.5 = slower, 1.0 = normal, 2.0 = faster
    Method SetSensitivity(sens:Float)
        sensitivity = Max(0.1, Min(sens, 5.0))
    End Method
    
    ' Enable/disable snap to ticks
    ' When enabled, value will snap to nearest tick mark position
    Method SetSnapToTicks(snap:Int)
        snapToTicks = snap
    End Method
    
    ' Set number of tick marks
    ' Range: 2 to 50 (clamped for visual clarity)
    Method SetTickCount(count:Int)
        tickCount = Max(2, Min(count, 50))
    End Method
    
    ' Show/hide tick marks
    Method SetShowTicks(show:Int)
        showTicks = show
    End Method
    
    ' Show/hide value text (percentage display in center)
    Method SetShowValue(show:Int)
        showValue = show
    End Method
    
    ' Show/hide indicator line (pointer showing current value)
    Method SetShowIndicator(show:Int)
        showIndicator = show
    End Method
    
    ' Enable/disable mouse wheel control
    Method SetWheelEnabled(enabled:Int)
        wheelEnabled = enabled
    End Method
    
    ' Set mouse wheel step size (0.01 to 0.5, clamped)
    ' Default: 0.05 (5% per wheel tick)
    Method SetWheelStep(StepA:Float)
        wheelStep = Max(0.01, Min(StepA, 0.5))
    End Method
    
    ' Set knob body color
    Method SetKnobColor(r:Int, g:Int, b:Int)
        knobR = r
        knobG = g
        knobB = b
    End Method
    
    ' Set indicator line color
    Method SetIndicatorColor(r:Int, g:Int, b:Int)
        indicatorR = r
        indicatorG = g
        indicatorB = b
    End Method
    
    ' Set tick marks color
    Method SetTickColor(r:Int, g:Int, b:Int)
        tickR = r
        tickG = g
        tickB = b
    End Method
    
    ' Set value text color (percentage display)
    Method SetTextColor(r:Int, g:Int, b:Int)
        textR = r
        textG = g
        textB = b
    End Method
    
    ' Resize knob (changes diameter, recalculates all dimensions)
    Method SetSize(size:Int)
        rect.w = size
        rect.h = size
        radius = Float(size) / 2.0
        innerRadius = radius * 0.3
        indicatorLength = radius * 0.7
    End Method
    
    ' =========================================================================
    '                         EVENT SYSTEM
    ' =========================================================================
    
    ' Internal: Fire an event (add to event queue)
    Method FireEvent(eventType:String)
        Local ev:TEvent = New TEvent
        ev.target = Self
        ev.eventType = eventType
        events.AddLast(ev)
    End Method
    
    ' Check if knob was just pressed this frame
    Method WasPressed:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "KnobPress" Then Return True
        Next
        Return False
    End Method
    
    ' Check if knob was just released this frame
    Method WasReleased:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "KnobRelease" Then Return True
        Next
        Return False
    End Method
    
    ' Check if knob value is changing (drag or wheel)
    Method IsChanging:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "KnobChange" Then Return True
        Next
        Return False
    End Method
    
    ' Clear all events (call at end of frame after processing)
    Method ClearEvents()
        events.Clear()
    End Method
    
    ' =========================================================================
    '                         UTILITY
    ' =========================================================================
    
    ' Clamp a float value between min and max bounds
    Function Clamp:Float(val:Float, minVal:Float, maxVal:Float)
        If val < minVal Then Return minVal
        If val > maxVal Then Return maxVal
        Return val
    End Function
End Type
