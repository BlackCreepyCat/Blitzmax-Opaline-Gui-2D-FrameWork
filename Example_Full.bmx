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
Include "opaline/gui_opaline.bmx"

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
TWidget.GuiSetRoot(root)  ' <-- IMPORTANT !

' Create demo windows
Local win1:TWindow = New TWindow(120, 80, 540, 540, "Opaline Main Window",True,True,False,True)
win1.SetResizable(True)
win1.SetMinSize(540, 540)  

'win1.SetStatusText("I like status window text!")

' More complex status text, sections adding (width = -1 for flexible)
win1.AddStatusSection("Ready", -1, LABEL_ALIGN_LEFT)        ' Section 0 - flexible
win1.AddStatusSection("Ln 1", -1, LABEL_ALIGN_CENTER)       ' Section 1 - 60px
win1.AddStatusSection("Col 1", -1, LABEL_ALIGN_CENTER)      ' Section 2 - 60px
win1.AddStatusSection("UTF-8", -1, LABEL_ALIGN_RIGHT)       ' Section 3 - 80px

' Mettre à jour une section
'win1.SetStatusSection(0, "Modified")
'win1.SetStatusSection(1, "Ln 42")
'win1.SetStatusSection(2, "Col 15")



Local win2:TWindow = New TWindow(340, 220, 380, 320, "Settings Window",True,True,True,True)

' Simple status text



Local win3:TWindow = New TWindow(1400, 80, 450, 800, "Progress Demo",False,False,True)
Local win4:TWindow = New TWindow(700, 400, 450, 350, "Text Input Demo",False,False,False)
Local win5:TWindow = New TWindow(700, 50, 650, 340, "ListBox Demo",True,True,True)
Local win6:TWindow = New TWindow(100, 650, 500, 350, "ComboBox Demo",True,True,True)
Local win7:TWindow = New TWindow(620, 450, 500, 400, "Tabber Demo",True,True,True)
Local win8:TWindow = New TWindow(1200, 500, 400, 450, "ImageBox Demo",True,True,True, True)

Local win9:TWindow = New TWindow(50, 400, 500, 300, "TextArea Demo",True,True,True)
win9.SetResizable(True)
win9.SetMinSize(500, 300)  

' =============================================================================
'                         MODAL WINDOW DEMO
' =============================================================================
' Create a modal "About" window - it will block all other windows
Global winModal:TWindow = New TWindow(GraphicsWidth()/2 - 200, GraphicsHeight()/2 - 150, 400, 250, "About - MODAL WINDOW", True, False, False)
winModal.SetModalState(True)  ' <-- Set this window as MODAL

root.AddChild win1
root.AddChild win2
root.AddChild win3
root.AddChild win4
root.AddChild win5
root.AddChild win6
root.AddChild win7
root.AddChild win8
root.AddChild win9
root.AddChild winModal  ' Modal window added last (will be on top)

' =============================================================================
'                    SCREEN WIDGETS (directly on root, not in a window)
' =============================================================================
' These widgets are placed directly on the screen, behind all windows
Global lblScreenInfo:TLabel = New TLabel(10, 60, 400, 20, "Screen widgets (not in any window):")
lblScreenInfo.SetColor(255, 200, 100)
root.AddChild lblScreenInfo

Global lblScreenStatus:TLabel = New TLabel(10, 130, 400, 20, "Click the buttons above! Right-click anywhere for context menu.")
lblScreenStatus.SetColor(150, 255, 150)
root.AddChild lblScreenStatus

Global btnScreenTest:TButton = New TButton(15, 85, 120, 35, "Screen Button")
root.AddChild btnScreenTest

Global btnShowMsgBox:TButton = New TButton(15, 175, 120, 35, "Show MessageBox")
root.AddChild btnShowMsgBox





