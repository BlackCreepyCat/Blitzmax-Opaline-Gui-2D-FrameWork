' =============================================================================
'                              BACKGROUND CLASS
' =============================================================================
' 				Allow you to make some cool animated background
' =============================================================================
Const BLOB_NUMBER:Int = 50
Global BLOB_PARTICLES:TBackground[BLOB_NUMBER]

Type TBackground
    Field x:Float
    Field y:Float

    Field vx:Float
    Field vy:Float

    Field angle:Float
	Field rotatespeed:Float
    
    ' Image reference
    Field blobImage:TImage

	' Create the blob instance  
    Method New(blob:TImage)
        Self.blobImage = blob

        x = Rnd(GraphicsWidth())
        y = Rnd(GraphicsHeight())

        vx = Rnd(-2.0, 2.0)
        vy = Rnd(-2.0, 2.0)

        angle = Rnd(360.0)
		rotatespeed = 0.22
    End Method
	
	' Init the background
	Function Init()
		Local blobsprite:TImage = TBackground.CreateImageBlob()

		For Local i:Int = 0 Until BLOB_NUMBER
			BLOB_PARTICLES[i] = New TBackground(blobsprite)
		Next	
	End Function
	
	' Create the blob image
	Function CreateImageBlob:TImage(BLOB_SIZE:Int=512)
		Local blob:TImage = CreateImage(BLOB_SIZE, BLOB_SIZE)

		TWidget.GuiSetViewport(0,0,BLOB_SIZE,BLOB_SIZE) ; Cls

		For Local r:Float = 1 Until BLOB_SIZE Step 0.5
			Local energy:Float = (r * r) / 1024.0
			
			TWidget.GuiDrawOval(Int(r/2), Int(r/2), Int(BLOB_SIZE-r), Int(BLOB_SIZE-r),1, Int(energy), Int(energy), Int(energy))
		Next

		GrabImage(blob, 0, 0)

		TWidget.GuiSetViewport(0,0,GraphicsWidth(),GraphicsHeight())
		MidHandleImage(blob)
		
		Return blob
	End Function
	
	' Refresh the blob background
	Function Refresh()
		SetBlend LIGHTBLEND

		For Local p:TBackground = EachIn BLOB_PARTICLES
			p.Update()
			p.Render()
		Next

		SetBlend SOLIDBLEND
	End Function
	
	' Update the rendering
    Method Update()
        x :+ vx
        y :+ vy
        If x < 0 Or x > GraphicsWidth() Then vx = -vx
        If y < 0 Or y > GraphicsHeight() Then vy = -vy
        angle :+ rotatespeed
    End Method
    
    Method Render()
        Local color_r:Int = 50 ' 1024 - (angle Mod 256)
        Local color_g:Int = 90 ' Min(255, Max(0, 512 - x))
        Local color_b:Int = 150 ' Min(255, Max(0, 512 - y))
        
        SetColor color_r, color_g, color_b

        SetRotation angle
        DrawImage blobImage, x, y
		SetRotation 0
    End Method
End Type