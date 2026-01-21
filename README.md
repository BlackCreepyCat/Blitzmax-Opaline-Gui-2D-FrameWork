                 Simple GUI Framework - BlitzMax NG
                             Opaline UI

By Creepy Cat (C)2025/2026 : https://github.com/BlackCreepyCat

You can use this code:
- However you wish, but you are prohibited from selling it...
- You can convert it into another language! Do not hesitate!
- Use it For paid/free apps/games, i don't care...
- I'm just asking for a small citation somewhere! :)

What you need to see? Just Blitzmax! (it's free/opensource) :
-------------------------------------------------------------
- https://blitzmax.org/
- https://github.com/bmx-ng

You want to use VS Code? You can!
---------------------------------
- https://code.visualstudio.com/download
- https://marketplace.visualstudio.com/items?itemName=Hezkore.blitzmax

Description:
------------
Opaline UI is a low-level kernel for creating a graphical interface from scratch. I believe it can be easily converted to other languages, only if they allow linked lists. No complex external dependencies (it's self-contained). It need also includes some basic graphical functions like:

![Nouveau projet](https://github.com/user-attachments/assets/c8358eda-b1c8-4e43-8be3-8bb32d76c700)

- Text/Box/Rect/Line/Oval/Circle/SetViewport/StringWidth (see the class: gui_core.bmx).

Example with the gui_core.bmx to C++ class convertion and SDL:
*-------------------------------------------------------------
<img width="769" height="951" alt="image" src="https://github.com/user-attachments/assets/bf825650-8f07-4f63-8436-756594d7c10a" />


Maybe compatible or can be converted for:
-----------------------------------------
- FreeBasic?
- Monkey?
- Monkey2?
- PureBasic?
- Java?
- Raylib?
- SDL/SDL2/C/C++?

![Nouveau projet](https://github.com/user-attachments/assets/be24bc48-856e-46c1-9d74-2a4adb5eb43a)

The GUI is really ugly! :) But that's intentional... This way, only the GUI's behavior (the most important part) is coded; all the other graphical improvements take up code and make it less readable.

It's a kernel, very, very low level... But once the core of the GUI is converted, you're free to improve it! At least the widget behaviors (which are numerous, believe me! but invisible to GUI users) are there.

Forum Link:
-----------
https://www.syntaxboom.net/forum/blitzmax-ng/code-archives-ad/1116-short-gui-kernel-skeleton

<img width="1923" height="1106" alt="image" src="https://github.com/user-attachments/assets/f24759a5-2068-41df-a099-b03371c72829" />





# 🎨 Opaline GUI Framework

**A lightweight, fully-featured GUI framework for BlitzMax NG**

![Version](https://img.shields.io/badge/version-1.0-blue.svg)
![License](https://img.shields.io/badge/license-Free-green.svg)
![BlitzMax NG](https://img.shields.io/badge/BlitzMax-NG-orange.svg)

By **Creepy Cat** © 2025/2026

---

## ✨ Features

- 🪟 **17 Widget Types** - Windows, Buttons, Labels, Panels, TextInputs, TextAreas, ListBoxes, ComboBoxes, CheckBoxes, Radio Buttons, Sliders, ProgressBars, Tabbers, ImageBoxes, MessageBoxes, Context Menus
- 🎯 **Modal Windows** - Block input to other windows with overlay effect
- 📐 **Anchor System** - Automatic widget resizing when parent resizes
- 🖱️ **Window Resizing** - Drag the bottom-right grip to resize windows
- 🎨 **Theming** - Easily customizable colors and styles via constants
- ⌨️ **Keyboard Support** - Full text editing with Ctrl+C/X/V, cursor navigation
- 📋 **Clipboard Integration** - System clipboard support for copy/paste
- 🔄 **Z-Ordering** - Proper window stacking and focus management
- 📜 **Scrolling** - Built-in scrollbar support for lists and text areas

---

## 📦 Installation

1. Clone or download this repository
2. Place the GUI files in your project folder
3. Include the main file in your BlitzMax project:

```blitzmax
SuperStrict
Import BRL.GLMax2D
Import BRL.LinkedList

Include "gui_opaline.bmx"
```

---

## 🚀 Quick Start

```blitzmax
SuperStrict
Import BRL.GLMax2D
Import BRL.LinkedList

Include "gui_opaline.bmx"

' Create graphics window
Graphics 1280, 720, 0

' Initialize GUI system
TWidget.GuiInit()

' Create root container
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

' Create a window
Local win:TWindow = New TWindow(100, 100, 400, 300, "My Window")
win.SetResizable(True)
root.AddChild(win)

' Add a button to the window
Local btn:TButton = New TButton(20, 20, 150, 35, "Click Me!")
win.AddChild(btn)

' Main loop
While Not AppTerminate() And Not KeyHit(KEY_ESCAPE)
    Cls
    TWidget.GuiRefresh()
    
    ' Check for button click
    If btn.HasEvent("click")
        Print "Button clicked!"
    EndIf
    
    TWidget.GuiClearEvents()
    Flip
Wend
```

---

## 📚 Widget Reference

### TWindow

Draggable window with title bar, control buttons, and optional status bar.

```blitzmax
' Constructor
Local win:TWindow = New TWindow(x, y, width, height, title, showClose, showMin, showMax, showStatusBar)

' Methods
win.SetResizable(True)              ' Enable window resizing
win.SetMinSize(200, 150)            ' Set minimum size (client area)
win.SetStatusText("Ready")          ' Simple status bar text
win.AddStatusSection("Text", -1)    ' Add status bar section (-1 = flexible width)
win.SetStatusSection(0, "New Text") ' Update section text
win.SetModalState(True)             ' Make window modal
win.Close()                         ' Close and remove window
```

### TButton

Clickable button with hover and pressed states.

```blitzmax
Local btn:TButton = New TButton(x, y, width, height, "Label")

' Check for click event
If btn.HasEvent("click")
    ' Handle click
EndIf
```

### TLabel

Text display widget with alignment options.

```blitzmax
Local lbl:TLabel = New TLabel(x, y, width, height, "Text", alignment)

' Alignments: LABEL_ALIGN_LEFT, LABEL_ALIGN_CENTER, LABEL_ALIGN_RIGHT
lbl.SetColor(255, 200, 100)  ' Set text color
lbl.SetText("New Text")       ' Change text
```

### TPanel

Container with optional title and border styles.

```blitzmax
Local panel:TPanel = New TPanel(x, y, width, height, "Title", style)

' Styles: PANEL_STYLE_FLAT, PANEL_STYLE_RAISED, PANEL_STYLE_SUNKEN
panel.AddChild(someWidget)  ' Add widgets to panel
```

### TTextInput

Single-line text input field.

```blitzmax
Local input:TTextInput = New TTextInput(x, y, width, height, "Default text")

input.SetPlaceholder("Enter name...")  ' Placeholder text
input.SetMaxLength(50)                  ' Character limit
input.SetPasswordMode(True)             ' Hide characters
Local text:String = input.GetText()     ' Get current text
```

### TTextArea

Multi-line text editor with optional line numbers.

```blitzmax
Local textArea:TTextArea = New TTextArea(x, y, width, height, "Initial text")

textArea.SetShowLineNumbers(True)   ' Show line numbers
textArea.SetReadOnly(True)          ' Make read-only
textArea.SetText("New content")     ' Set text
Local text:String = textArea.GetText()
Local lineCount:Int = textArea.GetLineCount()
```

### TCheckBox

Toggle checkbox with label.

```blitzmax
Local chk:TCheckBox = New TCheckBox(x, y, width, height, "Option", initialState)

If chk.IsChecked()
    ' Checkbox is checked
EndIf
chk.SetChecked(True)  ' Set state programmatically
```

### TRadio

Radio button for mutually exclusive options.

```blitzmax
' Create a group (TList) for mutual exclusion
Local group:TList = New TList

Local r1:TRadio = New TRadio(x, y, 20, 20, "Option 1", group)
Local r2:TRadio = New TRadio(x, y+30, 20, 20, "Option 2", group)
Local r3:TRadio = New TRadio(x, y+60, 20, 20, "Option 3", group)

r2.selected = True  ' Set default selection
```

### TSlider

Horizontal slider for value selection.

```blitzmax
Local slider:TSlider = New TSlider(x, y, width, height, minValue, maxValue)

slider.SetValue(50)                  ' Set current value
Local val:Float = slider.GetValue()  ' Get current value
```

### TProgressBar

Progress indicator bar.

```blitzmax
Local progress:TProgressBar = New TProgressBar(x, y, width, height)

progress.SetValue(0.75)  ' Set progress (0.0 to 1.0)
progress.SetShowText(True)  ' Show percentage text
```

### TListBox

Scrollable list with optional multi-column support.

```blitzmax
Local list:TListBox = New TListBox(x, y, width, height)

list.AddItem("Item 1")
list.AddItem("Item 2")
list.AddItem("Item 3")

Local selected:Int = list.GetSelectedIndex()
Local text:String = list.GetSelectedItem()

' Multi-column support
list.SetColumns(["Name", "Size", "Date"])
list.AddItem("File.txt,1.2 KB,2025-01-15")
```

### TComboBox

Dropdown selection box.

```blitzmax
Local combo:TComboBox = New TComboBox(x, y, width, height)

combo.SetPlaceholder("Select...")
combo.AddItem("Option 1")
combo.AddItem("Option 2")
combo.AddItem("Option 3")

combo.SetSelectedIndex(0)  ' Select first item
Local selected:String = combo.GetSelectedText()
```

### TTabber

Tab control for organizing content.

```blitzmax
Local tabber:TTabber = New TTabber(x, y, width, height)

tabber.AddTab("General")
tabber.AddTab("Settings")
tabber.AddTab("About")

' Add widgets to specific tabs
Local lbl:TLabel = New TLabel(20, 30, 200, 20, "General content")
tabber.AddChild(lbl)
tabber.AddWidgetToTab(0, lbl)  ' Assign to first tab
```

### TImageBox

Image display with scaling options.

```blitzmax
Local imgBox:TImageBox = New TImageBox(x, y, width, height)

imgBox.SetImage(myPixmap)           ' Set image from TPixmap
imgBox.SetImageFromFile("pic.png")  ' Load from file
imgBox.SetScaleMode(SCALE_FIT)      ' SCALE_NONE, SCALE_FIT, SCALE_STRETCH
```

### TMessageBox

Modal dialog boxes.

```blitzmax
' Show a message box
TMessageBox.Show("Title", "Message text", MSGBOX_OK, callbackFunction)

' Types: MSGBOX_OK, MSGBOX_OKCANCEL, MSGBOX_YESNO, MSGBOX_YESNOCANCEL

' Callback function
Function OnResult:Int(result:Int)
    Select result
        Case MSGBOX_RESULT_OK    Print "OK clicked"
        Case MSGBOX_RESULT_YES   Print "Yes clicked"
        Case MSGBOX_RESULT_NO    Print "No clicked"
    End Select
End Function
```

### TContextMenu

Right-click context menus.

```blitzmax
Local menu:TContextMenu = New TContextMenu()

menu.AddItem("Cut", "cut", "Ctrl+X")
menu.AddItem("Copy", "copy", "Ctrl+C")
menu.AddItem("Paste", "paste", "Ctrl+V")
menu.AddSeparator()
menu.AddCheckItem("Word Wrap", "wrap", True)
menu.AddDisabledItem("Unavailable", "disabled")

' Show menu at mouse position
menu.ShowAt(MouseX(), MouseY())

' Check for selection
If menu.HasEvent("select")
    Local action:String = menu.GetSelectedAction()
    Select action
        Case "cut"   ' Handle cut
        Case "copy"  ' Handle copy
    End Select
EndIf
```

---

## 📐 Anchor System

The anchor system allows widgets to automatically resize and reposition when their parent window is resized.

### Anchor Constants

```blitzmax
ANCHOR_NONE   = 0   ' No anchor (centers on resize)
ANCHOR_LEFT   = 1   ' Distance to left edge stays fixed
ANCHOR_TOP    = 2   ' Distance to top edge stays fixed
ANCHOR_RIGHT  = 4   ' Distance to right edge stays fixed
ANCHOR_BOTTOM = 8   ' Distance to bottom edge stays fixed
ANCHOR_ALL    = 15  ' Anchored to all edges (stretches)
```

### Usage Examples

```blitzmax
' TextArea that stretches with window
textArea.SetAnchors(ANCHOR_ALL)

' Button that stays in bottom-right corner
btnOK.SetAnchors(ANCHOR_RIGHT | ANCHOR_BOTTOM)

' Label that stretches horizontally but stays at top
titleLabel.SetAnchors(ANCHOR_LEFT | ANCHOR_TOP | ANCHOR_RIGHT)

' Panel that only stretches vertically
sidePanel.SetAnchors(ANCHOR_LEFT | ANCHOR_TOP | ANCHOR_BOTTOM)

' Widget that centers (moves proportionally)
logo.SetAnchors(ANCHOR_NONE)
```

### Behavior

| Anchors | Horizontal Behavior | Vertical Behavior |
|---------|--------------------|--------------------|
| LEFT only | Fixed position | - |
| RIGHT only | Moves with right edge | - |
| LEFT + RIGHT | Stretches width | - |
| TOP only | - | Fixed position |
| BOTTOM only | - | Moves with bottom edge |
| TOP + BOTTOM | - | Stretches height |
| NONE | Centers (moves half) | Centers (moves half) |

---

## 🎨 Theming

Customize the look by modifying constants in `gui_constants.bmx`:

```blitzmax
' Window colors
Const COLOR_TITLEBAR_ACTIVE_R:Int = 60
Const COLOR_TITLEBAR_ACTIVE_G:Int = 60
Const COLOR_TITLEBAR_ACTIVE_B:Int = 80

' Button colors
Const COLOR_BUTTON_NORMAL_R:Int = 70
Const COLOR_BUTTON_NORMAL_G:Int = 70
Const COLOR_BUTTON_NORMAL_B:Int = 90

' Text colors
Const COLOR_TEXT_R:Int = 220
Const COLOR_TEXT_G:Int = 220
Const COLOR_TEXT_B:Int = 230

' And many more...
```

---

## 📁 File Structure

```
gui_opaline.bmx       ' Main include file (imports all modules)
gui_constants.bmx     ' Theme colors and layout constants
gui_core.bmx          ' Base TWidget class and utilities
gui_mouse.bmx         ' Mouse state management
gui_container.bmx     ' Root container
gui_window.bmx        ' TWindow widget
gui_button.bmx        ' TButton widget
gui_label.bmx         ' TLabel widget
gui_panel.bmx         ' TPanel widget
gui_checkbox.bmx      ' TCheckBox widget
gui_radio.bmx         ' TRadio widget
gui_slider.bmx        ' TSlider widget
gui_progressbar.bmx   ' TProgressBar widget
gui_textinput.bmx     ' TTextInput widget
gui_textarea.bmx      ' TTextArea widget
gui_listbox.bmx       ' TListBox widget
gui_combobox.bmx      ' TComboBox widget
gui_tabber.bmx        ' TTabber widget
gui_imagebox.bmx      ' TImageBox widget
gui_messagebox.bmx    ' TMessageBox widget
gui_taskbar.bmx       ' TTaskbar widget
gui_contextmenu.bmx   ' TContextMenu widget
```

---

## 🔄 Main Loop Structure

```blitzmax
' Initialize
Graphics 1920, 1080, 0
TWidget.GuiInit()
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

' Create your UI here...

' Main loop
While Not AppTerminate()
    Cls
    
    ' Update and draw all widgets
    TWidget.GuiRefresh()
    
    ' Handle your events here
    If myButton.HasEvent("click")
        ' Do something
    EndIf
    
    ' Clear events at end of frame
    TWidget.GuiClearEvents()
    
    Flip
Wend
```

---

## 📝 License

**Free to use** with the following conditions:

- ✅ Use in commercial or free applications/games
- ✅ Convert to other programming languages
- ✅ Modify and extend
- ❌ Sell the framework itself
- 📌 Please include a small credit/citation somewhere

---

## 🤝 Contributing

Contributions are welcome! Feel free to:

- Report bugs
- Suggest features
- Submit pull requests
- Share your projects using Opaline

---

## 📧 Contact

- **GitHub**: [BlackCreepyCat](https://github.com/BlackCreepyCat)

---

## 🙏 Acknowledgments

Built with ❤️ for the BlitzMax community.

Special thanks to all contributors and users!


