' =============================================================================
'                          CORE STRUCTURES
' =============================================================================
' Base structures used by all GUI components
' =============================================================================

' Rectangle structure for widget positioning and sizing
Type TRect
    Field x:Int, y:Int, w:Int, h:Int
End Type

' Event structure for widget interactions
Type TEvent
    Field target:TWidget
    Field eventType:String
End Type

' =============================================================================
'                        ABSTRACT WIDGET CLASS
' =============================================================================
' Base class for all GUI widgets
Type TWidget Abstract
    Field rect:TRect = New TRect
    Field children:TList = New TList  ' Child widgets
    Field parent:TWidget              ' Parent widget

    ' Custom color for this widget (if different from theme)
    Field red:Int 
    Field green:Int
    Field blue:Int

    Method New(x:Int, y:Int, w:Int, h:Int)
        rect.x = x
        rect.y = y
        rect.w = w
        rect.h = h
    End Method

    ' Add a child widget to this widget
    Method AddChild(child:TWidget)
        If child = Null Return
        If child.parent Then child.parent.children.Remove(child)
        children.AddLast(child)
        child.parent = Self
    End Method

    ' Bring a child widget to the front (z-order)
    Method BringToFront(child:TWidget)
        If child = Null Or Not children.Contains(child) Return
        children.Remove(child)
        children.AddLast(child)
    End Method

    ' Helper: Check if a point is inside this widget's rectangle
    Method ContainsPoint:Int(x:Int, y:Int)
        Return x >= 0 And x < rect.w And y >= 0 And y < rect.h
    End Method

    ' Abstract methods - must be implemented by subclasses
    Method Draw(px:Int=0, py:Int=0) Abstract
    Method Update:Int(mx:Int, my:Int) Abstract

	' Function to constraint the viewport
	Function GuiSetViewport(Px:Int,Py:Int,Tx:Int,Ty:Int)
		SetViewport(Px,Py,Tx,Ty)
	End Function
    
    ' Function to draw gui text
    Function GuiDrawText(Px:Int,Py:Int,caption:String, style:Int, red:Int,green:Int,blue:Int)
    
        Select style
        
        ' Normal
        Case 1

            SetColor red,green,blue
            DrawText caption, px,py
        
        ' Shadowed
        Case 2
            
            'shadow
            SetColor 5,5,5
            DrawText caption, px+1,py+1
                    
            SetColor red,green,blue
            DrawText caption, px,py
                    
        End Select
        
        ' Reset color to white after drawing text (good practice)
        SetColor 255, 255, 255
        
    End Function
    
    ' Actually draws a filled rectangle with optional embossed/pressed styles
    Function GuiDrawRect(px:Int,py:Int,tx:Int,ty:Int , style:Int, red:Int,green:Int,blue:Int)
        Select Style
        Case 1
            ' Flat filled rectangle
            SetColor red,green,blue
            DrawRect px,py,tx,ty
        
        ' normal emboss
        Case 2
            ' Raised/embossed look
            SetColor red,green,blue
            DrawRect px,py,tx,ty

            SetColor red/2,green/2,blue/2	
            DrawLine px,py+ty,px+tx,py+ty
            DrawLine px+tx,py,px+tx,py+ty	
                        
            SetColor red*2,green*2,blue*2	
            DrawLine px,py,px+tx,py
            DrawLine px,py,px,py+ty	
        
        'clicked emboss	
        Case 3
            ' Pressed/clicked look (inverted bevel)
            SetColor red,green,blue
            DrawRect px,py,tx,ty

            SetColor red*2,green*2,blue*2	
            DrawLine px,py+ty,px+tx,py+ty
            DrawLine px+tx,py,px+tx,py+ty	
                        
            SetColor red/2,green/2,blue/2	
            DrawLine px,py,px+tx,py
            DrawLine px,py,px,py+ty		
        End Select
        
        ' Reset color to white after drawing (good practice)
        SetColor 255, 255, 255
        
    End Function
    
    ' Actually draws an oval/circle with optional shadow style
    Function GuiDrawOval(px:Int,py:Int,RadiusX:Int,RadiusY:Int, style:Int, red:Int,green:Int,blue:Int)
        Select Style
        Case 1
            ' Flat filled oval
            SetColor red,green,blue
            DrawOval px, py, RadiusX,RadiusY
        
        ' normal shadowed
        Case 2
            ' Shadowed effect (simple offset shadow)
            SetColor 5,5,5
            DrawOval px+2, py+2, RadiusX,RadiusY	
            
            SetColor red,green,blue
            DrawOval px, py, RadiusX,RadiusY	
        End Select
        
        ' Reset color to white after drawing
        SetColor 255, 255, 255
        
    End Function
End Type