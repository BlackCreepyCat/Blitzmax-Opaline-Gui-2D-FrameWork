' =============================================================================
'                          MOUSE STATE MANAGER
' =============================================================================
' Tracks mouse position, button states, and wheel for GUI interaction
' =============================================================================

Type TMouse
    Field x:Int, y:Int
    Field GuiMouseDown:Int[3]      ' Current button states
    Field GuiMouseHit:Int[3]       ' Button just pressed this frame
    Field GuiMouseReleased:Int[3]  ' Button just released this frame
    
    ' Mouse wheel support
    Field wheel:Int = 0            ' Current wheel delta this frame
    Field wheelAccum:Int = 0       ' Accumulated wheel value (for smooth scrolling)
    Field lastWheelZ:Int = 0       ' Previous MouseZ value for delta calculation
    
    ' Input consumption (for popup/overlay priority)
    Field inputConsumed:Int = False  ' Set to True when a popup consumes input

    ' Update mouse state - call once per frame
    Method Update()
        x = MouseX()
        y = MouseY()
        
        ' Reset input consumed flag at start of each frame
        inputConsumed = False

        ' Check each mouse button (left, middle, right)
        For Local b:Int = 0 Until 3
            Local current:Int = MouseDown(b + 1)
            GuiMouseHit[b]      = (current And GuiMouseDown[b] = 0)
            GuiMouseReleased[b] = (GuiMouseDown[b] And current = 0)
            GuiMouseDown[b]     = current
        Next
        
        ' Update wheel delta
        Local currentWheelZ:Int = MouseZ()
        wheel = currentWheelZ - lastWheelZ
        lastWheelZ = currentWheelZ
        
        ' Accumulate for widgets that need it
        If wheel <> 0
            wheelAccum :+ wheel
        EndIf
    End Method

    ' Check if button was just pressed (respects input consumption)
    Method Hit:Int(button:Int = 1)
        If inputConsumed Then Return False
        Return GuiMouseHit[button - 1]
    End Method
    
    ' Check if button was just pressed (ignores input consumption - for popups)
    Method HitRaw:Int(button:Int = 1)
        Return GuiMouseHit[button - 1]
    End Method

    ' Check if button is currently held down
    Method Down:Int(button:Int = 1)
        Return GuiMouseDown[button - 1]
    End Method

    ' Check if button was just released
    Method Released:Int(button:Int = 1)
        Return GuiMouseReleased[button - 1]
    End Method
    
    ' Mark input as consumed (call from popups after handling a click)
    Method ConsumeInput()
        inputConsumed = True
    End Method
    
    ' Check if input has been consumed this frame
    Method IsInputConsumed:Int()
        Return inputConsumed
    End Method
    
    ' Get wheel delta for this frame (positive = up, negative = down)
    Method WheelIdle:Int()
        Return wheel
    End Method
    
    ' Get wheel direction: 1 = up, -1 = down, 0 = no movement
    Method WheelUp:Int()
        Return wheel > 0
    End Method
    
    Method WheelDown:Int()
        Return wheel < 0
    End Method
    
    ' Get and reset accumulated wheel value
    Method GetWheelAccum:Int()
        Local val:Int = wheelAccum
        wheelAccum = 0
        Return val
    End Method
    
    ' Reset wheel accumulator manually
    Method ResetWheelAccum()
        wheelAccum = 0
    End Method
End Type

' Global instances
Global GuiMouse:TMouse = New TMouse
Global draggedWindow:TWindow = Null
