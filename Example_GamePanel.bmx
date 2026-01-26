SuperStrict

Import BRL.GLMax2D
Import BRL.LinkedList

Include "opaline/gui_opaline.bmx"

' =============================================================================
'                  GAME OPTIONS INTERFACE - Example
' =============================================================================

Graphics 1280, 720, 0

TWidget.GuiInit()
TBackground.Init()

' Create root container
Global root:TContainer = New TContainer(GraphicsWidth(), GraphicsHeight())
TWidget.GuiSetRoot(root)

' =============================================================================
'                  MAIN OPTIONS WINDOW
' =============================================================================
Local winOptions:TWindow = New TWindow(240, 60, 800, 600, "Game Options", True, False, False, True)
winOptions.SetResizable(True)
winOptions.SetMinSize(800, 600)
root.AddChild winOptions

' Window title
Local lblTitle:TLabel = New TLabel(20, 10, 760, 30, "Configure Your Game Settings", LABEL_ALIGN_CENTER)
lblTitle.SetColor(255, 220, 100)
lblTitle.SetAnchors(ANCHOR_LEFT | ANCHOR_TOP | ANCHOR_RIGHT)
winOptions.AddChild lblTitle

' Create main tabber
Global tabber:TTabber = New TTabber(20, 50, 760, 440)
tabber.SetAnchors(ANCHOR_ALL)
winOptions.AddChild tabber

' Add tabs
tabber.AddTab("Graphics")
tabber.AddTab("Sounds")
tabber.AddTab("Gameplay")
tabber.AddTab("Network")

' =============================================================================
'                  TAB 1: GRAPHICS
' =============================================================================

' --- Video Settings Panel ---
Local panelVideo:TPanel = New TPanel(20, 20, 720, 180, "Video Settings", PANEL_STYLE_RAISED)
tabber.AddChild panelVideo
tabber.AddWidgetToTab(0, panelVideo)

' Resolution
Local lblResolution:TLabel = New TLabel(20, 30, 120, 24, "Resolution:")
panelVideo.AddChild lblResolution

Global comboResolution:TComboBox = New TComboBox(150, 28, 180, 28)
comboResolution.AddItem("3840x2160 (4K)")
comboResolution.AddItem("2560x1440 (2K)")
comboResolution.AddItem("1920x1080 (Full HD)")
comboResolution.AddItem("1600x900")
comboResolution.AddItem("1280x720 (HD)")
comboResolution.AddItem("1024x768")
comboResolution.SetSelectedIndex(2)
panelVideo.AddChild comboResolution

' Display Mode
Local lblDisplayMode:TLabel = New TLabel(360, 30, 100, 24, "Display:")
panelVideo.AddChild lblDisplayMode

Global comboDisplay:TComboBox = New TComboBox(470, 28, 200, 28)
comboDisplay.AddItem("Fullscreen")
comboDisplay.AddItem("Windowed")
comboDisplay.AddItem("Borderless Window")
comboDisplay.SetSelectedIndex(0)
panelVideo.AddChild comboDisplay

' Refresh Rate
Local lblRefresh:TLabel = New TLabel(20, 70, 120, 24, "Refresh Rate:")
panelVideo.AddChild lblRefresh

Global comboRefresh:TComboBox = New TComboBox(150, 68, 100, 28)
comboRefresh.AddItem("144 Hz")
comboRefresh.AddItem("120 Hz")
comboRefresh.AddItem("60 Hz")
comboRefresh.AddItem("30 Hz")
comboRefresh.SetSelectedIndex(2)
panelVideo.AddChild comboRefresh

' V-Sync
Global chkVSync:TCheckBox = New TCheckBox(280, 70, 180, 24, "V-Sync Enabled", True)
panelVideo.AddChild chkVSync

' FPS Counter
Global chkFPS:TCheckBox = New TCheckBox(480, 70, 180, 24, "Show FPS Counter", False)
panelVideo.AddChild chkFPS

