' =============================================================================
'                              WINDOW WIDGET
' =============================================================================
' Draggable window with title bar, control buttons, and optional status bar
' Supports MODAL windows that block input to other windows
' =============================================================================

' -----------------------------------------------------------------------------
' Global Modal Window Tracking
' -----------------------------------------------------------------------------
Global g_ModalWindow:TWindow = Null  ' Currently active modal window

' -----------------------------------------------------------------------------
' Status Bar Section - represents one section of the status bar
' -----------------------------------------------------------------------------
Type TStatusSection
    Field text:String = ""           ' Text to display
    Field width:Int = -1             ' Width in pixels (-1 = auto/flexible)
    Field alignment:Int = LABEL_ALIGN_LEFT
    Field textR:Int = COLOR_STATUSBAR_TEXT_R
    Field textG:Int = COLOR_STATUSBAR_TEXT_G
    Field textB:Int = COLOR_STATUSBAR_TEXT_B
    
    Method New(text:String = "", width:Int = -1, alignment:Int = LABEL_ALIGN_LEFT)
        Self.text = text
        Self.width = width
        Self.alignment = alignment
    End Method
End Type

' -----------------------------------------------------------------------------
' Window Widget
' -----------------------------------------------------------------------------
Type TWindow Extends TWidget
    Field title:String
    Field isDragging:Int = False
    Field dragOffsetX:Int
    Field dragOffsetY:Int
    
    ' Title bar buttons
    Field closeBtn:TButton
    Field minBtn:TButton
    Field maxBtn:TButton

    ' Optional button setup
    Field showCloseButton:Int = True
    Field showMinButton:Int   = True
    Field showMaxButton:Int   = True

    ' Status bar
    Field showStatusBar:Int = False
    Field statusSections:TList = New TList  ' List of TStatusSection
    Field statusText:String = ""            ' Simple single-text mode

    ' =========================================================================
    '                         MODAL SUPPORT
    ' =========================================================================
    Field isModal:Int = False              ' Is this a modal window?

    ' Constructor - creates window with title bar and optional status bar
    ' Parameters:
    '   x, y, w, h    - Position and size (h is CLIENT area height)
    '   title         - Window title
    '   showClose     - Show close button
    '   showMin       - Show minimize button  
    '   showMax       - Show maximize button
    '   showStatus    - Show status bar at bottom
    Method New(x:Int, y:Int, w:Int, h:Int, windowTitle:String, showClose:Int=True, showMin:Int=True, showMax:Int=True, showStatus:Int=False)
        ' Calculate total height: titlebar + client + optional statusbar
        ' Super.New MUST be first, so we calculate inline
        Super.New(x, y, w, h + TITLEBAR_HEIGHT + (showStatus * STATUSBAR_HEIGHT))
        
        title = windowTitle
        showStatusBar = showStatus

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
            closeBtn = New TButton(Right - TITLE_BUTTON_SIZE, btnY, TITLE_BUTTON_SIZE, TITLE_BUTTON_SIZE, "Ω")
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

    ' =========================================================================
    '                         MODAL METHODS
    ' =========================================================================
    
    ' Set this window as modal (blocks input to all other windows)
    ' Only one modal window can be active at a time
    Method SetModalState(modal:Int = True)
        If modal
            ' If another modal is already active, close it first (or deny)
            If g_ModalWindow <> Null And g_ModalWindow <> Self
                ' Option: You could print a warning or handle this differently
                Print "Warning: Another modal window is already active!"
            EndIf
            
            isModal = True
            g_ModalWindow = Self
            
            ' Bring this window to front
            If parent Then parent.BringToFront(Self)
        Else
            isModal = False
            If g_ModalWindow = Self
                g_ModalWindow = Null
            EndIf
        EndIf
    End Method
    
    ' Check if this window is modal
    Method GetModalState:Int()
        Return isModal
    End Method
    
    ' Static function to check if any modal window is active
    Function IsAnyModalActive:Int()
        Return g_ModalWindow <> Null
    End Function
    
    ' Static function to get the current modal window
    Function GetActiveModalWindow:TWindow()
        Return g_ModalWindow
    End Function

    ' =========================================================================
    '                         STATUS BAR METHODS
    ' =========================================================================
    
    ' Set simple status bar text (single section mode)
    Method SetStatusText(text:String)
        statusText = text
    End Method
    
    ' Get current status bar text
    Method GetStatusText:String()
        Return statusText
    End Method
    
    ' Clear the status bar text
    Method ClearStatus()
        statusText = ""
        statusSections.Clear()
    End Method
    
    ' Add a section to the status bar (multi-section mode)
    ' width = -1 means flexible (takes remaining space)
    Method AddStatusSection:Int(text:String = "", width:Int = -1, alignment:Int = LABEL_ALIGN_LEFT)
        Local section:TStatusSection = New TStatusSection(text, width, alignment)
        statusSections.AddLast(section)
        Return statusSections.Count() - 1
    End Method
    
    ' Set text for a specific section by index
    Method SetStatusSection(index:Int, text:String)
        Local i:Int = 0
        For Local section:TStatusSection = EachIn statusSections
            If i = index
                section.text = text
                Return
            EndIf
            i :+ 1
        Next
    End Method
    
    ' Get text from a specific section
    Method GetStatusSection:String(index:Int)
        Local i:Int = 0
        For Local section:TStatusSection = EachIn statusSections
            If i = index Then Return section.text
            i :+ 1
        Next
        Return ""
    End Method
    
    ' Set color for a specific section
    Method SetStatusSectionColor(index:Int, r:Int, g:Int, b:Int)
        Local i:Int = 0
        For Local section:TStatusSection = EachIn statusSections
            If i = index
                section.textR = r
                section.textG = g
                section.textB = b
                Return
            EndIf
            i :+ 1
        Next
    End Method
    
    ' Get number of status sections
    Method GetStatusSectionCount:Int()
        Return statusSections.Count()
    End Method
    
    ' Remove all status sections
    Method ClearStatusSections()
        statusSections.Clear()
    End Method
    
    ' Show or hide the status bar dynamically
    Method SetShowStatusBar(show:Int)
        If show = showStatusBar Then Return
        
        If show And Not showStatusBar
            ' Adding status bar - increase window height
            rect.h :+ STATUSBAR_HEIGHT
        ElseIf Not show And showStatusBar
            ' Removing status bar - decrease window height
            rect.h :- STATUSBAR_HEIGHT
        EndIf
        
        showStatusBar = show
    End Method

    ' =========================================================================
    '                         HELPER METHODS
    ' =========================================================================
    
    ' Returns the client area height (excluding titlebar and statusbar)
    Method GetClientHeight:Int()
        Local h:Int = rect.h - TITLEBAR_HEIGHT
        If showStatusBar Then h :- STATUSBAR_HEIGHT
        Return h
    End Method
    
    ' Returns the client area width
    Method GetClientWidth:Int()
        Return rect.w
    End Method

    ' Returns True if this window is the topmost (last in parent's children list)
    Method IsTopWindow:Int()
        If parent = Null Return False
        Return parent.children.Last() = Self
    End Method

    ' =========================================================================
    '                         DRAWING
    ' =========================================================================
    
    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y

        ' Draw title bar with different color depending on active/inactive state
        ' Modal windows are ALWAYS drawn as active
        If IsTopWindow() Or isModal
            TWidget.GuiDrawRect(ax, ay, rect.w, TITLEBAR_HEIGHT, 2, COLOR_TITLEBAR_ACTIVE_R, COLOR_TITLEBAR_ACTIVE_G, COLOR_TITLEBAR_ACTIVE_B)
        Else
            TWidget.GuiDrawRect(ax, ay, rect.w, TITLEBAR_HEIGHT, 2, COLOR_TITLEBAR_INACTIVE_R, COLOR_TITLEBAR_INACTIVE_G, COLOR_TITLEBAR_INACTIVE_B)
        EndIf

        ' Draw title text with shadow
        TWidget.GuiDrawText(ax + 8, ay + 6, title, TEXT_STYLE_SHADOW, COLOR_WINDOW_TITLE_R, COLOR_WINDOW_TITLE_G, COLOR_WINDOW_TITLE_B)

        ' Calculate client area height
        Local ClientHeight:Int = GetClientHeight()

        ' Draw client area background
        TWidget.GuiDrawRect(ax, ay + TITLEBAR_HEIGHT, rect.w, ClientHeight, 2, red, green, blue)

        ' Draw status bar if enabled
        If showStatusBar
            DrawStatusBar(ax, ay + TITLEBAR_HEIGHT + ClientHeight)
        EndIf

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
    
    ' Draw the status bar
    Method DrawStatusBar(ax:Int, ay:Int)
        ' Calculate the actual Y position of the status bar
        Local statusY:Int = ay - (STATUSBAR_HEIGHT + 2)
        
        ' Draw status bar background (sunken style)
        TWidget.GuiDrawRect(ax + 2, statusY, rect.w - 4, STATUSBAR_HEIGHT, 3, COLOR_STATUSBAR_BG_R, COLOR_STATUSBAR_BG_G, COLOR_STATUSBAR_BG_B)
        
        Local padding:Int = 6
        Local textY:Int = statusY + (STATUSBAR_HEIGHT - TextHeight("X")) / 2
        
        ' If we have sections, draw them
        If statusSections.Count() > 0
            Local currentX:Int = ax + padding
            Local remainingWidth:Int = rect.w - padding * 2
            Local flexCount:Int = 0
            Local fixedWidth:Int = 0
            
            ' First pass: calculate fixed widths and count flexible sections
            For Local section:TStatusSection = EachIn statusSections
                If section.width > 0
                    fixedWidth :+ section.width
                Else
                    flexCount :+ 1
                EndIf
            Next
            
            ' Calculate width for flexible sections
            Local flexWidth:Int = 0
            If flexCount > 0
                flexWidth = (remainingWidth - fixedWidth - (statusSections.Count() - 1) * 2) / flexCount
            EndIf
            
            ' Second pass: draw sections
            Local sectionIndex:Int = 0
            For Local section:TStatusSection = EachIn statusSections
                Local sectionWidth:Int
                If section.width > 0
                    sectionWidth = section.width
                Else
                    sectionWidth = flexWidth
                EndIf
                
                ' Draw separator before section (except first)
                If sectionIndex > 0
                    SetColor COLOR_STATUSBAR_SEPARATOR_R, COLOR_STATUSBAR_SEPARATOR_G, COLOR_STATUSBAR_SEPARATOR_B
                    DrawLine currentX - 1, statusY + 4, currentX - 1, statusY + STATUSBAR_HEIGHT - 4
                EndIf
                
                ' Calculate text position based on alignment
                Local textX:Int
                Select section.alignment
                    Case LABEL_ALIGN_LEFT
                        textX = currentX
                    Case LABEL_ALIGN_CENTER
                        textX = currentX + (sectionWidth - TextWidth(section.text)) / 2
                    Case LABEL_ALIGN_RIGHT
                        textX = currentX + sectionWidth - TextWidth(section.text)
                End Select
                
                ' Clip and draw text
                TWidget.GuiSetViewport(currentX, statusY, sectionWidth, STATUSBAR_HEIGHT)
                TWidget.GuiDrawText(textX, textY, section.text, TEXT_STYLE_NORMAL, section.textR, section.textG, section.textB)
                TWidget.GuiSetViewport(0, 0, GraphicsWidth(), GraphicsHeight())
                
                currentX :+ sectionWidth + 2
                sectionIndex :+ 1
            Next
        Else
            ' Simple single text mode
            TWidget.GuiSetViewport(ax + padding, statusY, rect.w - padding * 2, STATUSBAR_HEIGHT)
            TWidget.GuiDrawText(ax + padding, textY, statusText, TEXT_STYLE_NORMAL, COLOR_STATUSBAR_TEXT_R, COLOR_STATUSBAR_TEXT_G, COLOR_STATUSBAR_TEXT_B)
            TWidget.GuiSetViewport(0, 0, GraphicsWidth(), GraphicsHeight())
        EndIf
    End Method

    ' =========================================================================
    '                         UPDATE / INPUT
    ' =========================================================================
    
    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        
        Local lx:Int = mx - rect.x
        Local ly:Int = my - rect.y

        ' Handle ongoing drag
        If isDragging
            If GuiMouse.Down()
                rect.x = mx - dragOffsetX
                rect.y = my - dragOffsetY
                ' Modal windows are always on top, no need to BringToFront
                If parent And Not isModal Then parent.BringToFront(Self)
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
                    ' Modal windows stay on top, don't allow other windows to come to front
                    If parent And Not isModal Then parent.BringToFront(Self)
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

        ' Calculate client area bounds
        Local clientTop:Int = TITLEBAR_HEIGHT
        Local clientBottom:Int = rect.h
        If showStatusBar Then clientBottom :- STATUSBAR_HEIGHT

        ' Update client area children only if this is the top window (or modal) and mouse is in client area
        If (IsTopWindow() Or isModal) And ly >= clientTop And ly < clientBottom
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
        ' But NOT if a modal window is active and this is not the modal
        If draggedWindow = Null And GuiMouse.Hit()
            If lx >= 0 And lx < rect.w And ly >= 0 And ly < rect.h
                If parent And Not isModal Then parent.BringToFront(Self)
                Return True
            EndIf
        EndIf

        Return False
    End Method

    ' Closes the window - removes it from parent and clears children
    Method Close()
        ' If this was the modal window, clear the global reference
        If g_ModalWindow = Self
            g_ModalWindow = Null
            isModal = False
        EndIf
        
        children.Clear()
        If parent
            parent.children.Remove(Self)
        EndIf
    End Method
End Type