' =============================================================================
'                         CONTEXT MENU SETUP
' =============================================================================
' Create a context menu that appears on right-click
Global contextMenu:TContextMenu = New TContextMenu()
contextMenu.AddItemWithShortcut("Cut", "Ctrl+X", "cut")
contextMenu.AddItemWithShortcut("Copy", "Ctrl+C", "copy")
contextMenu.AddItemWithShortcut("Paste", "Ctrl+V", "paste")
contextMenu.AddSeparator()
contextMenu.AddItem("Select All", "selectall")
contextMenu.AddSeparator()
contextMenu.AddCheckbox("Show Grid", False, "grid")
contextMenu.AddCheckbox("Snap to Grid", True, "snap")
contextMenu.AddSeparator()
contextMenu.AddDisabledItem("Disabled Item", "disabled")
contextMenu.AddItem("Properties...", "properties")

' =============================================================================
'                         TEXTAREA DEMO (win9)
' =============================================================================
Local lblTextAreaTitle:TLabel = New TLabel(10, 10, 480, 20, "Multi-line Text Editor (TTextArea)", LABEL_ALIGN_CENTER)
lblTextAreaTitle.SetColor(100, 200, 255)
lblTextAreaTitle.SetAnchors(ANCHOR_LEFT | ANCHOR_TOP | ANCHOR_RIGHT)  ' S'étire horizontalement
win9.AddChild lblTextAreaTitle

' Create the TextArea with some initial text
Local sampleCode:String = "' Welcome to TTextArea!~n"
sampleCode :+ "' This is a multi-line text editor.~n"
sampleCode :+ "~n"
sampleCode :+ "Function HelloWorld()~n"
sampleCode :+ "    Print ~qHello, World!~q~n"
sampleCode :+ "End Function~n"
sampleCode :+ "~n"
sampleCode :+ "' Features:~n"
sampleCode :+ "' - Multi-line editing~n"
sampleCode :+ "' - Selection with mouse/keyboard~n"
sampleCode :+ "' - Copy/Cut/Paste (Ctrl+C/X/V)~n"
sampleCode :+ "' - Line numbers (optional)~n"
sampleCode :+ "' - Scroll support~n"

Global textArea:TTextArea = New TTextArea(10, 35, 480, 180, sampleCode)
textArea.SetShowLineNumbers(True)
textArea.SetAnchors(ANCHOR_ALL)  ' S'étire dans toutes les directions
win9.AddChild textArea

' Options panel
Local chkLineNumbers:TCheckBox = New TCheckBox(10, 225, 150, 18, "Line Numbers", True)
chkLineNumbers.SetAnchors(ANCHOR_LEFT | ANCHOR_BOTTOM)  ' Reste en bas à gauche
win9.AddChild chkLineNumbers

Local chkReadOnly:TCheckBox = New TCheckBox(170, 225, 150, 18, "Read Only", False)
chkReadOnly.SetAnchors(ANCHOR_LEFT | ANCHOR_BOTTOM)  ' Reste en bas à gauche
win9.AddChild chkReadOnly

Local lblLineInfo:TLabel = New TLabel(10, 250, 480, 20, "Line: 1  Col: 1  Lines: " + textArea.GetLineCount())
lblLineInfo.SetColor(150, 150, 180)
lblLineInfo.SetAnchors(ANCHOR_LEFT | ANCHOR_BOTTOM | ANCHOR_RIGHT)  ' S'étire horizontalement, reste en bas
win9.AddChild lblLineInfo

' =============================================================================
'                         MESSAGEBOX CALLBACK FUNCTION
' =============================================================================
' This function is called when a MessageBox button is clicked
Function OnMessageBoxResult:Int(result:Int)
    Select result
        Case MSGBOX_RESULT_OK
            Print "MessageBox: OK clicked"
            lblScreenStatus.SetText("MessageBox result: OK")
            lblScreenStatus.SetColor(100, 255, 100)
        Case MSGBOX_RESULT_CANCEL
            Print "MessageBox: Cancel clicked"
            lblScreenStatus.SetText("MessageBox result: CANCEL")
            lblScreenStatus.SetColor(255, 150, 100)
        Case MSGBOX_RESULT_YES
            Print "MessageBox: Yes clicked"
            lblScreenStatus.SetText("MessageBox result: YES")
            lblScreenStatus.SetColor(100, 255, 100)
        Case MSGBOX_RESULT_NO
            Print "MessageBox: No clicked"
            lblScreenStatus.SetText("MessageBox result: NO")
            lblScreenStatus.SetColor(255, 100, 100)
    End Select
    Return 0
