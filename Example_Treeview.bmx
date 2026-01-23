' =============================================================================
'                     Simple GUI Framework - BlitzMax NG
'                         TREEVIEW DEMO : Opaline UI
'        By Creepy Cat (C)2025/2026 : https://github.com/BlackCreepyCat
' =============================================================================

SuperStrict

' Import required BlitzMax modules
Import BRL.GLMax2D
Import BRL.LinkedList

' Import GUI framework modules
Include "opaline/gui_opaline.bmx"

' =============================================================================
'                             INITIALISATION
' =============================================================================

Graphics 1280, 800, 0

TWidget.GuiInit()
TBackground.Init()

Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

' =============================================================================
'                               FENÊTRE PRINCIPALE
' =============================================================================

Local win:TWindow = New TWindow(40, 40, 900, 680, "TTreeView - Demo", True, True, True,True)
win.SetResizable(True)
win.SetMinSize(900, 680)
root.AddChild win
win.SetStatusText("Hello")

' Titre
Local title:TLabel = New TLabel(20, 15, 860, 28, "Opaline GUI - TreeView Demonstration", LABEL_ALIGN_CENTER)
title.SetColor(240, 220, 100)
win.AddChild title

' =============================================================================
'                                 TREEVIEW
' =============================================================================

Global tree:TTreeView = New TTreeView(20, 60, 520, 525)
tree.SetAnchors(ANCHOR_LEFT | ANCHOR_TOP | ANCHOR_RIGHT | ANCHOR_BOTTOM)
tree.SetShowIcons(True)
tree.SetShowLines(True)

win.AddChild tree

' =============================================================================
'                            PANNEAU DE CONTRÔLES
' =============================================================================

Local ctrlPanel:TPanel = New TPanel(560, 60, 300, 520, "Controls & Options", PANEL_STYLE_RAISED)
ctrlPanel.SetAnchors(ANCHOR_TOP | ANCHOR_RIGHT | ANCHOR_BOTTOM)
win.AddChild ctrlPanel

' Boutons d'action
Local y:Int = 25

Local btnExpand:TButton   = New TButton(20, y, 260, 32, "Expand All"  ) ; y:+45 ; ctrlPanel.AddChild btnExpand
Local btnCollapse:TButton = New TButton(20, y, 260, 32, "Collapse All") ; y:+45 ; ctrlPanel.AddChild btnCollapse
Local btnClear:TButton    = New TButton(20, y, 260, 32, "Clear Tree"   ) ; y:+45 ; ctrlPanel.AddChild btnClear
Local btnAddRoot:TButton  = New TButton(20, y, 260, 32, "Add Root"     ) ; y:+45 ; ctrlPanel.AddChild btnAddRoot
Local btnAddChild:TButton = New TButton(20, y, 260, 32, "Add Child"    ) ; y:+50 ; ctrlPanel.AddChild btnAddChild

' Options visuelles
Local lblOpt:TLabel = New TLabel(20, y, 260, 22, "Display:", LABEL_ALIGN_LEFT) ; y:+28
lblOpt.SetColor(180,200,255)
ctrlPanel.AddChild lblOpt

Global chkIcons :TCheckBox = New TCheckBox(25, y, 240, 22, "Show icons", True)  ; y:+28 ; ctrlPanel.AddChild chkIcons
Global chkLines :TCheckBox = New TCheckBox(25, y, 240, 22, "Show lines", True)  ; y:+28 ; ctrlPanel.AddChild chkLines
Global chkAlt   :TCheckBox = New TCheckBox(25, y, 240, 22, "Alternate rows",True); y:+38 ; ctrlPanel.AddChild chkAlt

' Recherche rapide
Local lblSearch:TLabel = New TLabel(20, y, 260, 22, "Quick find:") ; y:+26
lblSearch.SetColor(200,220,255)
ctrlPanel.AddChild lblSearch

Global searchInput:TTextInput = New TTextInput(20, y, 260, 28, "")
searchInput.SetPlaceholder("type to highlight...")
ctrlPanel.AddChild searchInput

' Info en bas
Global infoLabel:TLabel = New TLabel(20, 600, 860, 24, "Select / expand / collapse nodes – right-click for future context menu", LABEL_ALIGN_CENTER)
infoLabel.SetColor(140,220,255)
win.AddChild infoLabel

' Status bar simple
win.AddStatusSection("Ready", -1, LABEL_ALIGN_LEFT)
win.AddStatusSection("Nodes: 0", 140, LABEL_ALIGN_CENTER)
win.AddStatusSection("Selected: —", 240, LABEL_ALIGN_RIGHT)

' =============================================================================
'                      PEUPLEMENT DU TREE (structure réaliste)
' =============================================================================

Local pc:TTreeNode = tree.AddRootNode("This Computer")
pc.icon = ICON_COMPUTER   ' icône ordinateur
pc.Expand()

Local cdrive:TTreeNode = pc.AddChild("C: (Windows)")
cdrive.icon = ICON_DRIVE
cdrive.Expand()

Local progfiles:TTreeNode = cdrive.AddChild("Program Files")
progfiles.icon = ICON_FOLDER
progfiles.Expand()

Local blitzmax:TTreeNode = progfiles.AddChild("BlitzMax NG")
blitzmax.icon = ICON_FOLDER

blitzmax.AddChild("Test.zip").icon = ICON_FILE_ARCHIVE
blitzmax.AddChild("Test.bmp").icon = ICON_FILE_IMAGE
blitzmax.AddChild("Test.wav").icon = ICON_FILE_AUDIO
blitzmax.AddChild("Test.avi").icon = ICON_FILE_VIDEO

blitzmax.AddChild("mod").icon = ICON_FOLDER
blitzmax.AddChild("samples").icon = ICON_FOLDER

