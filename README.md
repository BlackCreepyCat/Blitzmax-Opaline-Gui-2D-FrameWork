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

Description:
------------
Opaline UI is a low-level kernel for creating a graphical interface from scratch. I believe it can be easily converted to other languages, only if they allow linked lists. It need also includes some basic graphical functions like:

- Text/Box/Rect/Line/Oval/Circle/SetViewport/StringWidth (see the class: gui_core.bmx).

Maybe compatible/converted with:
--------------------------------
- FreeBasic?
- Monkey?
- Monkey2?
- PureBasic?
- Java?
- SDL/SDL2?

Forum Link:
-----------
https://www.syntaxboom.net/forum/blitzmax-ng/code-archives-ad/1116-short-gui-kernel-skeleton



<img width="1922" height="1108" alt="image" src="https://github.com/user-attachments/assets/85b48c0e-2b7e-4e80-9285-4a82e3ead393" />


C translation of the main example:

```ruby
#include "raylib.h"
#include "GUI.h"
#include "Widget.h"
#include "Window.h"
#include "Button.h"
#include "Label.h"
#include "Panel.h"
#include "CheckBox.h"
#include "Radio.h"
#include "ProgressBar.h"
#include "Slider.h"
#include "TextInput.h"
#include "ListBox.h"
#include "ComboBox.h"
#include "Tabber.h"

#include <memory>
#include <string>
#include <vector>
#include <iostream>

// -----------------------------------------------------------------------------
// Variables globales pour les démos live-update (comme dans BlitzMax)
// -----------------------------------------------------------------------------
Label* lblSliderVal1 = nullptr;
Label* lblSliderVal2 = nullptr;
ProgressBar* progress1 = nullptr;
Slider* slider1 = nullptr;
Slider* slider2 = nullptr;

// TextInput demo
Label* lblInputInfo = nullptr;
Label* lblInputValue = nullptr;
TextInput* inputName = nullptr;
TextInput* inputEmail = nullptr;
TextInput* inputPassword = nullptr;
TextInput* inputCode = nullptr;

// Mouse percent demo
Label* mouseLabel = nullptr;

// List / Combo demo labels
Label* lblListInfo = nullptr;
Label* lblComboInfo = nullptr;
Label* lblComboValue = nullptr;

// Tabber demo
Label* lblTabInfo = nullptr;
Label* lblBrightnessVal = nullptr;
Label* lblMasterVal = nullptr;
Label* lblMusicVal = nullptr;
Label* lblSfxVal = nullptr;
Label* lblMouseSensVal = nullptr;

// Status label (fenêtre 1)
Label* statusLabel = nullptr;

int main(void)
{
    // Init fenêtre (équivalent Graphics 1920,1080,0)
    const int screenWidth = 1920;
    const int screenHeight = 1080;
    InitWindow(screenWidth, screenHeight, "Opaline GUI Framework - raylib Demo");
    SetTargetFPS(60);

    // Init GUI system
    GUI::Init();                       // équiv TWidget.GuiInit()

    // Root container plein écran
    auto root = std::make_unique<Container>(0, 0, (float)screenWidth, (float)screenHeight);
    GUI::SetRoot(root.get());

    // -----------------------------------------------------------------------
    // Création des 7 fenêtres de démo
    // -----------------------------------------------------------------------
    auto win1 = std::make_unique<Window>(120, 80, 540, 540, "Opaline Main Window", true, true, false);
    auto win2 = std::make_unique<Window>(340, 220, 380, 320, "Settings Window", true, true, true);
    auto win3 = std::make_unique<Window>(1400, 80, 450, 800, "Progress Demo", false, false, true);
    auto win4 = std::make_unique<Window>(700, 400, 450, 350, "Text Input Demo", false, false, false);
    auto win5 = std::make_unique<Window>(700, 50, 650, 340, "ListBox Demo", true, true, true);
    auto win6 = std::make_unique<Window>(100, 650, 500, 350, "ComboBox Demo", true, true, true);
    auto win7 = std::make_unique<Window>(620, 450, 500, 400, "Tabber Demo", true, true, true);

    root->AddChild(std::move(win1));
    root->AddChild(std::move(win2));
    root->AddChild(std::move(win3));
    root->AddChild(std::move(win4));
    root->AddChild(std::move(win5));
    root->AddChild(std::move(win6));
    root->AddChild(std::move(win7));

    // -----------------------------------------------------------------------
    // Fenêtre 1 : Labels, Panels, Boutons, Radios, Nested Panels
    // -----------------------------------------------------------------------
    // (implémentation similaire à ce que tu as dans BlitzMax – ajoute les widgets via win1->AddChild(...))

    // Exemple rapide pour win1 (à compléter avec tous les panels/boutons/radios)
    auto titleLabel = std::make_unique<Label>(20, 20, 500, 24, "Welcome to the CreepyCat Opaline GUI Framework! (C)2026");
    titleLabel->SetColor(YELLOW);
    win1->AddChild(std::move(titleLabel));

    // ... ajoute buttonPanel, optionsPanel, statusPanel, nested panels, etc.

    statusLabel = new Label(10, 15, 480, 30, "Status: Ready");  // gardé pour events
    statusLabel->SetColor(LIME);

    // -----------------------------------------------------------------------
    // Fenêtre 3 : Progress + Slider + mouse demo
    // -----------------------------------------------------------------------
    progress1 = new ProgressBar(120, 28, 270, 24, 0.0f);
    slider1   = new Slider(100, 28, 200, 24, 0.5f, Slider::Style::Horizontal);
    slider2   = new Slider(100, 63, 200, 24, 0.75f, Slider::Style::Horizontal);

    lblSliderVal1 = new Label(310, 30, 60, 20, "50%");
    lblSliderVal2 = new Label(310, 65, 60, 20, "75%");

    mouseLabel = new Label(250, 60, 140, 20, "Mouse X: 0%");
    mouseLabel->SetColor(YELLOW);

    // -----------------------------------------------------------------------
    // Fenêtre 4 : TextInput demo
    // -----------------------------------------------------------------------
    inputName     = new TextInput(120, 58, 300, 28, "");
    inputEmail    = new TextInput(120, 98, 300, 28, "");
    inputPassword = new TextInput(120, 138, 300, 28, "");
    inputPassword->SetPasswordMode(true);
    inputCode     = new TextInput(120, 178, 100, 28, "");
    inputCode->SetMaxLength(6);

    lblInputInfo  = new Label(15, 30, 380, 20, "Click on a field to edit");
    lblInputValue = new Label(15, 55, 380, 20, "Value: ");

    // -----------------------------------------------------------------------
    // Fenêtre 5 & 6 : ListBox / ComboBox (à remplir avec AddItem / AddItemMulti)
    // -----------------------------------------------------------------------
    // lblListInfo, lblComboInfo, lblComboValue

    // -----------------------------------------------------------------------
    // Fenêtre 7 : Tabber (onglets General/Graphics/Audio/Controls)
    // -----------------------------------------------------------------------
    // lblTabInfo, lblBrightnessVal, etc.

    // -----------------------------------------------------------------------
    // Boucle principale
    // -----------------------------------------------------------------------
    while (!WindowShouldClose())
    {
        float dt = GetFrameTime();
        GUI::Update(dt);   // inputs, mouse, events, updates widgets

        // -------------------------------------------------------------------
        // Live updates – exactement comme dans ton While
        // -------------------------------------------------------------------

        // Slider values → labels
        if (lblSliderVal1) lblSliderVal1->SetText(std::to_string((int)(slider1->GetPercent() * 100)) + "%");
        if (lblSliderVal2) lblSliderVal2->SetText(std::to_string((int)(slider2->GetPercent() * 100)) + "%");

        // Slider → progress demo
        if (progress1 && slider1) progress1->SetValue(slider1->GetValue());

        // Mouse X → progress bars (effet démo)
        float mousePercent = (float)GetMouseX() / (float)screenWidth;
        if (mouseLabel) mouseLabel->SetText("Mouse X: " + std::to_string((int)(mousePercent * 100)) + "%");

        // TextInput changes
        if (inputName && inputName->TextChanged()) {
            if (lblInputInfo) lblInputInfo->SetText("Name changed!");
            if (lblInputValue) lblInputValue->SetText("Value: " + inputName->GetText());
        }
        // ... pareil pour email, password, code

        // Button / Checkbox / Radio / Combo / Tabber events
        // → utilise les méthodes WasClicked(), StateChanged(), SelectionChanged(), TabChanged()
        // pour modifier statusLabel, lblListInfo, lblComboValue, lblTabInfo, etc.

        BeginDrawing();
            ClearBackground(RAYWHITE);
            GUI::Draw();   // dessine tout

            // Petit texte d'aide en haut à gauche
            DrawText("Opaline GUI Framework - raylib port (C)2026 Creepy Cat", 10, 10, 20, DARKBLUE);
            DrawText("Drag windows by title | Mouse wheel on sliders/lists | Click Combo to open", 10, 35, 16, GRAY);
        EndDrawing();
    }

    CloseWindow();
    return 0;
}
```
