' =============================================================================
'                              WINDOW WIDGET
' =============================================================================
' Draggable window with title bar and control buttons
' =============================================================================

Type TWindow Extends TWidget
    Field title:String
    Field isDragging:Int = False
    Field dragOffsetX:Int
    Field dragOffsetY:Int
    
    Field closeBtn:TButton
    Field minBtn:TButton
    Field maxBtn:TButton

    ' Optional button setup
    Field showCloseButton:Int   = True
    Field showMinButton:Int     = True
    Field showMaxButton:Int     = True

    ' Constructor - creates window with title bar and the three standard control buttons
    Method New(x:Int, y:Int, w:Int, h:Int, title:String, showClose:Int=True, showMin:Int=True, showMax:Int=True )
        Super.New(x, y, w, h + TITLEBAR_HEIGHT)
        Self.title = title

        showCloseButton = showClose
        showMinButton   = showMin
        showMaxButton   = showMax

		SetTitleButtons(showCloseButton, showMinButton, showMaxButton)

        ' Set default client area background color
        red = COLOR_WINDOW_CLIENT_R
        green = COLOR_WINDOW_CLIENT_G
        blue = COLOR_WINDOW_CLIENT_B
    End Method

    ' Configure which titlebar buttons to show (call after creation if needed)
    Method SetTitleButtons(showClose:Int=True, showMin:Int=True, showMax:Int=True)

        ' Remove existing buttons first
        If closeBtn Then children.Remove(closeBtn); closeBtn = Null
        If minBtn   Then children.Remove(minBtn);   minBtn   = Null
        If maxBtn   Then children.Remove(maxBtn);   maxBtn   = Null
        
        Local btnY:Int = (TITLEBAR_HEIGHT - TITLE_BUTTON_SIZE) / 2
        Local Right:Int = rect.w - TITLE_BUTTON_MARGIN
        
        If showClose
            closeBtn = New TButton(Right - TITLE_BUTTON_SIZE, btnY, TITLE_BUTTON_SIZE, TITLE_BUTTON_SIZE, "X")
            closeBtn.isTitleButton = True
            closeBtn.buttonType = BTN_TYPE_CLOSE
            closeBtn.id = "window_close"

			closeBtn.red = 232
			closeBtn.green = 17
			closeBtn.blue = 35
						
            AddChild(closeBtn)
            Right :- TITLE_BUTTON_SIZE + 4
        EndIf
        
        If showMax
            maxBtn = New TButton(Right - TITLE_BUTTON_SIZE, btnY, TITLE_BUTTON_SIZE, TITLE_BUTTON_SIZE, "Ξ")
            maxBtn.isTitleButton = True
            maxBtn.buttonType = BTN_TYPE_MAXIMIZE
            maxBtn.id = "window_maximize"
            AddChild(maxBtn)
            Right :- TITLE_BUTTON_SIZE + 4
        EndIf
        
        If showMin
            minBtn = New TButton(Right - TITLE_BUTTON_SIZE, btnY, TITLE_BUTTON_SIZE, TITLE_BUTTON_SIZE, "-")
            minBtn.isTitleButton = True
            minBtn.buttonType = BTN_TYPE_MINIMIZE
            minBtn.id = "window_minimize"
            AddChild(minBtn)
        EndIf

    End Method

    ' Returns True if this window is the topmost (last in parent's children list)
    Method IsTopWindow:Int()
        If parent = Null Return False
        Return parent.children.Last() = Self
    End Method

    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y

        ' Draw title bar with different color depending on active/inactive state
        If IsTopWindow()
            TWidget.GuiDrawRect(ax, ay, rect.w, TITLEBAR_HEIGHT, 2, COLOR_TITLEBAR_ACTIVE_R, COLOR_TITLEBAR_ACTIVE_G, COLOR_TITLEBAR_ACTIVE_B)
        Else
            TWidget.GuiDrawRect(ax, ay, rect.w, TITLEBAR_HEIGHT, 2, COLOR_TITLEBAR_INACTIVE_R, COLOR_TITLEBAR_INACTIVE_G, COLOR_TITLEBAR_INACTIVE_B)
        EndIf


        ' Draw title text with shadow
        TWidget.GuiDrawText(ax + 8, ay + 6, title, TEXT_STYLE_SHADOW, COLOR_WINDOW_TITLE_R, COLOR_WINDOW_TITLE_G, COLOR_WINDOW_TITLE_B)

        ' Draw client area background
        TWidget.GuiDrawRect(ax, ay + (TITLEBAR_HEIGHT + 1)  , rect.w, rect.h - (TITLEBAR_HEIGHT + 1), 2, red, green, blue)


        ' First draw title bar buttons (they should appear on top of title bar)
        For Local c:TWidget = EachIn children
            If TButton(c) And TButton(c).isTitleButton
                c.Draw(ax, ay)
            EndIf
        Next

        ' Then draw all other children (content) below the title bar
        For Local c:TWidget = EachIn children
            If Not (TButton(c) And TButton(c).isTitleButton)
                c.Draw(ax, ay + TITLEBAR_HEIGHT)
            EndIf
        Next
    End Method

    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        
        Local lx:Int = mx - rect.x
        Local ly:Int = my - rect.y

        ' Handle ongoing drag
        If isDragging
            If GuiMouse.Down()
                rect.x = mx - dragOffsetX
                rect.y = my - dragOffsetY
                If parent Then parent.BringToFront(Self)
                Return True
            ElseIf GuiMouse.Released()
                isDragging = False
                draggedWindow = Null
                Return True
            EndIf
        EndIf

        ' Start dragging only if mouse is over title bar and not over any button
        If draggedWindow = Null And GuiMouse.Hit()
            If lx >= 0 And lx < rect.w And ly >= 0 And ly < TITLEBAR_HEIGHT
                Local overButton:Int = False
                
                If closeBtn And lx >= closeBtn.rect.x And lx < closeBtn.rect.x + closeBtn.rect.w And ly >= closeBtn.rect.y And ly < closeBtn.rect.y + closeBtn.rect.h Then overButton = True
                If minBtn And lx >= minBtn.rect.x And lx < minBtn.rect.x + minBtn.rect.w And ly >= minBtn.rect.y And ly < minBtn.rect.y + minBtn.rect.h Then overButton = True
                If maxBtn And lx >= maxBtn.rect.x And lx < maxBtn.rect.x + maxBtn.rect.w And ly >= maxBtn.rect.y And ly < maxBtn.rect.y + maxBtn.rect.h Then overButton = True

                If Not overButton
                    If parent Then parent.BringToFront(Self)
                    isDragging = True
                    dragOffsetX = lx
                    dragOffsetY = ly
                    draggedWindow = Self
                    Return True
                EndIf
            EndIf
        EndIf

        ' Update title bar buttons (in reverse order for correct z-index)
        Local revAll:TList = New TList
        For Local c:TWidget = EachIn children
            revAll.AddFirst(c)
        Next

        For Local c:TWidget = EachIn revAll
            If TButton(c) And TButton(c).isTitleButton
                Local relX:Int = lx - c.rect.x
                Local relY:Int = ly - c.rect.y
                If c.Update(relX, relY) Then Return True
            EndIf
        Next

        ' Update client area children only if this is the top window and mouse is below title bar
        If IsTopWindow() And ly >= TITLEBAR_HEIGHT
            Local clientX:Int = lx
            Local clientY:Int = ly - TITLEBAR_HEIGHT

            Local revClient:TList = New TList
            For Local c:TWidget = EachIn children
                revClient.AddFirst(c)
            Next

            For Local c:TWidget = EachIn revClient
                If Not (TButton(c) And TButton(c).isTitleButton)
                    Local relX:Int = clientX - c.rect.x
                    Local relY:Int = clientY - c.rect.y
                    If c.Update(relX, relY) Then Return True
                EndIf
            Next
        EndIf

        ' If clicked anywhere in the window (but not handled above), bring to front
        If draggedWindow = Null And GuiMouse.Hit()
            If lx >= 0 And lx < rect.w And ly >= 0 And ly < rect.h
                If parent Then parent.BringToFront(Self)
                Return True
            EndIf
        EndIf

        Return False
    End Method

    ' Closes the window - removes it from parent and clears children
    Method Close()
        children.Clear()
        If parent
            parent.children.Remove(Self)
        EndIf
    End Method
End Type