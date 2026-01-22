' =============================================================================
'                             LISTBOX WIDGET
' =============================================================================
' Multi-column listbox with vertical and horizontal scrolling
' Scrollbars are EXTERNAL to the content area for cleaner layout
' Supports column headers, row selection, and mouse wheel
' =============================================================================

' -----------------------------------------------------------------------------
' Column definition for multi-column listbox
' -----------------------------------------------------------------------------
Type TListColumn
    Field title:String        ' Column header text
    Field width:Int           ' Column width in pixels
    Field alignment:Int       ' Text alignment (LABEL_ALIGN_LEFT, CENTER, RIGHT)
    
    Method New(title:String, width:Int, alignment:Int = LABEL_ALIGN_LEFT)
        Self.title = title
        Self.width = width
        Self.alignment = alignment
    End Method
End Type

' -----------------------------------------------------------------------------
' Single row item (can have multiple cell values for columns)
' -----------------------------------------------------------------------------
Type TListItem
    Field cells:String[]      ' Array of cell values (one per column)
    Field data:Object         ' Optional user data attached to item
    Field tag:Int             ' Optional integer tag
    
    ' Create item with single value (for single-column listbox)
    Method New(text:String = "", data:Object = Null, tag:Int = 0)
        cells = [text]
        Self.data = data
        Self.tag = tag
    End Method
    
    ' Create item with multiple column values
    Function CreateMultiColumn:TListItem(values:String[], data:Object = Null, tag:Int = 0)
        Local item:TListItem = New TListItem
        item.cells = values[..]  ' Copy array
        item.data = data
        item.tag = tag
        Return item
    End Function
    
    ' Get cell value by column index
    Method GetCell:String(columnIndex:Int)
        If columnIndex >= 0 And columnIndex < cells.Length
            Return cells[columnIndex]
        EndIf
        Return ""
    End Method
    
    ' Set cell value by column index
    Method SetCell(columnIndex:Int, value:String)
        If columnIndex >= 0 And columnIndex < cells.Length
            cells[columnIndex] = value
        EndIf
    End Method
End Type

