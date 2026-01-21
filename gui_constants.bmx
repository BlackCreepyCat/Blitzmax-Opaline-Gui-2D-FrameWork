' =============================================================================
'                          GUI CONSTANTS
' =============================================================================
' All constants used by the GUI framework
' Modify these to customize the look and feel
' =============================================================================

' Layout Constants
Const TITLEBAR_HEIGHT:Int = 28
Const TITLE_BUTTON_SIZE:Int = 22
Const TITLE_BUTTON_MARGIN:Int = 6
Const STATUSBAR_HEIGHT:Int = 24

' Button Types
Const BTN_TYPE_NORMAL:Int = 0
Const BTN_TYPE_CLOSE:Int = 1
Const BTN_TYPE_MINIMIZE:Int = 2
Const BTN_TYPE_MAXIMIZE:Int = 3

' Label Alignment
Const LABEL_ALIGN_LEFT:Int = 0
Const LABEL_ALIGN_CENTER:Int = 1
Const LABEL_ALIGN_RIGHT:Int = 2

' Panel Styles
Const PANEL_STYLE_FLAT:Int = 0
Const PANEL_STYLE_RAISED:Int = 1
Const PANEL_STYLE_SUNKEN:Int = 2

' ProgressBar Styles
Const PROGRESSBAR_STYLE_HORIZONTAL:Int = 0
Const PROGRESSBAR_STYLE_VERTICAL:Int = 1

' Slider Styles
Const SLIDER_STYLE_HORIZONTAL:Int = 0
Const SLIDER_STYLE_VERTICAL:Int = 1

' Text Styles
Const TEXT_STYLE_NORMAL:Int = 1
Const TEXT_STYLE_SHADOW:Int = 2

' ListBox Constants
Const LISTBOX_SCROLLBAR_WIDTH:Int = 25
Const LISTBOX_DEFAULT_ITEM_HEIGHT:Int = 24
Const LISTBOX_HEADER_HEIGHT:Int = 26

' ComboBox Constants
Const COMBOBOX_BUTTON_WIDTH:Int = 24
Const COMBOBOX_DEFAULT_HEIGHT:Int = 28
Const COMBOBOX_MAX_VISIBLE_ITEMS:Int = 8
Const COMBOBOX_ITEM_HEIGHT:Int = 24

' =============================================================================
'                          COLOR THEME
' =============================================================================

' -----------------------------------------------------------------------------
' TaskBar Constants
' -----------------------------------------------------------------------------
Const TASKBAR_HEIGHT:Int = 40
Const TASKBAR_BUTTON_MIN_WIDTH:Int = 80
Const TASKBAR_BUTTON_MAX_WIDTH:Int = 180
Const TASKBAR_BUTTON_HEIGHT:Int = 30
Const TASKBAR_BUTTON_MARGIN:Int = 5
Const TASKBAR_CLOCK_WIDTH:Int = 70

' TaskBar Colors
Const COLOR_TASKBAR_BG_R:Int = 35
Const COLOR_TASKBAR_BG_G:Int = 35
Const COLOR_TASKBAR_BG_B:Int = 50

Const COLOR_TASKBAR_CLOCK_R:Int = 200
Const COLOR_TASKBAR_CLOCK_G:Int = 220
Const COLOR_TASKBAR_CLOCK_B:Int = 255

' -----------------------------------------------------------------------------
' Window Colors
' -----------------------------------------------------------------------------
Const COLOR_TITLEBAR_ACTIVE_R:Int = 90
Const COLOR_TITLEBAR_ACTIVE_G:Int = 130
Const COLOR_TITLEBAR_ACTIVE_B:Int = 210

Const COLOR_TITLEBAR_INACTIVE_R:Int = 70
Const COLOR_TITLEBAR_INACTIVE_G:Int = 110
Const COLOR_TITLEBAR_INACTIVE_B:Int = 190

Const COLOR_WINDOW_CLIENT_R:Int = 40
Const COLOR_WINDOW_CLIENT_G:Int = 40
Const COLOR_WINDOW_CLIENT_B:Int = 60

Const COLOR_WINDOW_TITLE_R:Int = 240
Const COLOR_WINDOW_TITLE_G:Int = 240
Const COLOR_WINDOW_TITLE_B:Int = 255

