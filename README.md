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
  <img src="https://via.placeholder.com/1200x300/1a1a1a/ffffff?text=Opaline+GUI+Framework" alt="Opaline GUI Banner" width="100%">
</p>

<h1 align="center">🎨 Opaline GUI – Lightweight 2D GUI Framework for BlitzMax NG</h1>

<p align="center">
  <strong>A low-level, portable, dependency-free GUI kernel built from scratch</strong><br>
  By <a href="https://github.com/BlackCreepyCat">Creepy Cat</a> © 2025–2026
</p>

<p align="center">
  <a href="https://github.com/BlackCreepyCat/Blitzmax-Opaline-Gui-2D-FrameWork/stargazers"><img src="https://img.shields.io/github/stars/BlackCreepyCat/Blitzmax-Opaline-Gui-2D-FrameWork?style=social" alt="Stars"></a>
  <a href="https://github.com/BlackCreepyCat/Blitzmax-Opaline-Gui-2D-FrameWork/releases"><img src="https://img.shields.io/github/v/release/BlackCreepyCat/Blitzmax-Opaline-Gui-2D-FrameWork?color=green" alt="Latest Release"></a>
</p>

---

## ✨ Why Opaline?

Opaline is a **very low-level GUI kernel** written in BlitzMax NG.

- Portable to other languages (C++, FreeBasic, Monkey, Raylib, SDL...) if they support linked lists  
- Zero complex dependencies – only BRL.GLMax2D + BRL.LinkedList  
- Focus on **behavior** (events, focus, z-order, modality, anchors, scrolling, clipboard) rather than pretty graphics  
- Intentionally basic/ugly look → you take over the drawing for your style  

The core is solid even if the default visuals are minimal.

## 🚀 Features

- 17+ widgets with mature behaviors  
- Resizable & modal windows (with overlay)  
- Powerful anchor system (widgets auto-stretch/stick on resize)  
- Simple theming via color constants  
- Full keyboard support (text editing, Ctrl+C/X/V, arrows, home/end, selection)  
- System clipboard integration  
- Automatic z-order & focus management  
- Built-in scrolling for lists & textareas  
- Context menus, message boxes, status bars, taskbar support  

## 📦 Installation

1. Clone or download the repo  
2. Copy the `.bmx` files to your project  
3. Include the main file:


