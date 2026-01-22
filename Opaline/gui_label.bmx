' =============================================================================
'                              LABEL WIDGET
' =============================================================================
' Static text display with alignment options
' =============================================================================

Type TLabel Extends TWidget
    ' The text to display
    Field text:String
    
    ' Text alignment (left, center, right)
    Field alignment:Int = LABEL_ALIGN_LEFT
    
    ' Text rendering style (normal or shadowed)
    Field textStyle:Int = TEXT_STYLE_SHADOW

    ' Constructor
    Method New(x:Int, y:Int, w:Int, h:Int, text:String, align:Int = LABEL_ALIGN_LEFT)
        Super.New(x, y, w, h)
        Self.text = text
        Self.alignment = align

        ' Default text color from theme constants
        red = COLOR_LABEL_TEXT_R
        green = COLOR_LABEL_TEXT_G
        blue = COLOR_LABEL_TEXT_B
        
    End Method

    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        
        ' Calculate absolute screen position
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y

        Local textX:Int
        ' Vertically center the text
        Local textY:Int = ay + (rect.h - TWidget.GuiTextHeight(text)) / 2

        ' Calculate horizontal position according to alignment
        Select alignment
            Case LABEL_ALIGN_LEFT
                textX = ax
            Case LABEL_ALIGN_CENTER
                textX = ax + (rect.w - TWidget.GuiTextWidth(text)) / 2
            Case LABEL_ALIGN_RIGHT
                textX = ax + rect.w - TWidget.GuiTextWidth(text)
        End Select

        ' Draw the text using the utility function with current color and style
        TWidget.GuiDrawText(textX, textY, text, textStyle, red, green, blue)

        ' Draw all child widgets (if any)
        For Local c:TWidget = EachIn children
            c.Draw(ax, ay)
        Next
    End Method

    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        
        ' Labels usually don't react to mouse input themselves,
        ' but we still propagate update to possible children
        For Local c:TWidget = EachIn children
            Local relX:Int = mx - c.rect.x
            Local relY:Int = my - c.rect.y

            If c.Update(relX, relY) Then Return True
        Next
        Return False
    End Method

    ' Change the displayed text
    Method SetText(newText:String)
        text = newText
    End Method
    
    ' Get current text content
    Method GetText:String()
        Return text
    End Method
    
    ' Override default text color
    Method SetColor(r:Int, g:Int, b:Int)
        red = r
        green = g
        blue = b
    End Method
    
    ' Change text alignment at runtime
    Method SetAlignment(align:Int)
        alignment = align
    End Method
    
    ' Change text rendering style (normal / shadow)
    Method SetTextStyle(style:Int)
        textStyle = style
    End Method
End Type