Const COLOR_STATUSBAR_BG_R:Int = 50
Const COLOR_STATUSBAR_BG_G:Int = 50
Const COLOR_STATUSBAR_BG_B:Int = 70

Const COLOR_STATUSBAR_TEXT_R:Int = 200
Const COLOR_STATUSBAR_TEXT_G:Int = 200
Const COLOR_STATUSBAR_TEXT_B:Int = 220

Const COLOR_STATUSBAR_SEPARATOR_R:Int = 80
Const COLOR_STATUSBAR_SEPARATOR_G:Int = 80
Const COLOR_STATUSBAR_SEPARATOR_B:Int = 100

' -----------------------------------------------------------------------------
' Button Colors
' -----------------------------------------------------------------------------
Const COLOR_BUTTON_NORMAL_R:Int = 90
Const COLOR_BUTTON_NORMAL_G:Int = 140
Const COLOR_BUTTON_NORMAL_B:Int = 220

Const COLOR_BUTTON_HOVER_R:Int = 110
Const COLOR_BUTTON_HOVER_G:Int = 160
Const COLOR_BUTTON_HOVER_B:Int = 240

Const COLOR_BUTTON_PRESSED_R:Int = 60
Const COLOR_BUTTON_PRESSED_G:Int = 100
Const COLOR_BUTTON_PRESSED_B:Int = 180

Const COLOR_BUTTON_CLOSE_NORMAL_R:Int = 232
Const COLOR_BUTTON_CLOSE_NORMAL_G:Int = 17
Const COLOR_BUTTON_CLOSE_NORMAL_B:Int = 35

Const COLOR_BUTTON_CLOSE_HOVER_R:Int = 232
Const COLOR_BUTTON_CLOSE_HOVER_G:Int = 37
Const COLOR_BUTTON_CLOSE_HOVER_B:Int = 55

Const COLOR_BUTTON_CLOSE_PRESSED_R:Int = 132
Const COLOR_BUTTON_CLOSE_PRESSED_G:Int = 17
Const COLOR_BUTTON_CLOSE_PRESSED_B:Int = 35

Const COLOR_BUTTON_TEXT_R:Int = 255
Const COLOR_BUTTON_TEXT_G:Int = 255
Const COLOR_BUTTON_TEXT_B:Int = 255

' -----------------------------------------------------------------------------
' Checkbox Colors
' -----------------------------------------------------------------------------
Const COLOR_CHECKBOX_NORMAL_R:Int = 90
Const COLOR_CHECKBOX_NORMAL_G:Int = 140
Const COLOR_CHECKBOX_NORMAL_B:Int = 220

Const COLOR_CHECKBOX_HOVER_R:Int = 110
Const COLOR_CHECKBOX_HOVER_G:Int = 160
Const COLOR_CHECKBOX_HOVER_B:Int = 240

Const COLOR_CHECKBOX_PRESSED_R:Int = 60
Const COLOR_CHECKBOX_PRESSED_G:Int = 100
Const COLOR_CHECKBOX_PRESSED_B:Int = 180

Const COLOR_CHECKBOX_MARK_R:Int = 220
Const COLOR_CHECKBOX_MARK_G:Int = 230
Const COLOR_CHECKBOX_MARK_B:Int = 255

Const COLOR_CHECKBOX_TEXT_R:Int = 240
Const COLOR_CHECKBOX_TEXT_G:Int = 240
Const COLOR_CHECKBOX_TEXT_B:Int = 255

' -----------------------------------------------------------------------------
' Radio Button Colors
' -----------------------------------------------------------------------------
Const COLOR_RADIO_OUTLINE_R:Int = 255
Const COLOR_RADIO_OUTLINE_G:Int = 255
Const COLOR_RADIO_OUTLINE_B:Int = 255

Const COLOR_RADIO_SELECTED_R:Int = 60
Const COLOR_RADIO_SELECTED_G:Int = 100
Const COLOR_RADIO_SELECTED_B:Int = 180

Const COLOR_RADIO_TEXT_R:Int = 255
Const COLOR_RADIO_TEXT_G:Int = 255
Const COLOR_RADIO_TEXT_B:Int = 255

' -----------------------------------------------------------------------------
' Label Colors
' -----------------------------------------------------------------------------
Const COLOR_LABEL_TEXT_R:Int = 240
Const COLOR_LABEL_TEXT_G:Int = 240
Const COLOR_LABEL_TEXT_B:Int = 255

' -----------------------------------------------------------------------------
' Panel Colors
' -----------------------------------------------------------------------------
Const COLOR_PANEL_BG_R:Int = 50
Const COLOR_PANEL_BG_G:Int = 50
Const COLOR_PANEL_BG_B:Int = 70

Const COLOR_PANEL_BORDER_R:Int = 80
Const COLOR_PANEL_BORDER_G:Int = 80
Const COLOR_PANEL_BORDER_B:Int = 100

Const COLOR_PANEL_TITLE_R:Int = 200
Const COLOR_PANEL_TITLE_G:Int = 200
Const COLOR_PANEL_TITLE_B:Int = 220

' -----------------------------------------------------------------------------
' ProgressBar Colors
' -----------------------------------------------------------------------------
Const COLOR_PROGRESSBAR_BG_R:Int = 30
Const COLOR_PROGRESSBAR_BG_G:Int = 30
Const COLOR_PROGRESSBAR_BG_B:Int = 50

Const COLOR_PROGRESSBAR_FILL_R:Int = 80
Const COLOR_PROGRESSBAR_FILL_G:Int = 180
Const COLOR_PROGRESSBAR_FILL_B:Int = 80

Const COLOR_PROGRESSBAR_BORDER_R:Int = 100
Const COLOR_PROGRESSBAR_BORDER_G:Int = 100
Const COLOR_PROGRESSBAR_BORDER_B:Int = 120

' -----------------------------------------------------------------------------
' TextInput Colors
' -----------------------------------------------------------------------------
Const COLOR_TEXTINPUT_BG_R:Int = 25
Const COLOR_TEXTINPUT_BG_G:Int = 25
Const COLOR_TEXTINPUT_BG_B:Int = 35

Const COLOR_TEXTINPUT_TEXT_R:Int = 240
Const COLOR_TEXTINPUT_TEXT_G:Int = 240
Const COLOR_TEXTINPUT_TEXT_B:Int = 255

Const COLOR_TEXTINPUT_CURSOR_R:Int = 255
Const COLOR_TEXTINPUT_CURSOR_G:Int = 255
Const COLOR_TEXTINPUT_CURSOR_B:Int = 255

Const COLOR_TEXTINPUT_SELECTION_R:Int = 70
Const COLOR_TEXTINPUT_SELECTION_G:Int = 130
Const COLOR_TEXTINPUT_SELECTION_B:Int = 200

Const COLOR_TEXTINPUT_PLACEHOLDER_R:Int = 120
Const COLOR_TEXTINPUT_PLACEHOLDER_G:Int = 120
Const COLOR_TEXTINPUT_PLACEHOLDER_B:Int = 140

' -----------------------------------------------------------------------------
' Slider Colors
' -----------------------------------------------------------------------------
Const COLOR_SLIDER_TRACK_R:Int = 30
Const COLOR_SLIDER_TRACK_G:Int = 30
Const COLOR_SLIDER_TRACK_B:Int = 50

Const COLOR_SLIDER_THUMB_R:Int = 90
Const COLOR_SLIDER_THUMB_G:Int = 140
Const COLOR_SLIDER_THUMB_B:Int = 220

' -----------------------------------------------------------------------------
' ListBox Colors
' -----------------------------------------------------------------------------
Const COLOR_LISTBOX_BG_R:Int = 30
Const COLOR_LISTBOX_BG_G:Int = 30
Const COLOR_LISTBOX_BG_B:Int = 45

Const COLOR_LISTBOX_ITEM_R:Int = 240
Const COLOR_LISTBOX_ITEM_G:Int = 240
Const COLOR_LISTBOX_ITEM_B:Int = 255

Const COLOR_LISTBOX_SELECTED_R:Int = 70
Const COLOR_LISTBOX_SELECTED_G:Int = 120
Const COLOR_LISTBOX_SELECTED_B:Int = 200

Const COLOR_LISTBOX_HOVER_R:Int = 50
Const COLOR_LISTBOX_HOVER_G:Int = 70
Const COLOR_LISTBOX_HOVER_B:Int = 100

Const COLOR_LISTBOX_HEADER_R:Int = 60
Const COLOR_LISTBOX_HEADER_G:Int = 80
Const COLOR_LISTBOX_HEADER_B:Int = 120