End Function

' =============================================================================
'                         MODAL WINDOW CONTENT
' =============================================================================
' Add content to the modal window
Local modalTitle:TLabel = New TLabel(20, 20, 360, 30, "Opaline GUI Framework", LABEL_ALIGN_CENTER)
modalTitle.SetColor(255, 220, 100)  ' Gold color
winModal.AddChild modalTitle

Local modalVersion:TLabel = New TLabel(20, 55, 360, 20, "Version 1.0 - Modal Window Demo", LABEL_ALIGN_CENTER)
modalVersion.SetColor(200, 200, 220)
winModal.AddChild modalVersion

Local modalAuthor:TLabel = New TLabel(20, 85, 360, 20, "By Creepy Cat (C)2025/2026", LABEL_ALIGN_CENTER)
modalAuthor.SetColor(180, 180, 200)
winModal.AddChild modalAuthor

Local modalInfo:TLabel = New TLabel(20, 120, 360, 40, "This is a MODAL window. It blocks all", LABEL_ALIGN_CENTER)
modalInfo.SetColor(150, 200, 255)
winModal.AddChild modalInfo

Local modalInfo2:TLabel = New TLabel(20, 145, 360, 40, "input to other windows until closed.", LABEL_ALIGN_CENTER)
modalInfo2.SetColor(150, 200, 255)
winModal.AddChild modalInfo2

' OK button to close the modal
Global btnModalOK:TButton = New TButton(150, 190, 100, 35, "OK")
winModal.AddChild btnModalOK

' =============================================================================
'                         WINDOW 1 - LABELS & PANELS DEMO
' =============================================================================

' --- Title Label ---
Local titleLabel:TLabel = New TLabel(20, 20, 500, 24, "Welcome to the CreepyCat Opaline GUI Framework! (C)2026", LABEL_ALIGN_CENTER)
titleLabel.SetColor(255, 220, 100)  ' Gold color
titleLabel.SetAnchors(ANCHOR_LEFT | ANCHOR_TOP | ANCHOR_RIGHT)  ' S'étire horizontalement
win1.AddChild titleLabel

Local infoLabel:TLabel = New TLabel(20, 50, 300, 20, "This demonstrates Labels and Panels")
win1.AddChild infoLabel

' --- Panel with buttons ---
Local buttonPanel:TPanel = New TPanel(20, 90, 240, 140, "Actions", PANEL_STYLE_RAISED)
win1.AddChild buttonPanel

Local btn1:TButton = New TButton(20, 30, 200, 35, "New Project")
buttonPanel.AddChild btn1
btn1.SetColor(200, 80,30)



Local btn2:TButton = New TButton(20, 75, 200, 35, "Open File")
buttonPanel.AddChild btn2
btn2.SetColor(30, 200,20)

' --- Panel with radio buttons ---
Local optionsPanel:TPanel = New TPanel(280, 90, 240, 140, "Display Mode", PANEL_STYLE_RAISED)
optionsPanel.SetAnchors(ANCHOR_TOP | ANCHOR_RIGHT)  ' Reste en haut à droite
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
statusPanel.SetAnchors(ANCHOR_LEFT | ANCHOR_RIGHT)  ' S'étire horizontalement, position Y fixe
win1.AddChild statusPanel

Local statusLabel:TLabel = New TLabel(10, 15, 480, 30, "Status: Ready", LABEL_ALIGN_LEFT)
statusLabel.SetColor(100, 255, 100)  ' Green
statusLabel.SetAnchors(ANCHOR_LEFT | ANCHOR_TOP | ANCHOR_RIGHT)  ' S'étire avec le panel parent
statusPanel.AddChild statusLabel

' --- Nested panels demo ---
' Shows that panels can contain other panels (hierarchy support)
Local outerPanel:TPanel = New TPanel(20, 330, 500, 180, "Nested Panels Demo", PANEL_STYLE_RAISED)
outerPanel.SetAnchors(ANCHOR_LEFT | ANCHOR_TOP | ANCHOR_RIGHT | ANCHOR_BOTTOM)  ' S'étire partout
win1.AddChild outerPanel

