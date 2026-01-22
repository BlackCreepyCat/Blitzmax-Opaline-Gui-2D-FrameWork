' =============================================================================
'                              PANEL WIDGET
' =============================================================================
' Container with border and optional title for grouping widgets
' =============================================================================

Type TPanel Extends TWidget
    ' Panel title (optional)
    Field title:String = ""
    
    ' Visual appearance style (flat, raised, sunken)
    Field style:Int = PANEL_STYLE_RAISED
    
    ' Whether to draw the background fill
    Field showBackground:Int = True
    
    ' Height reserved for the title bar (0 if no title)
    Field titleHeight:Int = 0
    
    ' Internal padding between border and child widgets
    Field padding:Int = 8

    ' Background color components (cached for performance)
    ' Note: currently using global constants but stored locally
    Field red:Int, green:Int, blue:Int

    Method New(x:Int, y:Int, w:Int, h:Int, title:String = "", panelStyle:Int = PANEL_STYLE_RAISED)
        Super.New(x, y, w, h)

        Self.title = title
        Self.style = panelStyle
        
        ' Reserve space for title if one is provided
        If title.Length > 0
            titleHeight = 23
        EndIf

        ' Cache background color from constants
        red = COLOR_PANEL_BG_R
        green = COLOR_PANEL_BG_G
        blue = COLOR_PANEL_BG_B
        
    End Method

    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        
        ' Absolute screen position
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y

        ' Draw panel background if enabled
        If showBackground
            Select style
                Case PANEL_STYLE_FLAT
                    ' Simple flat fill
                    TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, 1, red, green, blue)
                Case PANEL_STYLE_RAISED
                    ' 3D raised bevel effect
                    TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, 4, red, green, blue)
                Case PANEL_STYLE_SUNKEN
                    ' 3D sunken/inset effect
                    TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, 5, red, green, blue)
            End Select
        EndIf

        ' Draw optional title bar
        If title.Length > 0
            ' Title background
			TWidget.GuiDrawRect(ax + 3, ay + 3, rect.w - 6, titleHeight, 1, COLOR_PANEL_BORDER_R, COLOR_PANEL_BORDER_G, COLOR_PANEL_BORDER_B)
            
            ' Draw title text with shadow effect
            Local textX:Int = ax + padding
            Local textY:Int = ay + (titleHeight - TWidget.GuiTextHeight(title)) / 2 + 2

            TWidget.GuiDrawText(textX, textY, title, TEXT_STYLE_SHADOW, COLOR_PANEL_TITLE_R, COLOR_PANEL_TITLE_G, COLOR_PANEL_TITLE_B)
        EndIf

        ' Draw all child widgets below the title area
        For Local c:TWidget = EachIn children
            c.Draw(ax, ay + titleHeight)
        Next
    End Method

    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        
        ' Early exit if mouse is outside this panel
        If Not ContainsPoint(mx, my)
            Return False
        EndIf
        
        ' Adjust coordinates for content area (below title)
        Local contentX:Int = mx
        Local contentY:Int = my - titleHeight

        ' Process children in reverse order (topmost first = better z-order handling)
        Local rev:TList = New TList
        For Local c:TWidget = EachIn children
            rev.AddFirst(c)
        Next

        For Local c:TWidget = EachIn rev
            Local relX:Int = contentX - c.rect.x
            Local relY:Int = contentY - c.rect.y
            If c.Update(relX, relY) Then Return True    ' Event consumed by child
        Next

        ' If mouse click happened inside panel but not on any child → consume it
        ' (prevents click-through to widgets below the panel)
        If GuiMouse.Hit() And draggedWindow = Null
            Return True
        EndIf

        Return False
    End Method

    ' Public API - Title control
    Method SetTitle(newTitle:String)
        title = newTitle
        ' Automatically adjust title bar height
        If title.Length > 0
            titleHeight = 20
        Else
            titleHeight = 0
        EndIf
    End Method
    
    Method GetTitle:String()
        Return title
    End Method

    ' Public API - Style & appearance
    Method SetStyle(newStyle:Int)
        style = newStyle
    End Method
    
    Method SetShowBackground(show:Int)
        showBackground = show
    End Method
    
    ' Set panel background color
    Method SetColor(r:Int, g:Int, b:Int)
        red = r
        green = g
        blue = b
    End Method

    ' --------------------------------------------------------------------
    ' Helper methods for layout / positioning children inside content area
    ' --------------------------------------------------------------------

    ' Returns X position where content should start (after padding)
    Method GetContentX:Int()
        Return padding
    End Method
    
    ' Returns Y position of content area (after title + padding)
    Method GetContentY:Int()
        Return titleHeight + padding
    End Method
    
    ' Usable width for child widgets (excluding padding)
    Method GetContentWidth:Int()
        Return rect.w - (padding * 2)
    End Method
    
    ' Usable height for child widgets (excluding title and padding)
    Method GetContentHeight:Int()
        Return rect.h - titleHeight - (padding * 2)
    End Method
End Type