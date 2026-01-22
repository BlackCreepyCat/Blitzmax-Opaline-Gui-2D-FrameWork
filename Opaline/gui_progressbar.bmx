' =============================================================================
'                           PROGRESSBAR WIDGET
' =============================================================================
' Visual progress indicator with customizable colors and styles
' =============================================================================

Type TProgressBar Extends TWidget
    ' Current progress value (should stay between minValue and maxValue)
    Field value:Float = 0.0
    
    ' Minimum and maximum range of the progress bar
    Field minValue:Float = 0.0
    Field maxValue:Float = 1.0
    
    ' Orientation: horizontal or vertical
    Field style:Int = PROGRESSBAR_STYLE_HORIZONTAL
    
    ' Whether to display the percentage text in the center
    Field showPercentage:Int = True
    
    ' Fill (progress) color - customizable
    Field fillR:Int = COLOR_PROGRESSBAR_FILL_R
    Field fillG:Int = COLOR_PROGRESSBAR_FILL_G
    Field fillB:Int = COLOR_PROGRESSBAR_FILL_B

    ' Background color fields (renamed from red/green/blue to bgR/bgG/bgB would be clearer)
    Field red:Int   ' ← background red
    Field green:Int ' ← background green
    Field blue:Int  ' ← background blue

    ' ────────────────────────────────────────────────────────────────
    ' Constructor
    ' ────────────────────────────────────────────────────────────────
    Method New(x:Int, y:Int, w:Int, h:Int, initialValue:Float = 0.0)
        Super.New(x, y, w, h)

        ' Clamp initial value to valid range immediately
        value = Clamp(initialValue, minValue, maxValue)

        ' Default background color from theme constants
        red   = COLOR_PROGRESSBAR_BG_R
        green = COLOR_PROGRESSBAR_BG_G
        blue  = COLOR_PROGRESSBAR_BG_B
    End Method

    ' ────────────────────────────────────────────────────────────────
    ' Rendering
    ' ────────────────────────────────────────────────────────────────
    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y
        
        ' Draw background with pressed/embossed style (style 3)
        TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, 3, red, green, blue)
        
        ' Calculate fill dimensions and position
        Local fillWidth:Int
        Local fillHeight:Int
        Local fillX:Int = ax + 2
        Local fillY:Int = ay + 2
        
        ' Normalize value to 0..1 range (with clamping for safety)
        Local normalizedValue:Float = (value - minValue) / (maxValue - minValue)
        normalizedValue = Clamp(normalizedValue, 0.0, 1.0)
        
        If style = PROGRESSBAR_STYLE_HORIZONTAL
            fillWidth  = Int((rect.w - 4) * normalizedValue)
            fillHeight = rect.h - 4
        Else
            fillWidth  = rect.w - 4
            fillHeight = Int((rect.h - 4) * normalizedValue)

            ' For vertical bars, fill grows from bottom to top
            fillY = ay + rect.h - 2 - fillHeight
        EndIf
        
        ' Only draw fill if there's actual progress
        If fillWidth > 0 And fillHeight > 0
            ' Draw fill with raised/embossed style (style 2)
            TWidget.GuiDrawRect(fillX, fillY, fillWidth, fillHeight, 2, fillR, fillG, fillB)
        EndIf
        
        ' Optional percentage text overlay
        If showPercentage
            Local percent:Int = Int(normalizedValue * 100)
            Local percentText:String = percent + "%"
            
            ' Center the text horizontally and vertically
            Local textX:Int = ax + (rect.w - TextWidth(percentText)) / 2
            Local textY:Int = ay + (rect.h - TextHeight(percentText)) / 2
            
            ' Draw text with shadow for better readability
            TWidget.GuiDrawText(textX, textY, percentText, TEXT_STYLE_SHADOW, 255, 255, 255)
        EndIf

        ' Draw children (if any - rare for progress bars but kept for consistency)
        For Local c:TWidget = EachIn children
            c.Draw(ax, ay)
        Next
    End Method

    ' ────────────────────────────────────────────────────────────────
    ' Input handling
    ' ────────────────────────────────────────────────────────────────
    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        
        ' Progress bar usually doesn't react to mouse input
        ' We just forward to children (very uncommon case)
        For Local c:TWidget = EachIn children
            Local relX:Int = mx - c.rect.x
            Local relY:Int = my - c.rect.y
            If c.Update(relX, relY) Then Return True
        Next
        Return False
    End Method

    ' ────────────────────────────────────────────────────────────────
    ' Public API
    ' ────────────────────────────────────────────────────────────────

    ' Set the current progress value (automatically clamped)
    Method SetValue(newValue:Float)
        ' Clamp to keep value in valid range
        value = Clamp(newValue, minValue, maxValue)
    End Method
    
    ' Get the current progress value
    Method GetValue:Float()
        Return value
    End Method
    
    ' Set progress using a percentage (0..100)
    Method SetPercent(percent:Float)
        ' Convert percentage (0..100) to internal value
        value = minValue + (maxValue - minValue) * (percent / 100.0)
        value = Clamp(value, minValue, maxValue)
    End Method
    
    ' Get current progress as percentage (0..100)
    Method GetPercent:Float()
        If maxValue = minValue Then Return 0.0
        Return ((value - minValue) / (maxValue - minValue)) * 100.0
    End Method
    
    ' Change the valid range of the progress bar
    Method SetRange(minVal:Float, maxVal:Float)
        minValue = minVal
        maxValue = maxVal

        ' Important: re-clamp current value after range change
        value = Clamp(value, minValue, maxValue)
    End Method
    
    ' Customize the color of the filled (progress) part
    Method SetFillColor(r:Int, g:Int, b:Int)
        fillR = r
        fillG = g
        fillB = b
    End Method
    
    ' Customize the background color
    Method SetBackgroundColor(r:Int, g:Int, b:Int)
        red   = r
        green = g
        blue  = b
    End Method
    
    ' Change orientation (horizontal or vertical)
    Method SetStyle(newStyle:Int)
        style = newStyle
    End Method
    
    ' Show or hide the percentage text in the center
    Method SetShowPercentage(show:Int)
        showPercentage = show
    End Method

    ' ────────────────────────────────────────────────────────────────
    ' Utility function
    ' ────────────────────────────────────────────────────────────────
    ' Helper function (could be moved to a global Utils module)
    Function Clamp:Float(val:Float, minVal:Float, maxVal:Float)
        If val < minVal Then Return minVal
        If val > maxVal Then Return maxVal
        Return val
    End Function
End Type