' =============================================================================
'                             TREEVIEW WIDGET
' =============================================================================
' Hierarchical tree structure with expandable/collapsible nodes
' Uses TSlider for scrolling (same as ListBox)
' Supports window resizing with anchor system
' =============================================================================

' TreeView constants
Const TREEVIEW_INDENT:Int = 20              ' Indentation per level
Const TREEVIEW_ITEM_HEIGHT:Int = 22         ' Height of each tree item
Const TREEVIEW_ICON_SIZE:Int = 16           ' Size of expand/collapse icon
Const TREEVIEW_SCROLLBAR_WIDTH:Int = 26    ' Scrollbar width

' -----------------------------------------------------------------------------
' TreeNode - Single node in the tree
' -----------------------------------------------------------------------------
Type TTreeNode
    Field text:String                        ' Node display text
    Field parent:TTreeNode                   ' Parent node (Null = root)
    Field children:TList = New TList         ' Child nodes
    Field expanded:Int = False               ' Is this node expanded?
    Field level:Int = 0                      ' Depth level (0 = root)
    Field data:Object                        ' User data attached to node
    Field tag:Int                            ' User integer tag
    Field icon:String = "b"                   ' Optional icon character (from symbol font)



    ' Visual state
    Field visible:Int = True                 ' Is this node currently visible?
    Field selected:Int = False               ' Is this node selected?
    
    Method New(text:String, data:Object = Null, tag:Int = 0)
        Self.text = text
        Self.data = data
        Self.tag = tag
    End Method
    
    ' Add a child node
    Method AddChild:TTreeNode(childText:String, data:Object = Null, tag:Int = 0)
        Local child:TTreeNode = New TTreeNode(childText, data, tag)
        child.parent = Self
        child.level = Self.level + 1
        children.AddLast(child)
        Return child
    End Method
    
    ' Remove a child node
    Method RemoveChild(child:TTreeNode)
        If child And children.Contains(child)
            children.Remove(child)
            child.parent = Null
        EndIf
    End Method
    
    ' Check if this node has children
    Method HasChildren:Int()
        Return children.Count() > 0
    End Method
    
    ' Toggle expanded/collapsed state
    Method Toggle()
        If HasChildren()
            expanded = Not expanded
        EndIf
    End Method
    
    ' Expand this node
    Method Expand()
        If HasChildren()
            expanded = True
        EndIf
    End Method
    
    ' Collapse this node
    Method Collapse()
        expanded = False
    End Method
    
    ' Expand this node and all ancestors
    Method ExpandToRoot()
        Local node:TTreeNode = Self
        While node
            If node.HasChildren()
                node.expanded = True
            EndIf
            node = node.parent
        Wend
    End Method
    
    ' Recursively expand all children
    Method ExpandAll()
        expanded = True
        For Local child:TTreeNode = EachIn children
            child.ExpandAll()
        Next
    End Method
    
    ' Recursively collapse all children
    Method CollapseAll()
        expanded = False
        For Local child:TTreeNode = EachIn children
            child.CollapseAll()
        Next
    End Method
    
    ' Get full path from root to this node
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

