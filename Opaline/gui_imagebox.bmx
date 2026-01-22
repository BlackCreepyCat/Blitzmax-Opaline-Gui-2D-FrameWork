' =============================================================================
'                            IMAGEBOX WIDGET
' =============================================================================
' Displays an image with optional border frame and click support
' Uses DrawImageRect for flexible image scaling
' =============================================================================

' Image display styles
Const IMAGEBOX_STYLE_FLAT:Int = 0      ' No border
Const IMAGEBOX_STYLE_RAISED:Int = 1    ' Raised border (like button)
Const IMAGEBOX_STYLE_SUNKEN:Int = 2    ' Sunken border

Type TImageBox Extends TWidget
    ' Image reference
    Field image:TImage = Null
    
    ' Display options
    Field style:Int = IMAGEBOX_STYLE_FLAT     ' Border style
    Field showBorder:Int = False               ' Show border frame
    Field clickable:Int = False                ' Can be clicked like a button
    
    ' Interaction state (when clickable)
    Field pressed:Int = False
    Field hover:Int = False
    Field lastDown:Int = False
    Field clickedOnMe:Int = False
    Field events:TList = New TList
    
    ' Image display options
    Field preserveAspect:Int = False           ' Preserve aspect ratio
    Field centerImage:Int = True               ' Center image in widget
    Field imageAlpha:Float = 1.0               ' Image transparency
    
    ' Border colors (defaults to button colors)
    Field borderR:Int = COLOR_BUTTON_NORMAL_R
    Field borderG:Int = COLOR_BUTTON_NORMAL_G
    Field borderB:Int = COLOR_BUTTON_NORMAL_B
    Field useCustomBorderColor:Int = False  ' True if user set custom border color
    
    ' Background color (shown when no image or image has transparency)
    Field red:Int = 30
    Field green:Int = 30
    Field blue:Int = 40

    ' =========================================================================
    '                         CONSTRUCTOR
    ' =========================================================================
    
    Method New(x:Int, y:Int, w:Int, h:Int, img:TImage = Null)
        Super.New(x, y, w, h)
        image = img
        
        red = borderR
        green = borderG
        blue = borderB
    End Method

    ' =========================================================================
    '                         DRAWING
    ' =========================================================================
    
    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y
        
        ' Calculate image area (reduced by 2px if border is shown)
        Local imgX:Int = ax
        Local imgY:Int = ay
        Local imgW:Int = rect.w
        Local imgH:Int = rect.h
        
        ' Determine border style based on state
        Local drawStyle:Int = 2  ' Raised by default
        
        If showBorder
            If clickable And pressed
                drawStyle = 3  ' Sunken/pressed
                ' Offset image slightly when pressed for visual feedback
                imgX :+ 1
                imgY :+ 1
            ElseIf style = IMAGEBOX_STYLE_SUNKEN
                drawStyle = 3
            Else
                drawStyle = 2  ' Raised
            EndIf
            
            ' Adjust image area for border
            imgX :+ 2
            imgY :+ 2
            imgW :- 4
            imgH :- 4
        EndIf
        
        ' Draw border/background if enabled
        If showBorder
            ' Determine border color based on state
            Local bR:Int = borderR
            Local bG:Int = borderG
            Local bB:Int = borderB
            
            If clickable
                If pressed
                    If useCustomBorderColor
                        ' Darken custom color for pressed state
                        bR = Max(0, borderR - 30)
                        bG = Max(0, borderG - 30)
                        bB = Max(0, borderB - 30)
                    Else
                        bR = COLOR_BUTTON_PRESSED_R
                        bG = COLOR_BUTTON_PRESSED_G
                        bB = COLOR_BUTTON_PRESSED_B
                    EndIf
                ElseIf hover
                    If useCustomBorderColor
                        ' Lighten custom color for hover state
                        bR = Min(255, borderR + 20)
                        bG = Min(255, borderG + 20)
                        bB = Min(255, borderB + 20)
                    Else
                        bR = COLOR_BUTTON_HOVER_R
                        bG = COLOR_BUTTON_HOVER_G
                        bB = COLOR_BUTTON_HOVER_B
                    EndIf
                EndIf
            EndIf
            
            TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, drawStyle, bR, bG, bB)
        Else
            ' Draw background only (flat)
            TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, 1, red, green, blue)
        EndIf
        
        ' Draw the image if available
        If image <> Null
            ' Set viewport to clip image to widget bounds
            TWidget.GuiSetViewport(imgX, imgY, imgW, imgH)
            
            ' Calculate source and destination rectangles
            Local srcW:Int = ImageWidth(image)
            Local srcH:Int = ImageHeight(image)
            Local destX:Int = imgX
            Local destY:Int = imgY
            Local destW:Int = imgW
            Local destH:Int = imgH
            
            If preserveAspect
                ' Calculate aspect-preserved dimensions
                Local srcAspect:Float = Float(srcW) / Float(srcH)
                Local destAspect:Float = Float(imgW) / Float(imgH)
                
                If srcAspect > destAspect
                    ' Image is wider - fit to width
                    destW = imgW
                    destH = Int(imgW / srcAspect)
                Else
                    ' Image is taller - fit to height
                    destH = imgH
                    destW = Int(imgH * srcAspect)
                EndIf
                
                ' Center the image
                If centerImage
                    destX = imgX + (imgW - destW) / 2
                    destY = imgY + (imgH - destH) / 2
                EndIf
            ElseIf centerImage And (srcW < imgW Or srcH < imgH)
                ' Center small images without scaling
                If srcW < imgW And srcH < imgH
                    destX = imgX + (imgW - srcW) / 2
                    destY = imgY + (imgH - srcH) / 2
                    destW = srcW
                    destH = srcH
                EndIf
            EndIf
            
            ' Draw the image with alpha
            SetBlend ALPHABLEND
            SetAlpha imageAlpha
            SetColor 255, 255, 255
            DrawImageRect(image, destX, destY, destW, destH)
            SetAlpha 1.0
            
            ' Reset viewport
            TWidget.GuiSetViewport(0, 0, GraphicsWidth(), GraphicsHeight())
        EndIf
        
        ' Draw children (if any)
        For Local c:TWidget = EachIn children
            c.Draw(ax, ay)
        Next
    End Method

    ' =========================================================================
    '                         UPDATE / INPUT
    ' =========================================================================
    
    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        If Not enabled Then Return ContainsPoint(mx, my)
        
        Local over:Int = ContainsPoint(mx, my)
        hover = over
        
        ' Only handle click events if clickable
        If Not clickable Then Return over
        
        ' Update children first
        Local rev:TList = New TList
        For Local c:TWidget = EachIn children
            rev.AddFirst(c)
        Next
        For Local c:TWidget = EachIn rev
            Local relX:Int = mx - c.rect.x
            Local relY:Int = my - c.rect.y
            If c.Update(relX, relY) Then Return True
        Next
        
        Local down:Int = GuiMouse.Down()
        Local hit:Int = GuiMouse.Hit()
        
        ' Mouse button pressed while over (and no window is being dragged)
        If over And hit And draggedWindow = Null
            pressed = True
            clickedOnMe = True
            Local ev:TEvent = New TEvent
            ev.target = Self
            ev.eventType = "Pressed"
            events.AddLast(ev)
            Return True
        EndIf
        
        ' Keep pressed state while mouse button is held and still over
        If down
            pressed = clickedOnMe And over
        EndIf
        
        ' Mouse button released
        If lastDown And Not down
            If over And clickedOnMe
                Local ev:TEvent = New TEvent
                ev.target = Self
                ev.eventType = "Click"
                events.AddLast(ev)
            EndIf
            pressed = False
            clickedOnMe = False
        EndIf
        
        lastDown = down
        
        ' Reset states when mouse button is no longer down
        If Not down
            lastDown = False
            clickedOnMe = False
        EndIf
        
        Return over And (hit Or (lastDown And Not down))
    End Method

    ' =========================================================================
    '                         PUBLIC API
    ' =========================================================================
    
    ' Set the image to display
    Method SetImage(img:TImage)
        image = img
    End Method
    
    ' Get the current image
    Method GetImage:TImage()
        Return image
    End Method
    
    ' Load image from file
    Method LoadFromFile:Int(path:String, flags:Int = -1)
        image = LoadImage(path, flags)
        Return image <> Null
    End Method
    
    ' Clear the image
    Method ClearImage()
        image = Null
    End Method
    
    ' Set border visibility
    Method SetShowBorder(show:Int)
        showBorder = show
    End Method
    
    ' Set border style
    Method SetBorderStyle(newStyle:Int)
        style = newStyle
    End Method
    
    ' Set border color
    Method SetBorderColor(r:Int, g:Int, b:Int)
        borderR = r
        borderG = g
        borderB = b
        red = r
        green = g
        blue = b
        useCustomBorderColor = True
    End Method
    
    ' Alias for SetBorderColor (API consistency with other widgets)
    Method SetColor(r:Int, g:Int, b:Int)
        SetBorderColor(r, g, b)
    End Method
    
    ' Reset border color to default
    Method ResetBorderColor()
        borderR = COLOR_BUTTON_NORMAL_R
        borderG = COLOR_BUTTON_NORMAL_G
        borderB = COLOR_BUTTON_NORMAL_B
        red = borderR
        green = borderG
        blue = borderB
        useCustomBorderColor = False
    End Method
    
    ' Alias for ResetBorderColor (API consistency with other widgets)
    Method ResetColor()
        ResetBorderColor()
    End Method
    
    ' Set background color
    Method SetBackgroundColor(r:Int, g:Int, b:Int)
        red = r
        green = g
        blue = b
    End Method
    
    ' Enable/disable click handling
    Method SetClickable(canClick:Int)
        clickable = canClick
    End Method
    
    ' Check if clickable
    Method IsClickable:Int()
        Return clickable
    End Method
    
    ' Set aspect ratio preservation
    Method SetPreserveAspect(preserve:Int)
        preserveAspect = preserve
    End Method
    
    ' Set image centering
    Method SetCenterImage(center:Int)
        centerImage = center
    End Method
    
    ' Set image transparency (0.0 to 1.0)
    Method SetImageAlpha(alpha:Float)
        imageAlpha = alpha
        If imageAlpha < 0.0 Then imageAlpha = 0.0
        If imageAlpha > 1.0 Then imageAlpha = 1.0
    End Method
    
    ' Get image alpha
    Method GetImageAlpha:Float()
        Return imageAlpha
    End Method

    ' =========================================================================
    '                         EVENT HANDLING
    ' =========================================================================
    
    ' Check if clicked (press + release)
    Method WasClicked:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "Click" Then Return True
        Next
        Return False
    End Method
    
    ' Check if just pressed
    Method WasPressed:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "Pressed" Then Return True
        Next
        Return False
    End Method
    
    ' Check if mouse is hovering
    Method IsHovered:Int()
        Return hover
    End Method
    
    ' Check if currently pressed
    Method IsPressed:Int()
        Return pressed
    End Method
    
    ' Clear all events
    Method ClearEvents()
        events.Clear()
    End Method
End Type
