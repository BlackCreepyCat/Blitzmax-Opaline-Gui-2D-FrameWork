' =============================================================================
'                             TREEVIEW WIDGET
' =============================================================================
' Hierarchical tree structure with expandable/collapsible nodes
' Uses TSlider for vertical scrolling (similar to ListBox)
' Supports window resizing via anchor system
' =============================================================================

' TreeView constants
Const TREEVIEW_INDENT:Int = 20              ' Indentation width per hierarchy level
Const TREEVIEW_ITEM_HEIGHT:Int = 22         ' Fixed height of each tree item row
Const TREEVIEW_ICON_SIZE:Int = 16           ' Size of the expand/collapse icon
Const TREEVIEW_SCROLLBAR_WIDTH:Int = 28     ' Width reserved for the vertical scrollbar


' ----------------------------------------------------------
' TreeNode - Represents a single node in the tree hierarchy
' ---------------------------------------------------------
Type TTreeNode
    Field text:String                        ' Display text of the node
    Field parent:TTreeNode                   ' Parent node (Null for root nodes)
    Field children:TList = New TList         ' List of child nodes
    Field expanded:Int = False               ' True if this node is expanded
    Field level:Int = 0                      ' Depth level in the tree (0 = root)
    Field data:Object                        ' Optional user-defined data object
    Field tag:Int                            ' Optional user-defined integer tag
    Field icon:String = "b"                  ' Optional icon character from symbol font

    ' Visual / interaction state
    Field visible:Int = True                 ' Currently visible in the tree (affected by parent expansion)
    Field selected:Int = False               ' True if this node is currently selected
    
    Method New(text:String, data:Object = Null, tag:Int = 0)
        Self.text = text
        Self.data = data
        Self.tag = tag
    End Method
    
    ' Adds a new child node and returns it
    Method AddChild:TTreeNode(childText:String, data:Object = Null, tag:Int = 0)
        Local child:TTreeNode = New TTreeNode(childText, data, tag)
        child.parent = Self
        child.level = Self.level + 1
        children.AddLast(child)
        Return child
    End Method
    
    ' Removes a child node if it exists
    Method RemoveChild(child:TTreeNode)
        If child And children.Contains(child)
            children.Remove(child)
            child.parent = Null
        EndIf
    End Method
    
    ' Returns True if this node has at least one child
    Method HasChildren:Int()
        Return children.Count() > 0
    End Method
    
    ' Toggles the expanded/collapsed state (only if has children)
    Method Toggle()
        If HasChildren()
            expanded = Not expanded
        EndIf
    End Method
    
    ' Expands this node (only if has children)
    Method Expand()
        If HasChildren()
            expanded = True
        EndIf
    End Method
    
    ' Collapses this node
    Method Collapse()
        expanded = False
    End Method
    
    ' Expands this node and all its ancestors up to the root
    Method ExpandToRoot()
        Local node:TTreeNode = Self
        While node
            If node.HasChildren()
                node.expanded = True
            EndIf
            node = node.parent
        Wend
    End Method
    
    ' Recursively expands this node and all its descendants
    Method ExpandAll()
        expanded = True
        For Local child:TTreeNode = EachIn children
            child.ExpandAll()
        Next
    End Method
    
    ' Recursively collapses this node and all its descendants
    Method CollapseAll()
        expanded = False
        For Local child:TTreeNode = EachIn children
            child.CollapseAll()
        Next
    End Method
    
    ' Returns the full path from root to this node (e.g. "Root/Child/Subchild")
    Method GetPath:String(separator:String = "/")
        Local path:String = text
        Local node:TTreeNode = parent
        While node
            path = node.text + separator + path
            node = node.parent
        Wend
        Return path
    End Method
End Type


