' =============================================================================
' 					Simple GUI Framework - BlitzMax NG
' 						FRACTAL DEMO : Opaline UI
' By Creepy Cat (C)2025/2026 : https://github.com/BlackCreepyCat
' =============================================================================
SuperStrict

Import BRL.GLMax2D
Import BRL.LinkedList
Import BRL.PNGLoader
Include "opaline/gui_opaline.bmx"

' ====================
' FRACTAL CONSTANTS
' ====================
Global FRACTAL_WIDTH:Int = GraphicsWidth()
Global FRACTAL_HEIGHT:Int = GraphicsHeight()
Const MAX_ITERATIONS:Int = 1024     ' Increased to support deep zooms

' ==================
' GLOBAL VARIABLES
' ==================
Global fractalImage:TImage
Global fractalPixmap:TPixmap
Global mandelbrotData:Double[1920, 1080]    ' Stores smooth iteration count (mu)

' View parameters
Global centerX:Double = -0.5
Global centerY:Double = 0.0
Global zoom:Double = 1.0
Global maxIter:Int = 256                    ' Default starting value

' Palette selection
Global paletteType:Int = 0

' Calculation state
Global needsRecalc:Int = True
Global lastCalcTime:Int = 0

' Lasso zoom selection
Global isSelecting:Int = False
Global selectStartX:Int = 0
Global selectStartY:Int = 0
Global selectEndX:Int = 0
Global selectEndY:Int = 0

' ==============
' INITIALIZATION
' ==============
Graphics 1920, 1080, 0
TWidget.GuiInit()

FRACTAL_WIDTH = GraphicsWidth()
FRACTAL_HEIGHT = GraphicsHeight()

fractalPixmap = CreatePixmap(FRACTAL_WIDTH, FRACTAL_HEIGHT, PF_RGBA8888)
fractalImage = CreateImage(FRACTAL_WIDTH, FRACTAL_HEIGHT)

Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

' ===================
' CONTROL PANEL WINDOW
' ===================
Global winControls:TWindow = New TWindow(20, 20, 380, 780, "Mandelbrot Explorer", True, True, False, True)
winControls.SetResizable(False)
root.AddChild winControls

Local lblTitle:TLabel = New TLabel(20, 10, 340, 30, "Mandelbrot Explorer", LABEL_ALIGN_CENTER)
lblTitle.SetColor(255, 220, 100)
winControls.AddChild lblTitle

Local panelNav:TPanel = New TPanel(20, 50, 340, 120, "Navigation", PANEL_STYLE_RAISED)
winControls.AddChild panelNav

Global btnZoomIn:TButton = New TButton(15, 30, 150, 35, "Zoom In (+)")
btnZoomIn.SetColor(80, 140, 220)
panelNav.AddChild btnZoomIn

Global btnZoomOut:TButton = New TButton(175, 30, 150, 35, "Zoom Out (-)")
btnZoomOut.SetColor(80, 140, 220)
panelNav.AddChild btnZoomOut

Global btnReset:TButton = New TButton(15, 75, 310, 35, "Reset View")
btnReset.SetColor(220, 140, 80)
panelNav.AddChild btnReset

Local panelIter:TPanel = New TPanel(20, 185, 340, 120, "Precision", PANEL_STYLE_RAISED)
winControls.AddChild panelIter

Local lblIter:TLabel = New TLabel(15, 30, 200, 20, "Max iterations:")
lblIter.SetColor(200, 220, 255)
panelIter.AddChild lblIter

Global sliderIter:TSlider = New TSlider(15, 55, 250, 24, 1.0, SLIDER_STYLE_HORIZONTAL)
panelIter.AddChild sliderIter

Global lblIterValue:TLabel = New TLabel(275, 55, 50, 20, "256", LABEL_ALIGN_LEFT)
lblIterValue.SetColor(150, 255, 150)
panelIter.AddChild lblIterValue

Global btnCalculate:TButton = New TButton(15, 85, 310, 30, "Recalculate")
btnCalculate.SetColor(80, 180, 80)
panelIter.AddChild btnCalculate

Local panelPalette:TPanel = New TPanel(20, 320, 340, 220, "Color Palettes", PANEL_STYLE_RAISED)
winControls.AddChild panelPalette

Global radioPaletteGroup:TList = New TList

Global radioClassic:TRadio = New TRadio(20, 35, 20, 20, "Deep Blue", radioPaletteGroup)
radioClassic.selected = True
panelPalette.AddChild radioClassic