' -----------------------------------------------------------------------------
' TTreeView - Main tree widget
' -----------------------------------------------------------------------------
Type TTreeView Extends TWidget
    ' Tree structure
    Field rootNodes:TList = New TList        ' Top-level nodes
    Field selectedNode:TTreeNode = Null      ' Currently selected node
    Field hoverNode:TTreeNode = Null         ' Node under mouse cursor
    
    ' Scrolling - uses TSlider like ListBox
    Field scrollV:TSlider                    ' Vertical scrollbar
    Field scrollOffsetY:Int = 0              ' Vertical scroll offset
    Field needScrollV:Int = False            ' Need vertical scrollbar?
    
    ' Visual settings
    Field itemHeight:Int = TREEVIEW_ITEM_HEIGHT
    Field indent:Int = TREEVIEW_INDENT
    Field showIcons:Int = True               ' Show expand/collapse icons
    Field showLines:Int = True               ' Show tree lines
    
    ' Layout
    Field contentAreaX:Int = 0
    Field contentAreaY:Int = 0
    Field contentAreaW:Int = 0
    Field contentAreaH:Int = 0
    Field totalVisibleItems:Int = 0          ' Total number of visible items
    
    ' Events
    Field events:TList = New TList
    
    ' Colors
    Field bgR:Int = COLOR_LISTBOX_BG_R
    Field bgG:Int = COLOR_LISTBOX_BG_G
    Field bgB:Int = COLOR_LISTBOX_BG_B
 

    Field absX:Int = 0
    Field absY:Int = 0
   
    ' -----------------------------------------------------------------------------
    ' Constructor
    ' -----------------------------------------------------------------------------
    Method New(x:Int, y:Int, w:Int, h:Int)
        Super.New(x, y, w, h)
        
        ' Create vertical scrollbar (like ListBox)
        scrollV = New TSlider(0, 0, TREEVIEW_SCROLLBAR_WIDTH, h, 0.0, SLIDER_STYLE_VERTICAL)
        scrollV.SetRange(0.0, 1.0)
        scrollV.SetWheelEnabled(False)  ' We handle wheel ourselves
        
        UpdateLayout()
    End Method
    
    ' -----------------------------------------------------------------------------
    ' Node Management
    ' -----------------------------------------------------------------------------
    
    ' Add a root-level node
    Method AddRootNode:TTreeNode(text:String, data:Object = Null, tag:Int = 0)
        Local node:TTreeNode = New TTreeNode(text, data, tag)
        node.level = 0
        rootNodes.AddLast(node)
        UpdateLayout()
        Return node
    End Method
    
    ' Remove a root node
    Method RemoveRootNode(node:TTreeNode)
        If node And rootNodes.Contains(node)
            rootNodes.Remove(node)
            If selectedNode = node Then selectedNode = Null
            UpdateLayout()
        EndIf
    End Method
    
    ' Clear all nodes
    Method ClearAll()
        rootNodes.Clear()
        selectedNode = Null
        hoverNode = Null
        scrollOffsetY = 0
        scrollV.SetValue(0.0)
        UpdateLayout()
    End Method
    
    ' Find a node by path (e.g., "Root/Child1/Subchild")
    Method FindNodeByPath:TTreeNode(path:String, separator:String = "/")
        Local parts:String[] = path.Split(separator)
        If parts.Length = 0 Then Return Null
        
        ' Find root node
        Local currentNode:TTreeNode = Null
        For Local root:TTreeNode = EachIn rootNodes
            If root.text = parts[0]
                currentNode = root
                Exit
            EndIf
        Next
        
        If Not currentNode Then Return Null
        
        ' Traverse children
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
    
    ' Get all nodes as a flat list (for searching, etc.)
    Method GetAllNodes:TList()
        Local result:TList = New TList
        For Local root:TTreeNode = EachIn rootNodes
            result.AddLast(root)
            CollectNodesRecursive(root, result)
        Next
        Return result
    End Method
    
    Method CollectNodesRecursive(node:TTreeNode, list:TList)
        For Local child:TTreeNode = EachIn node.children
            list.AddLast(child)
            CollectNodesRecursive(child, list)
        Next
    End Method
    
    ' -----------------------------------------------------------------------------
    ' Selection
    ' -----------------------------------------------------------------------------
    
    Method SelectNode(node:TTreeNode)
        If selectedNode <> node
            If selectedNode Then selectedNode.selected = False
            selectedNode = node
            If node
                node.selected = True
                node.ExpandToRoot()  ' Auto-expand path to selected node
                EnsureNodeVisible(node)
            EndIf
            FireEvent("SelectionChanged")
        EndIf
    End Method
    
    Method GetSelectedNode:TTreeNode()
        Return selectedNode
    End Method
    
    Method ClearSelection()
        If selectedNode
            selectedNode.selected = False
            selectedNode = Null
            FireEvent("SelectionChanged")
        EndIf
    End Method
    
    ' Scroll to make a node visible
    Method EnsureNodeVisible(node:TTreeNode)
        If Not node Then Return
        
        ' Calculate node's visual index
        Local visualIndex:Int = GetVisualIndexOfNode(node)
        If visualIndex < 0 Then Return  ' Node not visible (parent collapsed)
        
        Local itemY:Int = visualIndex * itemHeight
        
        If itemY < scrollOffsetY
            scrollOffsetY = itemY
        EndIf
        
        If itemY + itemHeight > scrollOffsetY + contentAreaH
            scrollOffsetY = itemY + itemHeight - contentAreaH
        EndIf
        
        UpdateScrollbarFromOffset()
    End Method
    
    ' Get visual index of a node (returns -1 if not visible due to collapsed parent)
