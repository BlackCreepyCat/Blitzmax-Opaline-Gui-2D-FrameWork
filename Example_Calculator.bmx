' =============================================================================
'              Simple GUI Calculator Demo - BlitzMax NG (By Eagle54 2026)
' =============================================================================
' Opaline UI - Simple GUI Framework
' https://github.com/BlackCreepyCat
' =============================================================================

SuperStrict
Import BRL.GLMax2D
Import BRL.LinkedList

Include "opaline/gui_opaline.bmx"

' Create graphics window
Graphics 1280, 720, 0

' init vars
Global var_a:Int = 0, var_b:Int = 0, var_result:Int = 0, var_err:Int = 0
Global str_a:String = "", str_b:String = ""
Global str_ope:String = "", str_equ:String = ""
Global tasksequence:Int = 0, str_result:String = ""

' Initialize GUI system
TWidget.GuiInit()

' Create root container
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

' Create a window
Local win:TWindow = New TWindow(475, 100, 235, 350, "My Calculator",false)
win.SetResizable(False)
root.AddChild(win)

'==============
'BUTTONS GADGET
'==============

' size & space between button gadgets, "a grid-like ..."
Const STARTX:Int = 20
Const STARTY:Int = 20
Const SPACEXY:Int = 10
Const SIZEXY:Int = 40

' Add buttons to the window
Local btn7:TButton = New TButton(STARTX + 0 * (SPACEXY + SIZEXY), STARTY + 0 * (SPACEXY + SIZEXY), SIZEXY, SIZEXY, "7")
Local btn8:TButton = New TButton(STARTX + 1 * (SPACEXY + SIZEXY), STARTY + 0 * (SPACEXY + SIZEXY), SIZEXY, SIZEXY, "8")
Local btn9:TButton = New TButton(STARTX + 2 * (SPACEXY + SIZEXY), STARTY + 0 * (SPACEXY + SIZEXY), SIZEXY, SIZEXY, "9")
Local btn4:TButton = New TButton(STARTX + 0 * (SPACEXY + SIZEXY), STARTY + 1 * (SPACEXY + SIZEXY), SIZEXY, SIZEXY, "4")
Local btn5:TButton = New TButton(STARTX + 1 * (SPACEXY + SIZEXY), STARTY + 1 * (SPACEXY + SIZEXY), SIZEXY, SIZEXY, "5")
Local btn6:TButton = New TButton(STARTX + 2 * (SPACEXY + SIZEXY), STARTY + 1 * (SPACEXY + SIZEXY), SIZEXY, SIZEXY, "6")
Local btn1:TButton = New TButton(STARTX + 0 * (SPACEXY + SIZEXY), STARTY + 2 * (SPACEXY + SIZEXY), SIZEXY, SIZEXY, "1")
Local btn2:TButton = New TButton(STARTX + 1 * (SPACEXY + SIZEXY), STARTY + 2 * (SPACEXY + SIZEXY), SIZEXY, SIZEXY, "2")
Local btn3:TButton = New TButton(STARTX + 2 * (SPACEXY + SIZEXY), STARTY + 2 * (SPACEXY + SIZEXY), SIZEXY, SIZEXY, "3")
Local btn0:TButton = New TButton(STARTX + 0 * (SPACEXY + SIZEXY), STARTY + 3 * (SPACEXY + SIZEXY), SIZEXY, SIZEXY, "0")
Local btnequ:TButton = New TButton(STARTX + 1 * (SPACEXY + SIZEXY), STARTY + 3 * (SPACEXY + SIZEXY), SIZEXY, SIZEXY, "=")
Local btnclr:TButton = New TButton(STARTX + 2 * (SPACEXY + SIZEXY), STARTY + 3 * (SPACEXY + SIZEXY), SIZEXY, SIZEXY, "CLR")

Local btnadd:TButton = New TButton(STARTX + 3 * (SPACEXY + SIZEXY), STARTY + 0 * (SPACEXY + SIZEXY), SIZEXY, SIZEXY, "+")
Local btnsub:TButton = New TButton(STARTX + 3 * (SPACEXY + SIZEXY), STARTY + 1 * (SPACEXY + SIZEXY), SIZEXY, SIZEXY, "-")
Local btnmul:TButton = New TButton(STARTX + 3 * (SPACEXY + SIZEXY), STARTY + 2 * (SPACEXY + SIZEXY), SIZEXY, SIZEXY, "*")
Local btndiv:TButton = New TButton(STARTX + 3 * (SPACEXY + SIZEXY), STARTY + 3 * (SPACEXY + SIZEXY), SIZEXY, SIZEXY, "/")

