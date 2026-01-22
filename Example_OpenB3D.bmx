' =============================================================================
' 						Simple GUI Framework - BlitzMax NG
' 							OPENB3D DEMO : Opaline UI
' 		By Creepy Cat (C)2025/2026 : https://github.com/BlackCreepyCat
' =============================================================================


' NOTE: Unknow bug! when the taskbar is folded => the windows titlebar diseapear
' And re-appear when the taskbat is open ? The same example witout openB3D do
' Not generate it, i don't know why....

Strict

Import Openb3d.B3dglgraphics

Include "opaline/gui_opaline.bmx"

Graphics3D 1920,1080,0,2

Local camera:TCamera=CreateCamera()
CameraClsColor camera,32,32,64
PositionEntity camera,0,0,-6

AmbientLight 128,128,128

Local light:TLight=CreateLight(2)
PositionEntity light,6,6,-6
PointEntity light,camera

Local cube1:TMesh=CreateCube()
EntityColor cube1,220,0,0
PositionEntity cube1,0,0,0

' Init the GUI
TWidget.GuiInit()

' Create root container
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

' =============================================================
'                         GUI BUILDING
' =============================================================
Local win:TWindow = New TWindow(50, 50, 700, 500, "Window Demo", False, True, True)
root.AddChild win

Local title:TLabel = New TLabel(20, 20, 660, 24, "Opaline GUI - Button Demonstration", LABEL_ALIGN_CENTER)
title.SetColor(255, 220, 100)
win.AddChild title

Local win2:TWindow = New TWindow(350, 350, 700, 500, "Window Demo", False, True, True)
root.AddChild win2



Local btn1:TButton = New TButton(20, 20, 180, 38, "Quit Opaline")
btn1.SetEnabled(True)
win.AddChild btn1


While Not KeyDown(KEY_ESCAPE)

	' control cube
	TurnEntity cube1,5,6,2
		

	
	UpdateWorld 
	RenderWorld
	
	BeginMax2D()

	TWidget.GuiRefresh()



	ClearAllEvents(root)
	
	EndMax2D()
	
	Flip
Wend
End