Local innerPanel1:TPanel = New TPanel(15, 35, 220, 120, "Panel A", PANEL_STYLE_SUNKEN)
Local innerPanel2:TPanel = New TPanel(250, 35, 220, 120, "Panel B", PANEL_STYLE_SUNKEN)
innerPanel2.SetAnchors(ANCHOR_TOP | ANCHOR_RIGHT | ANCHOR_BOTTOM)  ' Panel B reste à droite et s'étire verticalement
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
'                         WINDOW 7 - TABBER DEMO
' =============================================================================

Local tabberTitle:TLabel = New TLabel(20, 10, 460, 24, "Tabber Demo - Tab Control Widget", LABEL_ALIGN_CENTER)
tabberTitle.SetColor(255, 200, 100)
win7.AddChild tabberTitle

' Create the tabber widget
Local tabber:TTabber = New TTabber(20, 40, 460, 320)
win7.AddChild tabber

' Add tabs
tabber.AddTab("General")
tabber.AddTab("Graphics")
tabber.AddTab("Audio")
tabber.AddTab("Controls")

' --- TAB 1: General Settings ---
Local lblGeneralTitle:TLabel = New TLabel(20, 20, 200, 24, "General Settings")
lblGeneralTitle.SetColor(200, 220, 255)
tabber.AddChild lblGeneralTitle
tabber.AddWidgetToTab(0, lblGeneralTitle)

Local chkAutoStart:TCheckBox = New TCheckBox(20, 55, 200, 24, "Start on system boot", False)
tabber.AddChild chkAutoStart
tabber.AddWidgetToTab(0, chkAutoStart)

Local chkUpdates:TCheckBox = New TCheckBox(20, 85, 200, 24, "Check for updates", True)
tabber.AddChild chkUpdates
tabber.AddWidgetToTab(0, chkUpdates)

Local chkNotify:TCheckBox = New TCheckBox(20, 115, 200, 24, "Show notifications", True)
tabber.AddChild chkNotify
tabber.AddWidgetToTab(0, chkNotify)

Local lblLanguage:TLabel = New TLabel(20, 160, 100, 24, "Language:")
tabber.AddChild lblLanguage
tabber.AddWidgetToTab(0, lblLanguage)

Local comboLang:TComboBox = New TComboBox(130, 158, 150, 28)
comboLang.SetPlaceholder("Select...")
comboLang.AddItem("English")
comboLang.AddItem("French")
comboLang.AddItem("German")
comboLang.AddItem("Spanish")
comboLang.AddItem("Japanese")
comboLang.SetSelectedIndex(0)
tabber.AddChild comboLang
tabber.AddWidgetToTab(0, comboLang)

Local btnSaveGeneral:TButton = New TButton(20, 220, 120, 35, "Save Settings")
tabber.AddChild btnSaveGeneral
tabber.AddWidgetToTab(0, btnSaveGeneral)

' --- TAB 2: Graphics Settings ---
Local lblGraphicsTitle:TLabel = New TLabel(20, 20, 200, 24, "Graphics Settings")
lblGraphicsTitle.SetColor(200, 255, 200)
tabber.AddChild lblGraphicsTitle
tabber.AddWidgetToTab(1, lblGraphicsTitle)

Local lblResolution:TLabel = New TLabel(20, 55, 100, 24, "Resolution:")
tabber.AddChild lblResolution
tabber.AddWidgetToTab(1, lblResolution)

Local comboResolution:TComboBox = New TComboBox(130, 53, 150, 28)
comboResolution.AddItem("1920x1080")
comboResolution.AddItem("1600x900")
comboResolution.AddItem("1280x720")
comboResolution.AddItem("1024x768")
comboResolution.SetSelectedIndex(0)
tabber.AddChild comboResolution
tabber.AddWidgetToTab(1, comboResolution)