win.AddChild(btn0)
win.AddChild(btn1)
win.AddChild(btn2)
win.AddChild(btn3)
win.AddChild(btn4)
win.AddChild(btn5)
win.AddChild(btn6)
win.AddChild(btn7)
win.AddChild(btn8)
win.AddChild(btn9)
win.AddChild(btnequ)
win.AddChild(btnclr)

win.AddChild(btnadd)
win.AddChild(btnsub)
win.AddChild(btnmul)
win.AddChild(btndiv)

'===================================
'STATUS PANEL GADGET

' --- Status panel (sunken style) ---
Local statusPanel:TPanel = New TPanel(STARTX + 0 * (SPACEXY + SIZEXY), STARTY + 5 * (SPACEXY + SIZEXY),  5 * SIZEXY - 10, SIZEXY, "", PANEL_STYLE_SUNKEN)
statusPanel.SetAnchors(ANCHOR_LEFT | ANCHOR_RIGHT)  ' S'étire horizontalement, position Y fixe

win.AddChild(statusPanel)

'===================================
'LABEL GADGET

Local lbl:TLabel = New TLabel(10 + STARTX + 0 * (SPACEXY + SIZEXY), STARTY + 5 * (SPACEXY + SIZEXY),  5 * SIZEXY - 10, SIZEXY, "Text", LABEL_ALIGN_LEFT)
lbl.SetColor(255, 200, 100)  ' Set text color
lbl.SetAnchors(ANCHOR_LEFT | ANCHOR_TOP | ANCHOR_RIGHT)
lbl.SetText(str_result)  ' Change text

win.AddChild(lbl)

'===================================
' Reset vars Func
Function Reset(lbl:TLabel)
  str_a = ""
  str_b = ""
  str_ope = ""
  str_equ = ""
  str_result = ""
  lbl.SetText(str_result)
  var_a = 0
  var_b = 0
  var_result = 0
  var_err = 0
  tasksequence = 0
End Function