Local users:TTreeNode = cdrive.AddChild("Users")
users.icon = ICON_FOLDER
users.Expand()

Local moi:TTreeNode = users.AddChild("CreepyCat")
moi.icon = ICON_FOLDER
moi.Expand()

moi.AddChild("Desktop").icon   = ICON_FOLDER
moi.AddChild("Documents").icon = ICON_FOLDER
moi.AddChild("Downloads").icon = ICON_FOLDER
moi.AddChild("Pictures").icon  = ICON_FOLDER
moi.AddChild("Music").icon     = ICON_FOLDER
moi.AddChild("Videos").icon    = ICON_FOLDER

Local ddrive:TTreeNode = pc.AddChild("D: (Data)")
ddrive.icon = ICON_DRIVE

ddrive.AddChild("Games").icon   = ICON_FOLDER
ddrive.AddChild("Movies").icon  = ICON_FOLDER
ddrive.AddChild("Projects").icon = ICON_FOLDER
ddrive.AddChild("Backups").icon = ICON_FOLDER

Local network:TTreeNode = tree.AddRootNode("Network")
network.icon = ICON_GLOBE
network.AddChild("NAS-Home").icon    = ICON_NETWORK
network.AddChild("WORKGROUP").icon   = ICON_NETWORK
network.AddChild("Printer-Laser").icon = ICON_PRINTER

tree.UpdateLayout()

' =============================================================================
'                                 BOUCLE PRINCIPALE
' =============================================================================

While Not KeyHit(KEY_ESCAPE) And Not AppTerminate()

    Cls
    TBackground.Refresh()
    TWidget.GuiRefresh()

    ' ──────────────────────────────────────────────
    '   Gestion des événements TreeView
    ' ──────────────────────────────────────────────

    If tree.SelectionChanged()
        Local node:TTreeNode = tree.GetSelectedNode()
        If node
            infoLabel.SetText("Selected: " + node.GetPath())
            infoLabel.SetColor(100,255,140)
            win.SetStatusSection(2, "Selected: " + node.text)
        Else
            infoLabel.SetText("No node selected")
            win.SetStatusSection(2, "Selected: —")
        EndIf
    EndIf

    If tree.NodeClicked()
        Local node:TTreeNode = tree.GetSelectedNode()

        If node
            Print "Node clicked: " + node.GetPath()
            win.SetStatusSection(0, "Clicked: " + node.text)
        EndIf

    EndIf

    ' Correction : NodeExpanded() détecte à la fois expand et collapse
    If tree.NodeExpanded()
        tree.UpdateLayout()
        win.SetStatusSection(0, "Structure changed")

        Local node:TTreeNode = tree.GetSelectedNode()
        If node
            If node.expanded
                infoLabel.SetText("Expanded: " + node.text)
                infoLabel.SetColor(100, 255, 140)
            Else
                infoLabel.SetText("Collapsed: " + node.text)
                infoLabel.SetColor(255, 200, 100)
            EndIf
        EndIf
    EndIf

    ' Boutons de contrôle

	If btnExpand.WasClicked()
		tree.ExpandAll()  
		infoLabel.SetText("Everything expanded")
		infoLabel.SetColor(120,220,255)
	EndIf

	If btnCollapse.WasClicked()
		tree.CollapseAll()  
		infoLabel.SetText("Everything collapsed")
		infoLabel.SetColor(255,200,120)
	EndIf
	
	
	If btnClear.WasClicked()
		tree.ClearAll()
		infoLabel.SetText("Tree cleared")
	EndIf
	
    If btnAddChild.WasClicked()
        Local sel:TTreeNode = tree.GetSelectedNode()

        If sel
            Local child:TTreeNode = sel.AddChild("Item " + (sel.children.Count()+1))
            child.icon = "2"
            sel.Expand()
            tree.UpdateLayout()
            infoLabel.SetText("Child added under " + sel.text)
        Else
            infoLabel.SetText("Select a node first!")
            infoLabel.SetColor(255,120,120)
        EndIf

    EndIf

	If btnAddRoot.WasClicked()
		Local rootNode:TTreeNode = tree.AddRootNode("Root " + (tree.rootNodes.Count() + 1))
		rootNode.icon = ICON_FOLDER
		rootNode.Expand()
		tree.UpdateLayout()

		infoLabel.SetText("Root node added")
		infoLabel.SetColor(120,220,255)
	EndIf


    ' Options d'affichage
    If chkIcons.StateChanged()  Then tree.SetShowIcons (chkIcons.IsChecked())
    If chkLines.StateChanged()  Then tree.SetShowLines (chkLines.IsChecked())

    ' Recherche simple (surlignage du premier trouvé)
    If searchInput.TextChanged()
        Local txt:String = searchInput.GetText().ToLower()
        If txt
            Local found:TTreeNode
            For Local node:TTreeNode = EachIn tree.GetAllNodes()
                If node.text.ToLower().Contains(txt)
                    found = node
                    Exit
                EndIf
            Next
            If found
                tree.SelectNode(found)
                infoLabel.SetText("Found: " + found.GetPath())
                infoLabel.SetColor(80,255,80)
            Else
                infoLabel.SetText("No match for: " + txt)
                infoLabel.SetColor(255,140,140)
            EndIf
        EndIf
    EndIf

    ' Mise à jour compteur de nœuds
    win.SetStatusSection(1, "Nodes: " + tree.GetAllNodes().Count())

    ' Clear all pending events at the end of the frame
    ' (prevents events from being processed multiple times)
    ClearAllEvents(root)



    ' Instructions
    SetColor 200,220,100
    DrawText "ESC = Quit  │  Click = select  │  Click icon = expand/collapse  │  Wheel = scroll", 10, 10

    Flip
Wend

End