Local chkFullscreen:TCheckBox = New TCheckBox(20, 95, 200, 24, "Fullscreen mode", False)
tabber.AddChild chkFullscreen
tabber.AddWidgetToTab(1, chkFullscreen)

Local chkVSync:TCheckBox = New TCheckBox(20, 125, 200, 24, "V-Sync enabled", True)
tabber.AddChild chkVSync
tabber.AddWidgetToTab(1, chkVSync)

Local lblBrightness:TLabel = New TLabel(20, 165, 100, 24, "Brightness:")
tabber.AddChild lblBrightness
tabber.AddWidgetToTab(1, lblBrightness)

Local sliderBrightness:TSlider = New TSlider(130, 163, 200, 24, 0.7, SLIDER_STYLE_HORIZONTAL)
tabber.AddChild sliderBrightness
tabber.AddWidgetToTab(1, sliderBrightness)

Local lblBrightnessVal:TLabel = New TLabel(340, 165, 50, 24, "70%")
tabber.AddChild lblBrightnessVal
tabber.AddWidgetToTab(1, lblBrightnessVal)

' --- TAB 3: Audio Settings ---
Local lblAudioTitle:TLabel = New TLabel(20, 20, 200, 24, "Audio Settings")
lblAudioTitle.SetColor(255, 200, 200)
tabber.AddChild lblAudioTitle
tabber.AddWidgetToTab(2, lblAudioTitle)

Local lblMasterVol:TLabel = New TLabel(20, 55, 100, 24, "Master:")
tabber.AddChild lblMasterVol
tabber.AddWidgetToTab(2, lblMasterVol)

Local sliderMaster:TSlider = New TSlider(130, 53, 200, 24, 0.8, SLIDER_STYLE_HORIZONTAL)
tabber.AddChild sliderMaster
tabber.AddWidgetToTab(2, sliderMaster)

Local lblMasterVal:TLabel = New TLabel(340, 55, 50, 24, "80%")
tabber.AddChild lblMasterVal
tabber.AddWidgetToTab(2, lblMasterVal)

Local lblMusicVol:TLabel = New TLabel(20, 95, 100, 24, "Music:")
tabber.AddChild lblMusicVol
tabber.AddWidgetToTab(2, lblMusicVol)

Local sliderMusic:TSlider = New TSlider(130, 93, 200, 24, 0.6, SLIDER_STYLE_HORIZONTAL)
tabber.AddChild sliderMusic
tabber.AddWidgetToTab(2, sliderMusic)

Local lblMusicVal:TLabel = New TLabel(340, 95, 50, 24, "60%")
tabber.AddChild lblMusicVal
tabber.AddWidgetToTab(2, lblMusicVal)

Local lblSfxVol:TLabel = New TLabel(20, 135, 100, 24, "Effects:")
tabber.AddChild lblSfxVol
tabber.AddWidgetToTab(2, lblSfxVol)

Local sliderSfx:TSlider = New TSlider(130, 133, 200, 24, 0.9, SLIDER_STYLE_HORIZONTAL)
tabber.AddChild sliderSfx
tabber.AddWidgetToTab(2, sliderSfx)

Local lblSfxVal:TLabel = New TLabel(340, 135, 50, 24, "90%")
tabber.AddChild lblSfxVal
tabber.AddWidgetToTab(2, lblSfxVal)

Local chkMute:TCheckBox = New TCheckBox(20, 180, 200, 24, "Mute all audio", False)
tabber.AddChild chkMute
tabber.AddWidgetToTab(2, chkMute)

' --- TAB 4: Controls Settings ---
Local lblControlsTitle:TLabel = New TLabel(20, 20, 200, 24, "Control Settings")
lblControlsTitle.SetColor(200, 200, 255)
tabber.AddChild lblControlsTitle
tabber.AddWidgetToTab(3, lblControlsTitle)

Local lblMouseSens:TLabel = New TLabel(20, 55, 120, 24, "Mouse Sensitivity:")
tabber.AddChild lblMouseSens
tabber.AddWidgetToTab(3, lblMouseSens)

Local sliderMouseSens:TSlider = New TSlider(150, 53, 180, 24, 0.5, SLIDER_STYLE_HORIZONTAL)
tabber.AddChild sliderMouseSens
tabber.AddWidgetToTab(3, sliderMouseSens)

