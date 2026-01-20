' =============================================================================
'                  Simple GUI Framework - BlitzMax NG
'                           MAIN FILE : Opaline UI
' =============================================================================
' By Creepy Cat (C)2025/2026
' https://github.com/BlackCreepyCat
'
' You can use this code:
' - However you wish, but you are prohibited from selling it...
' - You can convert it into another language! Do not hesitate!
' - Use it For paid/free apps/games, i don't care...
' - I'm just asking for a small citation somewhere! :)
' =============================================================================

SuperStrict

' Import required BlitzMax modules
Import BRL.GLMax2D
Import BRL.LinkedList

' Import GUI framework modules
Include "gui_constants.bmx"
Include "gui_core.bmx"
Include "gui_mouse.bmx"
Include "gui_container.bmx"
Include "gui_window.bmx"
Include "gui_button.bmx"
Include "gui_checkbox.bmx"
Include "gui_radio.bmx"
Include "gui_label.bmx"
Include "gui_panel.bmx"
Include "gui_progressbar.bmx"
Include "gui_slider.bmx"
Include "gui_textinput.bmx"
Include "gui_listbox.bmx"
Include "gui_combobox.bmx"
Include "gui_events.bmx"

' =============================================================================
'                              MAIN PROGRAM EXAMPLE
' =============================================================================
' Creates the main graphics window (fullscreen 1920×1080, windowed mode)
Graphics 1920, 1080, 0
'Graphics 1024, 768, 32,60

TWidget.GuiInit()

' Create root container that covers the entire screen
' All windows will be children of this root container
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)  ' <-- AJOUTER CETTE LIGNE !

' Create demo windows
Local win1:TWindow = New TWindow(120, 80, 540, 540, "Opaline Main Window",True,True,False)
Local win2:TWindow = New TWindow(340, 220, 380, 320, "Settings Window",True,True,True)
Local win3:TWindow = New TWindow(1400, 80, 450, 800, "Progress Demo",False,False,True)
Local win4:TWindow = New TWindow(700, 400, 450, 350, "Text Input Demo",False,False,False)
Local win5:TWindow = New TWindow(700, 50, 650, 340, "ListBox Demo",True,True,True)
Local win6:TWindow = New TWindow(100, 650, 500, 350, "ComboBox Demo",True,True,True)

root.AddChild win1
root.AddChild win2
root.AddChild win3
root.AddChild win4
root.AddChild win5
root.AddChild win6

' =============================================================================
'                         WINDOW 1 - LABELS & PANELS DEMO
' =============================================================================

' --- Title Label ---
Local titleLabel:TLabel = New TLabel(20, 20, 500, 24, "Welcome to the CreepyCat Opaline GUI Framework! (C)2026", LABEL_ALIGN_CENTER)
titleLabel.SetColor(255, 220, 100)  ' Gold color
win1.AddChild titleLabel

Local infoLabel:TLabel = New TLabel(20, 50, 300, 20, "This demonstrates Labels and Panels")
win1.AddChild infoLabel

' --- Panel with buttons ---
Local buttonPanel:TPanel = New TPanel(20, 90, 240, 140, "Actions", PANEL_STYLE_RAISED)
win1.AddChild buttonPanel

Local btn1:TButton = New TButton(20, 30, 200, 35, "New Project")
Local btn2:TButton = New TButton(20, 75, 200, 35, "Open File")
buttonPanel.AddChild btn1
buttonPanel.AddChild btn2

' --- Panel with radio buttons ---
Local optionsPanel:TPanel = New TPanel(280, 90, 240, 140, "Display Mode", PANEL_STYLE_RAISED)
win1.AddChild optionsPanel

' Radio buttons are grouped together (only one can be selected at a time)
Local radioGroup:TList = New TList
Local r1:TRadio = New TRadio(20, 30, 20, 20, "Wireframe", radioGroup)
Local r2:TRadio = New TRadio(20, 60, 20, 20, "Solid", radioGroup)
Local r3:TRadio = New TRadio(20, 90, 20, 20, "Textured", radioGroup)
optionsPanel.AddChild r1
optionsPanel.AddChild r2
optionsPanel.AddChild r3
r2.selected = True

