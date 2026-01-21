' =============================================================================
'                              TASKBAR WIDGET
' =============================================================================
' Windows-style taskbar with buttons for minimized windows and clock
' Automatically manages window minimize/restore functionality
' =============================================================================

' -----------------------------------------------------------------------------
' Global TaskBar Reference
' -----------------------------------------------------------------------------
Global g_TaskBar:TTaskBar = Null

' -----------------------------------------------------------------------------
' TaskBar Item - Links a button to a minimized window
' -----------------------------------------------------------------------------
Type TTaskBarItem
    Field window:TWindow           ' Reference to the minimized window
    Field button:TButton           ' The button in the taskbar
    Field windowTitle:String       ' Cached window title
    
    Method New(win:TWindow, btn:TButton)
        window = win
        button = btn
        windowTitle = win.title
    End Method
End Type

' -----------------------------------------------------------------------------
' TaskBar Widget
' -----------------------------------------------------------------------------
Type TTaskBar Extends TWidget
    Field panel:TPanel             ' The taskbar panel
    Field items:TList = New TList  ' List of TTaskBarItem
    Field isAutoHide:Int = True    ' Auto-hide mode (enabled by default)
    Field isHidden:Int = False     ' Current hidden state
    Field showClock:Int = True     ' Show clock on the right
    
    ' Auto-hide timing
    Field lastMouseOverTime:Int = 0   ' Last time mouse was over taskbar
    Field autoHideDelay:Int = 2000    ' Delay before hiding (ms)
    
    ' Colors
    Field red:Int = COLOR_TASKBAR_BG_R
    Field green:Int = COLOR_TASKBAR_BG_G
    Field blue:Int = COLOR_TASKBAR_BG_B
    
    ' Animation
    Field targetY:Int              ' Target Y position (where we want to be)
    Field currentY:Float           ' Current Y position (animated)
    Field animationSpeed:Float = 0.15  ' Animation speed (0.0 to 1.0, higher = faster)
    Field screenHeight:Int         ' Store screen height for calculations
    
    ' =========================================================================
    '                         CONSTRUCTOR
    ' =========================================================================
    Method New(scrWidth:Int, scrHeight:Int)
        ' Super.New MUST be first - calculate Y inline
        Super.New(0, scrHeight - TASKBAR_HEIGHT, scrWidth, TASKBAR_HEIGHT)
        
        ' Store screen height
        screenHeight = scrHeight
        
        ' Create the main panel
        panel = New TPanel(0, 0, scrWidth, TASKBAR_HEIGHT, "", PANEL_STYLE_RAISED)
        panel.red = red
        panel.green = green
        panel.blue = blue
        panel.padding = 0
        
        ' Initialize positions (visible by default)
        targetY = scrHeight - TASKBAR_HEIGHT
        currentY = Float(targetY)
        
        ' Initialize auto-hide timer
        lastMouseOverTime = MilliSecs()
        
        ' Set as global reference
        g_TaskBar = Self
    End Method
    
    ' =========================================================================
    '                         WINDOW MANAGEMENT
    ' =========================================================================
    
    ' Called when a window is minimized - creates a taskbar button
    Method OnWindowMinimize(win:TWindow)
        If win = Null Then Return
        
        ' Check if window already has a taskbar item
        For Local item:TTaskBarItem = EachIn items
            If item.window = win Then Return  ' Already in taskbar
        Next
        
        ' Create a new button for this window
        Local btn:TButton = New TButton(0, 0, TASKBAR_BUTTON_MAX_WIDTH, TASKBAR_BUTTON_HEIGHT, win.title)
        
        ' Set taskbar button color (darker blue to match taskbar style)
        btn.SetColor(COLOR_TASKBAR_BG_R + 30, COLOR_TASKBAR_BG_G + 30, COLOR_TASKBAR_BG_B + 30)
        
        ' Add button to panel
        panel.AddChild(btn)
        
        ' Create taskbar item
        Local item:TTaskBarItem = New TTaskBarItem(win, btn)
        items.AddLast(item)
        
        ' Reorganize buttons
        RepositionButtons()
        
        ' Hide the window
        win.Hide()
    End Method
    
    ' Called when a window should be restored from taskbar
    Method OnWindowRestore(win:TWindow)
        If win = Null Then Return
        
        Local itemToRemove:TTaskBarItem = Null
        
        For Local item:TTaskBarItem = EachIn items
            If item.window = win
                itemToRemove = item
                Exit
            EndIf
        Next
        
        If itemToRemove <> Null
            ' Remove button from panel
            panel.children.Remove(itemToRemove.button)
            
            ' Remove item from list
            items.Remove(itemToRemove)
            
            ' Show the window
            win.Show()
            
            ' Bring window to front
            If win.parent Then win.parent.BringToFront(win)
            
            ' IMPORTANT: Deactivate desktop mode so the window can receive input
            g_DesktopActive = False
            
            ' Reorganize remaining buttons
            RepositionButtons()
        EndIf
    End Method
    
    ' Remove a window from taskbar (called when window is closed)
    Method RemoveWindow(win:TWindow)
        If win = Null Then Return
        
        Local itemToRemove:TTaskBarItem = Null
        
        For Local item:TTaskBarItem = EachIn items
            If item.window = win
                itemToRemove = item
                Exit
            EndIf
        Next
        
        If itemToRemove <> Null
            panel.children.Remove(itemToRemove.button)
            items.Remove(itemToRemove)
            RepositionButtons()
        EndIf
    End Method
    
    ' Check if a window is minimized (in taskbar)
    Method IsWindowMinimized:Int(win:TWindow)
        For Local item:TTaskBarItem = EachIn items
            If item.window = win Then Return True
        Next
        Return False
    End Method
    
    ' Get the number of items in taskbar
    Method GetItemCount:Int()
        Return items.Count()
    End Method
    
    ' =========================================================================
    '                         BUTTON POSITIONING
    ' =========================================================================
    
    ' Recalculate and reposition all taskbar buttons
    Method RepositionButtons()
        Local count:Int = items.Count()
        If count = 0 Then Return
        
        ' Calculate available width (exclude clock area and margins)
        Local availableWidth:Int = rect.w - TASKBAR_BUTTON_MARGIN * 2
        If showClock Then availableWidth :- TASKBAR_CLOCK_WIDTH
        
        ' Calculate button width based on count
        Local totalSpacing:Int = (count - 1) * TASKBAR_BUTTON_MARGIN
        Local buttonWidth:Int = (availableWidth - totalSpacing) / count
        
        ' Clamp button width
        buttonWidth = Max(TASKBAR_BUTTON_MIN_WIDTH, Min(buttonWidth, TASKBAR_BUTTON_MAX_WIDTH))
        
        ' Position each button
        Local x:Int = TASKBAR_BUTTON_MARGIN
        Local y:Int = (TASKBAR_HEIGHT - TASKBAR_BUTTON_HEIGHT) / 2
        
        For Local item:TTaskBarItem = EachIn items
            item.button.rect.x = x
            item.button.rect.y = y
            item.button.rect.w = buttonWidth
            item.button.rect.h = TASKBAR_BUTTON_HEIGHT
            
            ' Truncate title if needed
            Local maxChars:Int = (buttonWidth - 10) / 8  ' Approximate
            If item.windowTitle.Length > maxChars
                item.button.caption = item.windowTitle[..maxChars-2] + ".."
            Else
                item.button.caption = item.windowTitle
            EndIf
            
            x :+ buttonWidth + TASKBAR_BUTTON_MARGIN
        Next
    End Method
    
    ' =========================================================================
    '                         AUTO-HIDE
    ' =========================================================================
    
    Method SetAutoHide(autoHide:Int)
        isAutoHide = autoHide
        If Not autoHide Then ShowTaskbar()
    End Method
    
    Method GetAutoHide:Int()
        Return isAutoHide
    End Method
    
    ' Show the taskbar (sets target, animation happens in Update)
    Method ShowTaskbar()
        isHidden = False
        targetY = screenHeight - TASKBAR_HEIGHT
        panel.visible = True
    End Method
    
    ' Hide the taskbar (sets target, animation happens in Update)
    Method HideTaskbar()
        isHidden = True
        targetY = screenHeight - 4  ' Almost completely hidden
    End Method
    
    Method ToggleVisibility()
        If isHidden
            ShowTaskbar()
        Else
            HideTaskbar()
        EndIf
    End Method
    
    ' Update animation - smooth interpolation towards target
    Method UpdateAnimation()
        If Abs(currentY - targetY) > 0.5
            currentY = currentY + (targetY - currentY) * animationSpeed
        Else
            currentY = Float(targetY)
        EndIf
        
        ' Update actual position
        rect.y = Int(currentY)
    End Method
    
    ' =========================================================================
    '                         UPDATE
    ' =========================================================================
    
    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        
        ' Always update animation
        UpdateAnimation()
        
        Local CurrentTime:Int = MilliSecs()
        
        ' Check if mouse is near/over taskbar area (use current animated position)
        Local overTaskbarZone:Int = (my >= screenHeight - TASKBAR_HEIGHT - 10)
        Local overTaskbar:Int = (mx >= 0 And mx < rect.w And my >= rect.y And my < rect.y + rect.h)
        
        ' Handle auto-hide behavior
        If isAutoHide
            If overTaskbarZone Or overTaskbar
                ' Mouse is near taskbar - show it and reset timer
                lastMouseOverTime = CurrentTime
                If isHidden Then ShowTaskbar()
            Else
                ' Mouse is away - hide after delay
                If Not isHidden And (CurrentTime - lastMouseOverTime > autoHideDelay)
                    HideTaskbar()
                EndIf
            EndIf
        EndIf
        
        ' If animating to hidden state or fully hidden, don't process clicks
        If isHidden And rect.y > screenHeight - TASKBAR_HEIGHT + 5 Then Return False
        
        ' Calculate local coordinates
        Local localMX:Int = mx
        Local localMY:Int = my - rect.y
        
        ' Update button hover states (always, even if not clicking)
        For Local item:TTaskBarItem = EachIn items
            Local btn:TButton = item.button
            Local relX:Int = localMX - btn.rect.x
            Local relY:Int = localMY - btn.rect.y
            Local overBtn:Int = overTaskbar And (relX >= 0 And relX < btn.rect.w And relY >= 0 And relY < btn.rect.h)
            btn.hover = overBtn
        Next
        
        ' If not over taskbar, don't consume input
        If Not overTaskbar Then Return False
        
        ' Check if mouse was clicked
        Local wasClicked:Int = GuiMouse.Hit()
        
        If wasClicked
            ' Check which button was clicked
            For Local item:TTaskBarItem = EachIn items
                Local btn:TButton = item.button
                Local relX:Int = localMX - btn.rect.x
                Local relY:Int = localMY - btn.rect.y
                Local overBtn:Int = (relX >= 0 And relX < btn.rect.w And relY >= 0 And relY < btn.rect.h)
                
                If overBtn
                    ' This button was clicked - restore the window
                    Print "TaskBar: Restoring window: " + item.windowTitle
                    OnWindowRestore(item.window)
                    Return True
                EndIf
            Next
            
            ' Clicked on taskbar but not on a button - still consume the click
            Return True
        EndIf
        
        ' Mouse is over but not clicking - don't consume input
        Return False
    End Method
    
    ' =========================================================================
    '                         DRAW
    ' =========================================================================
    
    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        If isHidden And isAutoHide Then
            ' Draw thin line indicator when hidden
            TWidget.GuiDrawRect(0, GraphicsHeight() - 4, rect.w, 4, 1, red + 20, green+ 20, blue + 20)
            Return
        EndIf
        
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y
        
        ' Draw panel background
        TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, 2, red, green, blue)
        
        ' Draw separator line at top
        TWidget.GuiDrawLine(ax, ay, ax + rect.w, ay, 1, red + 40, green + 40, blue + 40)
        
        ' Draw buttons
        For Local item:TTaskBarItem = EachIn items
            item.button.Draw(ax, ay)
        Next
        
        ' Draw clock if enabled
        If showClock
            DrawClock(ax, ay)
        EndIf
    End Method
    
    ' Draw the clock on the right side
    Method DrawClock(ax:Int, ay:Int)
        ' Get current time
        Local hours:Int = CurrentTime()[0..2].ToInt()
        Local minutes:Int = CurrentTime()[3..5].ToInt()
        Local seconds:Int = CurrentTime()[6..8].ToInt()
        
        ' Format time string
        Local timeStr:String = RSet(hours, 2).Replace(" ", "0") + ":" + RSet(minutes, 2).Replace(" ", "0")
        
        ' Calculate position (right side of taskbar)
        Local clockX:Int = ax + rect.w - (TASKBAR_CLOCK_WIDTH )
        Local clockY:Int = ay + (TASKBAR_HEIGHT - TextHeight(timeStr)) / 2
        
        ' Draw clock background
        TWidget.GuiDrawRect(clockX - 5, ay + 5, TASKBAR_CLOCK_WIDTH - 10, TASKBAR_HEIGHT - 10, 3, red - 10, green - 10, blue - 10)
        
        ' Draw time text
        TWidget.GuiDrawText(clockX + 5, clockY, timeStr, TEXT_STYLE_SHADOW, COLOR_TASKBAR_CLOCK_R, COLOR_TASKBAR_CLOCK_G, COLOR_TASKBAR_CLOCK_B)
    End Method
    
    ' =========================================================================
    '                         UTILITY METHODS
    ' =========================================================================
    
    ' Set taskbar colors
    Method SetColors(r:Int, g:Int, b:Int)
        red = r
        green = g
        blue = b

        panel.red = r
        panel.green = g
        panel.blue = b
    End Method
    
    ' Enable/disable clock display
    Method SetShowClock(show:Int)
        showClock = show
        RepositionButtons()
    End Method
    
    ' Get show clock state
    Method GetShowClock:Int()
        Return showClock
    End Method
    
    ' Resize taskbar (call when screen size changes)
    Method Resize(screenWidth:Int, screenHeight:Int)
        rect.w = screenWidth
        rect.y = screenHeight - TASKBAR_HEIGHT
        panel.rect.w = screenWidth
        RepositionButtons()
    End Method
End Type

' =============================================================================
'                         GLOBAL TASKBAR FUNCTIONS
' =============================================================================

' Initialize the taskbar (call after creating root container)
Function TaskBarInit:TTaskBar(screenWidth:Int, screenHeight:Int)
    If g_TaskBar <> Null Then Return g_TaskBar
    
    g_TaskBar = New TTaskBar(screenWidth, screenHeight)
    Return g_TaskBar
End Function

' Get the global taskbar
Function GetTaskBar:TTaskBar()
    Return g_TaskBar
End Function

' Called when minimize button is clicked on a window
Function TaskBarMinimizeWindow(win:TWindow)
    If g_TaskBar <> Null And win <> Null
        g_TaskBar.OnWindowMinimize(win)
    EndIf
End Function

' Called when a window should be restored
Function TaskBarRestoreWindow(win:TWindow)
    If g_TaskBar <> Null And win <> Null
        g_TaskBar.OnWindowRestore(win)
    EndIf
End Function

' Check if a window is minimized
Function TaskBarIsMinimized:Int(win:TWindow)
    If g_TaskBar <> Null And win <> Null
        Return g_TaskBar.IsWindowMinimized(win)
    EndIf
    Return False
End Function