Local lblMouseSensVal:TLabel = New TLabel(340, 55, 50, 24, "50%")
tabber.AddChild lblMouseSensVal
tabber.AddWidgetToTab(3, lblMouseSensVal)

Local chkInvertY:TCheckBox = New TCheckBox(20, 95, 200, 24, "Invert Y axis", False)
tabber.AddChild chkInvertY
tabber.AddWidgetToTab(3, chkInvertY)

Local chkVibration:TCheckBox = New TCheckBox(20, 125, 200, 24, "Controller vibration", True)
tabber.AddChild chkVibration
tabber.AddWidgetToTab(3, chkVibration)

Local btnResetControls:TButton = New TButton(20, 180, 150, 35, "Reset to Default")
tabber.AddChild btnResetControls
tabber.AddWidgetToTab(3, btnResetControls)

' --- Info label for tab changes ---
Local lblTabInfo:TLabel = New TLabel(20, 365, 460, 20, "Current tab: General")
lblTabInfo.SetColor(150, 200, 255)
win7.AddChild lblTabInfo

' =============================================================================
'                         WINDOW 8 - IMAGEBOX DEMO
' =============================================================================

win8.SetStatusText("ImageBox Widget Demo")

Local imgTitle:TLabel = New TLabel(20, 10, 360, 24, "ImageBox Demo - Image Display Widget", LABEL_ALIGN_CENTER)
imgTitle.SetColor(255, 180, 100)
win8.AddChild imgTitle

' --- ImageBox without border (flat) ---
Local lblImg1:TLabel = New TLabel(20, 45, 150, 20, "No border:")
win8.AddChild lblImg1



Local imgBox1:TImageBox = New TImageBox(20, 70, 80, 80)
imgBox1.SetBackgroundColor(60, 60, 80)
win8.AddChild imgBox1


' --- ImageBox with raised border ---
Local lblImg2:TLabel = New TLabel(130, 45, 150, 20, "Raised:")
win8.AddChild lblImg2

Local imgBox2:TImageBox = New TImageBox(120, 70, 80, 80)
imgBox2.SetShowBorder(True)
imgBox2.SetBorderStyle(IMAGEBOX_STYLE_RAISED)
imgBox2.SetBorderColor(80, 120, 180)
win8.AddChild imgBox2

' --- ImageBox with sunken border ---
Local lblImg3:TLabel = New TLabel(220, 45, 150, 20, "Sunken:")
win8.AddChild lblImg3

Local imgBox3:TImageBox = New TImageBox(220, 70, 80, 80)
imgBox3.SetShowBorder(True)
imgBox3.SetBorderStyle(IMAGEBOX_STYLE_SUNKEN)
imgBox3.SetBorderColor(100, 80, 60)
win8.AddChild imgBox3

' --- Clickable ImageBox (button-like) ---
Local lblImg4:TLabel = New TLabel(320, 45, 60, 20, "Clickable:")
win8.AddChild lblImg4

Local imgBox4:TImageBox = New TImageBox(320, 70, 60, 60)
imgBox4.SetShowBorder(True)
imgBox4.SetClickable(True)
imgBox4.SetBorderColor(100, 150, 200)
win8.AddChild imgBox4

' --- Large ImageBox with options ---
Local lblImgLarge:TLabel = New TLabel(20, 165, 200, 20, "Large ImageBox with options:")
win8.AddChild lblImgLarge


Local imgBoxLarge:TImageBox = New TImageBox(20, 190, 200, 150)
imgBoxLarge.SetShowBorder(True)
imgBoxLarge.SetBorderStyle(IMAGEBOX_STYLE_RAISED)
imgBoxLarge.SetBorderColor(80, 100, 140)
imgBoxLarge.SetPreserveAspect(True)
imgBoxLarge.SetCenterImage(True)
imgBoxLarge.LoadFromFile("image.jpg")

win8.AddChild imgBoxLarge