' --- Status panel (sunken style) ---
Local statusPanel:TPanel = New TPanel(20, 250, 500, 60, "", PANEL_STYLE_SUNKEN)
win1.AddChild statusPanel

Local statusLabel:TLabel = New TLabel(10, 15, 480, 30, "Status: Ready", LABEL_ALIGN_LEFT)
statusLabel.SetColor(100, 255, 100)  ' Green
statusPanel.AddChild statusLabel

' --- Nested panels demo ---
' Shows that panels can contain other panels (hierarchy support)
Local outerPanel:TPanel = New TPanel(20, 330, 500, 180, "Nested Panels Demo", PANEL_STYLE_RAISED)
win1.AddChild outerPanel

Local innerPanel1:TPanel = New TPanel(15, 35, 220, 120, "Panel A", PANEL_STYLE_SUNKEN)
Local innerPanel2:TPanel = New TPanel(250, 35, 220, 120, "Panel B", PANEL_STYLE_SUNKEN)
outerPanel.AddChild innerPanel1
outerPanel.AddChild innerPanel2

Local labelA:TLabel = New TLabel(10, 30, 200, 20, "Content in Panel A")
Local labelB:TLabel = New TLabel(10, 30, 200, 20, "Content in Panel B")
innerPanel1.AddChild labelA
innerPanel2.AddChild labelB

Local btnA:TButton = New TButton(10, 60, 180, 30, "Button A")
Local btnB:TButton = New TButton(10, 60, 180, 30, "Button B")
innerPanel1.AddChild btnA
innerPanel2.AddChild btnB

' =============================================================================
'                         WINDOW 2 - SETTINGS
' =============================================================================

' Settings panel
Local settingsPanel:TPanel = New TPanel(20, 20, 340, 200, "Preferences", PANEL_STYLE_RAISED)
win2.AddChild settingsPanel

Local chk1:TCheckBox = New TCheckBox(20, 35, 220, 24, "Dark mode", True)
Local chk2:TCheckBox = New TCheckBox(20, 65, 220, 24, "Show grid", False)
Local chk3:TCheckBox = New TCheckBox(20, 95, 220, 24, "Sound enabled", True)
Local chk4:TCheckBox = New TCheckBox(20, 125, 220, 24, "Auto-save", False)
settingsPanel.AddChild chk1
settingsPanel.AddChild chk2
settingsPanel.AddChild chk3
settingsPanel.AddChild chk4

' Info label at bottom
Local settingsInfo:TLabel = New TLabel(20, 240, 340, 20, "Changes are applied immediately", LABEL_ALIGN_CENTER)
settingsInfo.SetColor(150, 150, 180)
win2.AddChild settingsInfo

' =============================================================================
'                         WINDOW 3 - PROGRESSBAR DEMO
' =============================================================================

' Title
Local progressTitle:TLabel = New TLabel(20, 20, 410, 24, "ProgressBar Demo", LABEL_ALIGN_CENTER)
progressTitle.SetColor(100, 200, 255)
win3.AddChild progressTitle

' Instructions
Local progressInfo:TLabel = New TLabel(20, 50, 410, 20, "Move mouse horizontally to change values", LABEL_ALIGN_CENTER)
progressInfo.SetColor(180, 180, 200)
win3.AddChild progressInfo

' --- Horizontal ProgressBars ---
Local progressPanel:TPanel = New TPanel(20, 90, 410, 200, "Horizontal Bars", PANEL_STYLE_RAISED)
win3.AddChild progressPanel

Local lblProgress1:TLabel = New TLabel(15, 30, 100, 20, "Default:")
progressPanel.AddChild lblProgress1

Local progress1:TProgressBar = New TProgressBar(120, 28, 270, 24, 0.0)
progressPanel.AddChild progress1

Local lblProgress2:TLabel = New TLabel(15, 65, 100, 20, "Health:")
progressPanel.AddChild lblProgress2

Local progress2:TProgressBar = New TProgressBar(120, 63, 270, 24, 0.75)
progress2.SetFillColor(220, 60, 60)  ' Red
progressPanel.AddChild progress2