Method GetVisualIndexOfNode:Int(targetNode:TTreeNode)
    Local index:Int = 0
    For Local root:TTreeNode = EachIn rootNodes
        If root = targetNode Then Return index
        index :+ 1
        
        Local childIndex:Int = GetVisualIndexRecursive(root, targetNode, index)
        If childIndex >= 0 Then Return childIndex
        

        ' index = CountVisibleNodesRecursive(root, index)
    Next
    Return -1
End Method
    
Method GetVisualIndexRecursive:Int(node:TTreeNode, targetNode:TTreeNode, index:Int Var)
    If Not node.expanded Then Return -1
    
    For Local child:TTreeNode = EachIn node.children
        If child = targetNode Then Return index
        index :+ 1
        
        If child.expanded And child.HasChildren()
            Local childIndex:Int = GetVisualIndexRecursive(child, targetNode, index)
            If childIndex >= 0 Then Return childIndex

            ' index = CountVisibleNodesRecursive(child, index)
        EndIf
    Next
    Return -1
End Method
    
    ' -----------------------------------------------------------------------------
    ' Layout & Rendering Helpers
    ' -----------------------------------------------------------------------------
    
    Method UpdateLayout()
        ' Calculate total visible items (expanded nodes only)
        totalVisibleItems = 0
        For Local root:TTreeNode = EachIn rootNodes
            totalVisibleItems :+ 1
            totalVisibleItems = CountVisibleNodesRecursive(root, totalVisibleItems)
        Next
        
        Local contentHeight:Int = totalVisibleItems * itemHeight
        
        ' Determine if scrollbar needed
        needScrollV = (contentHeight > rect.h)
        
        ' Set content area
        contentAreaX = 0
        contentAreaY = 0
        contentAreaW = rect.w
        contentAreaH = rect.h
        
        If needScrollV
            contentAreaW :- TREEVIEW_SCROLLBAR_WIDTH
        EndIf
        
        ' Position scrollbar (EXTERNAL to content, like ListBox)
        If needScrollV
            scrollV.rect.x = rect.w - TREEVIEW_SCROLLBAR_WIDTH
            scrollV.rect.y = 0
            scrollV.rect.w = TREEVIEW_SCROLLBAR_WIDTH
            scrollV.rect.h = rect.h
        EndIf
        
        ' Clamp scroll offset
        Local maxScrollY:Int = Max(0, contentHeight - contentAreaH)
        scrollOffsetY = Max(0, Min(scrollOffsetY, maxScrollY))
        
        UpdateScrollbarFromOffset()
    End Method
    
    Method CountVisibleNodesRecursive:Int(node:TTreeNode, count:Int)
        If Not node.expanded Then Return count
        
        For Local child:TTreeNode = EachIn node.children
            count :+ 1
            If child.expanded And child.HasChildren()
                count = CountVisibleNodesRecursive(child, count)
            EndIf
        Next
        Return count
    End Method
    
    Method UpdateOffsetFromScrollbar()
        Local contentHeight:Int = totalVisibleItems * itemHeight
        Local maxScrollY:Int = Max(0, contentHeight - contentAreaH)
        
        scrollOffsetY = Int(scrollV.GetValue() * maxScrollY)
    End Method
    
    Method UpdateScrollbarFromOffset()
        Local contentHeight:Int = totalVisibleItems * itemHeight
        Local maxScrollY:Int = Max(0, contentHeight - contentAreaH)
        
        If maxScrollY > 0
            scrollV.SetValue(Float(scrollOffsetY) / Float(maxScrollY))
        Else
            scrollV.SetValue(0.0)
        EndIf
    End Method
    
    ' -----------------------------------------------------------------------------
    ' ANCHOR SYSTEM - Handle parent resize
    ' -----------------------------------------------------------------------------
    Method OnParentResize(deltaW:Int, deltaH:Int)
        ' Call parent method to handle anchors
        Super.OnParentResize(deltaW, deltaH)
        
        ' Recalculate layout after resize
        UpdateLayout()
    End Method
    
    ' -----------------------------------------------------------------------------
    ' Drawing
    ' -----------------------------------------------------------------------------
    ' =============================================================================
    '                              DRAW - CORRIGÉ
    ' =============================================================================
    Method Draw(px:Int = 0, py:Int = 0)
        If Not visible Then Return
        
        ' Coordonnées ABSOLUES du widget
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y
        
        ' Mémoriser pour Update()
        absX = ax
        absY = ay
        
        ' Draw background
        TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, 4, bgR, bgG, bgB)
        
        ' Coordonnées ABSOLUES du content area
        Local contentAbsX:Int = ax + contentAreaX
        Local contentAbsY:Int = ay + contentAreaY
        
        ' Clip au content area (coordonnées absolues)
        TWidget.GuiSetViewport(contentAbsX, contentAbsY, contentAreaW, contentAreaH)
        
        ' CORRECTION CRITIQUE : drawY doit partir du haut du content area
        Local drawY:Int = contentAbsY - scrollOffsetY
        
        ' Draw tree items (passer les coordonnées absolues)
        For Local root:TTreeNode = EachIn rootNodes
            drawY = DrawNodeRecursive(root, ax, contentAbsY, drawY)
        Next
        
        ' Reset viewport
        TWidget.GuiSetViewport(0, 0, GUI_GRAPHICSWIDTH, GUI_GRAPHICSHEIGHT)
        
        ' Draw scrollbar (on top, like ListBox)
        If needScrollV
            scrollV.Draw(ax, ay)
        EndIf
    End Method
    
    ' =============================================================================
    '                       DRAWNODERECURSIVE - CORRIGÉ
    ' =============================================================================
    Method DrawNodeRecursive:Int(node:TTreeNode, ax:Int, contentAbsY:Int, drawY:Int)
        ' CORRECTION : utiliser contentAbsY (position absolue du content area)
        ' au lieu de rect.y (position relative)
        Local visibleTop:Int = contentAbsY
        Local visibleBottom:Int = contentAbsY + contentAreaH
        
        ' Only draw if visible on screen
        If drawY + itemHeight > visibleTop And drawY < visibleBottom
            DrawNode(node, ax, drawY)
        EndIf
        
        drawY :+ itemHeight
        
        ' Draw children if expanded
        If node.expanded
            For Local child:TTreeNode = EachIn node.children
                drawY = DrawNodeRecursive(child, ax, contentAbsY, drawY)
            Next
        EndIf
        
        Return drawY
    End Method

    Method DrawNode(node:TTreeNode, ax:Int, drawY:Int)
        Local itemX:Int = ax + node.level * indent + 4
        
        ' Background
        If node = selectedNode
            TWidget.GuiDrawRect(ax, drawY, contentAreaW, itemHeight, 1, 
                COLOR_LISTBOX_SELECTED_R, COLOR_LISTBOX_SELECTED_G, COLOR_LISTBOX_SELECTED_B)
        ElseIf node = hoverNode
            TWidget.GuiDrawRect(ax, drawY, contentAreaW, itemHeight, 1, 
                COLOR_LISTBOX_HOVER_R, COLOR_LISTBOX_HOVER_G, COLOR_LISTBOX_HOVER_B)
        EndIf
        
        ' Expand/collapse icon
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
        
        ' Custom icon (if set)
        If node.icon.Length > 0
            TWidget.GuiDrawSymbol(itemX, drawY + (itemHeight - TWidget.GuiTextHeight("X")) / 2, node.icon, TEXT_STYLE_NORMAL, 180, 200, 255)
            itemX :+ 20
        EndIf
        
        ' Node text
        Local textY:Int = drawY + (itemHeight - TWidget.GuiTextHeight("X")) / 2

        TWidget.GuiDrawText(itemX, textY, node.text, TEXT_STYLE_NORMAL, COLOR_LISTBOX_ITEM_R, COLOR_LISTBOX_ITEM_G, COLOR_LISTBOX_ITEM_B)
        
        ' Tree lines (optional)
        If showLines And node.level > 0
            Local lineX:Int = ax + node.level * indent - indent / 2
            SetColor 80, 80, 100
            
            If node.parent
                DrawLine lineX, drawY, lineX, drawY + itemHeight / 2
            EndIf
            
            DrawLine lineX, drawY + itemHeight / 2, lineX + indent / 2 - 4, drawY + itemHeight / 2
        EndIf
    End Method
    
    ' -----------------------------------------------------------------------------
    ' Update / Input
    ' -----------------------------------------------------------------------------
