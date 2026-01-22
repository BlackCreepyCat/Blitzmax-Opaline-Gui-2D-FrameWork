' =============================================================================
' 						Simple GUI Framework - BlitzMax NG
' 							TABBER DEMO : Opaline UI
' 			By Creepy Cat (C)2025/2026 : https://github.com/BlackCreepyCat
' =============================================================================
SuperStrict

Import BRL.GLMax2D
Import BRL.LinkedList

Include "opaline/gui_opaline.bmx"

Graphics 1024,768, 0

' Init the GUI
TWidget.GuiInit()

' Creating the animated background
TBackground.Init()

' Create root container
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

' =============================================================
' 							GUI BUILDING
' =============================================================
Local win:TWindow = New TWindow(50, 50, 700, 500, "Tabber Demo", False, True, True)
root.AddChild win

Local title:TLabel = New TLabel(20, 20, 660, 24, "Opaline GUI - Tabber Demonstration", LABEL_ALIGN_CENTER)
title.SetColor(255, 200, 120)
win.AddChild title

Local tabber:TTabber = New TTabber(30, 70, 640, 280)
win.AddChild tabber

tabber.AddTab("General")
tabber.AddTab("Video")
tabber.AddTab("Audio")

' Tab 0 - General
Local lblG:TLabel = New TLabel(20, 20, 300, 24, "General settings")
lblG.SetColor(220, 220, 255)
tabber.AddChild lblG
tabber.AddWidgetToTab(0, lblG)

Local chkG1:TCheckBox = New TCheckBox(20, 60, 220, 24, "Auto-start", True)
tabber.AddChild chkG1
tabber.AddWidgetToTab(0, chkG1)

' Tab 1 - Video
Local lblV:TLabel = New TLabel(20, 20, 300, 24, "Video settings")
lblV.SetColor(200, 255, 200)
tabber.AddChild lblv
tabber.AddWidgetToTab(1, lblV)

Local comboRes:TComboBox = New TComboBox(20, 60, 220, 28)
comboRes.AddItem("1920×1080")
comboRes.AddItem("1600×900")
comboRes.AddItem("1280×720")
tabber.AddChild combores
tabber.AddWidgetToTab(1, comboRes)

' Tab 2 - Audio
Local lblA:TLabel = New TLabel(20, 20, 300, 24, "Audio settings")
lblA.SetColor(255, 220, 200)
tabber.AddChild lblA
tabber.AddWidgetToTab(2, lblA)

Local sliderVol:TSlider = New TSlider(20, 60, 220, 24, 0.8, SLIDER_STYLE_HORIZONTAL)
tabber.AddChild sliderVol
tabber.AddWidgetToTab(2, sliderVol)

Local info:TPanel = New TPanel(30, 370, 640, 110, "Current tab information", PANEL_STYLE_RAISED)
win.AddChild info

Local tabinfo:TLabel = New TLabel(20, 25, 600, 24, "Current tab: General")
tabinfo.SetColor(200, 220, 255)
info.AddChild tabinfo

Local detail:TLabel = New TLabel(20, 55, 600, 24, "Interact with widgets in each tab")
info.AddChild detail

' =============================================================================
' 									MAIN LOOP
' =============================================================================
While Not KeyHit(KEY_ESCAPE)
    Cls()

	TBackground.Refresh()
    TWidget.GuiRefresh()

    If tabber.TabChanged()
        Select tabber.GetActiveTab()
            Case 0    tabinfo.SetText("Current tab: General")
            Case 1    tabinfo.SetText("Current tab: Video")
            Case 2    tabinfo.SetText("Current tab: Audio")
        End Select
    EndIf

    ClearAllEvents(root)

    SetColor 255, 191, 16
    DrawText "Tabber Demo – ESC to quit", 10, 10
   
    Flip
Wend

End