# 🎨 Opaline GUI Framework v1.8

**A lightweight, self-contained 2D GUI framework for BlitzMax NG**

By Creepy Cat © 2025/2026 | [GitHub Repository](https://github.com/BlackCreepyCat/Blitzmax-Opaline-Gui-2D-FrameWork)

<img width="1923" height="1108" alt="image" src="https://github.com/user-attachments/assets/f933c388-e862-4707-9a95-2e8b85685291" />

---

## 📋 Table of Contents

- [About](#-about)
- [Features](#-features)
- [Quick Start](#-quick-start)
- [Widgets Reference](#-widgets-reference)
- [Core Systems](#-core-systems)
- [Examples](#-examples)
- [License](#-license)

---

## 🌟 About

Opaline is a **low-level GUI kernel** designed for creating graphical interfaces from scratch in BlitzMax NG. It's intentionally kept simple and readable to facilitate easy conversion to other languages.

### Why Opaline?

- ✅ **Self-contained** - No complex external dependencies
- ✅ **Portable** - Easy to convert to C++, FreeBasic, Monkey, Java, SDL2, Raylib, etc.
- ✅ **Educational** - Clean, readable code showcasing GUI behavior fundamentals
- ✅ **Complete** - Full widget system with event handling, themes, and layout management

### Design Philosophy

The GUI intentionally looks "basic" - this is by design! The focus is on **behavior and architecture**, not visual polish. Once you understand the core, you can easily customize the appearance.

<img width="1025" height="795" alt="image" src="https://github.com/user-attachments/assets/bacb27de-9b65-499c-ac3a-a2e6c977bece" />


---

## ⚡ Features

### Widget Library
- **Containers**: Window, Panel, TabBar, Tabber
- **Input Controls**: Button, CheckBox, RadioButton, TextInput, TextArea, ComboBox, Slider
- **Display**: Label, ImageBox, ProgressBar, ListBox, TreeView
- **Dialogs**: MessageBox, ContextMenu
- **System**: TaskBar with auto-hide, window management

![Nouveau projet](https://github.com/user-attachments/assets/c8358eda-b1c8-4e43-8be3-8bb32d76c700)

### Advanced Features
- 🎯 **Anchor System** - Automatic widget resizing and repositioning
- 🎨 **Theme Support** - Customizable colors and styles
- 📋 **Clipboard Integration** - Cut, copy, paste functionality
- 🖱️ **Mouse Wheel Support** - On sliders, lists, and scroll areas
- ⌨️ **Full Keyboard Support** - Text input, navigation, shortcuts
- 🪟 **Window Management** - Dragging, minimizing, maximizing, z-ordering
- 🎭 **Event System** - Comprehensive event handling for all widgets

![Nouveau projet](https://github.com/user-attachments/assets/be24bc48-856e-46c1-9d74-2a4adb5eb43a)

---

## 🚀 Quick Start

### Prerequisites

**BlitzMax NG** (free and open-source):
- Download: https://blitzmax.org/
- GitHub: https://github.com/bmx-ng
- Github: https://github.com/markcwm (for the 3D engine)

**Optional - VS Code Setup**:
- VS Code: https://code.visualstudio.com/download
- BlitzMax Extension: https://marketplace.visualstudio.com/items?itemName=Hezkore.blitzmax
- Github Blitzmax Ressources: https://github.com/search?q=+language%3ABlitzMax&type=repositories

### Basic Usage

```blitzmax
SuperStrict

Framework BRL.Max2D
Import BRL.StandardIO
Import BRL.PNGLoader

' Import the Opaline GUI
Include "Opaline/Opaline.bmx"

' Initialize graphics
Graphics 1024, 768, 0

' Initialize the GUI system
TWidget.GuiInit()

' Create root container
Local root:TContainer = New TContainer(0, 0, 1024, 768)
TWidget.GuiSetRoot(root)

' Create a window
Local win:TWindow = New TWindow(100, 100, 400, 300, "My First Window")
root.AddChild(win)

' Create a button
Local btn:TButton = New TButton(50, 50, 150, 30, "Click Me!")
win.AddChild(btn)

' Main loop
While Not KeyDown(KEY_ESCAPE)
    Cls
    
    ' Update and draw GUI
    TWidget.GuiRefresh()
    
    ' Check button events
    If btn.IsClicked()
        Print "Button clicked!"
        btn.ClearEvents()
    EndIf
    
    Flip
Wend
```
Create your own tools!
----------------------
<img width="1921" height="1106" alt="image" src="https://github.com/user-attachments/assets/e4b07b34-b23c-4662-a6b0-534bf7fd3c0b" />

<img width="1922" height="1106" alt="image" src="https://github.com/user-attachments/assets/2265e4bc-1934-42c6-a619-5e4349c5f110" />

---

## 📦 Widgets Reference

### 🪟 TWindow

Draggable, resizable window with title bar and control buttons.

```blitzmax
' Create window
Local win:TWindow = New TWindow(x, y, width, height, "Title")

' Methods
win.SetTitle("New Title")
win.Minimize()
win.Maximize()
win.Restore()
win.Close()
win.SetResizable(True)
win.SetMovable(True)
win.BringToFront()

' Events
If win.IsClosing() Then ...
If win.IsMinimized() Then ...
If win.IsMaximized() Then ...
```

**Window Styles:**
- `WINDOW_STYLE_NORMAL` - Standard window
- `WINDOW_STYLE_TOOL` - Tool palette style
- `WINDOW_STYLE_DIALOG` - Dialog box style

---

### 🔘 TButton

Clickable button with text and icons.

```blitzmax
' Create button
Local btn:TButton = New TButton(x, y, width, height, "Caption")

' Methods
btn.SetCaption("New Text")
btn.SetSymbol("►")  ' Unicode symbols
btn.SetEnabled(True)
btn.SetStyle(BUTTON_STYLE_NORMAL)
btn.SetColor(r, g, b)

' Events
If btn.IsClicked() Then ...
If btn.IsPressed() Then ...
If btn.IsHover() Then ...

' Don't forget to clear events!
btn.ClearEvents()
```

**Button Styles:**
- `BUTTON_STYLE_NORMAL` - Standard button
- `BUTTON_STYLE_FLAT` - Flat appearance
- `BUTTON_STYLE_TOGGLE` - Toggle on/off state

---

### ☑️ TCheckBox

Toggle checkbox with label.

```blitzmax
' Create checkbox
Local cb:TCheckBox = New TCheckBox(x, y, width, height, "Option")

' Methods
cb.SetChecked(True)
cb.SetCaption("Enable Feature")
cb.Toggle()

' State
Local checked:Int = cb.IsChecked()

' Events
If cb.StateChanged() Then ...
cb.ClearEvents()
```

---

### 🔘 TRadioButton

Mutually exclusive radio button groups.

```blitzmax
' Create radio buttons in same group
Local group:Int = 1
Local rb1:TRadioButton = New TRadioButton(x, y, w, h, "Option 1", group)
Local rb2:TRadioButton = New TRadioButton(x, y+30, w, h, "Option 2", group)

' Methods
rb1.SetChecked(True)
Local selected:Int = rb1.IsChecked()

' Events
If rb1.StateChanged() Then ...
rb1.ClearEvents()
```

---

### 📝 TTextInput

Single-line text input field.

```blitzmax
' Create text input
Local input:TTextInput = New TTextInput(x, y, width, height, "Default text")

' Methods
input.SetText("New text")
input.SetPlaceholder("Enter name...")
input.SetMaxLength(50)
input.SetPasswordMode(True)
input.SetReadOnly(False)
input.Clear()
input.SelectAll()

' Get text
Local text:String = input.GetText()

' Events
If input.TextChanged() Then ...
If input.EnterPressed() Then ...
input.ClearEvents()
```

**Features:**
- Cut/Copy/Paste support (Ctrl+X/C/V)
- Select all (Ctrl+A)
- Undo/Redo (Ctrl+Z/Y)
- Home/End navigation
- Password mode (displays •••)

---

### 📄 TTextArea

Multi-line text editor with scrolling.

```blitzmax
' Create text area
Local area:TTextArea = New TTextArea(x, y, width, height)

' Methods
area.SetText("Multi-line\ntext here")
area.AppendText("\nNew line")
area.Clear()
area.SetReadOnly(False)
area.SetWordWrap(True)

' Get text
Local text:String = area.GetText()
Local lineCount:Int = area.GetLineCount()

' Navigation
area.ScrollToTop()
area.ScrollToBottom()
area.ScrollToLine(10)

' Events
If area.TextChanged() Then ...
area.ClearEvents()
```

**Features:**
- Vertical scrollbar
- Word wrap option
- Line numbers (optional)
- Full clipboard support
- Mouse wheel scrolling

---

### 🎚️ TSlider

Value slider (horizontal or vertical).

```blitzmax
' Create slider
Local slider:TSlider = New TSlider(x, y, width, height, 0.5, SLIDER_STYLE_HORIZONTAL)

' Methods
slider.SetValue(0.75)
slider.SetPercent(75.0)
slider.SetRange(0.0, 100.0)
slider.SetThumbSize(20)
slider.SetWheelStep(0.1)
slider.SetWheelEnabled(True)

' Get value
Local value:Float = slider.GetValue()
Local percent:Float = slider.GetPercent()

' Events
If slider.IsChanging() Then ...  ' During drag
If slider.ValueChanged() Then ... ' When released
slider.ClearEvents()
```

**Slider Styles:**
- `SLIDER_STYLE_HORIZONTAL` - Horizontal slider
- `SLIDER_STYLE_VERTICAL` - Vertical slider

**NEW**: Mouse wheel support! Hover and scroll to adjust value.

---

### 📊 TProgressBar

Progress indicator (0-100%).

```blitzmax
' Create progress bar
Local progress:TProgressBar = New TProgressBar(x, y, width, height)

' Methods
progress.SetValue(50)      ' 0-100
progress.SetPercent(75.0)
progress.SetShowText(True)
progress.SetStyle(PROGRESSBAR_STYLE_BLOCKS)

' Get value
Local value:Int = progress.GetValue()
Local percent:Float = progress.GetPercent()
```

**Progress Styles:**
- `PROGRESSBAR_STYLE_SMOOTH` - Smooth fill
- `PROGRESSBAR_STYLE_BLOCKS` - Segmented blocks

---

### 📋 TListBox

Scrollable list of items with selection.

```blitzmax
' Create listbox
Local list:TListBox = New TListBox(x, y, width, height)

' Add items
list.AddItem("Item 1")
list.AddItem("Item 2")
list.AddItem("Item 3")

' Item management
list.RemoveItem(1)
list.ClearItems()
list.SetSelectedIndex(0)

' Get selection
Local index:Int = list.GetSelectedIndex()
Local text:String = list.GetSelectedText()
Local count:Int = list.GetItemCount()

' Events
If list.SelectionChanged() Then ...
If list.ItemDoubleClicked() Then ...
list.ClearEvents()
```

**Features:**
- Mouse wheel scrolling
- Keyboard navigation (arrow keys)
- Double-click support
- Auto-scrollbar when needed

---

### 🌳 TTreeView

Hierarchical tree structure with expandable nodes.

```blitzmax
' Create treeview
Local tree:TTreeView = New TTreeView(x, y, width, height)

' Add root nodes
Local root1:TTreeNode = tree.AddNode("Root 1")
Local root2:TTreeNode = tree.AddNode("Root 2")

' Add child nodes
Local child:TTreeNode = root1.AddChild("Child 1")
child.AddChild("Grandchild")

' Node methods
root1.Expand()
root1.Collapse()
root1.SetText("New Text")
root1.SetIcon("📁")

' Get selection
Local selected:TTreeNode = tree.GetSelectedNode()
If selected Then Print selected.GetText()

' Events
If tree.SelectionChanged() Then ...
If tree.NodeExpanded() Then ...
If tree.NodeCollapsed() Then ...
tree.ClearEvents()
```

---

### 🎨 TComboBox

Dropdown selection box.

```blitzmax
' Create combobox
Local combo:TComboBox = New TComboBox(x, y, width, height)

' Add items
combo.AddItem("Option 1")
combo.AddItem("Option 2")
combo.AddItem("Option 3")

' Selection
combo.SetSelectedIndex(0)
Local index:Int = combo.GetSelectedIndex()
Local text:String = combo.GetSelectedText()

' Events
If combo.SelectionChanged() Then ...
combo.ClearEvents()
```

---

### 🖼️ TImageBox

Display images with scaling options.

```blitzmax
' Load image
Local img:TImage = LoadImage("picture.png")

' Create imagebox
Local imgBox:TImageBox = New TImageBox(x, y, width, height, img)

' Methods
imgBox.SetImage(newImage)
imgBox.SetScaleMode(IMAGEBOX_SCALE_FIT)
imgBox.SetBorderStyle(IMAGEBOX_BORDER_NONE)

' Scale modes
' IMAGEBOX_SCALE_NONE - Original size
' IMAGEBOX_SCALE_FIT - Fit to box (keep ratio)
' IMAGEBOX_SCALE_STRETCH - Stretch to fill
```

---

### 🏷️ TLabel

Static text display.

```blitzmax
' Create label
Local lbl:TLabel = New TLabel(x, y, width, height, "Text")

' Methods
lbl.SetText("New text")
lbl.SetAlignment(LABEL_ALIGN_CENTER)
lbl.SetStyle(LABEL_STYLE_SHADOW)
lbl.SetColor(255, 255, 255)

' Alignment
' LABEL_ALIGN_LEFT
' LABEL_ALIGN_CENTER
' LABEL_ALIGN_RIGHT

' Styles
' LABEL_STYLE_NORMAL
' LABEL_STYLE_SHADOW
```

---

### 📦 TPanel

Container with border and optional title.

```blitzmax
' Create panel
Local panel:TPanel = New TPanel(x, y, width, height, "Panel Title")

' Methods
panel.SetTitle("New Title")
panel.SetStyle(PANEL_STYLE_RAISED)
panel.SetShowBackground(True)
panel.SetColor(r, g, b)

' Layout helpers
Local contentX:Int = panel.GetContentX()
Local contentY:Int = panel.GetContentY()
Local contentW:Int = panel.GetContentWidth()
Local contentH:Int = panel.GetContentHeight()

' Panel Styles
' PANEL_STYLE_FLAT
' PANEL_STYLE_RAISED
' PANEL_STYLE_SUNKEN
```

---

### 📑 TTabber

Tab-based container for switching between views.

```blitzmax
' Create tabber
Local tabber:TTabber = New TTabber(x, y, width, height)

' Add tabs
tabber.AddTab("Tab 1")
tabber.AddTab("Tab 2")
tabber.AddTab("Tab 3")

' Tab management
tabber.SetActiveTab(0)
tabber.RemoveTab(1)
Local activeIndex:Int = tabber.GetActiveTab()
Local tabCount:Int = tabber.GetTabCount()

' Add widgets to specific tab
Local panel:TPanel = New TPanel(10, 10, 200, 150)
tabber.AddChildToTab(panel, 0)  ' Add to first tab

' Events
If tabber.TabChanged() Then ...
tabber.ClearEvents()
```

**Features:**
- Automatic widget visibility per tab
- Close buttons on tabs (optional)
- Tab reordering (optional)
- Mouse wheel tab switching

---

### 💬 TMessageBox

Modal dialog boxes.

```blitzmax
' Show message box
TMessageBox.Show("Title", "Message text", MSGBOX_OK)

' Message box types
' MSGBOX_OK - OK button only
' MSGBOX_OKCANCEL - OK and Cancel buttons
' MSGBOX_YESNO - Yes and No buttons
' MSGBOX_YESNOCANCEL - Yes, No, and Cancel

' Check result in main loop
If TMessageBox.GetResult() = MSGBOX_RESULT_OK Then ...
If TMessageBox.GetResult() = MSGBOX_RESULT_YES Then ...
If TMessageBox.GetResult() = MSGBOX_RESULT_NO Then ...
If TMessageBox.GetResult() = MSGBOX_RESULT_CANCEL Then ...
```

---

### 📌 TContextMenu

Right-click context menu.

```blitzmax
' Create context menu
Local menu:TContextMenu = New TContextMenu()

' Add menu items
menu.AddItem("Copy")
menu.AddItem("Paste")
menu.AddSeparator()
menu.AddItem("Delete")

' Show menu at mouse position
If MouseDown(2) Then  ' Right click
    menu.Show(MouseX(), MouseY())
EndIf

' Check selection
Local selected:Int = menu.GetSelectedIndex()
If selected >= 0 Then
    Select selected
        Case 0: Print "Copy"
        Case 1: Print "Paste"
        Case 3: Print "Delete"
    End Select
    menu.ClearSelection()
EndIf
```

---

### 🖥️ TTaskBar

System taskbar with window management.

```blitzmax
' TaskBar is auto-created by GuiRefresh()
' Access via global: g_TaskBar

' Methods
g_TaskBar.SetAutoHide(True)
g_TaskBar.SetHeight(40)
g_TaskBar.Show()
g_TaskBar.Hide()

' Features
' - Minimized windows appear in taskbar
' - Click to restore windows
' - Auto-hide when mouse away (optional)
' - Always drawn on top
```

---

### Virtual Joystick Widget

A smooth virtual joystick for BlitzMax with analog control.  
Returns normalized X/Y values (-1.0 to +1.0), angle (degrees) and magnitude.

Perfect for touch / mouse-controlled games using the Opaline GUI framework.

```blitzmax
' Features
'- Normalized **X / Y** output in range **[-1.0 … +1.0]**
'- Polar coordinates: **angle** (0–360°) + **magnitude** (0.0–1.0)
'- Configurable **dead zone**
'- Smooth **snap-back** to center with adjustable speed
'- Axis **inversion** (X and/or Y)
'- Customizable **colors** for base and stick
'- Optional **crosshair** + directional guide lines
'- Simple event system: `JoystickPress` / `JoystickRelease` / `JoystickMove`
```

---





## 🎯 Core Systems

### Anchor System

Control how widgets resize when their parent changes size:

```blitzmax
Local panel:TPanel = New TPanel(10, 10, 300, 200)

' Anchor constants
' ANCHOR_LEFT - Distance to left edge stays fixed
' ANCHOR_TOP - Distance to top edge stays fixed
' ANCHOR_RIGHT - Distance to right edge stays fixed
' ANCHOR_BOTTOM - Distance to bottom edge stays fixed
' ANCHOR_ALL - Anchored to all edges (stretches)

' Examples:
panel.SetAnchors(ANCHOR_LEFT | ANCHOR_TOP)  ' Fixed position (default)
panel.SetAnchors(ANCHOR_RIGHT | ANCHOR_BOTTOM)  ' Stay in bottom-right corner
panel.SetAnchors(ANCHOR_LEFT | ANCHOR_RIGHT)  ' Stretch horizontally
panel.SetAnchors(ANCHOR_ALL)  ' Stretch in all directions
```

---

### Visibility System

Dual visibility control for manual and automatic hiding:

```blitzmax
' Manual visibility (user control)
widget.Show()
widget.Hide()
widget.SetVisible(True)

' Check visibility
If widget.IsVisible() Then ...

' Tabber visibility (automatic)
' Widgets in non-active tabs are automatically hidden
' This is handled internally by TTabber
```

---

### Event System

All interactive widgets generate events:

```blitzmax
' Check for events
If button.IsClicked() Then
    Print "Button was clicked!"
EndIf

If slider.ValueChanged() Then
    Print "New value: " + slider.GetValue()
EndIf

' IMPORTANT: Clear events after processing!
button.ClearEvents()
slider.ClearEvents()

' Or clear all events in GUI tree
TWidget.GuiClearEvents()
```

---

### Theme System

Customize colors globally:

```blitzmax
' Window colors
COLOR_WINDOW_BG_R = 60
COLOR_WINDOW_BG_G = 60
COLOR_WINDOW_BG_B = 60

' Button colors
COLOR_BUTTON_FACE_R = 70
COLOR_BUTTON_FACE_G = 70
COLOR_BUTTON_FACE_B = 70

' Text colors
COLOR_TEXT_NORMAL_R = 255
COLOR_TEXT_NORMAL_G = 255
COLOR_TEXT_NORMAL_B = 255

' See gui_theme.bmx for all available color constants
```

Or set individual widget colors:

```blitzmax
button.SetColor(100, 150, 200)
panel.SetColor(50, 50, 50)
```

---

### Mouse System

Centralized mouse handling:

```blitzmax
' Mouse state (auto-updated by GuiRefresh)
Local mx:Int = GuiMouse.x
Local my:Int = GuiMouse.y

' Mouse buttons
If GuiMouse.Hit() Then ...    ' Left button just pressed
If GuiMouse.Down() Then ...   ' Left button held down
If GuiMouse.Released() Then ... ' Left button just released

' Mouse wheel
Local wheel:Int = GuiMouse.WheelIdle()
If wheel > 0 Then Print "Scrolled up"
If wheel < 0 Then Print "Scrolled down"
```

---

### Clipboard System

Cut, copy, paste text:

```blitzmax
' Used internally by TextInput and TextArea
' Access via global: Gui_Clipboard

' Copy text
Gui_Clipboard.SetText("Hello")

' Paste text
Local text:String = Gui_Clipboard.GetText()

' Clear clipboard
Gui_Clipboard.Clear()
```

---

## 💡 Examples

Check the included example files:

- `Example_Template.bmx` - Minimal starter template
- `Example_Button.bmx` - Button demonstrations
- `Example_Window.bmx` - Window management
- `Example_Slider.bmx` - Slider controls
- `Example_TextArea.bmx` - Text editing
- `Example_Tabber.bmx` - Tab containers
- `Example_ContextMenu.bmx` - Right-click menus
- `Example_MessageBox.bmx` - Dialog boxes
- `Example_Treeview.bmx` - Hierarchical data
- `Example_Calculator.bmx` - Complete calculator app
- `Example_Full.bmx` - Kitchen sink demo
- `Example_OpenB3D.bmx` - 3D integration example

---

## 🎨 Advanced Usage

### Custom Widget Drawing

Override the `Draw()` method:

```blitzmax
Type TMyWidget Extends TWidget
    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y
        
        ' Your custom drawing here
        TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, 1, 100, 100, 100)
        TWidget.GuiDrawText(ax+5, ay+5, "Custom", 1, 255, 255, 255)
        
        ' Draw children
        For Local c:TWidget = EachIn children
            c.Draw(ax, ay)
        Next
    End Method
End Type
```

---

### Separate Update/Draw Cycles

For more control:

```blitzmax
While Not KeyDown(KEY_ESCAPE)
    Cls
    
    ' Update GUI logic
    TWidget.GuiUpdate()
    
    ' Your custom rendering here
    ' ...
    
    ' Draw GUI
    TWidget.GuiDraw()
    
    ' Clear events
    TWidget.GuiClearEvents()
    
    Flip
Wend
```

---

### Window Drag Handling

Prevent unwanted interactions during window dragging:

```blitzmax
' Global variable: draggedWindow
' When a window is being dragged, this is set automatically

If draggedWindow = Null Then
    ' Safe to process other interactions
EndIf
```

---

## 🔧 API Reference

### Core Functions

```blitzmax
' Initialize GUI (call once at startup)
TWidget.GuiInit()

' Set root container
TWidget.GuiSetRoot(root:TContainer)

' Get root container
Local root:TContainer = TWidget.GuiGetRoot()

' Main update/draw (call every frame)
TWidget.GuiRefresh()

' Or separate update and draw
TWidget.GuiUpdate()
TWidget.GuiDraw()

' Clear all events
TWidget.GuiClearEvents()

' Process window control buttons
TWidget.GuiProcessWindowEvents()
```

---

### Drawing Helpers

```blitzmax
' Draw rectangle (px, py, width, height, style, r, g, b, alpha)
' Styles: 0=outline, 1=flat, 2=raised, 3=pressed, 4=raised+border, 5=pressed+border
TWidget.GuiDrawRect(x, y, w, h, style, r, g, b, alpha)

' Draw text (px, py, text, style, r, g, b, alpha)
' Styles: 1=normal, 2=shadowed
TWidget.GuiDrawText(x, y, "text", style, r, g, b, alpha)

' Draw symbol (px, py, symbol, style, r, g, b, alpha)
TWidget.GuiDrawSymbol(x, y, "►", style, r, g, b, alpha)

' Draw oval (px, py, radiusX, radiusY, style, r, g, b, alpha)
' Styles: 1=flat, 2=shadowed
TWidget.GuiDrawOval(x, y, rx, ry, style, r, g, b, alpha)

' Draw line (px, py, toX, toY, style, r, g, b, alpha)
' Styles: 1=thin, 2=thick
TWidget.GuiDrawLine(x1, y1, x2, y2, style, r, g, b, alpha)

' Draw image (image, px, py, width, height, alpha)
TWidget.GuiDrawImageRect(img, x, y, w, h, alpha)

' Text measurements
Local w:Int = TWidget.GuiTextWidth("text", symbolFont=False)
Local h:Int = TWidget.GuiTextHeight("text", symbolFont=False)

' Set viewport for clipping
TWidget.GuiSetViewport(x, y, width, height)
```

## 🐛 Known Issues & Solutions

### Unknow...

---

## 🌍 Portability

Opaline is designed to be easily convertible to other languages and frameworks:

### Potential Targets
- **C/C++ with SDL2** - Direct graphics API mapping
- **FreeBasic** - Similar syntax, easy conversion
- **Monkey/Monkey2** - Compatible object model
- **Java** - Standard Swing/AWT alternative
- **Raylib** - Modern C game framework
- **PureBasic** - Native GUI alternative

### Conversion Tips
1. Replace `TList` with your language's dynamic array/list
2. Map drawing functions to your graphics library
3. Implement mouse/keyboard input handling
4. Keep the widget hierarchy and event system intact

---

## 📝 License

**Free to use** with the following terms:

✅ **You CAN:**
- Use in free or commercial projects
- Modify and customize
- Convert to other languages
- Use in games and applications

❌ **You CANNOT:**
- Sell the framework itself
- Remove attribution

**Please include** a small credit somewhere in your project! 😊

```
GUI powered by Opaline Framework
by Creepy Cat - https://github.com/BlackCreepyCat
```

---

## 🔗 Links

- **GitHub**: https://github.com/BlackCreepyCat/Blitzmax-Opaline-Gui-2D-FrameWork
- **Forum**: https://www.syntaxboom.net/forum/blitzmax-ng/code-archives-ad/1116-short-gui-kernel-skeleton
- **BlitzMax NG**: https://blitzmax.org/

---

## 🙏 Credits

Created with ❤️ by **Creepy Cat**

Special thanks to the BlitzMax NG community!

---

**Version**: 1.7  
**Last Updated**: January 2026

---

### 🎯 Quick Reference Card

```blitzmax
' === INITIALIZATION ===
TWidget.GuiInit()
Local root:TContainer = New TContainer(0, 0, w, h)
TWidget.GuiSetRoot(root)

' === MAIN LOOP ===
While Not KeyDown(KEY_ESCAPE)
    Cls
    TWidget.GuiRefresh()  ' Update + Draw
    Flip
Wend

' === COMMON PATTERNS ===
' Create window
Local win:TWindow = New TWindow(x, y, w, h, "Title")
root.AddChild(win)

' Create button
Local btn:TButton = New TButton(x, y, w, h, "Click")
win.AddChild(btn)

' Handle button click
If btn.IsClicked()
    Print "Clicked!"
    btn.ClearEvents()
EndIf

' Create text input
Local input:TTextInput = New TTextInput(x, y, w, h)
If input.TextChanged()
    Print input.GetText()
    input.ClearEvents()
EndIf

' Create slider
Local slider:TSlider = New TSlider(x, y, w, h, 0.5)
If slider.ValueChanged()
    Print slider.GetValue()
    slider.ClearEvents()
EndIf
```

Happy coding! 🚀