Global radioFire:TRadio = New TRadio(20, 70, 20, 20, "Sunset Fire", radioPaletteGroup)
panelPalette.AddChild radioFire

Global radioOcean:TRadio = New TRadio(20, 105, 20, 20, "Ultra Violet", radioPaletteGroup)
panelPalette.AddChild radioOcean

Global radioGray:TRadio = New TRadio(20, 140, 20, 20, "Electric Dreams", radioPaletteGroup)
panelPalette.AddChild radioGray

Global radioCool:TRadio = New TRadio(20, 175, 20, 20, "Cool Mint", radioPaletteGroup)
panelPalette.AddChild radioCool

Local panelInfo:TPanel = New TPanel(20, 555, 340, 160, "Information", PANEL_STYLE_SUNKEN)
winControls.AddChild panelInfo

Local lblCenterXTitle:TLabel = New TLabel(15, 30, 80, 20, "Center X:", LABEL_ALIGN_LEFT)
lblCenterXTitle.SetColor(150, 180, 220)
panelInfo.AddChild lblCenterXTitle
Global lblCenterXValue:TLabel = New TLabel(100, 30, 220, 20, "-0.5", LABEL_ALIGN_LEFT)
lblCenterXValue.SetColor(200, 230, 255)
panelInfo.AddChild lblCenterXValue

Local lblCenterYTitle:TLabel = New TLabel(15, 55, 80, 20, "Center Y:", LABEL_ALIGN_LEFT)
lblCenterYTitle.SetColor(150, 180, 220)
panelInfo.AddChild lblCenterYTitle
Global lblCenterYValue:TLabel = New TLabel(100, 55, 220, 20, "0.0", LABEL_ALIGN_LEFT)
lblCenterYValue.SetColor(200, 230, 255)
panelInfo.AddChild lblCenterYValue

Local lblZoomTitle:TLabel = New TLabel(15, 80, 80, 20, "Zoom:", LABEL_ALIGN_LEFT)
lblZoomTitle.SetColor(150, 180, 220)
panelInfo.AddChild lblZoomTitle
Global lblZoomValue:TLabel = New TLabel(100, 80, 220, 20, "1.0 x", LABEL_ALIGN_LEFT)
lblZoomValue.SetColor(200, 230, 255)
panelInfo.AddChild lblZoomValue

Local lblTimeTitle:TLabel = New TLabel(15, 105, 80, 20, "Time:", LABEL_ALIGN_LEFT)
lblTimeTitle.SetColor(150, 180, 220)
panelInfo.AddChild lblTimeTitle
Global lblTimeValue:TLabel = New TLabel(100, 105, 220, 20, "0 ms", LABEL_ALIGN_LEFT)
lblTimeValue.SetColor(200, 230, 255)
panelInfo.AddChild lblTimeValue

Local lblInstructions:TLabel = New TLabel(15, 130, 310, 20, "Click: zoom | Drag: selection", LABEL_ALIGN_CENTER)
lblInstructions.SetColor(180, 200, 150)
panelInfo.AddChild lblInstructions

winControls.AddStatusSection("Ready to explore infinity", -1, LABEL_ALIGN_CENTER)

' =============================================
' Slider initialization + correct initial display
' =============================================
sliderIter.SetValue(0.125)   ' ≈ 256-300 at startup - adjust as desired
' Force correct initial calculation and display
Local initPercent:Float = sliderIter.GetPercent() / 100.0
maxIter = 32 + Int(initPercent * (2048 - 32))
If maxIter >= 1000
    lblIterValue.SetText( (maxIter / 1000) + "k" )
Else
    lblIterValue.SetText( String(maxIter) )
EndIf

' Initial fractal calculation
CalculateMandelbrot()
Global MouseHitBuf:Int=0   ' Quick & dirty mouse hit buffer - yes, it's crappy :)

' =============================================================================
' MAIN LOOP
' =============================================================================
While Not AppTerminate()
    Cls
  
    If fractalImage
        DrawImage fractalImage, 0, 0
    EndIf
  
    If isSelecting
        TWidget.GuiDrawRect(selectStartX, selectStartY, selectEndX - selectStartX, selectEndY - selectStartY, 0, 100, 200, 255)
    EndIf
  
    HandleLassoSelection()
  
    TWidget.GuiRefresh()
  
    HandleEvents()
  
    If needsRecalc
        CalculateMandelbrot()
        needsRecalc = False
    EndIf
  
    ClearAllEvents(root)
  
    SetColor 179, 255, 0
    DrawText "Mandelbrot Explorer - Click to zoom / Drag for rectangle selection", 10, GraphicsHeight() - 40
    DrawText "Zoom: " + FormatZoom(zoom) + " | Iterations: " + maxIter, 10, GraphicsHeight() - 20
  
    Flip
Wend
End

' ====================================
' LASSO ZOOM SELECTION HANDLING
' ====================================
Function HandleLassoSelection()
    Local overWindow:Int = False
    If winControls.visible
        Local wx:Int = winControls.rect.x
        Local wy:Int = winControls.rect.y
        Local ww:Int = winControls.rect.w
        Local wh:Int = winControls.rect.h
      
        If MouseX() >= wx And MouseX() < wx + ww And MouseY() >= wy And MouseY() < wy + wh + TITLEBAR_HEIGHT
            overWindow = True
            MouseHitBuf = 1
        Else
            If MouseHitBuf = 1 Then
                FlushMouse()
                MouseHitBuf = 2
            EndIf
        EndIf
    EndIf
  
    If Not overWindow
        If MouseHit(1) And Not isSelecting
            isSelecting = True
            selectStartX = MouseX()
            selectStartY = MouseY()
            selectEndX = MouseX()
            selectEndY = MouseY()
        EndIf
      
        If isSelecting And MouseDown(1)
            selectEndX = MouseX()
            selectEndY = MouseY()
        EndIf
      
        If isSelecting And Not MouseDown(1)
            isSelecting = False
          
            Local minX:Int = Min(selectStartX, selectEndX)
            Local maxX:Int = Max(selectStartX, selectEndX)
            Local minY:Int = Min(selectStartY, selectEndY)
            Local maxY:Int = Max(selectStartY, selectEndY)
          
            Local selWidth:Int = maxX - minX
            Local selHeight:Int = maxY - minY
          
            If selWidth < 10 And selHeight < 10
                ' ZoomOnPoint(selectStartX, selectStartY, 2.0) ← uncomment if you want single-click zoom
            Else
                ZoomOnArea(minX, minY, maxX, maxY)
            EndIf
        EndIf
    Else
        If isSelecting
            isSelecting = False
        EndIf
    EndIf
End Function

' ==============================
' ZOOM FUNCTIONS
' ==============================
Function ZoomOnPoint(pixelX:Int, pixelY:Int, zoomFactor:Double)
    Local aspect:Double = Double(FRACTAL_WIDTH) / Double(FRACTAL_HEIGHT)
    Local scaleX:Double = 4.0 / zoom * aspect
    Local scaleY:Double = 4.0 / zoom
  
    centerX = centerX + (pixelX - FRACTAL_WIDTH/2) * scaleX / FRACTAL_WIDTH
    centerY = centerY + (pixelY - FRACTAL_HEIGHT/2) * scaleY / FRACTAL_HEIGHT
  
    zoom :* zoomFactor
    needsRecalc = True
    UpdateInfoLabels()
    winControls.SetStatusSection(0, "Zoom applied!")
End Function

Function ZoomOnArea(x1:Int, y1:Int, x2:Int, y2:Int)
    Local centerPixelX:Int = (x1 + x2) / 2
    Local centerPixelY:Int = (y1 + y2) / 2
  
    Local aspect:Double = Double(FRACTAL_WIDTH) / Double(FRACTAL_HEIGHT)
    Local scaleX:Double = 4.0 / zoom * aspect
    Local scaleY:Double = 4.0 / zoom
  
    Local newCenterX:Double = centerX + (centerPixelX - FRACTAL_WIDTH/2) * scaleX / FRACTAL_WIDTH
    Local newCenterY:Double = centerY + (centerPixelY - FRACTAL_HEIGHT/2) * scaleY / FRACTAL_HEIGHT
  
    Local selWidth:Int = Abs(x2 - x1)
    Local selHeight:Int = Abs(y2 - y1)
  
    Local zoomFactorX:Double = Double(FRACTAL_WIDTH) / Double(selWidth)
    Local zoomFactorY:Double = Double(FRACTAL_HEIGHT) / Double(selHeight)
    Local zoomFactor:Double = Min(zoomFactorX, zoomFactorY)
  
    centerX = newCenterX
    centerY = newCenterY
    zoom :* zoomFactor
  
    needsRecalc = True
    UpdateInfoLabels()
    winControls.SetStatusSection(0, "Area zoom applied!")
