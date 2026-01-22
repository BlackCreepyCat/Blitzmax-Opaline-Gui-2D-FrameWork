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

Graphics3D 1024,768,0,2

Local camera:TCamera=CreateCamera()
CameraClsColor camera,32,32,64
PositionEntity camera,0,0,-5

AmbientLight 0,0,0

Local light:TLight=CreateLight(2)
PositionEntity light,5,5,-5

Local light2:TLight=CreateLight(2)
PositionEntity light2,-5,-5,-5


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
Local win:TWindow = New TWindow(50, 50, 530, 300, "Window Demo", False, True, True)
root.AddChild win

Local title:TLabel = New TLabel(20, 20, 660, 24, "Opaline GUI - OPENB3D Demonstration", LABEL_ALIGN_CENTER)
title.SetColor(255, 220, 100)
win.AddChild title

Local btn1:TButton = New TButton(20, 20, 180, 38, "Quit Opaline")
btn1.SetEnabled(True)
win.AddChild btn1


While Not KeyDown(KEY_ESCAPE)

	' control cube
	TurnEntity cube1,1,1,1

	UpdateWorld 
	RenderWorld
	
	' return 2 max 2D
	BeginMax2D()

	TWidget.GuiRefresh()
	' Gui check here
	ClearAllEvents(root)
	
	EndMax2D()
	
	Flip
Wend

End
