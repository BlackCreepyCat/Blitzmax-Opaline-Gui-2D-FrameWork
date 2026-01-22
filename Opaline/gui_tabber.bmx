' =============================================================================
'                             TABBER WIDGET
' =============================================================================
' Tab control widget that allows switching between groups of widgets
' Each tab has a name and a list of widgets that are shown/hidden
' Respects manually hidden widgets (visibleByUser flag)
' =============================================================================

' Tab page structure
Type TTabPage
    Field name:String                     ' Tab title
    Field widgets:TList = New TList       ' Widgets in this tab
    Field tabWidth:Int = 0                ' Calculated tab button width
    
    Method New(name:String)
        Self.name = name
    End Method
End Type

Type TTabber Extends TWidget
    ' Tab pages
    Field pages:TList = New TList         ' List of TTabPage
    Field activeIndex:Int = 0             ' Currently active tab index
    Field hoverIndex:Int = -1             ' Tab under mouse cursor
    
    ' Events
    Field events:TList = New TList
    
    ' Calculated layout
    Field contentX:Int = 0
    Field contentY:Int = 0
    Field contentW:Int = 0
    Field contentH:Int = 0
    
    ' Constructor
    Method New(x:Int, y:Int, w:Int, h:Int)
        Super.New(x, y, w, h)
        
        red = COLOR_TABBER_BG_R
        green = COLOR_TABBER_BG_G
        blue = COLOR_TABBER_BG_B
        
        UpdateLayout()
    End Method
    
    ' --------------
    ' Tab Management
    ' --------------
    
    ' Add a new tab page
    Method AddTab:Int(name:String)
        Local page:TTabPage = New TTabPage(name)
        pages.AddLast(page)
        UpdateTabWidths()
        
        ' If this is the first tab, make it active
        If pages.Count() = 1
            SetActiveTab(0)
        Else
            ' Hide widgets of new tab since it's not active
            UpdateTabVisibility()
        EndIf
        
        Return pages.Count() - 1
    End Method
    
    ' Remove a tab by index
    Method RemoveTab(index:Int)
        If index < 0 Or index >= pages.Count() Then Return
        
        Local page:TTabPage = GetPage(index)
        If page
            ' Show all widgets before removing (restore their state)
            For Local w:TWidget = EachIn page.widgets
                w.visible = w.visibleByUser
            Next
            pages.Remove(page)
        EndIf
        
        ' Adjust active index if needed
        If activeIndex >= pages.Count()
            activeIndex = Max(0, pages.Count() - 1)
        EndIf
        
        UpdateTabWidths()
        UpdateTabVisibility()
    End Method
    
    ' Get tab page by index
    Method GetPage:TTabPage(index:Int)
        Local i:Int = 0
        For Local p:TTabPage = EachIn pages
            If i = index Then Return p
            i :+ 1
        Next
        Return Null
    End Method
    
    ' Get number of tabs
    Method GetTabCount:Int()
        Return pages.Count()
    End Method
    
    ' Get tab name
    Method GetTabName:String(index:Int)
        Local page:TTabPage = GetPage(index)
        If page Then Return page.name
        Return ""
    End Method
    
    ' Set tab name
    Method SetTabName(index:Int, name:String)
        Local page:TTabPage = GetPage(index)
        If page
            page.name = name
            UpdateTabWidths()
        EndIf
    End Method
    
    ' -----------------
    ' Widget Management
    ' -----------------
    
    ' Add a widget to a specific tab
    Method AddWidgetToTab(index:Int, widget:TWidget)
        Local page:TTabPage = GetPage(index)
        If page = Null Or widget = Null Then Return
        
        page.widgets.AddLast(widget)
        
        ' If this tab is not active, hide the widget
        If index <> activeIndex
            widget.SetVisibleByTabber(False)
        Else
            widget.SetVisibleByTabber(True)
        EndIf
    End Method
    
    ' Remove a widget from a tab
    Method RemoveWidgetFromTab(index:Int, widget:TWidget)
        Local page:TTabPage = GetPage(index)
        If page = Null Or widget = Null Then Return
        
        page.widgets.Remove(widget)
        ' Restore widget visibility
        widget.visible = widget.visibleByUser
    End Method
    
    ' Get widgets in a tab
    Method GetTabWidgets:TList(index:Int)
        Local page:TTabPage = GetPage(index)
        If page Then Return page.widgets
        Return Null
    End Method
    
    ' ---------------------
    ' Active Tab Management
    ' ---------------------
    
    ' Set the active tab
    Method SetActiveTab(index:Int)
        If index < 0 Or index >= pages.Count() Then Return
        If index = activeIndex Then Return
        
        Local oldIndex:Int = activeIndex
        activeIndex = index
        
        UpdateTabVisibility()
        
        FireEvent("TabChanged")
    End Method
    
    ' Get active tab index
    Method GetActiveTab:Int()
        Return activeIndex
    End Method
    
    ' Update visibility of all widgets based on active tab
    Method UpdateTabVisibility()
        Local i:Int = 0
        For Local page:TTabPage = EachIn pages
            Local isActive:Int = (i = activeIndex)
            
            For Local w:TWidget = EachIn page.widgets
                w.SetVisibleByTabber(isActive)
            Next
            
            i :+ 1
        Next
    End Method
    
    ' ------
    ' Layout
    ' ------
    Method UpdateLayout()
        ' Content area starts below tabs
        contentX = 0
        contentY = TABBER_TAB_HEIGHT
        contentW = rect.w
        contentH = rect.h - TABBER_TAB_HEIGHT
    End Method
    
    Method UpdateTabWidths()
        For Local page:TTabPage = EachIn pages
            ' Calculate width based on text
            Local textW:Int = TWidget.GuiTextWidth(page.name) + TABBER_TAB_PADDING * 2
            page.tabWidth = Max(textW, TABBER_TAB_MIN_WIDTH)
        Next
    End Method
    
    ' -------
    ' Drawing
    ' -------
    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y
        
        ' Draw tab bar background
        TWidget.GuiDrawRect(ax, ay, rect.w, TABBER_TAB_HEIGHT-1, 2, red, green, blue)
        
        ' Draw content area background
        TWidget.GuiDrawRect(ax, ay + TABBER_TAB_HEIGHT, rect.w, rect.h - TABBER_TAB_HEIGHT, 2, COLOR_TABBER_CONTENT_R, COLOR_TABBER_CONTENT_G, COLOR_TABBER_CONTENT_B)
        
        ' Draw tabs
        Local tabX:Int = ax + 2
        Local tabY:Int = ay + 2
        Local i:Int = 0
        
        For Local page:TTabPage = EachIn pages
            Local isActive:Int = (i = activeIndex)
            Local isHover:Int = (i = hoverIndex)
            
            ' Tab background color
            Local tabR:Int, tabG:Int, tabB:Int
            If isActive
                tabR = COLOR_TABBER_TAB_ACTIVE_R
                tabG = COLOR_TABBER_TAB_ACTIVE_G
                tabB = COLOR_TABBER_TAB_ACTIVE_B
            ElseIf isHover
                tabR = COLOR_TABBER_TAB_HOVER_R
                tabG = COLOR_TABBER_TAB_HOVER_G
                tabB = COLOR_TABBER_TAB_HOVER_B
            Else
                tabR = COLOR_TABBER_TAB_INACTIVE_R
                tabG = COLOR_TABBER_TAB_INACTIVE_G
                tabB = COLOR_TABBER_TAB_INACTIVE_B
            EndIf
            
            ' Draw tab button
            Local tabH:Int = TABBER_TAB_HEIGHT - 5
            If isActive Then tabH = TABBER_TAB_HEIGHT - 2  ' Active tab is slightly taller
            
            TWidget.GuiDrawRect(tabX, tabY, page.tabWidth, tabH, 2, tabR, tabG, tabB)
            
            ' Draw tab text
            Local textR:Int, textG:Int, textB:Int
            If isActive
                textR = COLOR_TABBER_TEXT_ACTIVE_R
                textG = COLOR_TABBER_TEXT_ACTIVE_G
                textB = COLOR_TABBER_TEXT_ACTIVE_B
            Else
                textR = COLOR_TABBER_TEXT_INACTIVE_R
                textG = COLOR_TABBER_TEXT_INACTIVE_G
                textB = COLOR_TABBER_TEXT_INACTIVE_B
            EndIf
            
            Local textX:Int = tabX + (page.tabWidth - TWidget.GuiTextWidth(page.name)) / 2
            Local textY:Int = tabY + (tabH - TWidget.GuiTextHeight(page.name)) / 2

            TWidget.GuiDrawText(textX, textY, page.name, TEXT_STYLE_SHADOW, textR, textG, textB)
            
            tabX :+ page.tabWidth + TABBER_TAB_SPACING
            i :+ 1
        Next
        
        ' Draw children (they handle their own visibility)
        For Local c:TWidget = EachIn children
            If c.visible
                c.Draw(ax, ay + TABBER_TAB_HEIGHT)
            EndIf
        Next
    End Method
    
    ' -----------------------
    ' Update / Input Handling
    ' -----------------------
    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        If Not enabled Then Return ContainsPoint(mx, my)
        
        Local over:Int = ContainsPoint(mx, my)
        
        ' Check tab bar area
        hoverIndex = -1
        If my >= 0 And my < TABBER_TAB_HEIGHT
            ' Find which tab is under cursor
            Local tabX:Int = 2
            Local i:Int = 0
            
            For Local page:TTabPage = EachIn pages
                If mx >= tabX And mx < tabX + page.tabWidth
                    hoverIndex = i
                    
                    ' Handle click on tab
                    If GuiMouse.Hit() And draggedWindow = Null
                        SetActiveTab(i)
                        Return True
                    EndIf
                    
                    Exit
                EndIf
                
                tabX :+ page.tabWidth + TABBER_TAB_SPACING
                i :+ 1
            Next
        EndIf
        
        ' Update children in content area (only visible ones)
        If my >= TABBER_TAB_HEIGHT
            Local clientX:Int = mx
            Local clientY:Int = my - TABBER_TAB_HEIGHT
            
            ' Update in reverse order for proper z-index
            Local revChildren:TList = New TList
            For Local c:TWidget = EachIn children
                revChildren.AddFirst(c)
            Next
            
            For Local c:TWidget = EachIn revChildren
                If c.visible And c.enabled
                    Local relX:Int = clientX - c.rect.x
                    Local relY:Int = clientY - c.rect.y
                    If c.Update(relX, relY) Then Return True
                EndIf
            Next
        EndIf
        
        Return over
    End Method
    
    ' ------------
    ' Event System
    ' ------------
    Method FireEvent(eventType:String)
        Local ev:TEvent = New TEvent
        ev.target = Self
        ev.eventType = eventType
        events.AddLast(ev)
    End Method
    
    Method TabChanged:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "TabChanged" Then Return True
        Next
        Return False
    End Method
    
    Method ClearEvents()
        events.Clear()
    End Method
End Type
