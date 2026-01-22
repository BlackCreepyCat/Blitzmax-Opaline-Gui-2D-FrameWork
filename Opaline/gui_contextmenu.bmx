' =============================================================================
'                           CONTEXT MENU WIDGET
' =============================================================================
' Right-click popup menu with selectable items
' Supports icons, separators, disabled items, and submenus (future)
' =============================================================================

' -----------------------------------------------------------------------------
' Menu Item Types
' -----------------------------------------------------------------------------
Const MENUITEM_NORMAL:Int = 0
Const MENUITEM_SEPARATOR:Int = 1
Const MENUITEM_CHECKBOX:Int = 2
Const MENUITEM_DISABLED:Int = 3

' -------------------
' Menu Item Structure
' -------------------
Type TMenuItem
    Field text:String = ""
    Field id:String = ""              ' Unique identifier for callbacks
    Field itemType:Int = MENUITEM_NORMAL
    Field checked:Int = False         ' For checkbox items
    Field enabled:Int = True
    Field icon:TImage = Null          ' Optional icon (future)
    Field shortcut:String = ""        ' Keyboard shortcut text (display only)
    Field userData:Object = Null      ' Custom user data
    
    Method New(text:String, id:String = "", itemType:Int = MENUITEM_NORMAL)
        Self.text = text
        Self.id = id
        If id = "" Then Self.id = text
        Self.itemType = itemType
        Self.enabled = (itemType <> MENUITEM_DISABLED)
    End Method
    
    ' Create a separator
    Function Separator:TMenuItem()
        Return New TMenuItem("", "", MENUITEM_SEPARATOR)
    End Function
End Type

' -------------------------
' Global Context Menu State
' -------------------------
Global g_ActiveContextMenu:TContextMenu = Null

' ------------------
' Context Menu Class
' ------------------
Type TContextMenu
    Field items:TList = New TList     ' List of TMenuItem
    Field x:Int, y:Int                ' Screen position
    Field width:Int = 150             ' Menu width
    Field itemHeight:Int = 26         ' Height per item
    Field separatorHeight:Int = 8     ' Height for separators
    Field visible:Int = False
    Field hoverIndex:Int = -1         ' Currently hovered item
    Field selectedItem:TMenuItem = Null  ' Last clicked item
    
    ' Colors
    Field bgR:Int = 45, bgG:Int = 45, bgB:Int = 55
    Field hoverR:Int = 70, hoverG:Int = 110, hoverB:Int = 180
    Field textR:Int = 240, textG:Int = 240, textB:Int = 255
    Field disabledR:Int = 120, disabledG:Int = 120, disabledB:Int = 140
    Field separatorR:Int = 80, separatorG:Int = 80, separatorB:Int = 100
    Field checkR:Int = 100, checkG:Int = 200, checkB:Int = 100
    
    ' Padding
    Field paddingX:Int = 8
    Field paddingY:Int = 4
    
    ' =========================================================================
    '                         CONSTRUCTOR
    ' =========================================================================
    Method New()
        ' Default constructor
    End Method
    
    ' =========================================================================
    '                         ITEM MANAGEMENT
    ' =========================================================================
    
    ' Add a normal menu item
    Method AddItem:TMenuItem(text:String, id:String = "")
        Local item:TMenuItem = New TMenuItem(text, id, MENUITEM_NORMAL)
        items.AddLast(item)
        UpdateWidth()
        Return item
    End Method
    
    ' Add a menu item with shortcut text
    Method AddItemWithShortcut:TMenuItem(text:String, shortcut:String, id:String = "")
        Local item:TMenuItem = New TMenuItem(text, id, MENUITEM_NORMAL)
        item.shortcut = shortcut
        items.AddLast(item)
        UpdateWidth()
        Return item
    End Method
    
    ' Add a checkbox menu item
    Method AddCheckbox:TMenuItem(text:String, checked:Int = False, id:String = "")
        Local item:TMenuItem = New TMenuItem(text, id, MENUITEM_CHECKBOX)
        item.checked = checked
        items.AddLast(item)
        UpdateWidth()
        Return item
    End Method
    
    ' Add a separator line
    Method AddSeparator()
        items.AddLast(TMenuItem.Separator())
    End Method
    
    ' Add a disabled (grayed out) item
    Method AddDisabledItem:TMenuItem(text:String, id:String = "")
        Local item:TMenuItem = New TMenuItem(text, id, MENUITEM_DISABLED)
        item.enabled = False
        items.AddLast(item)
        UpdateWidth()
        Return item
    End Method
    
    ' Clear all items
    Method Clear()
        items.Clear()
        width = 150
    End Method
    
    ' Get item by ID
    Method GetItem:TMenuItem(id:String)
        For Local item:TMenuItem = EachIn items
            If item.id = id Then Return item
        Next
        Return Null
    End Method
    
    ' Enable/disable an item by ID
    Method SetItemEnabled(id:String, enabled:Int)
        Local item:TMenuItem = GetItem(id)
        If item Then item.enabled = enabled
    End Method
    
    ' Set checkbox state by ID
    Method SetItemChecked(id:String, checked:Int)
        Local item:TMenuItem = GetItem(id)
        If item And item.itemType = MENUITEM_CHECKBOX Then item.checked = checked
    End Method
    
    ' Update menu width based on content
    Method UpdateWidth()
        Local maxW:Int = 100

        For Local item:TMenuItem = EachIn items

            If item.itemType <> MENUITEM_SEPARATOR
                Local textW:Int = TWidget.GuiTextWidth(item.text)
                If item.shortcut.Length > 0
                    textW :+ TWidget.GuiTextWidth(item.shortcut) + 30
                EndIf
                If item.itemType = MENUITEM_CHECKBOX
                    textW :+ 24  ' Space for checkmark
                EndIf
                maxW = Max(maxW, textW)
            EndIf

        Next

        width = maxW + paddingX * 2 + 20
    End Method
    
    ' Calculate total menu height
    Method GetHeight:Int()
        Local h:Int = paddingY * 2
        For Local item:TMenuItem = EachIn items
            If item.itemType = MENUITEM_SEPARATOR
                h :+ separatorHeight
            Else
                h :+ itemHeight
            EndIf
        Next
        Return h
    End Method
    
    ' =========================================================================
    '                         SHOW / HIDE
    ' =========================================================================
    
    ' Show the context menu at position
    Method Show(screenX:Int, screenY:Int)
        ' Close any existing context menu
        If g_ActiveContextMenu <> Null And g_ActiveContextMenu <> Self
            g_ActiveContextMenu.Hide()
        EndIf
        
        x = screenX
        y = screenY
        
        ' Adjust position to stay on screen
        Local menuH:Int = GetHeight()
        If x + width > GraphicsWidth()
            x = GraphicsWidth() - width - 5
        EndIf
        If y + menuH > GraphicsHeight()
            y = GraphicsHeight() - menuH - 5
        EndIf
        If x < 0 Then x = 5
        If y < 0 Then y = 5
        
        visible = True
        hoverIndex = -1
        selectedItem = Null
        g_ActiveContextMenu = Self
    End Method
    
    ' Hide the context menu
    Method Hide()
        visible = False
        hoverIndex = -1
        If g_ActiveContextMenu = Self
            g_ActiveContextMenu = Null
        EndIf
    End Method
    
    ' Check if menu is visible
    Method IsVisible:Int()
        Return visible
    End Method
    
    ' =========================================================================
    '                         UPDATE
    ' =========================================================================
    
    Method Update:Int()
        If Not visible Then Return False
        
        Local mx:Int = GuiMouse.x
        Local my:Int = GuiMouse.y
        
        ' Check if mouse is inside menu
        Local menuH:Int = GetHeight()
        Local inside:Int = (mx >= x And mx < x + width And my >= y And my < y + menuH)
        
        ' Update hover state
        hoverIndex = -1
        If inside
            Local currentY:Int = y + paddingY
            Local idx:Int = 0
            For Local item:TMenuItem = EachIn items
                Local ih:Int
                If item.itemType = MENUITEM_SEPARATOR
                    ih = separatorHeight
                Else
                    ih = itemHeight
                    If my >= currentY And my < currentY + ih
                        If item.enabled
                            hoverIndex = idx
                        EndIf
                    EndIf
                EndIf
                currentY :+ ih
                idx :+ 1
            Next
        EndIf
        
        ' Handle click
        If GuiMouse.Hit()
            If inside And hoverIndex >= 0
                ' Get the clicked item
                Local idx:Int = 0
                For Local item:TMenuItem = EachIn items
                    If idx = hoverIndex
                        ' Toggle checkbox if applicable
                        If item.itemType = MENUITEM_CHECKBOX
                            item.checked = Not item.checked
                        EndIf
                        selectedItem = item
                        Hide()
                        Return True
                    EndIf
                    idx :+ 1
                Next
            Else
                ' Click outside - close menu
                Hide()
                Return True
            EndIf
        EndIf
        
        ' Right click also closes the menu
        If GuiMouse.Hit(2)
            Hide()
            Return True
        EndIf
        
        ' Escape key closes menu
        If KeyHit(KEY_ESCAPE)
            Hide()
            Return True
        EndIf
        
        Return inside  ' Consume input if mouse is over menu
    End Method
    
    ' =========================================================================
    '                         DRAW
    ' =========================================================================
    
    Method Draw()
        If Not visible Then Return
        
        Local menuH:Int = GetHeight()
        
        ' Draw shadow
		TWidget.GuiDrawRect(x + 4, y + 4, width, menuH, 1, 0,0,0,0.3)
   
        ' Draw background
		TWidget.GuiDrawRect(x, y, width, menuH,2, bgR, bgG, bgB)
        
        ' Draw items
        Local currentY:Int = y + paddingY
        Local idx:Int = 0
        
     '   SetImageFont(Gui_SystemFont)
        
        For Local item:TMenuItem = EachIn items
            If item.itemType = MENUITEM_SEPARATOR
                ' Draw separator line
                SetColor(separatorR, separatorG, separatorB)
                DrawLine(x + paddingX, currentY + separatorHeight/2, x + width - paddingX, currentY + separatorHeight/2)
                currentY :+ separatorHeight
            Else
                ' Draw hover highlight
                If idx = hoverIndex
                 '   SetColor(hoverR, hoverG, hoverB)
                 '   DrawRect(x + 2, currentY, width - 4, itemHeight)

					TWidget.GuiDrawRect(x + 2, currentY, width - 4, itemHeight, 1, hoverR, hoverG, hoverB)
                EndIf
                
                ' Draw checkbox mark
                Local textStartX:Int = x + paddingX
                If item.itemType = MENUITEM_CHECKBOX
                    textStartX :+ 20
                    If item.checked
                        SetColor(checkR, checkG, checkB)
                        ' Draw checkmark
                        DrawLine(x + paddingX + 3, currentY + itemHeight/2, x + paddingX + 7, currentY + itemHeight/2 + 4)
                        DrawLine(x + paddingX + 7, currentY + itemHeight/2 + 4, x + paddingX + 14, currentY + itemHeight/2 - 4)
                    EndIf
                EndIf
                
                ' Draw text
                If item.enabled
                    SetColor(textR, textG, textB)
                Else
                    SetColor(disabledR, disabledG, disabledB)
                EndIf

                DrawText(item.text, textStartX, currentY + (itemHeight - TextHeight(item.text)) / 2)

				
                
                ' Draw shortcut text (right-aligned)
                If item.shortcut.Length > 0
                    Local shortcutX:Int = x + width - paddingX - TextWidth(item.shortcut)
                    SetColor(disabledR, disabledG, disabledB)
                    DrawText(item.shortcut, shortcutX, currentY + (itemHeight - TextHeight(item.shortcut)) / 2)
                EndIf
                
                currentY :+ itemHeight
            EndIf
            idx :+ 1
        Next
        
        SetColor(255, 255, 255)
    End Method
    
    ' =========================================================================
    '                         EVENT CHECKING
    ' =========================================================================
    
    ' Check if an item was just selected (call after Update)
    Method WasItemSelected:Int()
        Return selectedItem <> Null
    End Method
    
    ' Get the last selected item
    Method GetSelectedItem:TMenuItem()
        Return selectedItem
    End Method
    
    ' Get the ID of the last selected item
    Method GetSelectedId:String()
        If selectedItem Then Return selectedItem.id
        Return ""
    End Method
    
    ' Clear the selected item (call after handling the selection)
    Method ClearSelection()
        selectedItem = Null
    End Method
    
    ' =========================================================================
    '                         STATIC FUNCTIONS
    ' =========================================================================
    
    ' Check if any context menu is active
    Function IsAnyMenuActive:Int()
        Return g_ActiveContextMenu <> Null And g_ActiveContextMenu.visible
    End Function
    
    ' Get the active context menu
    Function GetActiveMenu:TContextMenu()
        Return g_ActiveContextMenu
    End Function
    
    ' Close any active context menu
    Function CloseActiveMenu()
        If g_ActiveContextMenu Then g_ActiveContextMenu.Hide()
    End Function
    
    ' Update the active context menu (call in main loop)
    Function UpdateActiveMenu:Int()
        If g_ActiveContextMenu And g_ActiveContextMenu.visible
            Return g_ActiveContextMenu.Update()
        EndIf
        Return False
    End Function
    
    ' Draw the active context menu (call after other drawing)
    Function DrawActiveMenu()
        If g_ActiveContextMenu And g_ActiveContextMenu.visible
            g_ActiveContextMenu.Draw()
        EndIf
    End Function
End Type