'===================================
' Main loop
While Not AppTerminate() And Not KeyHit(KEY_ESCAPE)
    Cls
    TWidget.GuiRefresh()
    
    ' Reset calculator
    If btnclr.wasclicked()
        Print "Button CLR clicked!"
        Reset(lbl)
    EndIf

    ' ==========================================
    ' Get first arg <0>
    If btn0.wasclicked()
        If tasksequence = 2 Then Reset(lbl)
        If tasksequence = 0
          Print "Button <0> clicked!"
          str_a = str_a + "0"
          str_result = str_result + "0"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' Get first arg <1>
    If btn1.wasclicked()
        If tasksequence = 2 Then Reset(lbl)
        If tasksequence = 0
          Print "Button <1> clicked!"
          str_a = str_a + "1"
          str_result = str_result + "1"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' Get first arg <2>
    If btn2.wasclicked()
        If tasksequence = 2 Then Reset(lbl)
        If tasksequence = 0
          Print "Button <2> clicked!"
          str_a = str_a + "2"
          str_result = str_result + "2"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' Get first arg <3>
    If btn3.wasclicked()
        If tasksequence = 2 Then Reset(lbl)
        If tasksequence = 0
          Print "Button <3> clicked!"
          str_a = str_a + "3"
          str_result = str_result + "3"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' Get first arg <4>
    If btn4.wasclicked()
        If tasksequence = 2 Then Reset(lbl)
        If tasksequence = 0
          Print "Button <4> clicked!"
          str_a = str_a + "4"
          str_result = str_result + "4"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' Get first arg <5>
    If btn5.wasclicked()
        If tasksequence = 2 Then Reset(lbl)
        If tasksequence = 0
          Print "Button <5> clicked!"
          str_a = str_a + "5"
          str_result = str_result + "5"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' Get first arg <6>
    If btn6.wasclicked()
        If tasksequence = 2 Then Reset(lbl)
        If tasksequence = 0
          Print "Button <6> clicked!"
          str_a = str_a + "6"
          str_result = str_result + "6"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' Get first arg <7>
    If btn7.wasclicked()
        If tasksequence = 2 Then Reset(lbl)
        If tasksequence = 0
          Print "Button <7> clicked!"
          str_a = str_a + "7"
          str_result = str_result + "7"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' Get first arg <8>
    If btn8.wasclicked()
        If tasksequence = 2 Then Reset(lbl)
        If tasksequence = 0
          Print "Button <8> clicked!"
          str_a = str_a + "8"
          str_result = str_result + "8"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' Get first arg <9>
    If btn9.wasclicked()
        If tasksequence = 2 Then Reset(lbl)
        If tasksequence = 0
          Print "Button <9> clicked!"
          str_a = str_a + "9"
          str_result = str_result + "9"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' ==========================================
    ' Get second arg <0>
    If btn0.wasclicked()
        If tasksequence = 1
          Print "Button <0> clicked!"
          str_b = str_b + "0"
          str_result = str_result + "0"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' Get second arg <1>
    If btn1.wasclicked()
        If tasksequence = 1
          Print "Button <1> clicked!"
          str_b = str_b + "1"
          str_result = str_result + "1"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' Get second arg <2>
    If btn2.wasclicked()
        If tasksequence = 1
          Print "Button <2> clicked!"
          str_b = str_b + "2"
          str_result = str_result + "2"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' Get second arg <3>
    If btn3.wasclicked()
        If tasksequence = 1
          Print "Button <3> clicked!"
          str_b = str_b + "3"
          str_result = str_result + "3"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' Get second arg <4>
    If btn4.wasclicked()
        If tasksequence = 1
          Print "Button <4> clicked!"
          str_b = str_b + "4"
          str_result = str_result + "4"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' Get second arg <5>
    If btn5.wasclicked()
        If tasksequence = 1
          Print "Button <5> clicked!"
          str_b = str_b + "5"
          str_result = str_result + "5"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' Get second arg <6>
    If btn6.wasclicked()
        If tasksequence = 1
          Print "Button <6> clicked!"
          str_b = str_b + "6"
          str_result = str_result + "6"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' Get second arg <7>
    If btn7.wasclicked()
        If tasksequence = 1
          Print "Button <7> clicked!"
          str_b = str_b + "7"
          str_result = str_result + "7"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' Get second arg <8>
    If btn8.wasclicked()
        If tasksequence = 1
          Print "Button <8> clicked!"
          str_b = str_b + "8"
          str_result = str_result + "8"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' Get second arg <9>
    If btn9.wasclicked()
        If tasksequence = 1
          Print "Button <9> clicked!"
          str_b = str_b + "9"
          str_result = str_result + "9"
          Print str_result
          lbl.SetText(str_result)
        EndIf
    EndIf

    ' ==========================================
    ' Get operator <+>
    If btnadd.wasclicked()
        If tasksequence = 0
          Print "Button <+> clicked!"
          str_ope = "+"
          str_result = str_a + str_ope
          Print str_result
          lbl.SetText(str_result)
          var_a = str_a.ToInt()
          tasksequence = 1
        EndIf
    EndIf

    ' Get operator <->
    If btnsub.wasclicked()
        If tasksequence = 0
          Print "Button <-> clicked!"
          str_ope = "-"
          str_result = str_a + str_ope
          Print str_result
          lbl.SetText(str_result)
          var_a = str_a.ToInt()
          tasksequence = 1
        EndIf
    EndIf

    ' Get operator <*>
    If btnmul.wasclicked()
        If tasksequence = 0
          Print "Button <*> clicked!"
          str_ope = "*"
          str_result = str_a + str_ope
          Print str_result
          lbl.SetText(str_result)
          var_a = str_a.ToInt()
          tasksequence = 1
        EndIf
    EndIf

    ' Get operator </>
    If btndiv.wasclicked()
        If tasksequence = 0
          Print "Button </> clicked!"
          str_ope = "/"
          str_result = str_a + str_ope
          Print str_result
          lbl.SetText(str_result)
          var_a = str_a.ToInt()
          tasksequence = 1
        EndIf
    EndIf

    ' ==========================================
    ' Get operator <=>
    If btnequ.wasclicked()
        If tasksequence = 1
          Print "Button <=> clicked!"
          var_b = str_b.ToInt()

          Select str_ope
            Case "+"
              var_result = var_a + var_b
            Case "-"
              var_result = var_a - var_b
            Case "*"
              var_result = var_a * var_b
            Case "/"
              If var_b = 0 Then
                var_err = 1
              Else
                var_result = var_a / var_b
              End If
          End Select

          If var_err = 0 Then
            str_equ = "="
            str_result = str_result + str_equ + String.FromInt(var_result)
          Else
            str_result = "ERROR!"
          End If
          Print str_result
          lbl.SetText(str_result)
          tasksequence = 2
        EndIf
    EndIf

    TWidget.GuiClearEvents()

      ' Draw instructions
    SetColor 255, 166, 0
    DrawText "Calculator Demo By Eagle54 2026 - Press ESC to exit", 10, 10

    Flip
Wend