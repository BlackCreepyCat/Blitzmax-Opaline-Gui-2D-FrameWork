' =============================================================================
' COMBOBOX WIDGET
' =============================================================================
' Custom dropdown/combobox widget using composition:
' - Draws its own button area (avoids using TButton to prevent event conflicts)
' - Uses an internal TListBox for the dropdown content (with scrollbar)
' - Implements a global active popup system to capture input and block underlying widgets
' =============================================================================

' Global reference to the currently open combobox (used to capture input)
Global g_ActiveComboBox:TComboBox = Null


Type TComboBox Extends TWidget

    '  Data
    Field items:TList          = New TList      ' List<String> containing all available options
    Field selectedIndex:Int    = -1             ' Currently selected item index (-1 = nothing selected)

    '  State
    Field isOpen:Int           = False          ' Is the dropdown currently visible?
    Field hover:Int            = False          ' Is mouse currently over the button?
    Field pressed:Int          = False          ' Is the button visually pressed?

    '  Internal dropdown components
    Field dropdownList:TListBox                 ' The listbox shown when dropdown is open
    Field maxVisibleItems:Int  = COMBOBOX_MAX_VISIBLE_ITEMS

    '  Appearance
    Field placeholder:String   = "Select..."    ' Text shown when no item is selected

    '  Events & position cache
    Field events:TList         = New TList
    Field absX:Int             = 0              ' Absolute screen X position (for dropdown)
    Field absY:Int             = 0              ' Absolute screen Y position

    '  Constructor
    Method New(x:Int, y:Int, w:Int, h:Int = COMBOBOX_DEFAULT_HEIGHT)
        Super.New(x, y, w, h)

        ' Set default background color
        red   = COLOR_COMBOBOX_BG_R
        green = COLOR_COMBOBOX_BG_G
        blue  = COLOR_COMBOBOX_BG_B

        ' Create internal listbox (position will be set dynamically when opened)
        dropdownList = New TListBox(0, 0, w , 100)
        dropdownList.SetShowHeader(False)
        dropdownList.SetAlternateRows(True)
        dropdownList.SetItemHeight(COMBOBOX_ITEM_HEIGHT)
    End Method

    '  Item Management
    Method AddItem:Int(text:String)
        items.AddLast(text)
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

        ' Adjust selected index if necessary
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
        If index < -1 Or index >= items.Count() Then Return

        Local oldIndex:Int = selectedIndex
        selectedIndex = index
        dropdownList.SetSelectedIndex(index)

        If oldIndex <> selectedIndex
            FireEvent("SelectionChanged")
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

    '  Dropdown visibility control
    Method OpenDropdown()
        If isOpen Then Return

        isOpen = True
        g_ActiveComboBox = Self

        ' Calculate optimal dropdown height
        Local itemCount:Int = items.Count()
        Local visibleItems:Int = Min(itemCount, maxVisibleItems)
        Local dropdownHeight:Int = visibleItems * COMBOBOX_ITEM_HEIGHT + 4

        ' Enforce minimum height
        If dropdownHeight < COMBOBOX_ITEM_HEIGHT + 4
            dropdownHeight = COMBOBOX_ITEM_HEIGHT + 4
        EndIf

        ' Resize & update internal listbox
        dropdownList.rect.w = rect.w - 3
        dropdownList.rect.h = dropdownHeight

        dropdownList.UpdateLayout()

        ' Synchronize selection and scroll to it
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

    '  Drawing - Main button
    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return

        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y

        ' Cache absolute position for dropdown rendering
        absX = ax
        absY = ay

        ' Choose colors according to current state
        Local bgR:Int, bgG:Int, bgB:Int
        Local btnR:Int, btnG:Int, btnB:Int

        If pressed Or isOpen
            bgR = COLOR_COMBOBOX_BG_R   - 10
            bgG = COLOR_COMBOBOX_BG_G   - 10
            bgB = COLOR_COMBOBOX_BG_B   - 10
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
        TWidget.GuiDrawRect(ax, ay, rect.w - COMBOBOX_BUTTON_WIDTH , rect.h + 1, 4, bgR, bgG, bgB)

        ' Draw right button area
        Local btnX:Int = ax + rect.w - COMBOBOX_BUTTON_WIDTH
        TWidget.GuiDrawRect(btnX, ay, COMBOBOX_BUTTON_WIDTH +1, rect.h + 1, 4, btnR, btnG, btnB)

        ' Draw arrow symbol (up/down depending on open state)
        Local arrowX:Int = btnX + (COMBOBOX_BUTTON_WIDTH / 2) - (TWidget.GuiTextWidth("X", True) / 2)
        Local arrowY:Int = ay + (rect.h / 2) - (TWidget.GuiTextHeight("X", True) / 2) + 4

        If isOpen
            TWidget.GuiDrawSymbol(arrowX, arrowY, "B", TEXT_STYLE_SHADOW, COLOR_COMBOBOX_ARROW_R, COLOR_COMBOBOX_ARROW_G, COLOR_COMBOBOX_ARROW_B)
        Else
            TWidget.GuiDrawSymbol(arrowX, arrowY, "C", TEXT_STYLE_SHADOW, COLOR_COMBOBOX_ARROW_R, COLOR_COMBOBOX_ARROW_G, COLOR_COMBOBOX_ARROW_B)
        EndIf

        ' Draw selected text or placeholder
        Local textX:Int = ax + 8
        Local textY:Int = ay + (rect.h - TWidget.GuiTextHeight("X")) / 2
        Local textW:Int = rect.w - COMBOBOX_BUTTON_WIDTH - 12

        TWidget.GuiSetViewport(ax + 4, ay, textW, rect.h)

        If selectedIndex >= 0
            TWidget.GuiDrawText(textX, textY, GetSelectedText(), TEXT_STYLE_NORMAL, COLOR_COMBOBOX_TEXT_R, COLOR_COMBOBOX_TEXT_G, COLOR_COMBOBOX_TEXT_B)
        Else
            TWidget.GuiDrawText(textX, textY, placeholder, TEXT_STYLE_NORMAL, COLOR_TEXTINPUT_PLACEHOLDER_R, COLOR_TEXTINPUT_PLACEHOLDER_G, COLOR_TEXTINPUT_PLACEHOLDER_B)
        EndIf


        TWidget.GuiSetViewport(0, 0, GUI_GRAPHICSWIDTH, GUI_GRAPHICSHEIGHT)
    End Method

    '  Drawing - Dropdown content (called separately)
    Method DrawDropdown()
        If Not isOpen Then Return

        Local dropX:Int = absX
        Local dropY:Int = absY + rect.h

        dropdownList.rect.x = 2
        dropdownList.rect.y = 3
        dropdownList.Draw(dropX, dropY)
    End Method

    '  Update - normal widget update (when dropdown is closed)
    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        If Not enabled Then Return ContainsPoint(mx, my)

        Local over:Int = ContainsPoint(mx, my)

        ' When open, normal Update is skipped → handled by UpdateActivePopup()
        If isOpen Then Return True

        ' Block interaction when another popup is active
        If g_ActiveComboBox <> Null And g_ActiveComboBox <> Self
            hover = False
            pressed = False
            Return over
        EndIf

        hover = over

        ' Visual pressed state
        pressed = over And GuiMouse.Down()

        ' Open dropdown on click
        If over And GuiMouse.Hit() And draggedWindow = Null
            OpenDropdown()
            Return True
        EndIf

        Return over
    End Method

    '  Static - Handle input when a dropdown is open, Call this BEFORE root.Update() in the main loop
    Function UpdateActivePopup:Int()
        If g_ActiveComboBox = Null Then Return False

        Local combo:TComboBox = g_ActiveComboBox

        Local dropX:Int = combo.absX
        Local dropY:Int = combo.absY + combo.rect.h
        Local dropW:Int = combo.dropdownList.rect.w
        Local dropH:Int = combo.dropdownList.rect.h

        Local dropRelX:Int = GuiMouse.x - dropX
        Local dropRelY:Int = GuiMouse.y - dropY

        Local overDropdown:Int = (dropRelX >= 0 And dropRelX < dropW And dropRelY >= 0 And dropRelY < dropH)
        Local overButton:Int   = combo.ContainsPoint(GuiMouse.x, GuiMouse.y)

        ' Let the listbox process input first
        combo.dropdownList.Update(dropRelX, dropRelY)

        ' Item was selected → close dropdown
        If combo.dropdownList.ItemClicked()
            combo.selectedIndex = combo.dropdownList.GetSelectedIndex()
            combo.FireEvent("SelectionChanged")
            combo.CloseDropdown()
            GuiMouse.ConsumeInput()
            Return True
        EndIf

        ' Click outside or on button → close
        If GuiMouse.HitRaw()
            If overButton Or Not overDropdown
                combo.CloseDropdown()
            EndIf
            GuiMouse.ConsumeInput()
        EndIf

        Return True
    End Function

    '  Static - Draw open dropdown (call AFTER all other drawing)
    Function DrawActivePopup()
        If g_ActiveComboBox = Null Then Return
        g_ActiveComboBox.DrawDropdown()
    End Function

    Function IsPopupActive:Int()
        Return g_ActiveComboBox <> Null
    End Function

    Function ShouldBlockInput:Int()
        Return g_ActiveComboBox <> Null
    End Function

    '  Event System
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

    '  Configuration

    Method SetMaxVisibleItems(count:Int)
        maxVisibleItems = Max(1, count)
    End Method
End Type