Local lblProgress3:TLabel = New TLabel(15, 100, 100, 20, "Mana:")
progressPanel.AddChild lblProgress3

Local progress3:TProgressBar = New TProgressBar(120, 98, 270, 24, 0.5)
progress3.SetFillColor(60, 100, 220)  ' Blue
progressPanel.AddChild progress3

Local lblProgress4:TLabel = New TLabel(15, 135, 100, 20, "XP:")
progressPanel.AddChild lblProgress4

Local progress4:TProgressBar = New TProgressBar(120, 133, 270, 24, 0.25)
progress4.SetFillColor(180, 140, 60)  ' Gold
progressPanel.AddChild progress4

' --- Vertical ProgressBars ---
Local vertPanel:TPanel = New TPanel(20, 310, 410, 160, "Vertical Bars", PANEL_STYLE_RAISED)
win3.AddChild vertPanel

Local vProgress1:TProgressBar = New TProgressBar(30, 30, 30, 100, 0.3)
vProgress1.SetStyle(PROGRESSBAR_STYLE_VERTICAL)
vProgress1.SetFillColor(80, 200, 80)
vProgress1.SetShowPercentage(False)
vertPanel.AddChild vProgress1

Local vProgress2:TProgressBar = New TProgressBar(80, 30, 30, 100, 0.5)
vProgress2.SetStyle(PROGRESSBAR_STYLE_VERTICAL)
vProgress2.SetFillColor(200, 80, 80)
vProgress2.SetShowPercentage(False)
vertPanel.AddChild vProgress2

Local vProgress3:TProgressBar = New TProgressBar(130, 30, 30, 100, 0.7)
vProgress3.SetStyle(PROGRESSBAR_STYLE_VERTICAL)
vProgress3.SetFillColor(80, 80, 200)
vProgress3.SetShowPercentage(False)
vertPanel.AddChild vProgress3

Local vProgress4:TProgressBar = New TProgressBar(180, 30, 30, 100, 0.9)
vProgress4.SetStyle(PROGRESSBAR_STYLE_VERTICAL)
vProgress4.SetFillColor(200, 200, 80)
vProgress4.SetShowPercentage(False)
vertPanel.AddChild vProgress4

' Mouse position label
Local mouseLabel:TLabel = New TLabel(250, 60, 140, 20, "Mouse X: 0%", LABEL_ALIGN_LEFT)
mouseLabel.SetColor(255, 255, 100)
vertPanel.AddChild mouseLabel

' =============================================================================
'                         WINDOW 3 - SLIDER DEMO
' =============================================================================

' --- Slider Panel ---
Local sliderPanel:TPanel = New TPanel(20, 510, 410, 250, "Sliders (use mouse wheel!)", PANEL_STYLE_RAISED)
win3.AddChild sliderPanel

' Horizontal sliders
Local lblSlider1:TLabel = New TLabel(15, 30, 80, 20, "Volume:")
sliderPanel.AddChild lblSlider1

Local slider1:TSlider = New TSlider(100, 28, 200, 24, 0.5, SLIDER_STYLE_HORIZONTAL)
sliderPanel.AddChild slider1

Local lblSliderVal1:TLabel = New TLabel(310, 30, 60, 20, "50%", LABEL_ALIGN_LEFT)
sliderPanel.AddChild lblSliderVal1

Local lblSlider2:TLabel = New TLabel(15, 65, 80, 20, "Brightness:")
sliderPanel.AddChild lblSlider2

Local slider2:TSlider = New TSlider(100, 63, 200, 24, 0.75, SLIDER_STYLE_HORIZONTAL)
slider2.SetThumbColor(255, 200, 80)
sliderPanel.AddChild slider2

Local lblSliderVal2:TLabel = New TLabel(310, 65, 60, 20, "75%", LABEL_ALIGN_LEFT)
sliderPanel.AddChild lblSliderVal2

' Vertical sliders
Local vSlider1:TSlider = New TSlider(30, 100, 24, 60, 0.3, SLIDER_STYLE_VERTICAL)
sliderPanel.AddChild vSlider1