Const COLOR_LISTBOX_HEADER_TEXT_R:Int = 220
Const COLOR_LISTBOX_HEADER_TEXT_G:Int = 230
Const COLOR_LISTBOX_HEADER_TEXT_B:Int = 255

Const COLOR_LISTBOX_GRID_R:Int = 50
Const COLOR_LISTBOX_GRID_G:Int = 50
Const COLOR_LISTBOX_GRID_B:Int = 70

Const COLOR_LISTBOX_ALT_ROW_R:Int = 35
Const COLOR_LISTBOX_ALT_ROW_G:Int = 35
Const COLOR_LISTBOX_ALT_ROW_B:Int = 50

' -----------------------------------------------------------------------------
' ComboBox Colors
' -----------------------------------------------------------------------------
Const COLOR_COMBOBOX_BG_R:Int = 35
Const COLOR_COMBOBOX_BG_G:Int = 35
Const COLOR_COMBOBOX_BG_B:Int = 50

Const COLOR_COMBOBOX_TEXT_R:Int = 240
Const COLOR_COMBOBOX_TEXT_G:Int = 240
Const COLOR_COMBOBOX_TEXT_B:Int = 255

Const COLOR_COMBOBOX_ARROW_R:Int = 200
Const COLOR_COMBOBOX_ARROW_G:Int = 210
Const COLOR_COMBOBOX_ARROW_B:Int = 230

Const COLOR_COMBOBOX_BUTTON_R:Int = 70
Const COLOR_COMBOBOX_BUTTON_G:Int = 100
Const COLOR_COMBOBOX_BUTTON_B:Int = 160

Const COLOR_COMBOBOX_HOVER_R:Int = 90
Const COLOR_COMBOBOX_HOVER_G:Int = 120
Const COLOR_COMBOBOX_HOVER_B:Int = 180

' -----------------------------------------------------------------------------
' Tabber Constants
' -----------------------------------------------------------------------------
Const TABBER_TAB_HEIGHT:Int = 28
Const TABBER_TAB_PADDING:Int = 12
Const TABBER_TAB_SPACING:Int = 2
Const TABBER_TAB_MIN_WIDTH:Int = 60

' -----------------------------------------------------------------------------
' Tabber Colors
' -----------------------------------------------------------------------------
Const COLOR_TABBER_BG_R:Int = 50
Const COLOR_TABBER_BG_G:Int = 50
Const COLOR_TABBER_BG_B:Int = 70

Const COLOR_TABBER_CONTENT_R:Int = 40
Const COLOR_TABBER_CONTENT_G:Int = 40
Const COLOR_TABBER_CONTENT_B:Int = 60

Const COLOR_TABBER_TAB_ACTIVE_R:Int = 90
Const COLOR_TABBER_TAB_ACTIVE_G:Int = 130
Const COLOR_TABBER_TAB_ACTIVE_B:Int = 210

Const COLOR_TABBER_TAB_INACTIVE_R:Int = 60
Const COLOR_TABBER_TAB_INACTIVE_G:Int = 60
Const COLOR_TABBER_TAB_INACTIVE_B:Int = 80

Const COLOR_TABBER_TAB_HOVER_R:Int = 75
Const COLOR_TABBER_TAB_HOVER_G:Int = 95
Const COLOR_TABBER_TAB_HOVER_B:Int = 145

Const COLOR_TABBER_TEXT_ACTIVE_R:Int = 255
Const COLOR_TABBER_TEXT_ACTIVE_G:Int = 255
Const COLOR_TABBER_TEXT_ACTIVE_B:Int = 255

Const COLOR_TABBER_TEXT_INACTIVE_R:Int = 180
Const COLOR_TABBER_TEXT_INACTIVE_G:Int = 180
Const COLOR_TABBER_TEXT_INACTIVE_B:Int = 200

' -----------------------------------------------------------------------------
' Modal Window Overlay Colors
' -----------------------------------------------------------------------------
Const COLOR_MODAL_OVERLAY_R:Int = 0
Const COLOR_MODAL_OVERLAY_G:Int = 0
Const COLOR_MODAL_OVERLAY_B:Int = 0
Const COLOR_MODAL_OVERLAY_ALPHA:Float = 0.5