' Field of View
Local lblFOV:TLabel = New TLabel(20, 110, 120, 24, "Field of View:")
panelVideo.AddChild lblFOV

Global sliderFOV:TSlider = New TSlider(150, 108, 420, 24, 0.66, SLIDER_STYLE_HORIZONTAL)
panelVideo.AddChild sliderFOV

Global lblFOVValue:TLabel = New TLabel(580, 110, 80, 24, "90°", LABEL_ALIGN_LEFT)
panelVideo.AddChild lblFOVValue

' Gamma
Local lblGamma:TLabel = New TLabel(20, 145, 120, 24, "Gamma:")
panelVideo.AddChild lblGamma

Global sliderGamma:TSlider = New TSlider(150, 143, 420, 24, 0.5, SLIDER_STYLE_HORIZONTAL)
panelVideo.AddChild sliderGamma

Global lblGammaValue:TLabel = New TLabel(580, 145, 80, 24, "1.0", LABEL_ALIGN_LEFT)
panelVideo.AddChild lblGammaValue

' --- Graphics Quality Panel ---
Local panelQuality:TPanel = New TPanel(20, 215, 350, 180, "Graphics Quality", PANEL_STYLE_RAISED)
tabber.AddChild panelQuality
tabber.AddWidgetToTab(0, panelQuality)

' Graphics Preset
Local lblPreset:TLabel = New TLabel(20, 30, 100, 24, "Preset:")
panelQuality.AddChild lblPreset

Global comboPreset:TComboBox = New TComboBox(130, 28, 180, 28)
comboPreset.AddItem("Ultra")
comboPreset.AddItem("High")
comboPreset.AddItem("Medium")
comboPreset.AddItem("Low")
comboPreset.AddItem("Custom")
comboPreset.SetSelectedIndex(1)
panelQuality.AddChild comboPreset

' Texture Quality
Local lblTexture:TLabel = New TLabel(20, 70, 100, 24, "Textures:")
panelQuality.AddChild lblTexture

Global comboTexture:TComboBox = New TComboBox(130, 68, 180, 28)
comboTexture.AddItem("Ultra")
comboTexture.AddItem("High")
comboTexture.AddItem("Medium")
comboTexture.AddItem("Low")
comboTexture.SetSelectedIndex(1)
panelQuality.AddChild comboTexture

' Shadow Quality
Local lblShadow:TLabel = New TLabel(20, 110, 100, 24, "Shadows:")
panelQuality.AddChild lblShadow

Global comboShadow:TComboBox = New TComboBox(130, 108, 180, 28)
comboShadow.AddItem("Ultra")
comboShadow.AddItem("High")
comboShadow.AddItem("Medium")
comboShadow.AddItem("Low")
comboShadow.AddItem("Off")
comboShadow.SetSelectedIndex(1)
panelQuality.AddChild comboShadow

' Anti-Aliasing
Global chkAA:TCheckBox = New TCheckBox(20, 145, 200, 24, "Anti-Aliasing (MSAA)", True)
panelQuality.AddChild chkAA

' --- Effects Panel ---
Local panelEffects:TPanel = New TPanel(390, 215, 350, 180, "Visual Effects", PANEL_STYLE_RAISED)
tabber.AddChild panelEffects
tabber.AddWidgetToTab(0, panelEffects)

Global chkBloom:TCheckBox = New TCheckBox(20, 30, 200, 24, "Bloom", True)
panelEffects.AddChild chkBloom

Global chkMotionBlur:TCheckBox = New TCheckBox(20, 60, 200, 24, "Motion Blur", False)
panelEffects.AddChild chkMotionBlur

Global chkAmbientOcclusion:TCheckBox = New TCheckBox(20, 90, 200, 24, "Ambient Occlusion", True)
panelEffects.AddChild chkAmbientOcclusion

Global chkDOF:TCheckBox = New TCheckBox(20, 120, 200, 24, "Depth of Field", False)
panelEffects.AddChild chkDOF

Global chkParticles:TCheckBox = New TCheckBox(20, 150, 200, 24, "High Quality Particles", True)
panelEffects.AddChild chkParticles

' =============================================================================
'                  TAB 2: SOUNDS
' =============================================================================

' --- Volume Settings Panel ---
Local panelVolume:TPanel = New TPanel(20, 20, 720, 200, "Volume Settings", PANEL_STYLE_RAISED)
tabber.AddChild panelVolume
tabber.AddWidgetToTab(1, panelVolume)

' Master Volume
Local lblMasterVol:TLabel = New TLabel(20, 30, 120, 24, "Master Volume:")
panelVolume.AddChild lblMasterVol

Global sliderMaster:TSlider = New TSlider(150, 28, 480, 24, 0.8, SLIDER_STYLE_HORIZONTAL)
panelVolume.AddChild sliderMaster

Global lblMasterVal:TLabel = New TLabel(640, 30, 60, 24, "80%", LABEL_ALIGN_LEFT)
panelVolume.AddChild lblMasterVal

' Music Volume
Local lblMusicVol:TLabel = New TLabel(20, 65, 120, 24, "Music Volume:")
panelVolume.AddChild lblMusicVol

Global sliderMusic:TSlider = New TSlider(150, 63, 480, 24, 0.7, SLIDER_STYLE_HORIZONTAL)
panelVolume.AddChild sliderMusic

Global lblMusicVal:TLabel = New TLabel(640, 65, 60, 24, "70%", LABEL_ALIGN_LEFT)
panelVolume.AddChild lblMusicVal

' SFX Volume
Local lblSfxVol:TLabel = New TLabel(20, 100, 120, 24, "Effects Volume:")
panelVolume.AddChild lblSfxVol

Global sliderSfx:TSlider = New TSlider(150, 98, 480, 24, 0.9, SLIDER_STYLE_HORIZONTAL)
panelVolume.AddChild sliderSfx

Global lblSfxVal:TLabel = New TLabel(640, 100, 60, 24, "90%", LABEL_ALIGN_LEFT)
panelVolume.AddChild lblSfxVal

' Voice Volume
Local lblVoiceVol:TLabel = New TLabel(20, 135, 120, 24, "Voice Volume:")
panelVolume.AddChild lblVoiceVol

Global sliderVoice:TSlider = New TSlider(150, 133, 480, 24, 0.85, SLIDER_STYLE_HORIZONTAL)
panelVolume.AddChild sliderVoice

Global lblVoiceVal:TLabel = New TLabel(640, 135, 60, 24, "85%", LABEL_ALIGN_LEFT)
panelVolume.AddChild lblVoiceVal

' Ambient Volume
Local lblAmbientVol:TLabel = New TLabel(20, 170, 120, 24, "Ambient Volume:")
panelVolume.AddChild lblAmbientVol

Global sliderAmbient:TSlider = New TSlider(150, 168, 480, 24, 0.6, SLIDER_STYLE_HORIZONTAL)
panelVolume.AddChild sliderAmbient

Global lblAmbientVal:TLabel = New TLabel(640, 170, 60, 24, "60%", LABEL_ALIGN_LEFT)
panelVolume.AddChild lblAmbientVal

' --- Audio Settings Panel ---
Local panelAudio:TPanel = New TPanel(20, 235, 350, 160, "Audio Settings", PANEL_STYLE_RAISED)
tabber.AddChild panelAudio
tabber.AddWidgetToTab(1, panelAudio)

' Audio Output
Local lblAudioOutput:TLabel = New TLabel(20, 30, 120, 24, "Audio Output:")
panelAudio.AddChild lblAudioOutput

Global comboAudioOutput:TComboBox = New TComboBox(150, 28, 160, 28)
comboAudioOutput.AddItem("Speakers")
comboAudioOutput.AddItem("Headphones")
comboAudioOutput.AddItem("Surround 5.1")
comboAudioOutput.AddItem("Surround 7.1")
comboAudioOutput.SetSelectedIndex(0)
panelAudio.AddChild comboAudioOutput

' Audio Quality
Local lblAudioQuality:TLabel = New TLabel(20, 70, 120, 24, "Audio Quality:")
panelAudio.AddChild lblAudioQuality

Global comboAudioQuality:TComboBox = New TComboBox(150, 68, 160, 28)
comboAudioQuality.AddItem("High (48kHz)")
comboAudioQuality.AddItem("Medium (44.1kHz)")
comboAudioQuality.AddItem("Low (22kHz)")
comboAudioQuality.SetSelectedIndex(0)
panelAudio.AddChild comboAudioQuality

' Options
Global chk3DAudio:TCheckBox = New TCheckBox(20, 110, 200, 24, "3D Audio (HRTF)", True)
panelAudio.AddChild chk3DAudio

Global chkSubtitles:TCheckBox = New TCheckBox(20, 140, 200, 24, "Show Subtitles", False)
panelAudio.AddChild chkSubtitles

' --- Voice Chat Panel ---
Local panelVoiceChat:TPanel = New TPanel(390, 235, 350, 160, "Voice Chat", PANEL_STYLE_RAISED)
tabber.AddChild panelVoiceChat
tabber.AddWidgetToTab(1, panelVoiceChat)

' Microphone
Local lblMicrophone:TLabel = New TLabel(20, 30, 100, 24, "Microphone:")
panelVoiceChat.AddChild lblMicrophone

Global comboMicrophone:TComboBox = New TComboBox(130, 28, 180, 28)
comboMicrophone.AddItem("Default Device")
comboMicrophone.AddItem("USB Microphone")
comboMicrophone.AddItem("Webcam Mic")
comboMicrophone.SetSelectedIndex(0)
panelVoiceChat.AddChild comboMicrophone

' Mic Sensitivity
Local lblMicSens:TLabel = New TLabel(20, 70, 100, 24, "Sensitivity:")
panelVoiceChat.AddChild lblMicSens

Global sliderMicSens:TSlider = New TSlider(130, 68, 180, 24, 0.5, SLIDER_STYLE_HORIZONTAL)
panelVoiceChat.AddChild sliderMicSens

Global chkPushToTalk:TCheckBox = New TCheckBox(20, 110, 200, 24, "Push-to-Talk", False)
panelVoiceChat.AddChild chkPushToTalk

Global chkEchoCancellation:TCheckBox = New TCheckBox(20, 140, 200, 24, "Echo Cancellation", True)
panelVoiceChat.AddChild chkEchoCancellation

' =============================================================================
'                  TAB 3: GAMEPLAY
' =============================================================================

' --- Controls Panel ---
Local panelControls:TPanel = New TPanel(20, 20, 350, 200, "Controls", PANEL_STYLE_RAISED)
tabber.AddChild panelControls
tabber.AddWidgetToTab(2, panelControls)

' Mouse Sensitivity
Local lblMouseSens:TLabel = New TLabel(20, 30, 120, 24, "Mouse Sens.:")
panelControls.AddChild lblMouseSens

Global sliderMouseSens:TSlider = New TSlider(150, 28, 150, 24, 0.5, SLIDER_STYLE_HORIZONTAL)
panelControls.AddChild sliderMouseSens

Global lblMouseSensVal:TLabel = New TLabel(310, 30, 30, 24, "50", LABEL_ALIGN_LEFT)
panelControls.AddChild lblMouseSensVal

' ADS Sensitivity
Local lblADSSens:TLabel = New TLabel(20, 65, 120, 24, "ADS Sens.:")
panelControls.AddChild lblADSSens

Global sliderADSSens:TSlider = New TSlider(150, 63, 150, 24, 0.4, SLIDER_STYLE_HORIZONTAL)
panelControls.AddChild sliderADSSens

Global lblADSSensVal:TLabel = New TLabel(310, 65, 30, 24, "40", LABEL_ALIGN_LEFT)
panelControls.AddChild lblADSSensVal

