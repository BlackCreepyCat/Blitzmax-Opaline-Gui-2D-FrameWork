' =============================================================================
'                              LABEL WIDGET
' =============================================================================
' Static text display widget with alignment options (left, center, right)
' Supports text styling (normal or shadowed) and custom colors.
' Inherits from TWidget for GUI hierarchy and rendering.
' =============================================================================

Type TLabel Extends TWidget
    
    ' The text content to display
    Field text:String
    
    ' Text alignment: LABEL_ALIGN_LEFT, LABEL_ALIGN_CENTER, or LABEL_ALIGN_RIGHT
    Field alignment:Int = LABEL_ALIGN_LEFT
    
    ' Text rendering style: TEXT_STYLE_SHADOW or TEXT_STYLE_NORMAL
    Field textStyle:Int = TEXT_STYLE_SHADOW
    
    ' Custom text color components (RGB)
    Field red:Int = COLOR_LABEL_TEXT_R
    Field green:Int = COLOR_LABEL_TEXT_G
    Field blue:Int = COLOR_LABEL_TEXT_B
    
    ' -----------------------------------------------------------------------------
    ' Constructor: Initializes the label with position, size, text, and alignment.
    ' Defaults to left-aligned shadowed text with theme colors.
    ' -----------------------------------------------------------------------------
    Method New(x:Int, y:Int, w:Int, h:Int, text:String, align:Int = LABEL_ALIGN_LEFT)
        Super.New(x, y, w, h)
        Self.text = text
        Self.alignment = align
        
        ' Set default text color from global theme constants
        Self.red   = COLOR_LABEL_TEXT_R
        Self.green = COLOR_LABEL_TEXT_G
        Self.blue  = COLOR_LABEL_TEXT_B
    End Method
    
    ' -----------------------------------------------------------------------------
    ' Draw: Renders the label text at the calculated position with alignment and style.
    ' Recursively draws child widgets if any (supports nesting).
    ' -----------------------------------------------------------------------------
    Method Draw(px:Int = 0, py:Int = 0)
        If Not visible Then Return
        
        ' Compute absolute screen position (parent offset + local rect)
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y
        
        ' Vertical centering: Align text to middle of widget height
        Local textY:Int = ay + (rect.h - TWidget.GuiTextHeight(text)) / 2
        
        ' Horizontal positioning based on alignment
        Local textX:Int
        Select alignment
            Case LABEL_ALIGN_LEFT
                textX = ax  ' Left-aligned: start at widget left edge
            Case LABEL_ALIGN_CENTER
                textX = ax + (rect.w - TWidget.GuiTextWidth(text)) / 2  ' Center: midpoint offset
            Case LABEL_ALIGN_RIGHT
                textX = ax + rect.w - TWidget.GuiTextWidth(text)  ' Right-aligned: end at widget right edge
        End Select
        
        ' Render text using global GUI utility with custom style and RGB color
        TWidget.GuiDrawText(textX, textY, text, textStyle, red, green, blue)
        
        ' Recursively draw all child widgets (enables widget composition)
        For Local c:TWidget = EachIn children
            c.Draw(ax, ay)
        Next
    End Method
    
    ' -----------------------------------------------------------------------------
    ' Update: Handles mouse input propagation to children (labels are non-interactive).
    ' Returns True if any child consumed the event.
    ' Coordinates are relative to this widget's origin.
    ' -----------------------------------------------------------------------------
    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        
        ' Labels ignore direct mouse input but forward to children
        For Local c:TWidget = EachIn children
            ' Transform mouse coords to child's local space
            Local relX:Int = mx - c.rect.x
            Local relY:Int = my - c.rect.y
            
            If c.Update(relX, relY) Then Return True
        Next
        Return False
    End Method
    
    ' -----------------------------------------------------------------------------
    ' SetText: Dynamically updates the displayed text content.
    ' -----------------------------------------------------------------------------
    Method SetText(newText:String)
        text = newText
    End Method
    
    ' -----------------------------------------------------------------------------
    ' GetText: Retrieves the current text content.
    ' -----------------------------------------------------------------------------
    Method GetText:String()
        Return text
    End Method
    
    ' -----------------------------------------------------------------------------
    ' SetColor: Overrides the default RGB text color at runtime.
    ' -----------------------------------------------------------------------------
    Method SetColor(r:Int, g:Int, b:Int)
        red = r
        green = g
        blue = b
    End Method
    
    ' -----------------------------------------------------------------------------
    ' SetAlignment: Changes text alignment dynamically (left/center/right).
    ' -----------------------------------------------------------------------------
    Method SetAlignment(align:Int)
        alignment = align
    End Method
    
    ' -----------------------------------------------------------------------------
    ' SetTextStyle: Switches between text styles (e.g., normal vs. shadowed).
    ' -----------------------------------------------------------------------------
    Method SetTextStyle(style:Int)
        textStyle = style
    End Method

End Type