End Function

' ======================
' EVENT HANDLING
' ======================
Function HandleEvents()
    If btnZoomIn.WasClicked()
        zoom :* 2.0
        needsRecalc = True
        UpdateInfoLabels()
        winControls.SetStatusSection(0, "Zoom in ✓")
    EndIf
  
    If btnZoomOut.WasClicked()
        zoom :/ 2.0
        needsRecalc = True
        UpdateInfoLabels()
        winControls.SetStatusSection(0, "Zoom out ✓")
    EndIf
  
    If btnReset.WasClicked()
        centerX = -0.5
        centerY = 0.0
        zoom = 1.0
        maxIter = 256
        sliderIter.SetValue(0.125)   ' Reset to ≈256-300
        needsRecalc = True
        UpdateInfoLabels()
        winControls.SetStatusSection(0, "View reset ✓")
    EndIf
  
    If sliderIter.ValueChanged()
        Local rawPercent:Float = sliderIter.GetPercent()   ' Returns 0..100
        Local norm:Float = rawPercent / 100.0              ' Normalize to 0..1
        norm = Min(1.0, Max(0.0, norm))
    
        Local minIter:Int = 32
        Local maxIterPossible:Int = 2048                   ' Change to 4096 or 8192 if desired
    
        maxIter = minIter + Int(norm * (maxIterPossible - minIter + 0.999))   ' +0.999 ensures we reach the max
    
        If maxIter >= 1000
            lblIterValue.SetText( (maxIter / 1000) + "k" )
        Else
            lblIterValue.SetText( String(maxIter) )
        EndIf
    
        needsRecalc = True
        UpdateInfoLabels()
        winControls.SetStatusSection(0, "Precision: " + maxIter)
    EndIf
  
    If radioClassic.WasSelected()
        paletteType = 0
        needsRecalc = True
        winControls.SetStatusSection(0, "Palette: Deep Blue")
    EndIf
  
    If radioFire.WasSelected()
        paletteType = 1
        needsRecalc = True
        winControls.SetStatusSection(0, "Palette: Sunset Fire")
    EndIf
  
    If radioOcean.WasSelected()
        paletteType = 2
        needsRecalc = True
        winControls.SetStatusSection(0, "Palette: Ultra Violet")
    EndIf
  
    If radioGray.WasSelected()
        paletteType = 3
        needsRecalc = True
        winControls.SetStatusSection(0, "Palette: Electric Dreams")
    EndIf
  
    If radioCool.WasSelected()
        paletteType = 4
        needsRecalc = True
        winControls.SetStatusSection(0, "Palette: Cool Mint")
    EndIf
  
    If btnCalculate.WasClicked()
        needsRecalc = True
        winControls.SetStatusSection(0, "Recalculation in progress...")
    EndIf
End Function

' ==============================
' FRACTAL CALCULATION - SMOOTH COLORING
' ==============================
Function CalculateMandelbrot()
    Local startTime:Int = MilliSecs()
    winControls.SetStatusSection(0, "Calculation in progress...")
  
    Local aspect:Double = Double(FRACTAL_WIDTH) / Double(FRACTAL_HEIGHT)
    Local scaleX:Double = 4.0 / zoom * aspect
    Local scaleY:Double = 4.0 / zoom
  
    For Local py:Int = 0 Until FRACTAL_HEIGHT
        For Local px:Int = 0 Until FRACTAL_WIDTH
            Local x0:Double = centerX + (px - FRACTAL_WIDTH/2.0) * scaleX / FRACTAL_WIDTH
            Local y0:Double = centerY + (py - FRACTAL_HEIGHT/2.0) * scaleY / FRACTAL_HEIGHT
          
            Local x:Double = 0.0
            Local y:Double = 0.0
            Local iter:Int = 0
          
            While (x*x + y*y <= 4.0) And (iter < maxIter)
                Local xtemp:Double = x*x - y*y + x0
                y = 2*x*y + y0
                x = xtemp
                iter :+ 1
            Wend
          
            Local mu:Double
            If iter = maxIter
                mu = maxIter
            Else
                ' Smooth coloring - classic log-log formula for continuous gradient
                Local zn:Double = Sqr(x*x + y*y)
                If zn > 0 Then
                    Local nu:Double = Log(Log(zn) / Log(2.0)) / Log(2.0)
                    mu = iter + 1.0 - nu
                Else
                    mu = iter
                EndIf
            EndIf
          
            mandelbrotData[px, py] = mu
        Next
    Next
  
    ConvertToImage()
  
    lastCalcTime = MilliSecs() - startTime
    winControls.SetStatusSection(0, "Calculation finished (" + lastCalcTime + " ms)")
    UpdateInfoLabels()