' Mouse Options
Global chkInvertY:TCheckBox = New TCheckBox(20, 105, 200, 24, "Invert Y Axis", False)
panelControls.AddChild chkInvertY

Global chkInvertX:TCheckBox = New TCheckBox(20, 135, 200, 24, "Invert X Axis", False)
panelControls.AddChild chkInvertX

Global chkRawInput:TCheckBox = New TCheckBox(20, 165, 200, 24, "Raw Mouse Input", True)
panelControls.AddChild chkRawInput

' --- Accessibility Panel ---
Local panelAccessibility:TPanel = New TPanel(390, 20, 350, 200, "Accessibility", PANEL_STYLE_RAISED)
tabber.AddChild panelAccessibility
tabber.AddWidgetToTab(2, panelAccessibility)

Global chkColorBlind:TCheckBox = New TCheckBox(20, 30, 250, 24, "Colorblind Mode", False)
panelAccessibility.AddChild chkColorBlind

Global chkSubtitlesGameplay:TCheckBox = New TCheckBox(20, 60, 250, 24, "Gameplay Subtitles", True)
panelAccessibility.AddChild chkSubtitlesGameplay

Global chkLargeCrosshair:TCheckBox = New TCheckBox(20, 90, 250, 24, "Large Crosshair", False)
panelAccessibility.AddChild chkLargeCrosshair

Global chkHighContrast:TCheckBox = New TCheckBox(20, 120, 250, 24, "High Contrast UI", False)
panelAccessibility.AddChild chkHighContrast

Global chkReduceMotion:TCheckBox = New TCheckBox(20, 150, 250, 24, "Reduce Motion Effects", False)
panelAccessibility.AddChild chkReduceMotion

' --- Gameplay Settings Panel ---
Local panelGameplay:TPanel = New TPanel(20, 235, 720, 160, "Gameplay Settings", PANEL_STYLE_RAISED)
tabber.AddChild panelGameplay
tabber.AddWidgetToTab(2, panelGameplay)

' Difficulty
Local lblDifficulty:TLabel = New TLabel(20, 30, 100, 24, "Difficulty:")
panelGameplay.AddChild lblDifficulty

Global comboDifficulty:TComboBox = New TComboBox(130, 28, 150, 28)
comboDifficulty.AddItem("Story")
comboDifficulty.AddItem("Easy")
comboDifficulty.AddItem("Normal")
comboDifficulty.AddItem("Hard")
comboDifficulty.AddItem("Nightmare")
comboDifficulty.SetSelectedIndex(2)
panelGameplay.AddChild comboDifficulty

' Auto-Save Frequency
Local lblAutoSave:TLabel = New TLabel(310, 30, 120, 24, "Auto-Save:")
panelGameplay.AddChild lblAutoSave

Global comboAutoSave:TComboBox = New TComboBox(440, 28, 150, 28)
comboAutoSave.AddItem("Every 5 min")
comboAutoSave.AddItem("Every 10 min")
comboAutoSave.AddItem("Every 15 min")
comboAutoSave.AddItem("Disabled")
comboAutoSave.SetSelectedIndex(1)
panelGameplay.AddChild comboAutoSave

' Gameplay Options
Global chkAutoLoot:TCheckBox = New TCheckBox(20, 75, 200, 24, "Auto-Loot Items", False)
panelGameplay.AddChild chkAutoLoot

Global chkTutorials:TCheckBox = New TCheckBox(240, 75, 200, 24, "Show Tutorials", True)
panelGameplay.AddChild chkTutorials

Global chkDamageNumbers:TCheckBox = New TCheckBox(460, 75, 200, 24, "Show Damage Numbers", True)
panelGameplay.AddChild chkDamageNumbers

Global chkAimAssist:TCheckBox = New TCheckBox(20, 105, 200, 24, "Aim Assist (Gamepad)", False)
panelGameplay.AddChild chkAimAssist

Global chkQuestMarkers:TCheckBox = New TCheckBox(240, 105, 200, 24, "Quest Markers", True)
panelGameplay.AddChild chkQuestMarkers