Local vSlider2:TSlider = New TSlider(70, 100, 24, 60, 0.6, SLIDER_STYLE_VERTICAL)
vSlider2.SetThumbColor(80, 200, 80)
sliderPanel.AddChild vSlider2

Local vSlider3:TSlider = New TSlider(110, 100, 24, 60, 0.9, SLIDER_STYLE_VERTICAL)
vSlider3.SetThumbColor(200, 80, 80)
sliderPanel.AddChild vSlider3

' =============================================================================
'                         WINDOW 4 - TEXTINPUT DEMO
' =============================================================================

Local inputTitle:TLabel = New TLabel(20, 20, 410, 24, "TextInput Demo", LABEL_ALIGN_CENTER)
inputTitle.SetColor(100, 255, 200)
win4.AddChild inputTitle

' Normal text input
Local lblName:TLabel = New TLabel(20, 60, 100, 24, "Name:")
win4.AddChild lblName

Local inputName:TTextInput = New TTextInput(120, 58, 300, 28, "")
inputName.SetPlaceholder("Enter your name...")
win4.AddChild inputName

' Email input
Local lblEmail:TLabel = New TLabel(20, 100, 100, 24, "Email:")
win4.AddChild lblEmail

Local inputEmail:TTextInput = New TTextInput(120, 98, 300, 28, "")
inputEmail.SetPlaceholder("user@example.com")
win4.AddChild inputEmail

' Password input
Local lblPassword:TLabel = New TLabel(20, 140, 100, 24, "Password:")
win4.AddChild lblPassword

Local inputPassword:TTextInput = New TTextInput(120, 138, 300, 28, "")
inputPassword.SetPlaceholder("Enter password...")
inputPassword.SetPasswordMode(True)
win4.AddChild inputPassword

' Limited length input
Local lblCode:TLabel = New TLabel(20, 180, 100, 24, "Code (6):")
win4.AddChild lblCode

Local inputCode:TTextInput = New TTextInput(120, 178, 100, 28, "")
inputCode.SetPlaceholder("XXXXXX")
inputCode.SetMaxLength(6)
win4.AddChild inputCode

' Info panel
Local inputInfoPanel:TPanel = New TPanel(20, 220, 410, 100, "Input Info", PANEL_STYLE_SUNKEN)
win4.AddChild inputInfoPanel

Local lblInputInfo:TLabel = New TLabel(15, 30, 380, 20, "Click on a field to edit")
lblInputInfo.SetColor(180, 180, 200)
inputInfoPanel.AddChild lblInputInfo

Local lblInputValue:TLabel = New TLabel(15, 55, 380, 20, "Value: ")
lblInputValue.SetColor(150, 255, 150)
inputInfoPanel.AddChild lblInputValue

' =============================================================================
'                         WINDOW 5 - LISTBOX DEMO
' =============================================================================

Local listTitle:TLabel = New TLabel(20, 10, 610, 24, "ListBox Demo - Multi-Column with Scrolling", LABEL_ALIGN_CENTER)
listTitle.SetColor(255, 180, 100)
win5.AddChild listTitle

' --- Simple single-column ListBox ---
Local lblSimpleList:TLabel = New TLabel(20, 40, 200, 20, "Simple List:")
win5.AddChild lblSimpleList

Local simpleList:TListBox = New TListBox(20, 65, 180, 180)
simpleList.SetShowHeader(False)
simpleList.SetAlternateRows(True)

' Add items to simple list
simpleList.AddItem("Apple")
simpleList.AddItem("Banana")
simpleList.AddItem("Cherry")
simpleList.AddItem("Date")
simpleList.AddItem("Elderberry")
simpleList.AddItem("Fig")
simpleList.AddItem("Grape")
simpleList.AddItem("Honeydew")
simpleList.AddItem("Kiwi")
simpleList.AddItem("Lemon")
simpleList.AddItem("Mango")
simpleList.AddItem("Nectarine")
simpleList.AddItem("Orange")
simpleList.AddItem("Papaya")
simpleList.AddItem("Quince")

win5.AddChild simpleList

' --- Multi-column ListBox (file browser style) ---
Local lblMultiList:TLabel = New TLabel(220, 40, 200, 20, "Multi-Column List:")
win5.AddChild lblMultiList