Method Update:Int(mx:Int, my:Int)
    If Not visible Return False
    If Not enabled Return ContainsPoint(mx, my)

    ' ────────────────────────────────────────────────
    ' 1. Mise à jour scrollbar (comme avant)
    ' ────────────────────────────────────────────────
    If needScrollV
        Local scrollVRelX:Int = mx - scrollV.rect.x
        Local scrollVRelY:Int = my - scrollV.rect.y
        If scrollV.Update(scrollVRelX, scrollVRelY)
            UpdateOffsetFromScrollbar()
            Return True
        EndIf
    EndIf

    ' ────────────────────────────────────────────────
    ' 2. Zone de contenu
    ' ────────────────────────────────────────────────
    Local overContent:Int = (mx >= contentAreaX And mx < contentAreaX + contentAreaW And                              my >= contentAreaY And my < contentAreaY + contentAreaH)

    ' Roulette
    If overContent And draggedWindow = Null
        Local wheel:Int = GuiMouse.WheelIdle()
        If wheel
            Local maxScroll:Int = Max(0, totalVisibleItems * itemHeight - contentAreaH)
            Local StepA:Int = itemHeight * 3   ' ← un peu plus rapide, plus agréable
            scrollOffsetY = Max(0, Min(maxScroll, scrollOffsetY - wheel * StepA))
            UpdateScrollbarFromOffset()
            Return True
        EndIf
    EndIf

    ' ────────────────────────────────────────────────
    ' 3. Détection du nœud sous la souris – version corrigée
    ' ────────────────────────────────────────────────
    hoverNode = Null

    If overContent
        ' Position relative dans la zone de défilement
        Local mouseYInContent:Int = my - contentAreaY
        Local VirtualMouseY:Int   = mouseYInContent + scrollOffsetY

        ' Protection contre division bizarre / valeurs négatives
        If VirtualMouseY < 0 Then VirtualMouseY = 0

        Local targetIndex:Int = VirtualMouseY / itemHeight

        ' Récupération du nœud
        Local nodeUnderMouse:TTreeNode = GetNodeAtVisualIndex(targetIndex)

        If nodeUnderMouse
            hoverNode = nodeUnderMouse

            If GuiMouse.Hit(1) And draggedWindow = Null   ' Clic gauche
                ' ─── Détection clic sur icône + ou - ───
                Local iconAreaLeft:Int  = contentAreaX + nodeUnderMouse.level * indent + 2
                Local iconAreaRight:Int = iconAreaLeft + TREEVIEW_ICON_SIZE + 8   ' marge un peu plus large

                If nodeUnderMouse.HasChildren() And showIcons And                  mx >= iconAreaLeft And mx <= iconAreaRight
                   
                    nodeUnderMouse.Toggle()
                    UpdateLayout()           ' ← très important ici
                    EnsureNodeVisible(nodeUnderMouse)   ' ← bonus UX
                    FireEvent("NodeExpanded")
                    Return True
                    
                Else
                    ' Clic normal → sélection
                    SelectNode(nodeUnderMouse)
                    FireEvent("NodeClicked")
                    Return True
                EndIf
            EndIf
        EndIf
    EndIf

    Return ContainsPoint(mx, my)
End Method
    
    ' Get node at specific visual index
Method GetNodeAtVisualIndex:TTreeNode(targetIndex:Int)
    Local currentIndex:Int = 0
    For Local root:TTreeNode = EachIn rootNodes
        If currentIndex = targetIndex Then Return root
        currentIndex :+ 1
        
        Local node:TTreeNode = GetNodeAtVisualIndexRecursive(root, targetIndex, currentIndex)
        If node Then Return node
        
        ' Removed: currentIndex = CountVisibleNodesRecursive(root, currentIndex)
        ' (The recursive call already advances currentIndex correctly)
    Next
    Return Null
End Method
    
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
    
    ' -----------------------------------------------------------------------------
    ' Events
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
    
    Method NodeClicked:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "NodeClicked" Then Return True
        Next
        Return False
    End Method
    
    Method NodeExpanded:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "NodeExpanded" Then Return True
        Next
        Return False
    End Method
    
    Method ClearEvents()
        events.Clear()
        scrollV.ClearEvents()
    End Method
    
    ' -----------------------------------------------------------------------------
    ' Configuration
    ' -----------------------------------------------------------------------------
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