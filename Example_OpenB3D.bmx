' =============================================================================
' 						Simple GUI Framework - BlitzMax NG
' 							OPENB3D DEMO : Opaline UI
' 		By Creepy Cat (C)2025/2026 : https://github.com/BlackCreepyCat
' =============================================================================
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
Local win:TWindow = New TWindow(50, 50, 430, 400, "Window Demo", False, True, True)
root.AddChild win

' Create a knot rotating
Local volumeKnob:TRotaryKnob = New TRotaryKnob(50, 140, 150, 0.1,11)
volumeKnob.SetKnobColor(60, 100, 180)
volumeKnob.SetIndicatorColor(255, 100, 100)
volumeKnob.SetSnapToTicks(True)
win.AddChild volumeKnob

Local title:TLabel = New TLabel(20, 20, 490, 24, "Opaline GUI - OPENB3D Demonstration", LABEL_ALIGN_CENTER)
title.SetColor(255, 220, 100)
win.AddChild title

Local btn1:TButton = New TButton(20, 60, 180, 38, "Quit Opaline")
btn1.SetEnabled(True)
win.AddChild btn1

' Create a joystick and ADD IT to the window
Local joy:TJoystick = New TJoystick(250, 60, 160)
joy.SetDeadZone(0.15)
joy.SetSnapSpeed(0.4)
joy.SetStickColor(200, 100, 150)
joy.SetStickSize(48)

win.AddChild joy  ' ← IMPORTANT : add the joystick to the window!

' Label to display joystick values
Local lblJoy:TLabel = New TLabel(150, 250, 200, 20, "Joystick: X=0.0 Y=0.0")
lblJoy.SetColor(150, 255, 150)
win.AddChild lblJoy

' OR add it directly to the screen (root):
Local joyScreen:TJoystick = New TJoystick(30, GraphicsHeight() - 200, 160)
joyScreen.SetStickColor(255, 150, 100)
root.AddChild joyScreen  ' Joystick directly on the screen

Local lblJoyScreen:TLabel = New TLabel(600, 180, 150, 20, "Screen Joy: 0.0")
lblJoyScreen.SetColor(255, 200, 100)
root.AddChild lblJoyScreen

While Not KeyDown(KEY_ESCAPE)
	' Control the cube with the joystick
	Local jx:Float = joy.GetX()
	Local jy:Float = joy.GetY()
	
	Local angle:Float = joy.GetAngle()
	Local power:Float = joy.GetMagnitude()
	
	' Use to rotate the cube
	TurnEntity cube1, jy * 2, jx * 2, volumeKnob.GetValue() * 4
	
	moveentity camera, -joyScreen.GetX()/20,0,joyScreen.GetY()/20
	
	' Display values
	lblJoy.SetText("Joy: X=" + Int(jx * 100) / 100.0 + " Y=" + Int(jy * 100) / 100.0)
	'lblJoyScreen.SetText("Screen: " + Int(joyScreen.GetMagnitude() * 100) + "%")
	

	UpdateWorld 
	RenderWorld
	
	' Return to Max2D
	BeginMax2D()
	TWidget.GuiRefresh()
	
	' GUI checks here
	If btn1.WasClicked() Then Exit
	ClearAllEvents(root)
	
	EndMax2D()
	
	Flip
Wend
End