' --- Options panel ---
Local imgOptionsPanel:TPanel = New TPanel(240, 165, 140, 175, "Options", PANEL_STYLE_RAISED)
win8.AddChild imgOptionsPanel

Local chkPreserveAspect:TCheckBox = New TCheckBox(15, 30, 110, 20, "Aspect?", True)
imgOptionsPanel.AddChild chkPreserveAspect

Local chkCenterImg:TCheckBox = New TCheckBox(15, 55, 110, 20, "Center?", True)
imgOptionsPanel.AddChild chkCenterImg

Local chkShowBorderLarge:TCheckBox = New TCheckBox(15, 80, 110, 20, "Border?", True)
imgOptionsPanel.AddChild chkShowBorderLarge

Local lblAlpha:TLabel = New TLabel(15, 110, 60, 20, "Alpha:")
imgOptionsPanel.AddChild lblAlpha

Local sliderAlpha:TSlider = New TSlider(15, 135, 110, 20, 1.0, SLIDER_STYLE_HORIZONTAL)
imgOptionsPanel.AddChild sliderAlpha

' --- Info panel ---
Local imgInfoPanel:TPanel = New TPanel(20, 355, 360, 50, "", PANEL_STYLE_SUNKEN)
win8.AddChild imgInfoPanel

Local lblImgInfo:TLabel = New TLabel(15, 12, 330, 24, "Click on the clickable ImageBox!")
lblImgInfo.SetColor(150, 200, 255)
imgInfoPanel.AddChild lblImgInfo

