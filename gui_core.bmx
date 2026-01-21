' =============================================================================
'                          CORE STRUCTURES
' =============================================================================
' Base structures used by all GUI components
' =============================================================================

' Rectangle structure for widget positioning and sizing
Type TRect
    Field x:Int, y:Int, w:Int, h:Int
End Type

' Event structure for widget interactions
Type TEvent
    Field target:TWidget
    Field eventType:String
End Type

' =============================================================================
'                          GLOBAL GUI STATE
' =============================================================================
Global Gui_SystemFont:TImageFont
Global Gui_SystemFontSize:Int = 16
Global Gui_Root:TContainer = Null  ' Global root container reference

Global Gui_Clipboard:TClipboard

' =============================================================================
'                        ABSTRACT WIDGET CLASS
' =============================================================================
' Base class for all GUI widgets
Type TWidget Abstract
    Field rect:TRect = New TRect
    Field children:TList = New TList  ' Child widgets
    Field parent:TWidget              ' Parent widget

    ' Custom color for this widget (if different from theme)
    Field red:Int 
    Field green:Int
    Field blue:Int
    
    ' Visibility and state management
    Field visible:Int = True          ' Current visibility (combined state)
    Field enabled:Int = True          ' Whether widget accepts input
    Field visibleByUser:Int = True    ' User-controlled visibility (manual Show/Hide)
    Field visibleByTabber:Int = True  ' Tabber-controlled visibility

    Method New(x:Int, y:Int, w:Int, h:Int)
        rect.x = x
        rect.y = y
        rect.w = w
        rect.h = h
    End Method

    ' Add a child widget to this widget
    Method AddChild(child:TWidget)
        If child = Null Return
        If child.parent Then child.parent.children.Remove(child)
        children.AddLast(child)
        child.parent = Self
    End Method

    ' Bring a child widget to the front (z-order)
    Method BringToFront(child:TWidget)
        If child = Null Or Not children.Contains(child) Return
        children.Remove(child)
        children.AddLast(child)
    End Method

    ' Helper: Check if a point is inside this widget's rectangle
    Method ContainsPoint:Int(x:Int, y:Int)
        Return x >= 0 And x < rect.w And y >= 0 And y < rect.h
    End Method

    ' =========================================================================
    '                      VISIBILITY & STATE MANAGEMENT
    ' =========================================================================
    
    ' Show the widget (user action)
    Method Show()
        visibleByUser = True
        UpdateVisibility()
    End Method
    
    ' Hide the widget (user action)
    Method Hide()
        visibleByUser = False
        UpdateVisibility()
    End Method
    
    ' Set visibility directly (user action)
    Method SetVisible(vis:Int)
        visibleByUser = vis
        UpdateVisibility()
    End Method
    
    ' Check if widget is visible
    Method IsVisible:Int()
        Return visible
    End Method
    
    ' Enable the widget (accepts input)
    Method Enable()
        enabled = True
    End Method
    
    ' Disable the widget (ignores input)
    Method Disable()
        enabled = False
    End Method
    
    ' Set enabled state
    Method SetEnabled(state:Int)
        enabled = state
    End Method
    
    ' Check if widget is enabled
    Method IsEnabled:Int()
        Return enabled
    End Method
    
    ' Called by TTabber to control visibility without affecting user preference
    Method SetVisibleByTabber(vis:Int)
        visibleByTabber = vis
        UpdateVisibility()
    End Method
    
    ' Update the combined visibility state
    ' Widget is visible only if BOTH user AND tabber want it visible
    Method UpdateVisibility()
        visible = visibleByUser And visibleByTabber
    End Method

    ' Abstract methods - must be implemented by subclasses
    Method Draw(px:Int=0, py:Int=0) Abstract
    Method Update:Int(mx:Int, my:Int) Abstract

    ' =========================================================================
    '                      STATIC GUI FUNCTIONS
    ' =========================================================================

    ' Initialize the GUI system
    ' Call once at startup before creating any widgets
    Function GuiInit(fontPath:String = "Arial.ttf", FontSize:Int = 16)
        Gui_SystemFontSize = FontSize
        Gui_SystemFont = LoadImageFont(fontPath, Gui_SystemFontSize, SMOOTHFONT)
		Gui_Clipboard:TClipboard = CreateClipboard()
    End Function
    
    ' Set the root container for the GUI
    ' Call after creating your root TContainer
    Function GuiSetRoot(root:TContainer)
        Gui_Root = root
    End Function
    
    ' Get the current root container
    Function GuiGetRoot:TContainer()
        Return Gui_Root
    End Function

    ' =========================================================================
    '                      MAIN REFRESH METHOD
    ' =========================================================================
    ' Call this once per frame in your main loop
    ' Handles: mouse update, popup priority, widget tree update & draw, window controls
    '
    ' Usage:
    '   While Not AppTerminate()
    '       Cls
    '       TWidget.GuiRefresh()
    '       ' ... your game logic and event handling ...
    '       Flip
    '   Wend
    ' =========================================================================
    Function GuiRefresh()
        If Gui_Root = Null Then Return
        
        ' 1. Update mouse state (position, buttons, wheel)
        GuiMouse.Update()
        
        ' 2. Handle context menu FIRST (highest priority overlay)
        If TContextMenu.UpdateActiveMenu() Then
            ' Context menu consumed the input, skip other updates
            Gui_Root.Draw()
            TComboBox.DrawActivePopup()
            TContextMenu.DrawActiveMenu()
            Return
        EndIf
        
        ' 3. Handle active popup (ComboBox dropdown has priority)
        TComboBox.UpdateActivePopup()
        
        ' 4. IMPORTANT: Always update focused TextInput/TextArea for keyboard handling
        ' This ensures keyboard input is processed even if mouse is elsewhere
        If g_FocusedTextInput <> Null And g_FocusedTextInput.focused
            g_FocusedTextInput.HandleKeyboard()
        ElseIf g_FocusedTextArea <> Null And g_FocusedTextArea.focused
            g_FocusedTextArea.HandleKeyboard()
        EndIf
        
        ' 5. Update widget tree (input handling, state changes)
        Gui_Root.Update(GuiMouse.x, GuiMouse.y)
        
        ' 6. Draw widget tree
        Gui_Root.Draw()
        
        ' 7. Draw popup overlays LAST (on top of everything)
        TComboBox.DrawActivePopup()
        
        ' 8. Draw context menu on top of everything
        TContextMenu.DrawActiveMenu()
        
        ' 9. Handle window control buttons (close / min / max) automatically
        GuiProcessWindowEvents()
        
        ' 10. Handle active MessageBox buttons
        TMessageBox.UpdateActiveMessageBox()
    End Function
    
    ' Alternative: Separate update and draw for more control
    Function GuiUpdate()
        If Gui_Root = Null Then Return
        
        ' Update mouse state
        GuiMouse.Update()
        
        ' Handle context menu first
        If TContextMenu.UpdateActiveMenu() Then Return
        
        ' Handle active popup first
        TComboBox.UpdateActivePopup()
        
        ' IMPORTANT: Always update focused TextInput/TextArea for keyboard handling
        ' This ensures keyboard input is processed even if mouse is elsewhere
        If g_FocusedTextInput <> Null And g_FocusedTextInput.focused
            g_FocusedTextInput.HandleKeyboard()
        ElseIf g_FocusedTextArea <> Null And g_FocusedTextArea.focused
            g_FocusedTextArea.HandleKeyboard()
        EndIf
        
        ' Update widget tree
        Gui_Root.Update(GuiMouse.x, GuiMouse.y)
        
        ' Handle window control buttons automatically
        GuiProcessWindowEvents()
        
        ' Handle active MessageBox buttons
        TMessageBox.UpdateActiveMessageBox()
    End Function
    
    Function GuiDraw()
        If Gui_Root = Null Then Return
        
        ' Draw widget tree
        Gui_Root.Draw()
        
        ' Draw popup overlays
        TComboBox.DrawActivePopup()
        
        ' Draw context menu on top
        TContextMenu.DrawActiveMenu()
    End Function
    
    ' Clear all events in the GUI tree
    ' Call at the end of your frame after processing events
    Function GuiClearEvents()
        If Gui_Root = Null Then Return
        ClearAllEvents(Gui_Root)
    End Function
    
    ' Process window control events (close, min, max buttons)
    ' Call in your main loop if you want automatic window control handling
    Function GuiProcessWindowEvents()
        If Gui_Root = Null Then Return
        For Local win:TWindow = EachIn Gui_Root.children
            ProcessWindowControlEvents(win)
        Next
    End Function

    ' =========================================================================
    '                      DRAWING HELPER FUNCTIONS
    ' =========================================================================

    ' Constrain the viewport
    Function GuiSetViewport(Px:Int, Py:Int, Tx:Int, Ty:Int)
        SetViewport(Px, Py, Tx, Ty)
    End Function
    
    ' Draw GUI text with optional shadow
    Function GuiDrawText(Px:Int, Py:Int, caption:String, style:Int, red:Int, green:Int, blue:Int, alpha:Float = 1.0)
        SetBlend(ALPHABLEND)
        SetImageFont(Gui_SystemFont)
        SetAlpha(alpha)
    
        Select style
        
        ' Normal
        Case 1
            SetColor red, green, blue
            DrawText caption, px, py
        
        ' Shadowed
        Case 2
            ' Shadow
            SetColor 5, 5, 5
            DrawText caption, px + 1, py + 1
                    
            SetColor red, green, blue
            DrawText caption, px, py           
        End Select
        
        ' Reset
        SetColor 255, 255, 255
        SetAlpha 1.0
    End Function
    
    ' Draw filled rectangle with optional embossed/pressed styles
    Function GuiDrawRect(px:Int, py:Int, tx:Int, ty:Int, style:Int, red:Int, green:Int, blue:Int, alpha:Float=1.0)
		SetBlend(ALPHABLEND)
		SetAlpha(alpha)
		
        Select style
        
        ' Flat filled rectangle
        Case 1
            SetColor red, green, blue
            DrawRect px, py, tx, ty
        
        ' Raised/embossed look
        Case 2
            SetColor red, green, blue
            DrawRect px, py, tx, ty

            SetColor red/2, green/2, blue/2	
            DrawLine px, py + ty, px + tx, py + ty
            DrawLine px + tx, py, px + tx, py + ty	
                        
            SetColor red*2, green*2, blue*2	
            DrawLine px, py, px + tx, py
            DrawLine px, py, px, py + ty	
        
        ' Pressed/clicked look (inverted bevel)
        Case 3
            SetColor red, green, blue
            DrawRect px, py, tx, ty

            SetColor red*2, green*2, blue*2	
            DrawLine px, py + ty, px + tx, py + ty
            DrawLine px + tx, py, px + tx, py + ty	
                        
            SetColor red/2, green/2, blue/2	
            DrawLine px, py, px + tx, py
            DrawLine px, py, px, py + ty		
        End Select
        
        ' Reset color
        SetColor 255, 255, 255
		SetAlpha 1.0
    End Function
    
    ' Draw oval/circle with optional shadow
    Function GuiDrawOval(px:Int, py:Int, RadiusX:Int, RadiusY:Int, style:Int, red:Int, green:Int, blue:Int, alpha:Float=1.0)
		SetBlend(ALPHABLEND)
		SetAlpha(alpha)
				
        Select style
        
        ' Flat filled oval
        Case 1
            SetColor red, green, blue
            DrawOval px, py, RadiusX, RadiusY
        
        ' Shadowed
        Case 2
            SetColor 5, 5, 5
            DrawOval px + 2, py + 2, RadiusX, RadiusY	
            
            SetColor red, green, blue
            DrawOval px, py, RadiusX, RadiusY	 
        End Select
        
        ' Reset color
        SetColor 255, 255, 255
		SetAlpha 1.0
    End Function

    ' Draw oval/circle with optional shadow
    Function GuiDrawLine(px:Int, py:Int, Tx:Int, Ty:Int, style:Int, red:Int, green:Int, blue:Int, alpha:Float=1.0)
		SetBlend(ALPHABLEND)
		SetAlpha(alpha)
				
        Select style
        
        ' Flat line
        Case 1
            SetColor red, green, blue
            DrawLine px, py, tx, ty	
        
        ' Fat Line
        Case 2
            SetColor red, green, blue

			SetLineWidth(3)
            DrawLine px, py, tx, ty	
			SetLineWidth(1)	
        End Select
        
        ' Reset color
        SetColor 255, 255, 255
		SetAlpha 1.0
    End Function
    
End Type
