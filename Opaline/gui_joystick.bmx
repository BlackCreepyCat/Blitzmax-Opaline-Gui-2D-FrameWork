' =============================================================================
'                           VIRTUAL JOYSTICK WIDGET
' =============================================================================
' Mobile-style virtual joystick with smooth analog control
' Returns normalized X/Y values (-1.0 to 1.0) and angle/magnitude
' Supports touch-like interaction with configurable dead zone and snap-back
' =============================================================================

' Joystick Constants
Const JOYSTICK_DEFAULT_SIZE:Int = 120        ' Default diameter of joystick base
Const JOYSTICK_DEFAULT_STICK_SIZE:Int = 60   ' Default diameter of stick/thumb
Const JOYSTICK_DEFAULT_DEADZONE:Float = 0.1  ' Default dead zone (0.0 to 1.0)

Type TJoystick Extends TWidget
    ' Visual dimensions
    Field baseRadius:Float          ' Radius of the base circle
    Field stickRadius:Float         ' Radius of the stick/thumb
    Field maxDistance:Float         ' Maximum distance stick can move from center
    
    ' Current stick position (relative to center, in pixels)
    Field stickX:Float = 0.0
    Field stickY:Float = 0.0
    
    ' Normalized output values (-1.0 to 1.0)
    Field normalizedX:Float = 0.0
    Field normalizedY:Float = 0.0
    
    ' Polar coordinates
    Field angle:Float = 0.0         ' Angle in degrees (0-360)
    Field magnitude:Float = 0.0     ' Distance from center (0.0 to 1.0)
    
    ' Interaction state
    Field isActive:Int = False      ' Is user currently controlling the stick?
    Field clickedOnStick:Int = False
    Field dragStartX:Int = 0
    Field dragStartY:Int = 0
    
    ' Behavior settings
    Field deadZone:Float = JOYSTICK_DEFAULT_DEADZONE  ' Values below this are treated as zero
    Field snapBack:Int = True       ' Auto-return to center when released
    Field snapSpeed:Float = 0.3     ' Speed of snap-back animation (0.0 to 1.0)
    Field invertX:Int = False       ' Invert X axis
    Field invertY:Int = False       ' Invert Y axis
    
    ' Visual style
    Field baseColor:Int = True      ' Use custom base color
    Field baseR:Int = 90
    Field baseG:Int = 140
    Field baseB:Int = 220
    Field baseAlpha:Float = 0.8
    
    Field stickColorActive:Int = True
    Field stickR:Int = 100
    Field stickG:Int = 140
    Field stickB:Int = 220
    Field stickAlpha:Float = 0.9

    Field outlineR:Int = 30
    Field outlineG:Int = 50
    Field outlineB:Int = 80

    
    Field showCrosshair:Int = True  ' Draw crosshair in center
    Field showOutline:Int = True    ' Draw outline around base
    
    ' Events
    Field events:TList = New TList
    
    ' =========================================================================
    '                         CONSTRUCTOR
    ' =========================================================================
    Method New(x:Int, y:Int, size:Int = JOYSTICK_DEFAULT_SIZE)
        ' Size is the diameter of the base circle
        Super.New(x, y, size, size)
        
        baseRadius = Float(size) / 2.0
        stickRadius = Float(JOYSTICK_DEFAULT_STICK_SIZE) / 2.0
        maxDistance = baseRadius - stickRadius - 5  ' Keep stick inside base
        
        ' Set default colors
        red = baseR
        green = baseG
        blue = baseB
    End Method
    
    ' =========================================================================
    '                         DRAWING
    ' =========================================================================
    Method Draw(px:Int = 0, py:Int = 0)
        If Not visible Then Return
        
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y
        
        ' Center of the joystick
        Local centerX:Float = Float(ax) + baseRadius
        Local centerY:Float = Float(ay) + baseRadius
        
        ' Draw base circle (background)
		GuiDrawOval(Int(ax), Int(ay), Int(rect.w) , Int(rect.h) , 3, baseR, baseG, baseB)
		GuiDrawOval(Int(centerX - (baseRadius/2)) , Int(centerY - (baseRadius/2)) , Int(baseRadius), Int(baseRadius), 3, baseR/2, baseG/2, baseB/2,0.5)
		        
        ' Draw crosshair in center and border
        If showCrosshair
			GuiDrawLine(Int(centerX - 15),Int( centerY), Int(centerX + 15), Int(centerY) , 2, outlineR - 20, outlineG - 20, outlineB - 20, 1)
			GuiDrawLine(Int(centerX), Int(centerY - 15), Int(centerX), Int(centerY + 15), 2, outlineR - 20, outlineG - 20, outlineB - 20, 1)
        EndIf
		
		Local LenA:Float = 18
		GuiDrawLine (Int(centerX-baseRadius+LenA), Int(centerY) , Int(centerX-baseRadius) , Int(centerY) , 2 , outlineR,outlineG,outlineB,0.7)
		GuiDrawLine (Int(centerX+baseRadius-LenA), Int(centerY) , Int(centerX+baseRadius) , Int(centerY) , 2 , outlineR,outlineG,outlineB,0.7)
		GuiDrawLine (Int(centerX), Int(centerY-baseRadius+LenA) , Int(centerX) , Int(centerY-baseRadius) , 2 , outlineR,outlineG,outlineB,0.7)
		GuiDrawLine (Int(centerX), Int(centerY+baseRadius-LenA) , Int(centerX) , Int(centerY+baseRadius) , 2 , outlineR,outlineG,outlineB,0.7)
		
        ' Calculate stick position on screen
        Local stickScreenX:Float = centerX + stickX
        Local stickScreenY:Float = centerY + stickY
        
        ' Draw connection line from center to stick (when active)
        If isActive And magnitude > deadZone

			GuiDrawLine(Int(centerX), Int(centerY), Int(stickScreenX), Int(stickScreenY), 2, stickR /2, stickG /2, stickB /2, 0.6)
        EndIf
        
        ' Draw stick/thumb
		Local stickDiameter:Float = stickRadius * 2

        If isActive
			GuiDrawOval(Int(stickScreenX - stickRadius + 2) , Int(stickScreenY - stickRadius + 2) , Int(stickDiameter - 4) , Int(stickDiameter - 4) , 3, Min(255, stickR + 30), Min(255, stickG + 30), Min(255, stickB + 30),stickAlpha)
        Else
			GuiDrawOval(Int(stickScreenX - stickRadius + 2) , Int(stickScreenY - stickRadius + 2) , Int(stickDiameter - 4) , Int(stickDiameter - 4) , 3, stickR, stickG, stickB,stickAlpha)
        EndIf


		Local centerDotRadius:Float = stickRadius * 0.5   
		GuiDrawOval( Int(stickScreenX - centerDotRadius), Int(stickScreenY - centerDotRadius) , Int(centerDotRadius*2) , Int(centerDotRadius*2) , 3 , stickR/2 , stickG/2 , stickB/2, 0.2 )

        
        ' Draw children (if any)
        For Local c:TWidget = EachIn children
            c.Draw(ax, ay)
        Next
    End Method
    
    ' =========================================================================
    '                         UPDATE / INPUT HANDLING
    ' =========================================================================
    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        If Not enabled Then Return ContainsPoint(mx, my)
        
        Local over:Int = ContainsPoint(mx, my)
        
        ' Center of the joystick (relative to widget)
        Local centerX:Float = baseRadius
        Local centerY:Float = baseRadius
        
        ' Check if mouse is over the stick
        Local stickScreenX:Float = centerX + stickX
        Local stickScreenY:Float = centerY + stickY
        Local distToStick:Float = Sqr((mx - stickScreenX) * (mx - stickScreenX) + (my - stickScreenY) * (my - stickScreenY))
        Local overStick:Int = (distToStick <= stickRadius)
        
        Local down:Int = GuiMouse.Down()
        Local hit:Int = GuiMouse.Hit()
        
        ' Start dragging stick
        If hit And (overStick Or over) And draggedWindow = Null
            isActive = True
            clickedOnStick = True
            dragStartX = mx
            dragStartY = my
            FireEvent("JoystickPress")
            Return True
        EndIf
        
        ' Handle dragging
        If clickedOnStick And down
            isActive = True
            
            ' Calculate offset from center
            Local offsetX:Float = Float(mx) - centerX
            Local offsetY:Float = Float(my) - centerY
            
            ' Calculate distance from center
            Local dist:Float = Sqr(offsetX * offsetX + offsetY * offsetY)
            
            ' Clamp to max distance
            If dist > maxDistance
                Local ratio:Float = maxDistance / dist
                offsetX = offsetX * ratio
                offsetY = offsetY * ratio
                dist = maxDistance
            EndIf
            
            ' Update stick position
            stickX = offsetX
            stickY = offsetY
            
            ' Calculate normalized values
            UpdateNormalizedValues()
            
            ' Fire continuous event
            FireEvent("JoystickMove")
            
            Return True
        EndIf
        
        ' Release
        If clickedOnStick And Not down
            clickedOnStick = False
            FireEvent("JoystickRelease")
            
            ' Snap back to center if enabled
            If snapBack
                isActive = False
            EndIf
        EndIf
        
        ' Animate snap-back to center
        If snapBack And Not isActive
            If Abs(stickX) > 0.1 Or Abs(stickY) > 0.1
                stickX = stickX * (1.0 - snapSpeed)
                stickY = stickY * (1.0 - snapSpeed)
                UpdateNormalizedValues()
            Else
                stickX = 0.0
                stickY = 0.0
                normalizedX = 0.0
                normalizedY = 0.0
                magnitude = 0.0
            EndIf
        EndIf
        
        Return over Or isActive
    End Method
    
    ' =========================================================================
    '                         HELPER METHODS
    ' =========================================================================
    
    ' Update normalized values from stick position
    Method UpdateNormalizedValues()
        ' Calculate normalized position (-1.0 to 1.0)
        Local rawX:Float = stickX / maxDistance
        Local rawY:Float = stickY / maxDistance
        
        ' Apply inversion if needed
        If invertX Then rawX = -rawX
        If invertY Then rawY = -rawY
        
        ' Calculate magnitude (0.0 to 1.0)
        magnitude = Sqr(rawX * rawX + rawY * rawY)
        
        ' Apply dead zone
        If magnitude < deadZone
            normalizedX = 0.0
            normalizedY = 0.0
            magnitude = 0.0
        Else
            ' Remap magnitude to account for dead zone
            ' (so full range is still 0.0 to 1.0 after dead zone)
            Local adjustedMag:Float = (magnitude - deadZone) / (1.0 - deadZone)
            adjustedMag = Min(1.0, adjustedMag)
            
            ' Scale normalized values
            If magnitude > 0.0
                normalizedX = rawX * (adjustedMag / magnitude)
                normalizedY = rawY * (adjustedMag / magnitude)
            Else
                normalizedX = 0.0
                normalizedY = 0.0
            EndIf
            
            magnitude = adjustedMag
        EndIf
        
        ' Calculate angle (0-360 degrees, 0 = right, 90 = down)
        If magnitude > 0.0
            angle = ATan2(rawY, rawX)
            If angle < 0.0 Then angle = angle + 360.0
        Else
            angle = 0.0
        EndIf
    End Method
    
    ' =========================================================================
    '                         PUBLIC API - GET VALUES
    ' =========================================================================
    
    ' Get normalized X value (-1.0 to 1.0)
    Method GetX:Float()
        Return normalizedX
    End Method
    
    ' Get normalized Y value (-1.0 to 1.0)
    Method GetY:Float()
        Return normalizedY
    End Method
    
    ' Get angle in degrees (0-360)
    Method GetAngle:Float()
        Return angle
    End Method
    
    ' Get magnitude (0.0 to 1.0)
    Method GetMagnitude:Float()
        Return magnitude
    End Method
    
    ' Check if joystick is currently being used
    Method GetIsActive:Int()
        Return isActive
    End Method
    
    ' Get all values at once
    Method GetValues(x:Float Var, y:Float Var, angle:Float Var, magnitude:Float Var)
        x = normalizedX
        y = normalizedY
        angle = Self.angle
        magnitude = Self.magnitude
    End Method
    
    ' =========================================================================
    '                         PUBLIC API - SETTINGS
    ' =========================================================================
    
    ' Set dead zone (0.0 to 1.0)
    Method SetDeadZone(dz:Float)
        deadZone = Max(0.0, Min(1.0, dz))
    End Method
    
    ' Get dead zone
    Method GetDeadZone:Float()
        Return deadZone
    End Method
    
    ' Enable/disable snap-back to center
    Method SetSnapBack(enabled:Int)
        snapBack = enabled
    End Method
    
    ' Set snap-back speed (0.0 to 1.0, higher = faster)
    Method SetSnapSpeed(speed:Float)
        snapSpeed = Max(0.01, Min(1.0, speed))
    End Method
    
    ' Invert X axis
    Method SetInvertX(Invert:Int)
        invertX = Invert
    End Method
    
    ' Invert Y axis
    Method SetInvertY(Invert:Int)
        invertY = Invert
    End Method
    
    ' Set base circle color
    Method SetBaseColor(r:Int, g:Int, b:Int, alpha:Float = 0.8)
        baseR = r
        baseG = g
        baseB = b
        baseAlpha = Max(0.0, Min(1.0, alpha))
    End Method
    
    ' Set stick/thumb color
    Method SetStickColor(r:Int, g:Int, b:Int, alpha:Float = 0.9)
        stickR = r
        stickG = g
        stickB = b
        stickAlpha = Max(0.0, Min(1.0, alpha))
    End Method

    
    ' Show/hide crosshair
    Method SetShowCrosshair(show:Int)
        showCrosshair = show
    End Method
    
    ' Show/hide outline
    Method SetShowOutline(show:Int)
        showOutline = show
    End Method
    
    ' Resize joystick
    Method SetSize(size:Int)
        rect.w = size
        rect.h = size
        baseRadius = Float(size) / 2.0
        maxDistance = baseRadius - stickRadius - 5
    End Method
    
    ' Set stick size
    Method SetStickSize(size:Int)
        stickRadius = Float(size) / 2.0
        maxDistance = baseRadius - stickRadius - 5
    End Method
    
    ' Reset joystick to center
    Method Reset()
        stickX = 0.0
        stickY = 0.0
        normalizedX = 0.0
        normalizedY = 0.0
        magnitude = 0.0
        angle = 0.0
        isActive = False
        clickedOnStick = False
    End Method
    
    ' =========================================================================
    '                         EVENT SYSTEM
    ' =========================================================================
    
    Method FireEvent(eventType:String)
        Local ev:TEvent = New TEvent
        ev.target = Self
        ev.eventType = eventType
        events.AddLast(ev)
    End Method
    
    ' Check if joystick was just pressed
    Method WasPressed:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "JoystickPress" Then Return True
        Next
        Return False
    End Method
    
    ' Check if joystick was just released
    Method WasReleased:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "JoystickRelease" Then Return True
        Next
        Return False
    End Method
    
    ' Check if joystick is being moved
    Method IsMoving:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "JoystickMove" Then Return True
        Next
        Return False
    End Method
    
    ' Clear all events
    Method ClearEvents()
        events.Clear()
    End Method
End Type
