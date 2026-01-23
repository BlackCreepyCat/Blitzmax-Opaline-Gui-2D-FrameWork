<p align="center">
  <img src="https://via.placeholder.com/1200x300/2c3e50/ecf0f1?text=Opaline+GUI+Framework" alt="Opaline GUI Banner">
</p>

<h1 align="center">🎨 Opaline GUI – BlitzMax NG 2D Framework</h1>

<p align="center">
  <strong>A low-level, lightweight, standalone and portable GUI framework</strong><br>
  By <a href="https://github.com/BlackCreepyCat">Creepy Cat</a> © 2025–2026
</p>

<p align="center">
  <a href="https://github.com/BlackCreepyCat/Blitzmax-Opaline-Gui-2D-FrameWork/stargazers">
    <img src="https://img.shields.io/github/stars/BlackCreepyCat/Blitzmax-Opaline-Gui-2D-FrameWork?style=social" alt="Stars">
  </a>
  <a href="https://github.com/BlackCreepyCat/Blitzmax-Opaline-Gui-2D-FrameWork/releases">
    <img src="https://img.shields.io/github/v/release/BlackCreepyCat/Blitzmax-Opaline-Gui-2D-FrameWork?color=green" alt="Latest Release">
  </a>
</p>

---

## ✨ Why Opaline?

Opaline is a **from-scratch GUI kernel** built very low-level, designed to:

- Be **easy to understand** and **portable** to other languages (as long as linked lists are supported)
- Have **zero complex external dependencies**
- Focus on **widget behavior** (the really hard part!) rather than fancy graphics
- Look intentionally ugly 😈 → you can make it pretty later!

Yes, it's ugly on purpose. But the core (events, focus, z-order, anchoring, modality, scrolling, clipboard…) is rock-solid.

## 🚀 Features (latest version)

- **17+ mature widgets**
- **Resizable windows** (bottom-right grip)
- **Modal windows** with overlay
- Powerful **anchoring** system (stretch / stick to edges)
- Super simple **themes** via color constants
- Full **keyboard support**: text editing, Ctrl+C/X/V, navigation, selection
- System **clipboard** integration
- Automatic **z-order & focus** management
- Built-in **scrolling** (lists, textareas)
- **Context menus**, **message boxes**, **taskbar** support…

### Available Widgets

- `TWindow` – Draggable, resizable, modal windows with status bar
- `TButton`, `TLabel`, `TPanel`
- `TTextInput` (single-line + placeholder + password mode)
- `TTextArea` (multi-line + line numbers + readonly)
- `TCheckBox`, `TRadio` (grouped)
- `TSlider`, `TProgressBar`
- `TListBox` (supports multiple columns)
- `TComboBox` (dropdown)
- `TTabber` (tabs)
- `TImageBox` (images + scaling modes)
- `TMessageBox` (standard OK/YesNo/Cancel modals…)
- `TContextMenu` (advanced right-click menus)
- `TTaskbar` (window taskbar)

## 📦 Installation (BlitzMax NG only)

1. Clone or download this repo
2. Put the `.bmx` files in your project
3. Include the main file:

```bmx
SuperStrict

Import BRL.GLMax2D
Import BRL.LinkedList

Include "gui_opaline.bmx"

Requirements: BlitzMax NG → https://blitzmax.org / https://github.com/bmx-ngRecommended editor: VS Code + BlitzMax extension → https://marketplace.visualstudio.com/items?itemName=Hezkore.blitzmax Quick Start (minimal example)bmx

SuperStrict
Import BRL.GLMax2D
Import BRL.LinkedList
Include "gui_opaline.bmx"

Graphics 1280, 720, 0

TWidget.GuiInit()
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

' A nice window
Local win:TWindow = New TWindow(180, 120, 520, 380, "Opaline Test", True, True, True, True)
win.SetResizable(True)
win.SetMinSize(320, 240)
root.AddChild(win)

' A button that does something
Local btn:TButton = New TButton(30, 40, 180, 45, "Click me!")
win.AddChild(btn)

While Not AppTerminate() And Not KeyHit(KEY_ESCAPE)
    Cls
    TWidget.GuiRefresh()
    
    If btn.HasEvent("click")
        Print "Button was clicked! :3"
        ' win.SetStatusText("Action completed!")
    EndIf
    
    TWidget.GuiClearEvents()
    Flip
Wend

 Widget Documentation (concrete examples)Check the original README for more detailed widget sections (kept and improved).Quick extra examples:bmx

' TextInput with placeholder & password
Local pass:TTextInput = New TTextInput(20, 100, 240, 32, "")
pass.SetPlaceholder("Password...")
pass.SetPasswordMode(True)

' Animated ProgressBar
Local prog:TProgressBar = New TProgressBar(20, 180, 300, 28)
prog.SetValue(0.68)
prog.SetShowText(True)

 Customization / ThemingChange colors in gui_constants.bmx:bmx

Const GUI_COLOR_WINDOW_BG:Int     = $2C2C2C
Const GUI_COLOR_BUTTON_NORMAL:Int = $3A3A3A
Const GUI_COLOR_TEXT:Int          = $E0E0E0
' etc.

You can also override the Draw() method of any widget for a fully custom look. Anchoring System (very powerful)bmx

btn.SetAnchors(ANCHOR_RIGHT | ANCHOR_BOTTOM)      ' sticks to bottom-right
textarea.SetAnchors(ANCHOR_ALL)                   ' stretches with window
label.SetAnchors(ANCHOR_LEFT | ANCHOR_TOP)        ' fixed top-left

Constants: ANCHOR_NONE, LEFT, TOP, RIGHT, BOTTOM, ALL LicenseUse it however you want:Free / paid / commercial / game / tool → allowed
Porting to FreeBasic, Monkey, C++, Raylib, SDL… → encouraged!
Small request: credit me / link back if you use it a lot 

Selling the framework as-is is not allowed. Contributions & SupportIssues / Pull Requests → very welcome!
Original forum thread: https://www.syntaxboom.net/forum/blitzmax-ng/code-archives-ad/1116-short-gui-kernel-skeleton
Tag me on X: @BlackCreepy_Cat

Have fun coding creepy interfaces! ‍

