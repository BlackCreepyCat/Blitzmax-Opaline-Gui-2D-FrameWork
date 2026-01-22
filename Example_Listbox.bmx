' =============================================================================
'                     Simple GUI Framework - BlitzMax NG
'                          LISTBOX DEMO : Opaline UI
'        By Creepy Cat (C)2025/2026 : https://github.com/BlackCreepyCat
' =============================================================================

SuperStrict

' Import required BlitzMax modules
Import BRL.GLMax2D
Import BRL.LinkedList

' Import GUI framework modules
Include "opaline/gui_opaline.bmx"

Graphics 1024, 768, 0

' Init the GUI
TWidget.GuiInit()

' Creating the animated background
TBackground.Init()

' Create root container
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

' Create main window
Local win:TWindow = New TWindow(50, 50, 700, 500, "ListBox Demo", False, True, True)
root.AddChild win

' Title label
Local titleLabel:TLabel = New TLabel(20, 20, 660, 24, "Opaline GUI - ListBox Demonstration", LABEL_ALIGN_CENTER)
titleLabel.SetColor(255, 220, 100)
win.AddChild titleLabel

' =============================================================================
'                         SINGLE COLUMN LISTBOX
' =============================================================================
Local lblSingle:TLabel = New TLabel(20, 60, 200, 20, "Single Column ListBox:")
win.AddChild lblSingle

Local singleList:TListBox = New TListBox(20, 85, 300, 200)
singleList.SetShowHeader(False)
singleList.SetAlternateRows(True)

' Add items
singleList.AddItem("Apples")
singleList.AddItem("Bananas")
singleList.AddItem("Cherries")
singleList.AddItem("Dates")
singleList.AddItem("Elderberries")
singleList.AddItem("Figs")
singleList.AddItem("Grapes")
singleList.AddItem("Honeydews")
singleList.AddItem("Kiwis")
singleList.AddItem("Lemons")
singleList.AddItem("Mangos")
singleList.AddItem("Oranges")
singleList.AddItem("Pineapples")
singleList.AddItem("Strawberries")
singleList.AddItem("Watermelons")

win.AddChild singleList

' =============================================================================
'                         MULTI-COLUMN LISTBOX
' =============================================================================
Local lblMulti:TLabel = New TLabel(350, 60, 200, 20, "Multi-Column ListBox:")
win.AddChild lblMulti

Local multiList:TListBox = New TListBox(350, 85, 320, 200)
multiList.SetShowHeader(True)
multiList.SetShowGrid(True)
multiList.SetAlternateRows(True)

' Define columns
multiList.AddColumn("Product", 120, LABEL_ALIGN_LEFT)
multiList.AddColumn("Category", 80, LABEL_ALIGN_CENTER)
multiList.AddColumn("Price", 60, LABEL_ALIGN_RIGHT)
multiList.AddColumn("Stock", 60, LABEL_ALIGN_CENTER)

' Add multi-column items
multiList.AddItemMulti(["Laptop", "Computer", "$999", "15"])
multiList.AddItemMulti(["Mouse", "Computer", "$25", "50"])
multiList.AddItemMulti(["Keyboard", "Computer", "$75", "30"])
multiList.AddItemMulti(["Monitor", "Computer", "$299", "8"])
multiList.AddItemMulti(["Chair", "Furniture", "$150", "12"])
multiList.AddItemMulti(["Desk", "Furniture", "$250", "5"])
multiList.AddItemMulti(["Notebook", "Stationery", "$5", "100"])
multiList.AddItemMulti(["Pen", "Stationery", "$2", "200"])
multiList.AddItemMulti(["Coffee Mug", "Kitchen", "$12", "25"])
multiList.AddItemMulti(["Water Bottle", "Kitchen", "$18", "40"])

win.AddChild multiList

' =============================================================================
'                         SELECTION INFO PANEL
' =============================================================================
Local infoPanel:TPanel = New TPanel(20, 300, 650, 150, "Selection Info", PANEL_STYLE_RAISED)
win.AddChild infoPanel

Local lblInfo:TLabel = New TLabel(15, 30, 620, 20, "Click on items to select them. Use mouse wheel to scroll.")
lblInfo.SetColor(150, 200, 255)
infoPanel.AddChild lblInfo

Local lblSelected:TLabel = New TLabel(15, 60, 620, 20, "Selected: None")
lblSelected.SetColor(255, 255, 150)
infoPanel.AddChild lblSelected

Local lblMultiSelected:TLabel = New TLabel(15, 90, 620, 20, "Multi-Column Selected: None")
lblMultiSelected.SetColor(255, 255, 150)
infoPanel.AddChild lblMultiSelected

' =============================================================================
'                              MAIN LOOP
' =============================================================================
While Not KeyHit(KEY_ESCAPE)
	Cls()

	TBackground.Refresh()
	
    ' Update GUI
    Twidget.GuiRefresh()
    
    ' Simple list selection
    If singleList.SelectionChanged() Or singleList.ItemClicked()
        Local item:TListItem = singleList.GetSelectedItem()
        If item
            lblSelected.SetText("Simple List: Selected '" + item.GetCell(0) + "' (index " + singleList.GetSelectedIndex() + ")")
        EndIf
    EndIf
    
    ' Multi-column list selection
    If multiList.SelectionChanged() Or multiList.ItemClicked()
        Local item:TListItem = multiList.GetSelectedItem()
        If item
            lblMultiSelected.SetText("Multi List: " + item.GetCell(0) + " | " + item.GetCell(1) + " | " + item.GetCell(2))
        EndIf
    EndIf

    
    ' Clear events
    ClearAllEvents(root)
    
    ' Draw instructions
    SetColor 255, 166, 0
    DrawText "ListBox Demo - Press ESC to exit, click items to select, use mouse wheel to scroll", 10, 10
    
    Flip
Wend

End