' ---------------------------------
' TTreeView - Main tree view widget
' ---------------------------------
Type TTreeView Extends TWidget
    ' Tree structure
    Field rootNodes:TList = New TList        ' List of top-level (root) nodes
    Field selectedNode:TTreeNode = Null      ' Currently selected node
    Field hoverNode:TTreeNode = Null         ' Node currently under the mouse cursor
    
    ' Scrolling
    Field scrollV:TSlider                    ' Vertical scrollbar control
    Field scrollOffsetY:Int = 0              ' Current vertical scroll offset in pixels
    Field needScrollV:Int = False            ' True if vertical scrollbar is required
    
    ' Visual appearance settings
    Field itemHeight:Int = TREEVIEW_ITEM_HEIGHT
    Field indent:Int = TREEVIEW_INDENT
    Field showIcons:Int = True               ' Display expand/collapse icons
    Field showLines:Int = True               ' Display connecting tree lines
    
    ' Layout areas (relative to widget)
    Field contentAreaX:Int = 0
    Field contentAreaY:Int = 0
    Field contentAreaW:Int = 0
    Field contentAreaH:Int = 0
    Field totalVisibleItems:Int = 0          ' Total count of currently visible items (for scrollbar)
    
    ' Events
    Field events:TList = New TList           ' List of pending events
    
    ' Colors
    Field bgR:Int = COLOR_LISTBOX_BG_R
    Field bgG:Int = COLOR_LISTBOX_BG_G
    Field bgB:Int = COLOR_LISTBOX_BG_B
    
    ' Absolute screen position (used for input handling)
    Field absX:Int = 0
    Field absY:Int = 0
   
    ' -----------
    ' Constructor
    ' -----------
    Method New(x:Int, y:Int, w:Int, h:Int)
        Super.New(x, y, w, h)
        
        ' Initialize vertical scrollbar
        scrollV = New TSlider(0, 0, TREEVIEW_SCROLLBAR_WIDTH, h, 0.0, SLIDER_STYLE_VERTICAL)
        scrollV.SetRange(0.0, 1.0)
        scrollV.SetWheelEnabled(False)  ' Wheel handled manually in Update()
        
        UpdateLayout()
    End Method
    
    ' ---------------
    ' Node Management
    ' ---------------
    
    ' Adds a new root-level node and returns it
    Method AddRootNode:TTreeNode(text:String, data:Object = Null, tag:Int = 0)
        Local node:TTreeNode = New TTreeNode(text, data, tag)
        node.level = 0
        rootNodes.AddLast(node)
        UpdateLayout()
        Return node
    End Method
    
    ' Removes a root node if it exists
    Method RemoveRootNode(node:TTreeNode)
        If node And rootNodes.Contains(node)
            rootNodes.Remove(node)
            If selectedNode = node Then selectedNode = Null
            UpdateLayout()
        EndIf
    End Method
    
    ' Clears all nodes and resets state
    Method ClearAll()
        rootNodes.Clear()
        selectedNode = Null
        hoverNode = Null
        scrollOffsetY = 0
        scrollV.SetValue(0.0)
        UpdateLayout()
    End Method
    
    ' Finds a node by its full path string (separator default = "/")
    Method FindNodeByPath:TTreeNode(path:String, separator:String = "/")
        Local parts:String[] = path.Split(separator)
        If parts.Length = 0 Then Return Null
        
        ' Find matching root
        Local currentNode:TTreeNode = Null
        For Local root:TTreeNode = EachIn rootNodes
            If root.text = parts[0]
                currentNode = root
                Exit
            EndIf
        Next
        
        If Not currentNode Then Return Null
        
        ' Traverse remaining path parts
        For Local i:Int = 1 Until parts.Length
            Local found:Int = False
            For Local child:TTreeNode = EachIn currentNode.children
                If child.text = parts[i]
                    currentNode = child
                    found = True
                    Exit
                EndIf
            Next
            If Not found Then Return Null
        Next
        
        Return currentNode
    End Method
    
    ' Returns a flat list of all nodes (root + descendants)
    Method GetAllNodes:TList()
        Local result:TList = New TList
        For Local root:TTreeNode = EachIn rootNodes
            result.AddLast(root)
            CollectNodesRecursive(root, result)
        Next
        Return result
    End Method
    
    ' Helper: recursively collects all descendants into the list
    Method CollectNodesRecursive(node:TTreeNode, list:TList)
        For Local child:TTreeNode = EachIn node.children
            list.AddLast(child)
            CollectNodesRecursive(child, list)
        Next
    End Method
    
    ' --------------------
    ' Selection Management
    ' --------------------
    
    ' Selects a node, deselects previous, expands path and makes visible
    Method SelectNode(node:TTreeNode)
        If selectedNode <> node
            If selectedNode Then selectedNode.selected = False
            selectedNode = node
            If node
                node.selected = True
                node.ExpandToRoot()          ' Auto-expand ancestors
                EnsureNodeVisible(node)      ' Scroll to make node visible
            EndIf
            FireEvent("SelectionChanged")
        EndIf
    End Method
    
    ' Returns the currently selected node (or Null)
    Method GetSelectedNode:TTreeNode()
        Return selectedNode
    End Method
    
    ' Clears the current selection
    Method ClearSelection()
        If selectedNode
            selectedNode.selected = False
            selectedNode = Null
            FireEvent("SelectionChanged")
        EndIf
    End Method

	' Expands all nodes in the tree (root and descendants) , automatically resets scroll position to top and updates layout
	Method ExpandAll()
		' Reset scroll to top before expanding (prevents visual glitches)
		scrollOffsetY = 0
		
		' Expand all root nodes and their descendants
		For Local root:TTreeNode = EachIn rootNodes
			root.ExpandAll()
		Next
		
		' Recalculate layout (totalVisibleItems, scrollbar range, etc.)
		UpdateLayout()
		
		' Ensure scroll is at top (security, in case UpdateLayout modified it)
		scrollOffsetY = 0
		UpdateScrollbarFromOffset()
		
		' Fire event to notify listeners
		FireEvent("TreeExpanded")
	End Method

	' Collapses all nodes in the tree (root and descendants) , automatically resets scroll position to top and updates layout
	Method CollapseAll()
		' Reset scroll to top before collapsing
		scrollOffsetY = 0
		
		' Collapse all root nodes and their descendants
		For Local root:TTreeNode = EachIn rootNodes
			root.CollapseAll()
		Next
		
		' Recalculate layout
		UpdateLayout()
		
		' Ensure scroll is at top
		scrollOffsetY = 0
		UpdateScrollbarFromOffset()
		
		' Fire event to notify listeners
		FireEvent("TreeCollapsed")
	End Method

	' Expands all nodes up to a specific depth level , depth: 0 = only roots visible, 1 = roots + first children, etc.
	Method ExpandToLevel(depth:Int)
		scrollOffsetY = 0
		
		For Local root:TTreeNode = EachIn rootNodes
			ExpandNodeToLevel(root, 0, depth)
		Next
		
		UpdateLayout()
		scrollOffsetY = 0
		UpdateScrollbarFromOffset()
		
		FireEvent("TreeExpanded")
	End Method

	' Helper method for ExpandToLevel (recursive)
	Method ExpandNodeToLevel(node:TTreeNode, currentLevel:Int, targetLevel:Int)
		If currentLevel < targetLevel
			node.Expand()
			For Local child:TTreeNode = EachIn node.children
				ExpandNodeToLevel(child, currentLevel + 1, targetLevel)
			Next
		Else
			node.Collapse()
		EndIf
	End Method
	
	Method CountVisibleNodesRecursive:Int(node:TTreeNode)

		If Not node.expanded Then Return 0

		Local count:Int = 0

		For Local child:TTreeNode = EachIn node.children
			count :+ 1
			If child.expanded Then
				count :+ CountVisibleNodesRecursive(child)
			EndIf
		Next

		Return count
	End Method	

    
    ' Scrolls the view so the specified node becomes visible
    Method EnsureNodeVisible(node:TTreeNode)
        If Not node Then Return
        
        Local visualIndex:Int = GetVisualIndexOfNode(node)

		If visualIndex < 0 Then
			UpdateLayout()
			visualIndex = GetVisualIndexOfNode(node)
			If visualIndex < 0 Then Return
		EndIf
        
        Local itemY:Int = visualIndex * itemHeight
        
        ' Scroll up if node is above current view
        If itemY < scrollOffsetY
            scrollOffsetY = itemY
        EndIf
        
        ' Scroll down if node is below current view
        If itemY + itemHeight > scrollOffsetY + contentAreaH
            scrollOffsetY = itemY + itemHeight - contentAreaH
        EndIf
        
        UpdateScrollbarFromOffset()
    End Method
    
    ' Returns the visual row index of a node (-1 if not visible)
	Method GetVisualIndexOfNode:Int(targetNode:TTreeNode)

		Local index:Int = 0

		For Local root:TTreeNode = EachIn rootNodes

			If root = targetNode Then Return index
			index :+ 1

			GetVisualIndexRecursive(root, targetNode, index)

			If index < 0 Then
				Return -1
			EndIf
		Next

		Return -1
	End Method
    
    ' Recursive helper for GetVisualIndexOfNode (index passed by reference)
	Method GetVisualIndexRecursive:Int(node:TTreeNode, targetNode:TTreeNode, index:Int Var)

		If Not node.expanded Then Return 0

		For Local child:TTreeNode = EachIn node.children

			If child = targetNode Then
				Return index
			EndIf

			index :+ 1

			If child.expanded Then
				Local found:Int = GetVisualIndexRecursive(child, targetNode, index)
				If found >= 0 Then Return found
			EndIf
		Next

		Return -1
	End Method
    


    ' --------------------------
    ' Layout & Rendering Helpers
    ' --------------------------
	Method UpdateLayout()

		' --------------------------------------------------
		' 1) Recalcul exact du nombre d’items visibles
		' --------------------------------------------------
		totalVisibleItems = 0

		For Local root:TTreeNode = EachIn rootNodes
			totalVisibleItems :+ 1
			totalVisibleItems :+ CountVisibleNodesRecursive(root)
		Next

		Local contentHeight:Int = totalVisibleItems * itemHeight


		' --------------------------------------------------
		' 2) Détermination de la nécessité du scrollbar
		' --------------------------------------------------
		needScrollV = (contentHeight > rect.h)


		' --------------------------------------------------
		' 3) Définition de la zone de contenu
		' --------------------------------------------------
		contentAreaX = 0
		contentAreaY = 0
		contentAreaW = rect.w
		contentAreaH = rect.h

		If needScrollV
			contentAreaW :- TREEVIEW_SCROLLBAR_WIDTH
		EndIf


		' --------------------------------------------------
		' 4) Clamp du scrollOffsetY AVANT synchro slider
		' --------------------------------------------------
		Local maxScrollY:Int = Max(0, contentHeight - contentAreaH)
		scrollOffsetY = Max(0, Min(scrollOffsetY, maxScrollY))


		' --------------------------------------------------
		' 5) Configuration / synchronisation du scrollbar
		' --------------------------------------------------
		If needScrollV

			scrollV.SetEnabled(True)

			' Position & taille
			scrollV.rect.x = rect.w - TREEVIEW_SCROLLBAR_WIDTH
			scrollV.rect.y = 3
			scrollV.rect.w = TREEVIEW_SCROLLBAR_WIDTH - 2
			scrollV.rect.h = rect.h - 6

			' Range EN PIXELS (clé de la stabilité)
			scrollV.SetRange(0.0, Float(maxScrollY))

			' Synchronisation valeur ← offset
			scrollV.SetValue(Float(scrollOffsetY))

		Else
			' Scroll inutile → reset complet
			scrollV.SetEnabled(False)
			scrollV.SetRange(0.0, 0.0)
			scrollV.SetValue(0.0)
			scrollOffsetY = 0
		EndIf

	End Method
        
    ' Updates scroll offset based on scrollbar position
	Method UpdateOffsetFromScrollbar()
		scrollOffsetY = Int(scrollV.GetValue())
	End Method
		
		' Updates scrollbar position based on current scroll offset
	Method UpdateScrollbarFromOffset()
		scrollV.SetValue(Float(scrollOffsetY))
	End Method
    
    ' ------------------------
    ' Anchor / Resize handling
    ' ------------------------
    Method OnParentResize(deltaW:Int, deltaH:Int)
        ' Let parent handle anchors first
        Super.OnParentResize(deltaW, deltaH)
        
        ' Recalculate layout after size change
        UpdateLayout()
    End Method
    
    ' =============================================================================
    '                              DRAWING
    ' =============================================================================
    Method Draw(px:Int = 0, py:Int = 0)
        If Not visible Then Return
        
        ' Calculate absolute screen coordinates
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y
        
        ' Store for input handling in Update()
        absX = ax
        absY = ay
        
        ' Draw widget background
        TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, 4, bgR, bgG, bgB)
        
        ' Absolute content area coordinates
        Local contentAbsX:Int = ax + contentAreaX
        Local contentAbsY:Int = ay + contentAreaY
        
        ' Temporary adjustment for better clipping / borders (can be refined later)
        TWidget.GuiSetViewport(contentAbsX + 2, contentAbsY + 2, contentAreaW - 2, contentAreaH - 4)
        
        ' Starting draw position (top of visible content)
        Local drawY:Int = contentAbsY - scrollOffsetY + 2
        
        ' Draw all visible tree nodes
        For Local root:TTreeNode = EachIn rootNodes
            drawY = DrawNodeRecursive(root, ax, contentAbsY, drawY)
        Next
        
        ' Restore full viewport
        TWidget.GuiSetViewport(0, 0, GUI_GRAPHICSWIDTH, GUI_GRAPHICSHEIGHT)
        
        ' Draw scrollbar on top if needed
        If needScrollV
            scrollV.Draw(ax, ay)
        EndIf
    End Method
    
    ' Recursively draws a node and its visible children
    Method DrawNodeRecursive:Int(node:TTreeNode, ax:Int, contentAbsY:Int, drawY:Int)
        Local visibleTop:Int = contentAbsY
        Local visibleBottom:Int = contentAbsY + contentAreaH
        
        ' Draw only if item intersects visible area
        If drawY + itemHeight > visibleTop And drawY < visibleBottom
            DrawNode(node, ax, drawY)
        EndIf
        
        drawY :+ itemHeight
        
        ' Draw expanded children
        If node.expanded
            For Local child:TTreeNode = EachIn node.children
                drawY = DrawNodeRecursive(child, ax, contentAbsY, drawY)
            Next
        EndIf
        
        Return drawY
    End Method
    
    ' Draws a single node row (background, icon, text, lines)
    Method DrawNode(node:TTreeNode, ax:Int, drawY:Int)
        Local itemX:Int = ax + node.level * indent + 4
        
        ' Draw selection or hover background
        If node = selectedNode
            TWidget.GuiDrawRect(ax, drawY, contentAreaW, itemHeight, 1, 
                COLOR_LISTBOX_SELECTED_R, COLOR_LISTBOX_SELECTED_G, COLOR_LISTBOX_SELECTED_B)
        ElseIf node = hoverNode
            TWidget.GuiDrawRect(ax, drawY, contentAreaW, itemHeight, 1, 
                COLOR_LISTBOX_HOVER_R, COLOR_LISTBOX_HOVER_G, COLOR_LISTBOX_HOVER_B)
        EndIf
        
        ' Draw expand/collapse icon if applicable
        If node.HasChildren() And showIcons
            Local iconX:Int = itemX - 2
            Local iconY:Int = drawY + (itemHeight - TREEVIEW_ICON_SIZE) / 2
            
            If node.expanded
                TWidget.GuiDrawSymbol(iconX, iconY, "C", TEXT_STYLE_NORMAL, 200, 200, 220)
            Else
                TWidget.GuiDrawSymbol(iconX, iconY, "E", TEXT_STYLE_NORMAL, 200, 200, 220)
            EndIf
            
            itemX :+ TREEVIEW_ICON_SIZE + 4
        EndIf
        
        ' Draw custom icon if defined
        If node.icon.Length > 0
            TWidget.GuiDrawSymbol(itemX, drawY + (itemHeight - TWidget.GuiTextHeight("X")) / 2, 
                node.icon, TEXT_STYLE_NORMAL, 180, 200, 255)
            itemX :+ 20
        EndIf
        
        ' Draw node text
        Local textY:Int = drawY + (itemHeight - TWidget.GuiTextHeight("X")) / 2
        TWidget.GuiDrawText(itemX + 3 , textY, node.text, TEXT_STYLE_NORMAL, COLOR_LISTBOX_ITEM_R, COLOR_LISTBOX_ITEM_G, COLOR_LISTBOX_ITEM_B)
        
        ' Draw optional tree connection lines
        If showLines And node.level > 0
            Local lineX:Int = ax + node.level * indent - indent / 2
			TWidget.GuiDrawtext(lineX, drawY, "├", TEXT_STYLE_NORMAL, 200, 200, 220)
        EndIf
    End Method
    
    ' -----------------------
    ' Update / Input Handling
    ' -----------------------
    Method Update:Int(mx:Int, my:Int)
        If Not visible Return False
        If Not enabled Return ContainsPoint(mx, my)

        ' 1. Handle scrollbar input
        If needScrollV
            Local scrollVRelX:Int = mx - scrollV.rect.x
            Local scrollVRelY:Int = my - scrollV.rect.y
            If scrollV.Update(scrollVRelX, scrollVRelY)
                UpdateOffsetFromScrollbar()
                Return True
            EndIf
        EndIf

        ' 2. Check if mouse is over content area
        Local overContent:Int = (mx >= contentAreaX And mx < contentAreaX + contentAreaW And my >= contentAreaY And my < contentAreaY + contentAreaH)

        ' Mouse wheel scrolling (only over content)
        If overContent And draggedWindow = Null
            Local wheel:Int = GuiMouse.WheelIdle()
            If wheel
                Local maxScroll:Int = Max(0, totalVisibleItems * itemHeight - contentAreaH)
                Local stepSize:Int = itemHeight * 3   ' Faster, smoother scrolling
                scrollOffsetY = Max(0, Min(maxScroll, scrollOffsetY - wheel * stepSize))
                UpdateScrollbarFromOffset()
                Return True
            EndIf
        EndIf

        ' 3. Mouse hover and click detection
        hoverNode = Null

        If overContent
            ' Convert mouse Y to virtual scrolled position
            Local mouseYInContent:Int = my - contentAreaY
            Local VirtualMouseY:Int   = mouseYInContent + scrollOffsetY

            ' Prevent negative index
            If VirtualMouseY < 0 Then VirtualMouseY = 0

            Local targetIndex:Int = VirtualMouseY / itemHeight

            Local nodeUnderMouse:TTreeNode = GetNodeAtVisualIndex(targetIndex)

            If nodeUnderMouse
                hoverNode = nodeUnderMouse

                If GuiMouse.Hit(1) And draggedWindow = Null   ' Left mouse button clicked

					' Check if click was on expand/collapse icon
					Local iconAreaLeft:Int  = nodeUnderMouse.level * indent + 2
					Local iconAreaRight:Int = iconAreaLeft + TREEVIEW_ICON_SIZE + 8  ' ou TREEVIEW_ICON_CLICK_PADDING

					If nodeUnderMouse.HasChildren() And showIcons And mx >= iconAreaLeft And mx <= iconAreaRight
						' Click on expand/collapse icon
						nodeUnderMouse.Toggle()
						UpdateLayout()                    ' Important: refresh layout after expand/collapse
						EnsureNodeVisible(nodeUnderMouse) ' Nice UX: keep clicked node in view
						FireEvent("NodeExpanded")
						Return True
					Else
						' Normal node click → select it
						SelectNode(nodeUnderMouse)
						FireEvent("NodeClicked")
						Return True
					EndIf



                EndIf
            EndIf
        EndIf

        Return ContainsPoint(mx, my)
    End Method
    
    ' Returns the node at the given visual row index (or Null)
    Method GetNodeAtVisualIndex:TTreeNode(targetIndex:Int)
        Local currentIndex:Int = 0
        For Local root:TTreeNode = EachIn rootNodes
            If currentIndex = targetIndex Then Return root
            currentIndex :+ 1
            
            Local node:TTreeNode = GetNodeAtVisualIndexRecursive(root, targetIndex, currentIndex)
            If node Then Return node
        Next
        Return Null
    End Method
    
    ' Recursive helper for GetNodeAtVisualIndex (index passed by reference)
    Method GetNodeAtVisualIndexRecursive:TTreeNode(node:TTreeNode, targetIndex:Int, currentIndex:Int Var)
        If Not node.expanded Then Return Null
        
        For Local child:TTreeNode = EachIn node.children
            If currentIndex = targetIndex Then Return child
            currentIndex :+ 1
            
            If child.expanded And child.HasChildren()
                Local found:TTreeNode = GetNodeAtVisualIndexRecursive(child, targetIndex, currentIndex)
                If found Then Return found
            EndIf
        Next
        Return Null
    End Method
    
    ' ------------
    ' Event System
    ' ------------
	' Returns True if a TreeExpanded event is pending
	Method TreeExpanded:Int()
		For Local ev:TEvent = EachIn events
			If ev.eventType = "TreeExpanded" Then Return True
		Next
		Return False
	End Method

	' Returns True if a TreeCollapsed event is pending
	Method TreeCollapsed:Int()
		For Local ev:TEvent = EachIn events
			If ev.eventType = "TreeCollapsed" Then Return True
		Next
		Return False
	End Method

    Method FireEvent(eventType:String)
        Local ev:TEvent = New TEvent
        ev.target = Self
        ev.eventType = eventType
        events.AddLast(ev)
    End Method
    
    ' Returns True if a SelectionChanged event is pending
    Method SelectionChanged:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "SelectionChanged" Then Return True
        Next
        Return False
    End Method
    
    ' Returns True if a NodeClicked event is pending
    Method NodeClicked:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "NodeClicked" Then Return True
        Next
        Return False
    End Method
    
    ' Returns True if a NodeExpanded event is pending
    Method NodeExpanded:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "NodeExpanded" Then Return True
        Next
        Return False
    End Method
    
    ' Clears all pending events (including scrollbar events)
    Method ClearEvents()
        events.Clear()
        scrollV.ClearEvents()
    End Method
    
    ' ---------------------
    ' Configuration Setters
    ' ---------------------
    Method SetItemHeight(height:Int)
        itemHeight = height
        UpdateLayout()
    End Method
    
    Method SetIndent(pixels:Int)
        indent = pixels
    End Method
    
    Method SetShowIcons(show:Int)
        showIcons = show
    End Method
    
    Method SetShowLines(show:Int)
        showLines = show
    End Method
    
    Method SetBackgroundColor(r:Int, g:Int, b:Int)
        bgR = r
        bgG = g
        bgB = b
    End Method
End Type
