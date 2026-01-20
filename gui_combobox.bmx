' =============================================================================
'                             COMBOBOX WIDGET
' =============================================================================
' Dropdown selection widget using composition:
' - Uses internal drawing for the button area (not TButton to avoid event conflicts)
' - Uses TListBox for the dropdown list (with scrollbar support)
' - Global popup system to prevent clicks on widgets below
' =============================================================================

' Global active popup - when set, this widget captures all input
Global g_ActiveComboBox:TComboBox = Null

Type TComboBox Extends TWidget
    ' Data
    Field items:TList = New TList           ' List of String items
    Field selectedIndex:Int = -1            ' Currently selected item (-1 = none)
    
    ' State
    Field isOpen:Int = False                ' Is dropdown currently open?
    Field hover:Int = False                 ' Mouse over the button?
    Field pressed:Int = False               ' Button currently pressed?
    
    ' Dropdown list (internal, not added as child)
    Field dropdownList:TListBox
    Field maxVisibleItems:Int = COMBOBOX_MAX_VISIBLE_ITEMS
    
    ' Appearance
    Field placeholder:String = "Select..."
    
    ' Events
    Field events:TList = New TList
    
    ' Absolute position for dropdown positioning
    Field absX:Int = 0
    Field absY:Int = 0

    ' -----------------------------------------------------------------------------
    ' Constructor
    ' -----------------------------------------------------------------------------
    Method New(x:Int, y:Int, w:Int, h:Int = COMBOBOX_DEFAULT_HEIGHT)
        Super.New(x, y, w, h)
        
        ' Default colors
        red = COLOR_COMBOBOX_BG_R
        green = COLOR_COMBOBOX_BG_G
        blue = COLOR_COMBOBOX_BG_B
        
        ' Create internal listbox for dropdown
        ' Position will be set dynamically when opened
        dropdownList = New TListBox(0, 0, w, 100)
        dropdownList.SetShowHeader(False)
        dropdownList.SetAlternateRows(True)
        dropdownList.SetItemHeight(COMBOBOX_ITEM_HEIGHT)
    End Method

    ' -----------------------------------------------------------------------------
    ' Item Management
    ' -----------------------------------------------------------------------------
    
    Method AddItem:Int(text:String)
        items.AddLast(text)
        ' Sync with internal listbox
        dropdownList.AddItem(text)
        Return items.Count() - 1
    End Method
    
    Method RemoveItem(index:Int)
        If index < 0 Or index >= items.Count() Then Return
        
        Local i:Int = 0
        For Local s:String = EachIn items
            If i = index
                items.Remove(s)
                Exit
            EndIf
            i :+ 1
        Next
        
        dropdownList.RemoveItem(index)
        
        If selectedIndex = index
            selectedIndex = -1
        ElseIf selectedIndex > index
            selectedIndex :- 1
        EndIf
    End Method
    
    Method ClearItems()
        items.Clear()
        dropdownList.ClearItems()
        selectedIndex = -1
    End Method
    
    Method GetItemCount:Int()
        Return items.Count()
    End Method
    
    Method GetItem:String(index:Int)
        Local i:Int = 0
        For Local s:String = EachIn items
            If i = index Then Return s
            i :+ 1
        Next
        Return ""
    End Method
    
    Method GetSelectedIndex:Int()
        Return selectedIndex
    End Method
    
    Method SetSelectedIndex(index:Int)
        If index >= -1 And index < items.Count()
            Local oldIndex:Int = selectedIndex
            selectedIndex = index
            dropdownList.SetSelectedIndex(index)
            If oldIndex <> selectedIndex
                FireEvent("SelectionChanged")
            EndIf
        EndIf
    End Method
    
    Method GetSelectedText:String()
        If selectedIndex >= 0
            Return GetItem(selectedIndex)
        EndIf
        Return ""
    End Method
    
    Method SetPlaceholder(text:String)
        placeholder = text
    End Method

    ' -----------------------------------------------------------------------------
    ' Dropdown Control
    ' -----------------------------------------------------------------------------
    
    Method OpenDropdown()
        If isOpen Then Return
        
        isOpen = True
        g_ActiveComboBox = Self
        
        ' Calculate dropdown height based on item count
        Local itemCount:Int = items.Count()
        Local visibleItems:Int = Min(itemCount, maxVisibleItems)
        Local dropdownHeight:Int = visibleItems * COMBOBOX_ITEM_HEIGHT + 4
        
        ' Minimum height
        If dropdownHeight < COMBOBOX_ITEM_HEIGHT + 4
            dropdownHeight = COMBOBOX_ITEM_HEIGHT + 4
        EndIf
        
        ' Update listbox size
        dropdownList.rect.w = rect.w
        dropdownList.rect.h = dropdownHeight
        dropdownList.UpdateLayout()
        
        ' Sync selection
        dropdownList.SetSelectedIndex(selectedIndex)
        If selectedIndex >= 0
            dropdownList.EnsureVisible(selectedIndex)
        EndIf
    End Method
    
    Method CloseDropdown()
        If Not isOpen Then Return
        
        isOpen = False
        If g_ActiveComboBox = Self
            g_ActiveComboBox = Null
        EndIf
    End Method
    
    Method ToggleDropdown()
        If isOpen
            CloseDropdown()
        Else
            OpenDropdown()
        EndIf
    End Method

    ' -----------------------------------------------------------------------------
    ' Drawing
    ' -----------------------------------------------------------------------------
    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y
        
        ' Store absolute position for dropdown
        absX = ax
        absY = ay
        
        ' Determine button colors based on state
        Local bgR:Int, bgG:Int, bgB:Int
        Local btnR:Int, btnG:Int, btnB:Int
        
        If pressed Or isOpen
            bgR = COLOR_COMBOBOX_BG_R - 10
            bgG = COLOR_COMBOBOX_BG_G - 10
            bgB = COLOR_COMBOBOX_BG_B - 10
            btnR = COLOR_COMBOBOX_BUTTON_R - 20
            btnG = COLOR_COMBOBOX_BUTTON_G - 20
            btnB = COLOR_COMBOBOX_BUTTON_B - 20
        ElseIf hover
            bgR = COLOR_COMBOBOX_HOVER_R
            bgG = COLOR_COMBOBOX_HOVER_G
            bgB = COLOR_COMBOBOX_HOVER_B
            btnR = COLOR_COMBOBOX_BUTTON_R + 20
            btnG = COLOR_COMBOBOX_BUTTON_G + 20
            btnB = COLOR_COMBOBOX_BUTTON_B + 20
        Else
            bgR = red
            bgG = green
            bgB = blue
            btnR = COLOR_COMBOBOX_BUTTON_R
            btnG = COLOR_COMBOBOX_BUTTON_G
            btnB = COLOR_COMBOBOX_BUTTON_B
        EndIf
        
        ' Draw main background
        TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, 2, bgR, bgG, bgB)
        
        ' Draw dropdown button area (right side)
        Local btnX:Int = ax + rect.w - COMBOBOX_BUTTON_WIDTH
        TWidget.GuiDrawRect(btnX, ay, COMBOBOX_BUTTON_WIDTH, rect.h, 2, btnR, btnG, btnB)
        
        ' Draw arrow (triangle pointing down, or up if open)
        Local arrowX:Int = btnX + COMBOBOX_BUTTON_WIDTH / 2
        Local arrowY:Int = ay + rect.h / 2

        If isOpen
            ' Arrow pointing up
			TWidget.GuiDrawLine(arrowX - 5, arrowY + 2, arrowX, arrowY - 3, 1 , COLOR_COMBOBOX_ARROW_R, COLOR_COMBOBOX_ARROW_G, COLOR_COMBOBOX_ARROW_B)
			TWidget.GuiDrawLine(arrowX, arrowY - 3, arrowX + 5, arrowY + 2, 1 , COLOR_COMBOBOX_ARROW_R, COLOR_COMBOBOX_ARROW_G, COLOR_COMBOBOX_ARROW_B)
			TWidget.GuiDrawLine(arrowX - 5, arrowY + 3, arrowX, arrowY - 2, 1 , COLOR_COMBOBOX_ARROW_R, COLOR_COMBOBOX_ARROW_G, COLOR_COMBOBOX_ARROW_B)
			TWidget.GuiDrawLine(arrowX, arrowY - 2, arrowX + 5, arrowY + 3, 1 , COLOR_COMBOBOX_ARROW_R, COLOR_COMBOBOX_ARROW_G, COLOR_COMBOBOX_ARROW_B)

        Else
            ' Arrow pointing down
			TWidget.GuiDrawLine(arrowX - 5, arrowY - 2, arrowX, arrowY + 3, 1 , COLOR_COMBOBOX_ARROW_R, COLOR_COMBOBOX_ARROW_G, COLOR_COMBOBOX_ARROW_B)
			TWidget.GuiDrawLine(arrowX, arrowY + 3, arrowX + 5, arrowY - 2, 1 , COLOR_COMBOBOX_ARROW_R, COLOR_COMBOBOX_ARROW_G, COLOR_COMBOBOX_ARROW_B)
			TWidget.GuiDrawLine(arrowX - 5, arrowY - 3, arrowX, arrowY + 2, 1 , COLOR_COMBOBOX_ARROW_R, COLOR_COMBOBOX_ARROW_G, COLOR_COMBOBOX_ARROW_B)
			TWidget.GuiDrawLine(arrowX, arrowY + 2, arrowX + 5, arrowY - 3, 1 , COLOR_COMBOBOX_ARROW_R, COLOR_COMBOBOX_ARROW_G, COLOR_COMBOBOX_ARROW_B)

        EndIf
        
        ' Draw selected text or placeholder
        Local textX:Int = ax + 8
        Local textY:Int = ay + (rect.h - TextHeight("X")) / 2
        Local textW:Int = rect.w - COMBOBOX_BUTTON_WIDTH - 12
        
        TWidget.GuiSetViewport(ax + 4, ay, textW, rect.h)
        
        If selectedIndex >= 0
            TWidget.GuiDrawText(textX, textY, GetSelectedText(), TEXT_STYLE_NORMAL, COLOR_COMBOBOX_TEXT_R, COLOR_COMBOBOX_TEXT_G, COLOR_COMBOBOX_TEXT_B)
        Else
            TWidget.GuiDrawText(textX, textY, placeholder, TEXT_STYLE_NORMAL, COLOR_TEXTINPUT_PLACEHOLDER_R, COLOR_TEXTINPUT_PLACEHOLDER_G, COLOR_TEXTINPUT_PLACEHOLDER_B)
        EndIf
        
        TWidget.GuiSetViewport(0, 0, GraphicsWidth(), GraphicsHeight())
        
        SetColor 255, 255, 255
    End Method
    
    ' Draw the dropdown (called separately, after all other widgets)
    Method DrawDropdown()
        If Not isOpen Then Return
        
        ' Position dropdown below the combobox
        Local dropX:Int = absX
        Local dropY:Int = absY + rect.h
        
        ' Draw dropdown list at absolute position
        dropdownList.rect.x = 0
        dropdownList.rect.y = 0
        dropdownList.Draw(dropX, dropY)
    End Method

    ' -----------------------------------------------------------------------------
    ' Update / Input Handling (called by normal widget tree update)
    ' -----------------------------------------------------------------------------
    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        If Not enabled Then Return ContainsPoint(mx, my)
        
        Local over:Int = ContainsPoint(mx, my)
        
        ' If THIS combobox has an open dropdown, don't handle here
        ' (it's handled by UpdateActivePopup)
        If isOpen Then Return True
        
        ' If ANOTHER popup is active, block hover and clicks completely
        If g_ActiveComboBox <> Null And g_ActiveComboBox <> Self
            hover = False
            pressed = False
            Return over
        EndIf
        
        ' Normal handling - set hover state
        hover = over
        
        ' Handle button press
        pressed = False
        If over And GuiMouse.Down()
            pressed = True
        EndIf
        
        ' Handle click on combobox button to open
        If over And GuiMouse.Hit() And draggedWindow = Null
            OpenDropdown()
            Return True
        EndIf
        
        Return over
    End Method
    
    ' -----------------------------------------------------------------------------
    ' Static method to update the active popup BEFORE other widgets
    ' Call this at the START of your main loop, BEFORE root.Update()
    ' Returns True if popup is active
    ' -----------------------------------------------------------------------------
    Function UpdateActivePopup:Int()
        If g_ActiveComboBox = Null Then Return False
        
        Local combo:TComboBox = g_ActiveComboBox
        
        ' Calculate dropdown bounds in screen coordinates
        Local dropX:Int = combo.absX
        Local dropY:Int = combo.absY + combo.rect.h
        Local dropW:Int = combo.dropdownList.rect.w
        Local dropH:Int = combo.dropdownList.rect.h
        
        ' Calculate relative mouse position for dropdown
        Local dropRelX:Int = GuiMouse.x - dropX
        Local dropRelY:Int = GuiMouse.y - dropY
        
        ' Check if mouse is over dropdown area
        Local overDropdown:Int = (dropRelX >= 0 And dropRelX < dropW And dropRelY >= 0 And dropRelY < dropH)
        
        ' Check if mouse is over the combobox button itself
        Local overButton:Int = (GuiMouse.x >= combo.absX And GuiMouse.x < combo.absX + combo.rect.w And GuiMouse.y >= combo.absY And GuiMouse.y < combo.absY + combo.rect.h)
        
        ' Update the dropdown list FIRST (before consuming input)
        ' This allows the ListBox to process the click normally
        combo.dropdownList.Update(dropRelX, dropRelY)
        
        ' Check if an item was clicked in the dropdown
        If combo.dropdownList.ItemClicked()
            combo.selectedIndex = combo.dropdownList.GetSelectedIndex()
            combo.FireEvent("SelectionChanged")
            combo.CloseDropdown()
            ' Consume input so other widgets don't react to this click
            GuiMouse.ConsumeInput()
            Return True
        EndIf
        
        ' Handle click outside dropdown or on button
        If GuiMouse.HitRaw()
            If overButton
                ' Click on the combobox button itself - close dropdown
                combo.CloseDropdown()
            ElseIf Not overDropdown
                ' Click outside - close dropdown
                combo.CloseDropdown()
            EndIf
            ' Always consume when popup is open and there's a click
            GuiMouse.ConsumeInput()
        EndIf
        
        ' Popup is still active
        Return True
    End Function
    
    ' Static method to draw the active popup (call after all other drawing)
    Function DrawActivePopup()
        If g_ActiveComboBox = Null Then Return
        g_ActiveComboBox.DrawDropdown()
    End Function
    
    ' Check if any combobox popup is active
    Function IsPopupActive:Int()
        Return g_ActiveComboBox <> Null
    End Function
    
    ' Check if a click at the given screen position should be blocked by the popup
    ' Call this from other widgets before processing clicks
    Function ShouldBlockInput:Int()
        Return g_ActiveComboBox <> Null
    End Function

    ' -----------------------------------------------------------------------------
    ' Event System
    ' -----------------------------------------------------------------------------
    Method FireEvent(eventType:String)
        Local ev:TEvent = New TEvent
        ev.target = Self
        ev.eventType = eventType
        events.AddLast(ev)
    End Method
    
    Method SelectionChanged:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "SelectionChanged" Then Return True
        Next
        Return False
    End Method
    
    Method ClearEvents()
        events.Clear()
        dropdownList.ClearEvents()
    End Method

    ' -----------------------------------------------------------------------------
    ' Configuration
    ' -----------------------------------------------------------------------------
    Method SetMaxVisibleItems(count:Int)
        maxVisibleItems = Max(1, count)
    End Method
End Type