Global chkMinimap:TCheckBox = New TCheckBox(460, 105, 200, 24, "Show Minimap", True)
panelGameplay.AddChild chkMinimap

' =============================================================================
'                  TAB 4: NETWORK
' =============================================================================

' --- Connection Settings Panel ---
Local panelConnection:TPanel = New TPanel(20, 20, 720, 150, "Connection Settings", PANEL_STYLE_RAISED)
tabber.AddChild panelConnection
tabber.AddWidgetToTab(3, panelConnection)

' Server Region
Local lblRegion:TLabel = New TLabel(20, 30, 120, 24, "Server Region:")
panelConnection.AddChild lblRegion

Global comboRegion:TComboBox = New TComboBox(150, 28, 200, 28)
comboRegion.AddItem("Auto (Best Ping)")
comboRegion.AddItem("North America")
comboRegion.AddItem("Europe")
comboRegion.AddItem("Asia")
comboRegion.AddItem("South America")
comboRegion.AddItem("Oceania")
comboRegion.SetSelectedIndex(0)
panelConnection.AddChild comboRegion

' Max Ping
Local lblMaxPing:TLabel = New TLabel(380, 30, 100, 24, "Max Ping:")
panelConnection.AddChild lblMaxPing

Global comboMaxPing:TComboBox = New TComboBox(490, 28, 120, 28)
comboMaxPing.AddItem("50 ms")
comboMaxPing.AddItem("100 ms")
comboMaxPing.AddItem("150 ms")
comboMaxPing.AddItem("200 ms")
comboMaxPing.AddItem("Unlimited")
comboMaxPing.SetSelectedIndex(2)
panelConnection.AddChild comboMaxPing

' Bandwidth Limit
Local lblBandwidth:TLabel = New TLabel(20, 70, 120, 24, "Bandwidth:")
panelConnection.AddChild lblBandwidth

Global comboBandwidth:TComboBox = New TComboBox(150, 68, 200, 28)
comboBandwidth.AddItem("Unlimited")
comboBandwidth.AddItem("High (10 Mbps)")
comboBandwidth.AddItem("Medium (5 Mbps)")
comboBandwidth.AddItem("Low (2 Mbps)")
comboBandwidth.SetSelectedIndex(0)
panelConnection.AddChild comboBandwidth

' Network Options
Global chkAutoConnect:TCheckBox = New TCheckBox(20, 110, 250, 24, "Auto-Connect on Start", True)
panelConnection.AddChild chkAutoConnect

Global chkLowLatency:TCheckBox = New TCheckBox(290, 110, 250, 24, "Low Latency Mode", True)
panelConnection.AddChild chkLowLatency

' --- Matchmaking Panel ---
Local panelMatchmaking:TPanel = New TPanel(20, 185, 350, 210, "Matchmaking", PANEL_STYLE_RAISED)
tabber.AddChild panelMatchmaking
tabber.AddWidgetToTab(3, panelMatchmaking)

' Matchmaking Mode
Local lblMatchMode:TLabel = New TLabel(20, 30, 120, 24, "Match Mode:")
panelMatchmaking.AddChild lblMatchMode

Global comboMatchMode:TComboBox = New TComboBox(150, 28, 160, 28)
comboMatchMode.AddItem("Quick Match")
comboMatchMode.AddItem("Ranked")
comboMatchMode.AddItem("Custom")
comboMatchMode.AddItem("Training")
comboMatchMode.SetSelectedIndex(0)
panelMatchmaking.AddChild comboMatchMode

' Team Size
Local lblTeamSize:TLabel = New TLabel(20, 70, 120, 24, "Team Size:")
panelMatchmaking.AddChild lblTeamSize

Global comboTeamSize:TComboBox = New TComboBox(150, 68, 160, 28)
comboTeamSize.AddItem("Solo")
comboTeamSize.AddItem("Duo")
comboTeamSize.AddItem("Squad (4)")
comboTeamSize.AddItem("Any")
comboTeamSize.SetSelectedIndex(2)
panelMatchmaking.AddChild comboTeamSize

