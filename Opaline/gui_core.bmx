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
'                          ANCHOR CONSTANTS
' =============================================================================
' Anchors determine how a widget resizes/moves when its parent resizes
' By default widgets are anchored to TOP and LEFT (position stays fixed)
' =============================================================================
Const ANCHOR_NONE:Int   = 0
Const ANCHOR_LEFT:Int   = 1   ' Distance to left edge stays fixed
Const ANCHOR_TOP:Int    = 2   ' Distance to top edge stays fixed
Const ANCHOR_RIGHT:Int  = 4   ' Distance to right edge stays fixed
Const ANCHOR_BOTTOM:Int = 8   ' Distance to bottom edge stays fixed
Const ANCHOR_ALL:Int    = 15  ' Anchored to all edges (stretches both ways)

' =============================================================================
'                          GLOBAL GUI STATE
' =============================================================================
Global Gui_SymbolFont:TImageFont
Global Gui_SymbolFontSize:Int = 18

Global Gui_SystemFont:TImageFont
Global Gui_SystemFontSize:Int = 16

Global Gui_Root:TContainer = Null  ' Global root container reference
Global Gui_Clipboard:TClipboard ' Init the clipboard

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
    
    ' Anchor system for automatic resizing
    Field anchors:Int = ANCHOR_LEFT | ANCHOR_TOP  ' Default: fixed position top-left

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

    ' =========================================================================
    '                      ANCHOR SYSTEM
    ' =========================================================================
    
    ' Set anchor flags for this widget
    ' Examples:
    '   SetAnchors(ANCHOR_LEFT | ANCHOR_TOP)           - Fixed position (default)
    '   SetAnchors(ANCHOR_RIGHT | ANCHOR_BOTTOM)       - Stays in bottom-right corner
    '   SetAnchors(ANCHOR_LEFT | ANCHOR_RIGHT)         - Stretches horizontally
    '   SetAnchors(ANCHOR_ALL)                         - Stretches in all directions
    Method SetAnchors(anchorFlags:Int)
        anchors = anchorFlags
    End Method
    
    ' Get current anchor flags
    Method GetAnchors:Int()
        Return anchors
    End Method
    
    ' Called when parent resizes - adjusts position and size based on anchors
    ' deltaW, deltaH = change in parent's width and height
    Method OnParentResize(deltaW:Int, deltaH:Int)
        Local anchorL:Int = (anchors & ANCHOR_LEFT) <> 0
        Local anchorR:Int = (anchors & ANCHOR_RIGHT) <> 0
        Local anchorT:Int = (anchors & ANCHOR_TOP) <> 0
        Local anchorB:Int = (anchors & ANCHOR_BOTTOM) <> 0
        
        ' Horizontal adjustment
        If anchorL And anchorR
            ' Anchored to both left and right: stretch width
            rect.w :+ deltaW
        ElseIf anchorR And Not anchorL
            ' Anchored to right only: move right
            rect.x :+ deltaW
        ElseIf Not anchorL And Not anchorR
            ' No horizontal anchor: move by half (center)
            rect.x :+ deltaW / 2
        EndIf
        ' If only anchorL: do nothing (default behavior)
        
        ' Vertical adjustment
        If anchorT And anchorB
            ' Anchored to both top and bottom: stretch height
            rect.h :+ deltaH
        ElseIf anchorB And Not anchorT
            ' Anchored to bottom only: move down
            rect.y :+ deltaH
        ElseIf Not anchorT And Not anchorB
            ' No vertical anchor: move by half (center)
            rect.y :+ deltaH / 2
        EndIf
        ' If only anchorT: do nothing (default behavior)
        
        ' Recursively notify children (they may have their own anchors)
        For Local child:TWidget = EachIn children
            child.OnParentResize(deltaW, deltaH)
        Next
    End Method

    ' Abstract methods - must be implemented by subclasses
    Method Draw(px:Int=0, py:Int=0) Abstract
    Method Update:Int(mx:Int, my:Int) Abstract

    ' =========================================================================
    '                      STATIC GUI FUNCTIONS
    ' =========================================================================


    ' Initialize the GUI system, Call once at startup before creating any widgets
    Function GuiInit()
        Gui_SystemFont = LoadImageFont("incbin::Arial.ttf", Gui_SystemFontSize, SMOOTHFONT)
		Gui_SymbolFont = LoadImageFont("incbin::Symbol.ttf", Gui_SymbolFontSize, SMOOTHFONT)
		
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

    Function GuiRefresh()
        If Gui_Root = Null Then Return
        
        ' 1. Update mouse state (position, buttons, wheel)
        GuiMouse.Update()
        
        ' 2. Auto-initialize TaskBar if not already done
        If g_TaskBar = Null
            g_TaskBar = New TTaskBar(GraphicsWidth(), GraphicsHeight())
        EndIf
        
        ' 3. Handle context menu FIRST (highest priority overlay)
        If TContextMenu.UpdateActiveMenu() Then
            ' Context menu consumed the input, skip other updates
            Gui_Root.Draw()
            TComboBox.DrawActivePopup()
            TContextMenu.DrawActiveMenu()
            ' Draw taskbar on top
            If g_TaskBar <> Null Then g_TaskBar.Draw()
            Return
        EndIf
        
        ' 4. Handle active popup (ComboBox dropdown has priority)
        TComboBox.UpdateActivePopup()
        
        ' 5. IMPORTANT: Always update focused TextInput/TextArea for keyboard handling
        ' This ensures keyboard input is processed even if mouse is elsewhere
        If g_FocusedTextInput <> Null And g_FocusedTextInput.focused
            g_FocusedTextInput.HandleKeyboard()
        ElseIf g_FocusedTextArea <> Null And g_FocusedTextArea.focused
            g_FocusedTextArea.HandleKeyboard()
        EndIf
        
        ' 6. Update TaskBar (always update for auto-hide timer, but only consume clicks when appropriate)
        Local taskbarConsumed:Int = False
        If g_TaskBar <> Null
            taskbarConsumed = g_TaskBar.Update(GuiMouse.x, GuiMouse.y)
        EndIf
        
        ' 7. Update widget tree (input handling, state changes) - only if taskbar didn't consume the click
        If Not taskbarConsumed
            Gui_Root.Update(GuiMouse.x, GuiMouse.y)
        EndIf
        
        ' 8. Draw widget tree
        Gui_Root.Draw()
        
        ' 9. Draw TaskBar on top of windows but below popups
        If g_TaskBar <> Null
            g_TaskBar.Draw()
        EndIf
        
        ' 10. Draw popup overlays LAST (on top of everything)
        TComboBox.DrawActivePopup()
        
        ' 11. Draw context menu on top of everything
        TContextMenu.DrawActiveMenu()
        
        ' 12. Handle window control buttons (close / min / max) automatically
        GuiProcessWindowEvents()
        
        ' 13. Handle active MessageBox buttons
        TMessageBox.UpdateActiveMessageBox()
    End Function
    
    ' Alternative: Separate update and draw for more control
    Function GuiUpdate()
        If Gui_Root = Null Then Return
        
        ' Update mouse state
        GuiMouse.Update()
        
        ' Auto-initialize TaskBar if not already done
        If g_TaskBar = Null
            g_TaskBar = New TTaskBar(GraphicsWidth(), GraphicsHeight())
        EndIf
        
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
        
        ' Update TaskBar (always update for auto-hide timer)
        Local taskbarConsumed:Int = False
        If g_TaskBar <> Null
            taskbarConsumed = g_TaskBar.Update(GuiMouse.x, GuiMouse.y)
        EndIf
        
        ' Update widget tree - only if taskbar didn't consume the click
        If Not taskbarConsumed
            Gui_Root.Update(GuiMouse.x, GuiMouse.y)
        EndIf
        
        ' Handle window control buttons automatically
        GuiProcessWindowEvents()
        
        ' Handle active MessageBox buttons
        TMessageBox.UpdateActiveMessageBox()
    End Function
    
    Function GuiDraw()
        If Gui_Root = Null Then Return
        
        ' Draw widget tree
        Gui_Root.Draw()
        
        ' Draw TaskBar
        If g_TaskBar <> Null
            g_TaskBar.Draw()
        EndIf
        
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

	' ----------------------
    ' Constrain the viewport
	' ----------------------
    Function GuiSetViewport(Px:Int, Py:Int, Tx:Int, Ty:Int)
        SetViewport(Px, Py, Tx, Ty)
    End Function

	' ---------------------
	' Get text pixel Height
	' ---------------------
	Function GuiTextHeight:Int(caption:String , symbol:Int = False)
		Select symbol
		Case True
			SetImageFont(Gui_SymbolFont)
			Return TextHeight(caption)
			
		Case False
			SetImageFont(Gui_SystemFont)
			Return TextHeight(caption)
						
		EndSelect
	End Function

	' ---------------------
	' Get text pixel Width
	' ---------------------
	Function GuiTextWidth:Int(caption:String , symbol:Int = False)
		Select symbol
		Case True
			SetImageFont(Gui_SymbolFont)
			Return TextWidth(caption)
			
		Case False
			SetImageFont(Gui_SystemFont)
			Return TextWidth(caption)
						
		EndSelect
	End Function

	' ------------------------------------
    ' Draw GUI symbol with optional shadow
	' ------------------------------------
    Function GuiDrawSymbol(Px:Int, Py:Int, caption:String, style:Int, red:Int, green:Int, blue:Int, alpha:Float = 1.0)
        SetBlend(ALPHABLEND)
        SetImageFont(Gui_SymbolFont)
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
 
	' ---------------------------------- 
    ' Draw GUI text with optional shadow
	' ----------------------------------
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

	' -----------------------------------------------------------    
    ' Draw filled rectangle with optional embossed/pressed styles
	' -----------------------------------------------------------
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
 
	' ------------------------------------- 
    ' Draw oval/circle with optional shadow
	' -------------------------------------
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

	' -------------------------------------
    ' Draw oval/circle with optional shadow
	' -------------------------------------
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

	' -----------
    ' Draw images
	' -----------
	Function GuiDrawImageRect(image:TImage,px:Int, py:Int, Tx:Int, Ty:Int, alpha:Float=1.0)
		SetBlend(ALPHABLEND)
		SetAlpha alpha
		
		SetColor 255, 255, 255
		DrawImageRect(image, px, py, tx, ty	)
		
		SetAlpha 1.0
	End Function
End Type