Local multiList:TListBox = New TListBox(220, 65, 400, 180)
multiList.SetShowHeader(True)
multiList.SetShowGrid(True)
multiList.SetAlternateRows(True)

' Define columns
multiList.AddColumn("Name", 160, LABEL_ALIGN_LEFT)
multiList.AddColumn("Type", 80, LABEL_ALIGN_CENTER)
multiList.AddColumn("Size", 70, LABEL_ALIGN_RIGHT)
multiList.AddColumn("Date", 90, LABEL_ALIGN_CENTER)

' Add multi-column items
multiList.AddItemMulti(["Documents", "Folder", "--", "2025-01-15"])
multiList.AddItemMulti(["Pictures", "Folder", "--", "2025-01-14"])
multiList.AddItemMulti(["Music", "Folder", "--", "2025-01-10"])
multiList.AddItemMulti(["report.pdf", "PDF", "2.4 MB", "2025-01-18"])
multiList.AddItemMulti(["photo.jpg", "Image", "3.1 MB", "2025-01-17"])
multiList.AddItemMulti(["song.mp3", "Audio", "4.8 MB", "2025-01-16"])
multiList.AddItemMulti(["video.mp4", "Video", "156 MB", "2025-01-12"])
multiList.AddItemMulti(["notes.txt", "Text", "12 KB", "2025-01-19"])
multiList.AddItemMulti(["backup.zip", "Archive", "89 MB", "2025-01-11"])
multiList.AddItemMulti(["script.py", "Python", "8 KB", "2025-01-20"])
multiList.AddItemMulti(["data.json", "JSON", "156 KB", "2025-01-13"])
multiList.AddItemMulti(["style.css", "CSS", "4 KB", "2025-01-09"])
multiList.AddItemMulti(["index.html", "HTML", "12 KB", "2025-01-08"])
multiList.AddItemMulti(["config.xml", "XML", "2 KB", "2025-01-07"])
multiList.AddItemMulti(["readme.md", "Markdown", "6 KB", "2025-01-06"])

win5.AddChild multiList

' Selection info panel
Local listInfoPanel:TPanel = New TPanel(20, 255, 600, 50, "", PANEL_STYLE_SUNKEN)
win5.AddChild listInfoPanel

Local lblListInfo:TLabel = New TLabel(15, 12, 570, 24, "Select an item (use mouse wheel to scroll)")
lblListInfo.SetColor(150, 200, 255)
listInfoPanel.AddChild lblListInfo

' =============================================================================
'                         WINDOW 6 - COMBOBOX DEMO
' =============================================================================

Local comboTitle:TLabel = New TLabel(20, 10, 460, 24, "ComboBox Demo - Dropdown Selection", LABEL_ALIGN_CENTER)
comboTitle.SetColor(100, 255, 180)
win6.AddChild comboTitle

' --- Simple ComboBox ---
Local lblCombo1:TLabel = New TLabel(20, 50, 120, 24, "Country:")
win6.AddChild lblCombo1

Local comboCountry:TComboBox = New TComboBox(250, 48, 200, 28)
comboCountry.SetPlaceholder("Select country...")
comboCountry.AddItem("France")
comboCountry.AddItem("Germany")
comboCountry.AddItem("Italy")
comboCountry.AddItem("Spain")
comboCountry.AddItem("United Kingdom")
comboCountry.AddItem("United States")
comboCountry.AddItem("Canada")
comboCountry.AddItem("Japan")
comboCountry.AddItem("Australia")
comboCountry.AddItem("Brazil")
win6.AddChild comboCountry

' --- ComboBox with many items (to test scrolling) ---
Local lblCombo2:TLabel = New TLabel(20, 95, 120, 24, "Font Size:")
win6.AddChild lblCombo2

Local comboFontSize:TComboBox = New TComboBox(150, 93, 120, 28)
comboFontSize.SetPlaceholder("Size...")

For Local i:Int = 8 To 72 Step 2
    comboFontSize.AddItem(i + " pt")
Next

comboFontSize.SetSelectedIndex(4)  ' Default to 16pt
win6.AddChild comboFontSize