' =============================================================================
'                              MAIN LOOP
' =============================================================================
While Not AppTerminate()
    Cls

    TWidget.GuiRefresh()

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
    '                    TABBER DEMO - Event handling
    ' =============================================================================
    
    ' Update tab info label when tab changes
    If tabber.TabChanged()
        Local tabNames:String[] = ["General", "Graphics", "Audio", "Controls"]
        lblTabInfo.SetText("Current tab: " + tabNames[tabber.GetActiveTab()])
    EndIf
    
    ' Update slider value labels in Tabber
    lblBrightnessVal.SetText(Int(sliderBrightness.GetPercent()) + "%")
    lblMasterVal.SetText(Int(sliderMaster.GetPercent()) + "%")
    lblMusicVal.SetText(Int(sliderMusic.GetPercent()) + "%")
    lblSfxVal.SetText(Int(sliderSfx.GetPercent()) + "%")
    lblMouseSensVal.SetText(Int(sliderMouseSens.GetPercent()) + "%")

    ' =============================================================================
    '                    IMAGEBOX DEMO - Event handling
    ' =============================================================================
    
    ' Clickable ImageBox events
    If imgBox4.WasClicked()
        lblImgInfo.SetText("Clickable ImageBox was clicked!")
        lblImgInfo.SetColor(100, 255, 100)
    EndIf
    
    If imgBox4.IsHovered()
        win8.SetStatusText("Hovering over clickable ImageBox...")
    Else
        win8.SetStatusText("ImageBox Widget Demo")
    EndIf
    
    ' Update large ImageBox options from checkboxes
    If chkPreserveAspect.StateChanged()
        imgBoxLarge.SetPreserveAspect(chkPreserveAspect.IsChecked())
        lblImgInfo.SetText("Preserve Aspect: " + chkPreserveAspect.IsChecked())
        lblImgInfo.SetColor(200, 200, 255)
    EndIf
    
    If chkCenterImg.StateChanged()
        imgBoxLarge.SetCenterImage(chkCenterImg.IsChecked())
        lblImgInfo.SetText("Center Image: " + chkCenterImg.IsChecked())
        lblImgInfo.SetColor(200, 200, 255)
    EndIf
    
    If chkShowBorderLarge.StateChanged()
        imgBoxLarge.SetShowBorder(chkShowBorderLarge.IsChecked())
        lblImgInfo.SetText("Show Border: " + chkShowBorderLarge.IsChecked())
        lblImgInfo.SetColor(200, 200, 255)
    EndIf
    
    ' Update alpha from slider
    imgBoxLarge.SetImageAlpha(sliderAlpha.GetValue())


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

    ' =============================================================================
    '                    SCREEN WIDGETS - Event handling
    ' =============================================================================
    If btnScreenTest.WasClicked()
        Print "Screen button clicked!"
        lblScreenStatus.SetText("Screen Button was clicked!")
        lblScreenStatus.SetColor(100, 200, 255)
    EndIf
    
    If btnShowMsgBox.WasClicked()
        Print "Showing MessageBox..."
        TMessageBox.ShowYesNoCancel("Confirm Action", "Do you want to save your changes?", OnMessageBoxResult)
    EndIf
    
    ' =============================================================================
    '                    CONTEXT MENU - Right-click handling
    ' =============================================================================
    ' Show context menu on right-click (when no modal/messagebox is active)
    If GuiMouse.Hit(2) And Not TWindow.IsAnyModalActive() And Not TContextMenu.IsAnyMenuActive()
        contextMenu.Show(GuiMouse.x, GuiMouse.y)
    EndIf
    
    ' Handle context menu item selection
    If contextMenu.WasItemSelected()
        Local selectedId:String = contextMenu.GetSelectedId()
        Print "Context menu: " + selectedId + " selected"
        
        Select selectedId
            Case "cut"
                lblScreenStatus.SetText("Context Menu: Cut")
                lblScreenStatus.SetColor(255, 200, 100)
            Case "copy"
                lblScreenStatus.SetText("Context Menu: Copy")
                lblScreenStatus.SetColor(255, 200, 100)
            Case "paste"
                lblScreenStatus.SetText("Context Menu: Paste")
                lblScreenStatus.SetColor(255, 200, 100)
            Case "selectall"
                lblScreenStatus.SetText("Context Menu: Select All")
                lblScreenStatus.SetColor(255, 200, 100)
            Case "grid"
                Local item:TMenuItem = contextMenu.GetItem("grid")
                lblScreenStatus.SetText("Show Grid: " + item.checked)
                lblScreenStatus.SetColor(100, 200, 255)
            Case "snap"
                Local item:TMenuItem = contextMenu.GetItem("snap")
                lblScreenStatus.SetText("Snap to Grid: " + item.checked)
                lblScreenStatus.SetColor(100, 200, 255)
            Case "properties"
                lblScreenStatus.SetText("Context Menu: Properties")
                lblScreenStatus.SetColor(200, 150, 255)
        End Select
        
        contextMenu.ClearSelection()
    EndIf

    ' =============================================================================
    '                    TEXTAREA DEMO - Event handling
    ' =============================================================================
    ' Update line/column info
    If textArea <> Null
        lblLineInfo.SetText("Line: " + (textArea.cursorLine + 1) + "  Col: " + (textArea.cursorCol + 1) + "  Lines: " + textArea.GetLineCount())
        
        ' Handle checkbox changes
        If chkLineNumbers.StateChanged()
            textArea.SetShowLineNumbers(chkLineNumbers.IsChecked())
        EndIf
        
        If chkReadOnly.StateChanged()
            textArea.SetReadOnlyMode(chkReadOnly.IsChecked())
        EndIf
    EndIf

    ' =============================================================================
    '                    MODAL WINDOW - Event handling
    ' =============================================================================
    ' Close the modal window when OK button is clicked
    If winModal <> Null And btnModalOK <> Null
        If btnModalOK.WasClicked()
            Print "Modal window closed!"
            winModal.Close()
            winModal = Null
            btnModalOK = Null
        EndIf
    EndIf

    ' NOTE: Window control buttons (close/min/max) are now handled 
    ' automatically by GuiRefresh() - no need for manual loop!
    ' NOTE: MessageBox buttons are also handled automatically!
    
    ' Clear all pending events at the end of the frame
    ' (prevents events from being processed multiple times)
    ClearAllEvents(root)

    ' Display help text at top-left corner
    SetColor 179, 255, 0
    DrawText "Welcome to the CreepyCat Opaline GUI Framework! (C)2026", 10, 10
    DrawText "Drag windows by title bar | Use mouse wheel on sliders and lists | Click ComboBox to open dropdown", 10, 30
    
    Flip
Wend

End