End Function

' ===================
' IMAGE CONVERSION
' ===================
Function ConvertToImage()
    fractalPixmap.ClearPixels(0)
  
    For Local py:Int = 0 Until FRACTAL_HEIGHT
        For Local px:Int = 0 Until FRACTAL_WIDTH
            Local mu:Double = mandelbrotData[px, py]
            Local color:Int
          
            If mu >= maxIter
                color = $FF000000   ' Black for inside the set
            Else
                color = GetSmoothColor(mu, maxIter, paletteType)
            EndIf
          
            WritePixel(fractalPixmap, px, py, color)
        Next
    Next
  
    If fractalImage Then fractalImage = Null
    fractalImage = LoadImage(fractalPixmap)
End Function

' ==================
' BRIGHTER COLOR PALETTES
' ==================
Function GetSmoothColor:Int(mu:Double, maxIt:Int, pal:Int)
    If mu >= maxIt Return $FF000000
  
    Local t:Float = mu / maxIt
  
    Local r:Int, g:Int, b:Int
    Local boost:Float = 1.35   ' Global brightness boost (1.2 = subtle, 1.6 = very bright)
  
    Select pal
        Case 0 ' Deep Blue / Cyan - brighter version
            r = Int( (9   * (1-t) * t^3           ) * 255 * boost )
            g = Int( (22  * (1-t)^2 * t^2         ) * 255 * boost )
            b = Int( (35  * (1-t)^1.5 * t^2.5     ) * 255 * boost )
      
        Case 1 ' Sunset Fire - warmer and more visible
            r = Int( (45 * (1-t)^2.5 * t^1.8     ) * 255 * boost )
            g = Int( (28 * (1-t)^2   * t^2.2     ) * 255 * boost )
            b = Int( (12 * (1-t)^1.5 * t^3       ) * 255 * boost )
      
        Case 2 ' Ultra Violet / Pink - more punchy
            r = Int( (220 * t^4.2                ) * boost )
            g = Int( (110 * (1-t)^2.5 * t^3      ) * boost )
            b = Int( (240 * (1-t)^1.8 * t^3.5    ) * boost )
      
        Case 3 ' Electric Dreams - neon more vivid
            r = Int( (18  * (1-t)   * t^3        ) * 255 * boost )
            g = Int( (38  * (1-t)^1.5 * t^2.5    ) * 255 * boost )
            b = Int( (22  * (1-t)^2   * t^4      ) * 255 * boost )
      
        Case 4 ' Cool Mint - fresher and brighter
            r = Int( (15  * t^3.5                ) * 255 * boost )
            g = Int( (220 * (1-t)^0.8 * t^1.8    ) * boost )
            b = Int( (210 * (1-t)^1.2 * t^2.5    ) * boost )
    End Select
  
    ' Prevent overflow
    r = Min(255, Max(0, r))
    g = Min(255, Max(0, g))
    b = Min(255, Max(0, b))
  
    Return $FF000000 | (r Shl 16) | (g Shl 8) | b
End Function

' ========================
' UTILITY FUNCTIONS
' ========================
Function UpdateInfoLabels()
    lblCenterXValue.SetText(FormatDouble(centerX))
    lblCenterYValue.SetText(FormatDouble(centerY))
    lblZoomValue.SetText(FormatZoom(zoom))
    lblTimeValue.SetText(lastCalcTime + " ms")
End Function

Function FormatDouble:String(value:Double)
    If Abs(value) < 0.0001 And value <> 0.0
        Local str:String = String(value)
        If str.Length > 12 Then str = str[..12]
        Return str
    Else
        Local str:String = String(value)
        If str.Length > 10 Then str = str[..10]
        Return str
    EndIf
End Function

Function FormatZoom:String(value:Double)
    If value >= 1000000000.0
        Return String(Int(value/1000000000)) + "G x"
    ElseIf value >= 1000000.0
        Return String(Int(value/1000000)) + "M x"
    ElseIf value >= 1000.0
        Return String(Int(value/1000)) + "K x"
    Else
        Local str:String = String(value)
        If str.Length > 8 Then str = str[..8]
        Return str + " x"
    EndIf
End Function