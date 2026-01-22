' =============================================================================
'                    Simple GUI Framework - BlitzMax NG
'                       CONTEXTMENU DEMO : Opaline UI
'       By Creepy Cat (C)2025/2026 : https://github.com/BlackCreepyCat
' =============================================================================
SuperStrict

' Import required BlitzMax modules
Import BRL.GLMax2D
Import BRL.LinkedList

Include "opaline/gui_opaline.bmx"

Graphics 1024,768, 0

' Initialize the GUI
TWidget.GuiInit()

' Creating the animated background
TBackground.Init()

' Create root container
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

' =============================================================
'                       GUI BUILDING
' =============================================================
Local win:TWindow = New TWindow(50, 50, 700, 500, "ContextMenu Demo", False, True, True)
root.AddChild win

Local title:TLabel = New TLabel(20, 20, 660, 24, "Opaline GUI - Context Menu Demonstration", LABEL_ALIGN_CENTER)
title.SetColor(220, 180, 220)
win.AddChild title

Local Instr:TLabel = New TLabel(30, 80, 640, 40, "Right-click anywhere in this window to open the context menu", LABEL_ALIGN_CENTER)
Instr.SetColor(255, 220, 140)
win.AddChild Instr

' Create the context menu
Global ctxMenu:TContextMenu = New TContextMenu()

ctxMenu.AddItemWithShortcut("Cut", "Ctrl+X", "cut")
ctxMenu.AddItemWithShortcut("Copy", "Ctrl+C", "copy")
ctxMenu.AddItemWithShortcut("Paste", "Ctrl+V", "paste")
ctxMenu.AddSeparator()
ctxMenu.AddItem("Select All", "selectall")
ctxMenu.AddSeparator()
ctxMenu.AddCheckbox("Show Grid", False, "grid")
ctxMenu.AddCheckbox("Snap to Grid", True, "snap")
ctxMenu.AddSeparator()
ctxMenu.AddDisabledItem("Disabled Option", "disabled")
ctxMenu.AddItem("Properties...", "properties")

Local info:TPanel = New TPanel(30, 200, 640, 250, "Last selected item", PANEL_STYLE_RAISED)
win.AddChild info

Local lastAction:TLabel = New TLabel(20, 35, 600, 24, "No action yet - right-click to test")
lastAction.SetColor(220, 255, 180)
info.AddChild lastAction

Local detail:TLabel = New TLabel(20, 80, 600, 24, "Context menus support items, separators, checkboxes and disabled entries")
detail.SetColor(180, 200, 255)
info.AddChild detail

' =============================================================================
'                                   MAIN LOOP
' =============================================================================
While Not KeyHit(KEY_ESCAPE)
    Cls()

	TBackground.Refresh()
    TWidget.GuiRefresh()

    ' Show context menu on right-click (button 2)
    If GuiMouse.Hit(2) And Not TContextMenu.IsAnyMenuActive()
        ctxMenu.Show(GuiMouse.x, GuiMouse.y)
    EndIf

    ' Check if an item was selected
    If ctxMenu.WasItemSelected()
        Local id:String = ctxMenu.GetSelectedId()
        lastAction.SetText("Selected: " + id)

        Select id
            Case "cut"          lastAction.SetColor(255, 200, 100)
            Case "copy"         lastAction.SetColor(200, 255, 140)
            Case "paste"        lastAction.SetColor(140, 220, 255)
            Case "grid"         lastAction.SetText("Show Grid: " + ctxMenu.GetItem("grid").checked)
            Case "snap"         lastAction.SetText("Snap to Grid: " + ctxMenu.GetItem("snap").checked)
            Case "properties"   lastAction.SetColor(220, 140, 220)
            Default             lastAction.SetColor(255, 220, 180)
        End Select

        ctxMenu.ClearSelection()
    EndIf

    ClearAllEvents(root)

    SetColor 255, 191, 16
    DrawText "ContextMenu Demo – ESC to quit", 10, 10
   
    Flip
Wend

End