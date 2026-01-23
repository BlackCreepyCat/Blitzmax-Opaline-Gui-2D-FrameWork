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
--------------------------------------------------------------
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

<img width="1923" height="1108" alt="image" src="https://github.com/user-attachments/assets/f933c388-e862-4707-9a95-2e8b85685291" />

Work with Open B3D:
-------------------
<img width="1027" height="796" alt="image" src="https://github.com/user-attachments/assets/754d2ea3-d310-42fb-bb8d-20af181d958d" />




<p align="center">
  <img src="https://via.placeholder.com/1200x300/2c3e50/ecf0f1?text=Opaline+GUI+Framework" alt="Opaline GUI Banner" width="100%">
</p>

<h1 align="center">🎨 Opaline GUI – Lightweight 2D Framework for BlitzMax NG</h1>

<p align="center">
  <strong>A from-scratch, portable GUI kernel for building interactive interfaces</strong><br>
  By <a href="https://github.com/BlackCreepyCat">Creepy Cat</a> © 2025–2026
</p>

<p align="center">
  <a href="https://github.com/BlackCreepyCat/Blitzmax-Opaline-Gui-2D-FrameWork/stargazers"><img src="https://img.shields.io/github/stars/BlackCreepyCat/Blitzmax-Opaline-Gui-2D-FrameWork?style=social" alt="Stars"></a>
  <a href="https://github.com/BlackCreepyCat/Blitzmax-Opaline-Gui-2D-FrameWork/releases"><img src="https://img.shields.io/github/v/release/BlackCreepyCat/Blitzmax-Opaline-Gui-2D-FrameWork?color=green" alt="Latest Release"></a>
  <a href="https://github.com/BlackCreepyCat/Blitzmax-Opaline-Gui-2D-FrameWork/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-Free%20Use-green" alt="License"></a>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/c8358eda-b1c8-4e43-8be3-8bb32d76c700" alt="Opaline GUI Example" width="600">
</p>

---

## Table of Contents

- [Why Opaline?](#-why-opaline)
- [Features](#-features)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Widget Reference](#-widget-reference)
  - [TWindow](#twindow)
  - [TButton](#tbutton)
  - [TLabel](#tlabel)
  - [TPanel](#tpanel)
  - [TTextInput](#ttextinput)
  - [TTextArea](#ttextarea)
  - [TCheckBox](#tcheckbox)
  - [TRadio](#tradio)
  - [TSlider](#tslider)
  - [TProgressBar](#tprogressbar)
  - [TListBox](#tlistbox)
  - [TComboBox](#tcombobox)
  - [TTabber](#ttabber)
  - [TImageBox](#timagebox)
  - [TMessageBox](#tmessagebox)
  - [TContextMenu](#tcontextmenu)
- [Anchoring System](#-anchoring-system)
- [Customization & Theming](#-customization--theming)
- [License](#️-license)
- [Contributions & Support](#-contributions--support)

---

## ✨ Why Opaline?

Opaline is a **low-level GUI kernel** built from scratch in BlitzMax NG. It's designed to be:

- **Understandable and Portable**: Easily convert to other languages like C++, SDL, Raylib, or even FreeBasic/Monkey (as long as linked lists are supported).
- **Dependency-Free**: No complex externals—just core BlitzMax modules.
- **Behavior-Focused**: Prioritizes widget logic (events, focus, anchoring) over fancy visuals. It's intentionally "ugly" so you can customize the look!
- **Solid Core**: Handles invisible complexities like z-order, modality, scrolling, and clipboard integration.

The GUI might look basic, but its behavior is mature and robust. Perfect for games, tools, or apps.

<p align="center">
  <img src="https://github.com/user-attachments/assets/8502a366-f630-4ee7-b8f2-b3f57e68500a" alt="Opaline GUI Screenshot" width="800">
</p>

Compatible with OpenB3D for 3D integration:

<p align="center">
  <img src="https://github.com/user-attachments/assets/754d2ea3-d310-42fb-bb8d-20af181d958d" alt="OpenB3D Integration" width="600">
</p>

---

## 🚀 Features

- **17+ Widgets**: Fully-featured with mature behaviors.
- **Resizable & Modal Windows**: Drag grips, overlays, and status bars.
- **Powerful Anchoring**: Widgets stretch/stick automatically on resize.
- **Theming**: Simple color constants for quick customization.
- **Keyboard Handling**: Full text editing, shortcuts (Ctrl+C/X/V), navigation.
- **Clipboard Support**: System-integrated copy/paste.
- **Z-Order & Focus**: Automatic management.
- **Scrolling**: Built-in for lists and text areas.
- **Context Menus & Message Boxes**: Advanced right-click and dialogs.
- **Event System**: Check for "click", "change", etc., in your loop.

---

## 📦 Installation

1. **Clone or Download**: Get this repo.
2. **Add to Project**: Copy the `.bmx` files to your project folder.
3. **Include Main File**:

```bmx
SuperStrict

Import BRL.GLMax2D
Import BRL.LinkedList

Include "gui_opaline.bmx"

Requirements:BlitzMax NG: blitzmax.org or GitHub.
Recommended IDE: VS Code with BlitzMax Extension.

 Quick StartA minimal example to get a window and button working:bmx

SuperStrict
Import BRL.GLMax2D
Import BRL.LinkedList
Include "gui_opaline.bmx"

Graphics 1280, 720, 0

TWidget.GuiInit()
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

Local win:TWindow = New TWindow(180, 120, 520, 380, "Opaline Test", True, True, True, True)
win.SetResizable(True)
win.SetMinSize(320, 240)
root.AddChild(win)

Local btn:TButton = New TButton(30, 40, 180, 45, "Click Me!")
win.AddChild(btn)

While Not AppTerminate() And Not KeyHit(KEY_ESCAPE)
    Cls
    TWidget.GuiRefresh()
    
    If btn.HasEvent("click")
        Print "Button clicked! :3"
    EndIf
    
    TWidget.GuiClearEvents()
    Flip
Wend

 Widget ReferenceDetailed explanations, constructors, methods, and examples for each widget.TWindowDraggable, resizable window with title bar, buttons, and optional status bar.Constructor:bmx

Local win:TWindow = New TWindow(x:Int, y:Int, width:Int, height:Int, title:String, showClose:Bool, showMin:Bool, showMax:Bool, showStatusBar:Bool)

Key Methods:SetResizable(resizable:Bool): Enable/disable resizing.
SetMinSize(width:Int, height:Int): Set minimum client area size.
SetStatusText(text:String): Set simple status bar text.
AddStatusSection(text:String, width:Int): Add a status bar section (-1 for flexible).
SetStatusSection(index:Int, text:String): Update a section.
SetModalState(modal:Bool): Make modal (blocks others).
Close(): Close and remove the window.

Example:bmx

Local win:TWindow = New TWindow(100, 100, 400, 300, "My Window", True, True, True, True)
win.SetResizable(True)
win.SetMinSize(200, 150)
win.AddStatusSection("Status", -1)
root.AddChild(win)

TButtonClickable button with hover/pressed states.Constructor:bmx

Local btn:TButton = New TButton(x:Int, y:Int, width:Int, height:Int, label:String)

Key Methods:HasEvent(event:String): Check for "click".

Example:bmx

Local btn:TButton = New TButton(20, 20, 150, 35, "Click Me!")
If btn.HasEvent("click")
    Print "Clicked!"
EndIf

TLabelText display with alignment.Constructor:bmx

Local lbl:TLabel = New TLabel(x:Int, y:Int, width:Int, height:Int, text:String, alignment:Int)

Alignments: LABEL_ALIGN_LEFT, LABEL_ALIGN_CENTER, LABEL_ALIGN_RIGHT.Key Methods:SetColor(r:Int, g:Int, b:Int): Set text color.
SetText(text:String): Update text.

Example:bmx

Local lbl:TLabel = New TLabel(20, 20, 200, 20, "Hello", LABEL_ALIGN_CENTER)
lbl.SetColor(255, 0, 0)

TPanelContainer with title and border style.Constructor:bmx

Local panel:TPanel = New TPanel(x:Int, y:Int, width:Int, height:Int, title:String, style:Int)

Styles: PANEL_STYLE_FLAT, PANEL_STYLE_RAISED, PANEL_STYLE_SUNKEN.Key Methods:AddChild(widget:TWidget): Add sub-widgets.

Example:bmx

Local panel:TPanel = New TPanel(20, 20, 300, 200, "Group", PANEL_STYLE_RAISED)
panel.AddChild(New TButton(10, 10, 100, 30, "Inside"))

TTextInputSingle-line text input.Constructor:bmx

Local input:TTextInput = New TTextInput(x:Int, y:Int, width:Int, height:Int, defaultText:String)

Key Methods:SetPlaceholder(text:String): Set placeholder.
SetMaxLength(max:Int): Character limit.
SetPasswordMode(mode:Bool): Hide input.
GetText():String: Get current text.

Example:bmx

Local input:TTextInput = New TTextInput(20, 20, 200, 30, "")
input.SetPlaceholder("Username")
input.SetMaxLength(20)

TTextAreaMulti-line text editor.Constructor:bmx

Local area:TTextArea = New TTextArea(x:Int, y:Int, width:Int, height:Int, initialText:String)

Key Methods:SetShowLineNumbers(show:Bool): Toggle line numbers.
SetReadOnly(readOnly:Bool): Make uneditable.
SetText(text:String): Set content.
GetText():String: Get content.
GetLineCount():Int: Get number of lines.

Example:bmx

Local area:TTextArea = New TTextArea(20, 20, 300, 200, "Line1\nLine2")
area.SetShowLineNumbers(True)

TCheckBoxToggle checkbox.Constructor:bmx

Local chk:TCheckBox = New TCheckBox(x:Int, y:Int, width:Int, height:Int, label:String, initialState:Bool)

Key Methods:IsChecked():Bool: Check state.
SetChecked(checked:Bool): Set state.

Example:bmx

Local chk:TCheckBox = New TCheckBox(20, 20, 150, 20, "Enable Feature", False)
If chk.IsChecked() Then Print "Enabled!"

TRadioGrouped radio buttons.Constructor:bmx

Local radio:TRadio = New TRadio(x:Int, y:Int, width:Int, height:Int, label:String, group:TList)

Key Methods:Use a shared TList for grouping (mutual exclusion).
selected:Bool: Check/set selection.

Example:bmx

Local group:TList = New TList
Local r1:TRadio = New TRadio(20, 20, 150, 20, "Option 1", group)
Local r2:TRadio = New TRadio(20, 50, 150, 20, "Option 2", group)
r1.selected = True

TSliderValue slider.Constructor:bmx

Local slider:TSlider = New TSlider(x:Int, y:Int, width:Int, height:Int, minValue:Float, maxValue:Float)

Key Methods:SetValue(value:Float): Set position.
GetValue():Float: Get current value.

Example:bmx

Local slider:TSlider = New TSlider(20, 20, 200, 20, 0, 100)
slider.SetValue(50)

TProgressBarProgress indicator.Constructor:bmx

Local prog:TProgressBar = New TProgressBar(x:Int, y:Int, width:Int, height:Int)

Key Methods:SetValue(value:Float): Set progress (0.0-1.0).
SetShowText(show:Bool): Show percentage.

Example:bmx

Local prog:TProgressBar = New TProgressBar(20, 20, 200, 20)
prog.SetValue(0.75)
prog.SetShowText(True)

TListBoxScrollable list.Constructor:bmx

Local list:TListBox = New TListBox(x:Int, y:Int, width:Int, height:Int)

Key Methods:AddItem(item:String): Add entry.
GetSelectedIndex():Int: Get selection.
GetSelectedItem():String: Get selected text.
SetColumns(columns:String[]): For multi-column (comma-separated items).

Example:bmx

Local list:TListBox = New TListBox(20, 20, 200, 150)
list.AddItem("Apple")
list.AddItem("Banana")

TComboBoxDropdown selector.Constructor:bmx

Local combo:TComboBox = New TComboBox(x:Int, y:Int, width:Int, height:Int)

Key Methods:SetPlaceholder(text:String): Default text.
AddItem(item:String): Add option.
SetSelectedIndex(index:Int): Select item.
GetSelectedText():String: Get selection.

Example:bmx

Local combo:TComboBox = New TComboBox(20, 20, 200, 30)
combo.AddItem("Red")
combo.AddItem("Blue")

TTabberTab organizer.Constructor:bmx

Local tabber:TTabber = New TTabber(x:Int, y:Int, width:Int, height:Int)

Key Methods:AddTab(title:String): Add tab.
AddWidgetToTab(tabIndex:Int, widget:TWidget): Assign widget to tab.

Example:bmx

Local tabber:TTabber = New TTabber(20, 20, 400, 300)
tabber.AddTab("Tab 1")
tabber.AddTab("Tab 2")
Local lbl:TLabel = New TLabel(10, 10, 100, 20, "Content")
tabber.AddWidgetToTab(0, lbl)

TImageBoxImage viewer.Constructor:bmx

Local img:TImageBox = New TImageBox(x:Int, y:Int, width:Int, height:Int)

Key Methods:SetImage(pixmap:TPixmap): Set from pixmap.
SetImageFromFile(file:String): Load from file.
SetScaleMode(mode:Int): SCALE_NONE, SCALE_FIT, SCALE_STRETCH.

Example:bmx

Local img:TImageBox = New TImageBox(20, 20, 200, 150)
img.SetImageFromFile("image.png")
img.SetScaleMode(SCALE_FIT)

TMessageBoxModal dialogs.Static Methods:Show(title:String, message:String, type:Int, callback:Function(result:Int))

Types: MSGBOX_OK, MSGBOX_OKCANCEL, MSGBOX_YESNO, MSGBOX_YESNOCANCEL.Results: MSGBOX_RESULT_OK, MSGBOX_RESULT_CANCEL, etc.Example:bmx

Function OnMsgResult(result:Int)
    If result = MSGBOX_RESULT_YES Then Print "Yes!"
End Function

TMessageBox.Show("Confirm", "Are you sure?", MSGBOX_YESNO, OnMsgResult)

TContextMenuRight-click menu.Constructor:bmx

Local menu:TContextMenu = New TContextMenu()

Key Methods:AddItem(label:String, action:String, shortcut:String): Add entry.
AddSeparator(): Add divider.
AddCheckItem(label:String, action:String, checked:Bool): Toggle item.
AddDisabledItem(label:String, action:String): Disabled entry.
ShowAt(x:Int, y:Int): Display at position.
HasEvent(event:String): Check "select".
GetSelectedAction():String: Get chosen action.

Example:bmx

Local menu:TContextMenu = New TContextMenu()
menu.AddItem("Cut", "cut", "Ctrl+X")
menu.AddSeparator()
menu.ShowAt(MouseX(), MouseY())
If menu.HasEvent("select") And menu.GetSelectedAction() = "cut" Then Print "Cut!"

 Anchoring SystemWidgets anchor to parent edges for auto-resizing.Constants:ANCHOR_NONE = 0 (centers)
ANCHOR_LEFT = 1
ANCHOR_TOP = 2
ANCHOR_RIGHT = 4
ANCHOR_BOTTOM = 8
ANCHOR_ALL = 15 (stretches)

Method:bmx

widget.SetAnchors(anchors:Int)

Example:bmx

btn.SetAnchors(ANCHOR_RIGHT | ANCHOR_BOTTOM)  // Sticks to bottom-right

 Customization & ThemingEdit gui_constants.bmx for colors:bmx

Const GUI_COLOR_WINDOW_BG:Int = $2C2C2C
Const GUI_COLOR_TEXT:Int = $E0E0E0
' ... more constants

Override Draw() methods in widgets for custom rendering. LicenseFree to use for any purpose (free/paid apps/games). Porting encouraged! Just credit me if used extensively. No selling as-is. Contributions & SupportOpen issues/PRs welcome!
Original Forum: syntaxbomb.net
Tag me on X: @BlackCreepy_Cat

Have fun building creepy UIs! ‍