' -----------------------------------------------------------------------------
' Main ListBox widget
' -----------------------------------------------------------------------------
' Layout with external scrollbars:
' ┌─────────────────────────────┬──┐
' │  Header (full width)        │▲ │
' ├─────────────────────────────┤  │
' │                             │░░│
' │  Content (full width)       │░░│ scrollV (external)
' │                             │░░│
' │                             │▼ │
' ├─────────────────────────────┼──┤
' │◄░░░░░░░░░░░░░░░░░░░░░░░░░░► │  │ scrollH (external)
' └─────────────────────────────┴──┘
' -----------------------------------------------------------------------------
Type TListBox Extends TWidget
    ' Data
    Field items:TList = New TList           ' List of TListItem
    Field columns:TList = New TList         ' List of TListColumn
    
    ' Selection
    Field selectedIndex:Int = -1            ' Currently selected item index (-1 = none)
    Field hoverIndex:Int = -1               ' Item under mouse cursor
    Field multiSelect:Int = False           ' Allow multiple selection (future)
    
    ' Scrolling - scrollbars are EXTERNAL to content area
    Field scrollV:TSlider                   ' Vertical scrollbar (right side, external)
    Field scrollH:TSlider                   ' Horizontal scrollbar (bottom, external)

    Field scrollOffsetY:Int = 0             ' Vertical scroll offset in pixels
    Field scrollOffsetX:Int = 0             ' Horizontal scroll offset in pixels

    Field needScrollV:Int = False           ' Need vertical scrollbar?
    Field needScrollH:Int = False           ' Need horizontal scrollbar?
    
    ' Appearance
    Field itemHeight:Int = LISTBOX_DEFAULT_ITEM_HEIGHT
    Field showHeader:Int = True             ' Show column headers
    Field showGrid:Int = False              ' Show grid lines between cells
    Field alternateRows:Int = True          ' Alternate row background colors
    
    ' Events
    Field events:TList = New TList
    
    ' Layout dimensions (calculated)
    Field contentWidth:Int = 0              ' Total width of all columns
    Field contentHeight:Int = 0             ' Total height of all items
    Field headerHeight:Int = 0              ' Header height (0 if hidden)
    
    ' Content area (where items are drawn, excludes scrollbars)
    Field contentAreaX:Int = 0
    Field contentAreaY:Int = 0
    Field contentAreaW:Int = 0
    Field contentAreaH:Int = 0
    
    ' Absolute position (for clipping calculations)
    Field absX:Int = 0
    Field absY:Int = 0

    ' -----------------------------------------------------------------------------
    ' Constructor
    ' -----------------------------------------------------------------------------
    Method New(x:Int, y:Int, w:Int, h:Int)
        Super.New(x, y, w, h)
        
        ' Default background color
        red = COLOR_LISTBOX_BG_R
        green = COLOR_LISTBOX_BG_G
        blue = COLOR_LISTBOX_BG_B
        
        ' Create scrollbars (positions will be set in UpdateLayout)
        scrollV = New TSlider(0, 0, LISTBOX_SCROLLBAR_WIDTH  , 100, 0.0, SLIDER_STYLE_VERTICAL)
        scrollV.SetRange(0.0, 1.0)
        scrollV.SetWheelEnabled(False)  ' We handle wheel ourselves
        
        scrollH = New TSlider(0, 0, 100, LISTBOX_SCROLLBAR_WIDTH, 0.0, SLIDER_STYLE_HORIZONTAL)
        scrollH.SetRange(0.0, 1.0)
        scrollH.SetWheelEnabled(False)
        
        UpdateLayout()
    End Method

    ' -----------------------------------------------------------------------------
    ' Column Management
    ' -----------------------------------------------------------------------------
    
    Method AddColumn(title:String, width:Int, alignment:Int = LABEL_ALIGN_LEFT)
        Local col:TListColumn = New TListColumn(title, width, alignment)
        columns.AddLast(col)
        UpdateLayout()
    End Method
    
    Method GetColumnCount:Int()
        Return columns.Count()
    End Method
    
    Method GetColumn:TListColumn(index:Int)
        Local i:Int = 0
        For Local col:TListColumn = EachIn columns
            If i = index Then Return col
            i :+ 1
        Next
        Return Null
    End Method
    
    Method SetColumnWidth(index:Int, width:Int)
        Local col:TListColumn = GetColumn(index)
        If col Then col.width = width
        UpdateLayout()
    End Method

    ' -----------------------------------------------------------------------------
    ' Item Management
    ' -----------------------------------------------------------------------------
    
    Method AddItem:Int(text:String, data:Object = Null, tag:Int = 0)
        Local item:TListItem = New TListItem(text, data, tag)
        items.AddLast(item)
        UpdateLayout()
        Return items.Count() - 1
    End Method
    
    Method AddItemMulti:Int(values:String[], data:Object = Null, tag:Int = 0)
        Local item:TListItem = TListItem.CreateMultiColumn(values, data, tag)
        items.AddLast(item)
        UpdateLayout()
        Return items.Count() - 1
    End Method
    
    Method RemoveItem(index:Int)
        Local i:Int = 0
        For Local item:TListItem = EachIn items
            If i = index
                items.Remove(item)
                If selectedIndex = index
                    selectedIndex = -1
                ElseIf selectedIndex > index
                    selectedIndex :- 1
                EndIf
                UpdateLayout()
                Return
            EndIf
            i :+ 1
        Next
    End Method
    
    Method ClearItems()
        items.Clear()
        selectedIndex = -1
        scrollOffsetY = 0
        scrollOffsetX = 0
        scrollV.SetValue(0.0)
        scrollH.SetValue(0.0)
        UpdateLayout()
    End Method
    
    Method GetItemCount:Int()
        Return items.Count()
    End Method
    
    Method GetItem:TListItem(index:Int)
        Local i:Int = 0
        For Local item:TListItem = EachIn items
            If i = index Then Return item
            i :+ 1
        Next
        Return Null
    End Method
    
    Method GetSelectedItem:TListItem()
        Return GetItem(selectedIndex)
    End Method
    
    Method GetSelectedIndex:Int()
        Return selectedIndex
    End Method
    
    Method SetSelectedIndex(index:Int)
        If index >= -1 And index < items.Count()
            Local oldIndex:Int = selectedIndex
            selectedIndex = index
            If oldIndex <> selectedIndex
                FireEvent("SelectionChanged")
            EndIf
        EndIf
    End Method
    
    Method EnsureVisible(index:Int)
        If index < 0 Or index >= items.Count() Then Return
        
        Local itemY:Int = index * itemHeight
        
        If itemY < scrollOffsetY
            scrollOffsetY = itemY
        EndIf
        
        If itemY + itemHeight > scrollOffsetY + contentAreaH
            scrollOffsetY = itemY + itemHeight - contentAreaH
        EndIf
        
        UpdateScrollbarFromOffset()
    End Method

    ' -----------------------------------------------------------------------------
    ' Layout Calculation
    ' -----------------------------------------------------------------------------
    Method UpdateLayout()
        ' Header height
        headerHeight = 0
        If showHeader And columns.Count() > 0
            headerHeight = LISTBOX_HEADER_HEIGHT
        EndIf
        
        ' Total content dimensions
        contentWidth = 0
        For Local col:TListColumn = EachIn columns
            contentWidth :+ col.width
        Next
        
        ' Default width if no columns
        If contentWidth = 0
            contentWidth = rect.w - LISTBOX_SCROLLBAR_WIDTH
        EndIf
        
        contentHeight = items.Count() * itemHeight
        
        ' Determine which scrollbars are needed
        ' First pass: assume no scrollbars
        Local availW:Int = rect.w 
        Local availH:Int = rect.h - headerHeight
        
        needScrollV = (contentHeight > availH)
        needScrollH = (contentWidth > availW)
        
        ' Second pass: if V scrollbar needed, reduce available width
        If needScrollV
            availW = rect.w - LISTBOX_SCROLLBAR_WIDTH
            needScrollH = (contentWidth > availW)
        EndIf
        
        ' Third pass: if H scrollbar needed, reduce available height
        If needScrollH
            availH = rect.h - headerHeight - LISTBOX_SCROLLBAR_WIDTH
            needScrollV = (contentHeight > availH)
            
            ' Recheck horizontal after vertical adjustment
            If needScrollV
                availW = rect.w - LISTBOX_SCROLLBAR_WIDTH
            EndIf
        EndIf
        
        ' Set content area dimensions
        contentAreaX = 0
        contentAreaY = headerHeight
        contentAreaW = availW
        contentAreaH = availH
        
        ' Position scrollbars OUTSIDE content area
        If needScrollV
            scrollV.rect.x = rect.w - (LISTBOX_SCROLLBAR_WIDTH )
            scrollV.rect.y = headerHeight + 1
            scrollV.rect.w = LISTBOX_SCROLLBAR_WIDTH 
            scrollV.rect.h = contentAreaH - 3
        EndIf
        
        If needScrollH
            scrollH.rect.x = 1
            scrollH.rect.y = rect.h - LISTBOX_SCROLLBAR_WIDTH 
            scrollH.rect.w = contentAreaW - 3
            scrollH.rect.h = LISTBOX_SCROLLBAR_WIDTH
        EndIf
        
        ' Clamp scroll offsets
        Local maxScrollY:Int = Max(0, contentHeight - contentAreaH)
        Local maxScrollX:Int = Max(0, contentWidth - contentAreaW)
        
        scrollOffsetY = Max(0, Min(scrollOffsetY, maxScrollY))
        scrollOffsetX = Max(0, Min(scrollOffsetX, maxScrollX))
        
        UpdateScrollbarFromOffset()
    End Method
    
    Method UpdateOffsetFromScrollbar()
        Local maxScrollY:Int = Max(0, contentHeight - contentAreaH)
        Local maxScrollX:Int = Max(0, contentWidth - contentAreaW)
        
        scrollOffsetY = Int(scrollV.GetValue() * maxScrollY)
        scrollOffsetX = Int(scrollH.GetValue() * maxScrollX)
    End Method
    
    Method UpdateScrollbarFromOffset()
        Local maxScrollY:Int = Max(0, contentHeight - contentAreaH)
        Local maxScrollX:Int = Max(0, contentWidth - contentAreaW)
        
        If maxScrollY > 0
            scrollV.SetValue(Float(scrollOffsetY) / Float(maxScrollY))
        Else
            scrollV.SetValue(0.0)
        EndIf
        
        If maxScrollX > 0
            scrollH.SetValue(Float(scrollOffsetX) / Float(maxScrollX))
        Else
            scrollH.SetValue(0.0)
        EndIf
    End Method

    ' -----------------------------------------------------------------------------
    ' Drawing
    ' -----------------------------------------------------------------------------
    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y
        
        ' Store absolute position for clipping calculations
        absX = ax
        absY = ay
        
        ' Draw main background (entire widget area)
        TWidget.GuiDrawRect(ax-2, ay-2, rect.w+4, rect.h+4, 4, red, green, blue)
        
        ' Draw column headers (full width of content area)
        If showHeader And columns.Count() > 0
            DrawHeaders(ax, ay)
        EndIf
        
        ' Clip to content area for items
        Local clipX:Int = ax + contentAreaX
        Local clipY:Int = ay + contentAreaY

        TWidget.GuiSetViewport(clipX, clipY, contentAreaW, contentAreaH)
        
        ' Draw items
        DrawItems(clipX, clipY)
        


        ' Reset viewport
        TWidget.GuiSetViewport(0, 0, GUI_GRAPHICSWIDTH, GUI_GRAPHICSHEIGHT)
        
        ' Draw scrollbars (external, on top)
        If needScrollV
            scrollV.Draw(ax, ay)
        EndIf
        
        If needScrollH
            scrollH.Draw(ax, ay)
        EndIf
        
        ' Draw corner box if both scrollbars visible
        If needScrollV And needScrollH
            Local cornerX:Int = ax + rect.w - LISTBOX_SCROLLBAR_WIDTH
            Local cornerY:Int = ay + rect.h - LISTBOX_SCROLLBAR_WIDTH
            TWidget.GuiDrawRect(cornerX, cornerY, LISTBOX_SCROLLBAR_WIDTH, LISTBOX_SCROLLBAR_WIDTH, 1, red, green, blue)
        EndIf
    End Method
    
    Method DrawHeaders(ax:Int, ay:Int)
        Local headerX:Int = ax - scrollOffsetX
        Local headerY:Int = ay
        
        ' Header background (clips to content width)
        TWidget.GuiDrawRect(ax, headerY, contentWidth, headerHeight - 2, 2, COLOR_LISTBOX_HEADER_R, COLOR_LISTBOX_HEADER_G, COLOR_LISTBOX_HEADER_B)
        TWidget.GuiSetViewport(ax, headerY, contentAreaW, headerHeight)

        ' Draw each column header
        For Local col:TListColumn = EachIn columns
            ' Header text
            Local textX:Int
            Local textY:Int = headerY + (headerHeight - TWidget.GuiTextHeight(col.title)) / 2
            
            Select col.alignment
                Case LABEL_ALIGN_LEFT
                    textX = headerX + 6
                Case LABEL_ALIGN_CENTER
                    textX = headerX + (col.width - TWidget.GuiTextWidth(col.title)) / 2
                Case LABEL_ALIGN_RIGHT
                    textX = headerX + col.width - TWidget.GuiTextWidth(col.title) - 6
            End Select
            
            TWidget.GuiDrawText(textX, textY, col.title, TEXT_STYLE_SHADOW, COLOR_LISTBOX_HEADER_TEXT_R, COLOR_LISTBOX_HEADER_TEXT_G, COLOR_LISTBOX_HEADER_TEXT_B)
            
            ' Column separator
            If showGrid
				 TWidget.GuiDrawLine(headerX + col.width - 1, headerY + 2, headerX + col.width - 1, headerY + headerHeight - 2, 1, COLOR_LISTBOX_GRID_R + 20, COLOR_LISTBOX_GRID_G + 20, COLOR_LISTBOX_GRID_B + 20)
            EndIf
            
            headerX :+ col.width
        Next
        


        TWidget.GuiSetViewport(0, 0, GUI_GRAPHICSWIDTH, GUI_GRAPHICSHEIGHT)
    End Method
    
    Method DrawItems(clipX:Int, clipY:Int)
        Local itemIndex:Int = 0
        Local drawY:Int = clipY - scrollOffsetY
        
        For Local item:TListItem = EachIn items
            ' Only draw visible items
            If drawY + itemHeight > clipY And drawY < clipY + contentAreaH
                ' Row background
                Local bgR:Int, bgG:Int, bgB:Int
                
                If itemIndex = selectedIndex
                    bgR = COLOR_LISTBOX_SELECTED_R
                    bgG = COLOR_LISTBOX_SELECTED_G
                    bgB = COLOR_LISTBOX_SELECTED_B
                ElseIf itemIndex = hoverIndex
                    bgR = COLOR_LISTBOX_HOVER_R
                    bgG = COLOR_LISTBOX_HOVER_G
                    bgB = COLOR_LISTBOX_HOVER_B
                ElseIf alternateRows And (itemIndex Mod 2 = 1)
                    bgR = COLOR_LISTBOX_ALT_ROW_R
                    bgG = COLOR_LISTBOX_ALT_ROW_G
                    bgB = COLOR_LISTBOX_ALT_ROW_B
                Else
                    bgR = red
                    bgG = green
                    bgB = blue
                EndIf
                
                ' Draw row background (full content width for proper scrolling)
                TWidget.GuiDrawRect(clipX - scrollOffsetX, drawY, contentWidth, itemHeight, 1, bgR, bgG, bgB)
                
                ' Draw cells
                Local cellX:Int = clipX - scrollOffsetX
                Local colIndex:Int = 0
                
                If columns.Count() > 0
                    ' Multi-column mode - clip each cell individually
                    For Local col:TListColumn = EachIn columns
                        Local cellText:String = item.GetCell(colIndex)
                        Local textY:Int = drawY + (itemHeight - TWidget.GuiTextHeight("X")) / 2
                        Local textX:Int
                        
                        Select col.alignment
                            Case LABEL_ALIGN_LEFT
                                textX = cellX + 6
                            Case LABEL_ALIGN_CENTER
                                textX = cellX + (col.width - TWidget.GuiTextWidth(cellText)) / 2
                            Case LABEL_ALIGN_RIGHT
                                textX = cellX + col.width - TWidget.GuiTextWidth(cellText) - 6
                        End Select
                        
                        ' Calculate visible cell bounds (intersection with content area)
                        Local cellLeft:Int = Max(cellX, clipX)
                        Local cellRight:Int = Min(cellX + col.width, clipX + contentAreaW)
                        Local cellW:Int = cellRight - cellLeft
                        
                        ' Only draw if cell is visible
                        If cellW > 0
                            ' Set viewport to clip text within this cell
                            TWidget.GuiSetViewport(cellLeft, clipY, cellW, contentAreaH)
                            TWidget.GuiDrawText(textX, textY, cellText, TEXT_STYLE_NORMAL, COLOR_LISTBOX_ITEM_R, COLOR_LISTBOX_ITEM_G, COLOR_LISTBOX_ITEM_B)
                            ' Restore content area viewport
                            TWidget.GuiSetViewport(clipX, clipY, contentAreaW, contentAreaH)
                        EndIf
                        
                        ' Vertical grid line
                        If showGrid
							TWidget.GuiDrawLine(cellX + col.width - 1, drawY, cellX + col.width - 1, drawY + itemHeight, 1, COLOR_LISTBOX_GRID_R, COLOR_LISTBOX_GRID_G, COLOR_LISTBOX_GRID_B)
                        EndIf
                        
                        cellX :+ col.width
                        colIndex :+ 1
                    Next
                Else
                    ' Single-column mode - no extra clipping needed (already clipped to content area)
                    Local cellText:String = item.GetCell(0)
                    Local textX:Int = cellX + 6
                    Local textY:Int = drawY + (itemHeight - TWidget.GuiTextHeight("X")) / 2
                    TWidget.GuiDrawText(textX, textY, cellText, TEXT_STYLE_NORMAL, COLOR_LISTBOX_ITEM_R, COLOR_LISTBOX_ITEM_G, COLOR_LISTBOX_ITEM_B)
                EndIf
                
                ' Horizontal grid line
                If showGrid
					 TWidget.GuiDrawLine(clipX - scrollOffsetX, drawY + itemHeight - 1, clipX - scrollOffsetX + contentWidth, drawY + itemHeight - 1, 1, COLOR_LISTBOX_GRID_R, COLOR_LISTBOX_GRID_G, COLOR_LISTBOX_GRID_B)
                EndIf
            EndIf
            
            drawY :+ itemHeight
            itemIndex :+ 1
        Next
    End Method

    ' -----------------------------------------------------------------------------
    ' Update / Input Handling
    ' -----------------------------------------------------------------------------
    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        If Not enabled Then Return ContainsPoint(mx, my)
        
        Local over:Int = ContainsPoint(mx, my)
        
        ' Update vertical scrollbar
        If needScrollV
            Local scrollVRelX:Int = mx - scrollV.rect.x
            Local scrollVRelY:Int = my - scrollV.rect.y
            If scrollV.Update(scrollVRelX, scrollVRelY)
                UpdateOffsetFromScrollbar()
                Return True
            EndIf
        EndIf
        
        ' Update horizontal scrollbar
        If needScrollH
            Local scrollHRelX:Int = mx - scrollH.rect.x
            Local scrollHRelY:Int = my - scrollH.rect.y
            If scrollH.Update(scrollHRelX, scrollHRelY)
                UpdateOffsetFromScrollbar()
                Return True
            EndIf
        EndIf
        
        ' Check if mouse is over content area (not scrollbars)
        Local overContent:Int = (mx >= contentAreaX And mx < contentAreaX + contentAreaW And my >= contentAreaY And my < contentAreaY + contentAreaH)
        
        ' Handle mouse wheel over content area
        If overContent And draggedWindow = Null
            Local wheelDelta:Int = GuiMouse.WheelIdle()
            If wheelDelta <> 0
                Local maxScrollY:Int = Max(0, contentHeight - contentAreaH)
                Local scrollStep:Int = itemHeight * 2
                
                If wheelDelta > 0
                    scrollOffsetY = Max(0, scrollOffsetY - scrollStep)
                Else
                    scrollOffsetY = Min(maxScrollY, scrollOffsetY + scrollStep)
                EndIf
                
                UpdateScrollbarFromOffset()
                Return True
            EndIf
        EndIf
        
        ' Handle hover and click in content area
        hoverIndex = -1
        
        If overContent
            ' Calculate which item is under cursor
            Local relY:Int = my - contentAreaY + scrollOffsetY
            Local itemIndex:Int = relY / itemHeight
            
            If itemIndex >= 0 And itemIndex < items.Count()
                hoverIndex = itemIndex
                
                ' Handle click
                If GuiMouse.Hit() And draggedWindow = Null
                    SetSelectedIndex(itemIndex)
                    FireEvent("ItemClicked")
                    Return True
                EndIf
            EndIf
        EndIf
        
        Return over
    End Method

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
    
    Method ItemClicked:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "ItemClicked" Then Return True
        Next
        Return False
    End Method
    
    Method ItemDoubleClicked:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "ItemDoubleClicked" Then Return True
        Next
        Return False
    End Method
    
    Method ClearEvents()
        events.Clear()
        scrollV.ClearEvents()
        scrollH.ClearEvents()
    End Method

    ' -----------------------------------------------------------------------------
    ' Configuration
    ' -----------------------------------------------------------------------------
    Method SetItemHeight(height:Int)
        itemHeight = height
        UpdateLayout()
    End Method
    
    Method SetShowHeader(show:Int)
        showHeader = show
        UpdateLayout()
    End Method
    
    Method SetShowGrid(show:Int)
        showGrid = show
    End Method
    
    Method SetAlternateRows(alternate:Int)
        alternateRows = alternate
    End Method
    
    Method SetBackgroundColor(r:Int, g:Int, b:Int)
        red = r
        green = g
        blue = b
    End Method
End Type