' Matchmaking Options
Global chkCrossPlatform:TCheckBox = New TCheckBox(20, 110, 250, 24, "Cross-Platform Play", True)
panelMatchmaking.AddChild chkCrossPlatform

Global chkFillTeam:TCheckBox = New TCheckBox(20, 140, 250, 24, "Fill Team Automatically", True)
panelMatchmaking.AddChild chkFillTeam

Global chkFriendlyFire:TCheckBox = New TCheckBox(20, 170, 250, 24, "Friendly Fire (Custom)", False)
panelMatchmaking.AddChild chkFriendlyFire

' --- Privacy Panel ---
Local panelPrivacy:TPanel = New TPanel(390, 185, 350, 210, "Privacy & Social", PANEL_STYLE_RAISED)
tabber.AddChild panelPrivacy
tabber.AddWidgetToTab(3, panelPrivacy)

' Profile Visibility
Local lblVisibility:TLabel = New TLabel(20, 30, 120, 24, "Profile:")
panelPrivacy.AddChild lblVisibility

Global comboVisibility:TComboBox = New TComboBox(130, 28, 180, 28)
comboVisibility.AddItem("Public")
comboVisibility.AddItem("Friends Only")
comboVisibility.AddItem("Private")
comboVisibility.SetSelectedIndex(1)
panelPrivacy.AddChild comboVisibility

' Chat Filter
Local lblChatFilter:TLabel = New TLabel(20, 70, 120, 24, "Chat Filter:")
panelPrivacy.AddChild lblChatFilter

Global comboChatFilter:TComboBox = New TComboBox(130, 68, 180, 28)
comboChatFilter.AddItem("Off")
comboChatFilter.AddItem("Mild")
comboChatFilter.AddItem("Strict")
comboChatFilter.SetSelectedIndex(1)
panelPrivacy.AddChild comboChatFilter

' Privacy Options
Global chkShowOnline:TCheckBox = New TCheckBox(20, 110, 250, 24, "Show Online Status", True)
panelPrivacy.AddChild chkShowOnline

Global chkAllowInvites:TCheckBox = New TCheckBox(20, 140, 250, 24, "Allow Friend Invites", True)
panelPrivacy.AddChild chkAllowInvites

Global chkShareStats:TCheckBox = New TCheckBox(20, 170, 250, 24, "Share Statistics", False)
panelPrivacy.AddChild chkShareStats

' =============================================================================
'                  BOTTOM BUTTONS
' =============================================================================

' Button panel at bottom of window
Local panelButtons:TPanel = New TPanel(20, 500, 760, 60, "", PANEL_STYLE_FLAT)
panelButtons.SetAnchors(ANCHOR_LEFT | ANCHOR_RIGHT | ANCHOR_BOTTOM)
panelButtons.showBackground = False
winOptions.AddChild panelButtons

Global btnApply:TButton = New TButton(340, 10, 120, 40, "Apply")
btnApply.SetColor(80, 180, 80)
panelButtons.AddChild btnApply

Global btnCancel:TButton = New TButton(470, 10, 120, 40, "Cancel")
btnCancel.SetColor(180, 80, 80)
panelButtons.AddChild btnCancel

Global btnDefaults:TButton = New TButton(20, 10, 150, 40, "Reset to Defaults")
panelButtons.AddChild btnDefaults

' Status bar with 2 sections
winOptions.AddStatusSection("Ready to configure", -1, LABEL_ALIGN_LEFT)
winOptions.AddStatusSection("Current Tab: Graphics", 250, LABEL_ALIGN_RIGHT)

' =============================================================================
'                  MAIN LOOP
' =============================================================================

While Not AppTerminate()
    Cls
    
	' important
    TBackground.Refresh()
    TWidget.GuiRefresh()
    
	' Gui management here


	' Important
	ClearAllEvents(root)

	Flip
Wend
End