' --- Another ComboBox ---
Local lblCombo3:TLabel = New TLabel(20, 140, 120, 24, "Color:")
win6.AddChild lblCombo3

Local comboColor:TComboBox = New TComboBox(150, 138, 180, 28)
comboColor.SetPlaceholder("Pick a color...")
comboColor.AddItem("Red")
comboColor.AddItem("Green")
comboColor.AddItem("Blue")
comboColor.AddItem("Yellow")
comboColor.AddItem("Orange")
comboColor.AddItem("Purple")
comboColor.AddItem("Pink")
comboColor.AddItem("Cyan")
comboColor.AddItem("White")
comboColor.AddItem("Black")
win6.AddChild comboColor

' --- Info Panel ---
Local comboInfoPanel:TPanel = New TPanel(20, 185, 460, 80, "Selection Info", PANEL_STYLE_SUNKEN)
win6.AddChild comboInfoPanel

Local lblComboInfo:TLabel = New TLabel(15, 25, 430, 20, "Click on a ComboBox to open dropdown")
lblComboInfo.SetColor(180, 200, 220)
comboInfoPanel.AddChild lblComboInfo

Local lblComboValue:TLabel = New TLabel(15, 50, 430, 20, "Selected: (none)")
lblComboValue.SetColor(150, 255, 150)
comboInfoPanel.AddChild lblComboValue

' --- Note about ComboBox ---
Local lblComboNote:TLabel = New TLabel(20, 280, 460, 40, "Note: ComboBox uses TListBox internally for the dropdown")
lblComboNote.SetColor(150, 150, 180)
win6.AddChild lblComboNote

' =============================================================================
'                              MAIN LOOP
' =============================================================================
While Not AppTerminate()
    Cls

    TWidget.GuiUpdate()   ' Mouse + popup + widgets update
    TWidget.GuiDraw()     ' Widgets draw + popup overlay



    ' =============================================================================
    '                    SLIDER DEMO - Live value display
    ' =============================================================================

    ' Update slider value labels in real-time
    lblSliderVal1.SetText(Int(slider1.GetPercent()) + "%")
    lblSliderVal2.SetText(Int(slider2.GetPercent()) + "%")

    ' Optional: link one progress bar to a slider value (demo purpose)
    progress1.SetValue(slider1.GetValue())

    ' =============================================================================
    '                    TEXT INPUT - Event handling
    ' =============================================================================

    ' TextInput events - update info labels when text changes
    If inputName.TextChanged()
        lblInputInfo.SetText("Name changed!")
        lblInputValue.SetText("Value: " + inputName.GetText())
    EndIf

    If inputEmail.TextChanged()
        lblInputInfo.SetText("Email changed!")
        lblInputValue.SetText("Value: " + inputEmail.GetText())
    EndIf

    If inputPassword.TextChanged()
        lblInputInfo.SetText("Password changed!")
        lblInputValue.SetText("Value: " + inputPassword.GetText())
    EndIf

    If inputCode.TextChanged()
        lblInputInfo.SetText("Code changed!")
        lblInputValue.SetText("Value: " + inputCode.GetText())
    EndIf

    ' Detect when user presses Enter in any text field
    If inputName.WasSubmitted() Or inputEmail.WasSubmitted() Or inputPassword.WasSubmitted() Or inputCode.WasSubmitted()
        lblInputInfo.SetText("Form submitted! (Enter pressed)")
    EndIf

    ' =============================================================================
    '                    PROGRESSBAR DEMO - Mouse X controls values
    ' =============================================================================
    ' Demo: horizontal mouse position controls progress bars (fun effect)
    Local mousePercent:Float = Float(GuiMouse.x) / Float(GraphicsWidth())
    
    ' Update horizontal progress bars based on mouse X
    progress1.SetValue(mousePercent)
    progress2.SetValue(mousePercent * 0.75 + 0.25)  ' Offset for variety
    progress3.SetValue(1.0 - mousePercent)          ' Inverse
    progress4.SetValue((mousePercent * 2.0) Mod 1.0) ' Wrapping
    
    ' Update vertical progress bars
    vProgress1.SetValue(mousePercent)
    vProgress2.SetValue((mousePercent + 0.25) Mod 1.0)
    vProgress3.SetValue((mousePercent + 0.5) Mod 1.0)
    vProgress4.SetValue((mousePercent + 0.75) Mod 1.0)
    
    ' Show current mouse X percentage
    mouseLabel.SetText("Mouse X: " + Int(mousePercent * 100) + "%")



    ' =============================================================================
    '                    LISTBOX DEMO - Event handling
    ' =============================================================================
    
    ' Simple list selection
    If simpleList.SelectionChanged() Or simpleList.ItemClicked()
        Local item:TListItem = simpleList.GetSelectedItem()
        If item
            lblListInfo.SetText("Simple List: Selected '" + item.GetCell(0) + "' (index " + simpleList.GetSelectedIndex() + ")")
        EndIf
    EndIf
    
    ' Multi-column list selection
    If multiList.SelectionChanged() Or multiList.ItemClicked()
        Local item:TListItem = multiList.GetSelectedItem()
        If item
            lblListInfo.SetText("Multi List: " + item.GetCell(0) + " | " + item.GetCell(1) + " | " + item.GetCell(2))
        EndIf
    EndIf

    ' =============================================================================
    '                    COMBOBOX DEMO - Event handling
    ' =============================================================================
    
    If comboCountry.SelectionChanged()
        lblComboInfo.SetText("Country changed!")
        lblComboValue.SetText("Selected: " + comboCountry.GetSelectedText())
    EndIf
    
    If comboFontSize.SelectionChanged()
        lblComboInfo.SetText("Font size changed!")
        lblComboValue.SetText("Selected: " + comboFontSize.GetSelectedText())
    EndIf
    
    If comboColor.SelectionChanged()
        lblComboInfo.SetText("Color changed!")
        lblComboValue.SetText("Selected: " + comboColor.GetSelectedText())
    EndIf



    ' =============================================================================
    '                          EVENT HANDLING
    ' =============================================================================
    
    ' Button events - change status text when clicked
    If btn1.WasClicked()
        statusLabel.SetText("Status: Creating new project...")
        statusLabel.SetColor(100, 200, 255)
    EndIf
    
    If btn2.WasClicked()
        statusLabel.SetText("Status: Opening file dialog...")
        statusLabel.SetColor(255, 200, 100)
    EndIf
    
    If btnA.WasClicked()
        labelA.SetText("Button A clicked!")
    EndIf
    
    If btnB.WasClicked()
        labelB.SetText("Button B clicked!")
    EndIf
    
    ' Radio events - update status when selection changes
    If r1.WasSelected()
        statusLabel.SetText("Status: Wireframe mode")
        statusLabel.SetColor(255, 150, 150)
    EndIf
    
    If r2.WasSelected()
        statusLabel.SetText("Status: Solid mode")
        statusLabel.SetColor(150, 255, 150)
    EndIf
    
    If r3.WasSelected()
        statusLabel.SetText("Status: Textured mode")
        statusLabel.SetColor(150, 150, 255)
    EndIf
    
    ' Checkbox events - print state changes to console
    If chk1.StateChanged()
        Print "Dark mode: " + chk1.IsChecked()
    EndIf
    
    If chk2.StateChanged()
        Print "Show grid: " + chk2.IsChecked()
    EndIf
    
    If chk3.StateChanged()
        Print "Sound enabled: " + chk3.IsChecked()
    EndIf
    
    If chk4.StateChanged()
        Print "Auto-save: " + chk4.IsChecked()
    EndIf

    ' Handle window control buttons (close / min / max)
    For Local win:TWindow = EachIn root.children
        ProcessWindowControlEvents(win)
    Next


    
    ' Clear all pending events at the end of the frame
    ' (prevents events from being processed multiple times)
    ClearAllEvents(root)

    ' Display help text at top-left corner
    SetColor 220, 220, 255
    DrawText "Welcome to the CreepyCat Opaline GUI Framework! (C)2026", 10, 10
    DrawText "Drag windows by title bar | Use mouse wheel on sliders and lists | Click ComboBox to open dropdown", 10, 30
    
    Flip
Wend

End
