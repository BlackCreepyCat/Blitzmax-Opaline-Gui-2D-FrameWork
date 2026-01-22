' =============================================================================
'                           TEXTINPUT WIDGET
' =============================================================================
' Editable text field with cursor, selection, and mouse support
' Champ de texte éditable avec curseur, sélection et support souris
' =============================================================================

' Global reference to the currently focused TextInput
Global g_FocusedTextInput:TTextInput = Null

' Key repeat constants
Const KEY_REPEAT_DELAY:Int = 500      ' Initial delay before repeat starts (ms)
Const KEY_REPEAT_INTERVAL:Int = 50    ' Interval between repeats (ms)

Type TTextInput Extends TWidget
    Field text:String = ""
    Field cursorPos:Int = 0
    Field selectionStart:Int = -1
    Field selectionEnd:Int = -1
    Field scrollOffset:Int = 0
    Field focused:Int = False
    Field hover:Int = False
    Field cursorBlink:Int = 0
    Field cursorVisible:Int = True
    Field dragging:Int = False
    Field lastClickTime:Int = 0
    Field lastClickPos:Int = 0
    Field maxLength:Int = 0
    Field passwordMode:Int = False
    Field placeholder:String = ""
    Field events:TList = New TList
    
    ' Key repeat state for arrow keys
    Field keyRepeatKey:Int = 0           ' Currently repeating key (0 = none)
    Field keyRepeatStartTime:Int = 0     ' Time when key was first pressed
    Field keyRepeatLastTime:Int = 0      ' Time of last repeat
    Field keyRepeatActive:Int = False    ' Is repeat currently active?
    
    ' Background and text colors (customizable but default to theme constants)
    Field bgR:Int = COLOR_TEXTINPUT_BG_R
    Field bgG:Int = COLOR_TEXTINPUT_BG_G
    Field bgB:Int = COLOR_TEXTINPUT_BG_B
    
    Field textR:Int = COLOR_TEXTINPUT_TEXT_R
    Field textG:Int = COLOR_TEXTINPUT_TEXT_G
    Field textB:Int = COLOR_TEXTINPUT_TEXT_B

    ' Constructor - initializes position, size and initial text
    Method New(x:Int, y:Int, w:Int, h:Int, initialText:String = "")
        Super.New(x, y, w, h)
        text = initialText
        cursorPos = text.Length
    End Method

    ' Draws the text input: background, placeholder/text, selection, cursor
    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y
        
        ' Draw background with slight highlight when focused
        If focused
            TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, 3, bgR + 10, bgG + 10, bgB + 10)
        Else
            TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, 3, bgR, bgG, bgB)
        EndIf
        
        Local padding:Int = 4
        Local textAreaX:Int = ax + padding
        Local textAreaY:Int = ay + padding
        Local textAreaW:Int = rect.w - padding * 2
        Local textAreaH:Int = rect.h - padding * 2
        
        ' Restrict drawing to the text input area (clipping)
        TWidget.GuiSetViewport(textAreaX, textAreaY, textAreaW, textAreaH)
        
        Local displayText:String = GetDisplayText()
        
        ' Show placeholder when empty and not focused
        If text.Length = 0 And Not focused And placeholder.Length > 0
            TWidget.GuiDrawText(textAreaX - scrollOffset, ay + (rect.h - TWidget.GuiTextHeight("X")) / 2, placeholder, TEXT_STYLE_NORMAL, COLOR_TEXTINPUT_PLACEHOLDER_R, COLOR_TEXTINPUT_PLACEHOLDER_G, COLOR_TEXTINPUT_PLACEHOLDER_B)
            TWidget.GuiSetViewport(0, 0, GraphicsWidth(), GraphicsHeight())
            Return
        EndIf
        
        ' Draw selection background if any
        If HasSelection()
            Local selStart:Int = MinInt(selectionStart, selectionEnd)
            Local selEnd:Int = MaxInt(selectionStart, selectionEnd)
            
            Local selStartX:Int = textAreaX + TWidget.GuiTextWidth(displayText[..selStart]) - scrollOffset
            Local selEndX:Int = textAreaX + TWidget.GuiTextWidth(displayText[..selEnd]) - scrollOffset
            Local selWidth:Int = selEndX - selStartX
            
            TWidget.GuiDrawRect(selStartX, textAreaY, selWidth, textAreaH, 1, COLOR_TEXTINPUT_SELECTION_R, COLOR_TEXTINPUT_SELECTION_G, COLOR_TEXTINPUT_SELECTION_B)
        EndIf
        
        ' Draw the actual text content
        Local textY:Int = ay + (rect.h - TWidget.GuiTextHeight("X")) / 2
        TWidget.GuiDrawText(textAreaX - scrollOffset, textY, displayText, TEXT_STYLE_NORMAL, textR, textG, textB)
        
        ' Draw blinking cursor when focused
        If focused And cursorVisible
            Local cursorX:Int = textAreaX + TWidget.GuiTextWidth(displayText[..cursorPos]) - scrollOffset
            TWidget.GuiDrawRect(cursorX, textAreaY + 2, 2, textAreaH - 4, 1, COLOR_TEXTINPUT_CURSOR_R, COLOR_TEXTINPUT_CURSOR_G, COLOR_TEXTINPUT_CURSOR_B)
        EndIf
        
        ' Restore full viewport after clipping
        TWidget.GuiSetViewport(0, 0, GraphicsWidth(), GraphicsHeight())
        
        For Local c:TWidget = EachIn children
            c.Draw(ax, ay)
        Next
    End Method

    ' Main update method: handles mouse hover, focus, clicks, dragging, keyboard
    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        If Not enabled Then Return ContainsPoint(mx, my)
        
        Local over:Int = ContainsPoint(mx, my)
        hover = over
        
        ' Simple cursor blink timer (30 frames cycle)
        cursorBlink :+ 1
        If cursorBlink >= 30
            cursorBlink = 0
            cursorVisible = Not cursorVisible
        EndIf
        
        Local hit:Int = GuiMouse.Hit()
        Local down:Int = GuiMouse.Down()
        
        ' Mouse click to gain focus and set cursor/selection
        If over And hit And draggedWindow = Null
            ' Unfocus the previously focused TextInput
            If g_FocusedTextInput <> Null And g_FocusedTextInput <> Self
                g_FocusedTextInput.LoseFocus()
            EndIf
            
            ' Set focus to this TextInput
            focused = True
            g_FocusedTextInput = Self
            cursorVisible = True
            cursorBlink = 0
            
            ' IMPORTANT: Clear keyboard buffer to avoid "ghost" characters
            ' from keys pressed before gaining focus
            FlushKeys()
            
            Local clickPos:Int = GetCharIndexAtX(mx)
            Local CurrentTime:Int = MilliSecs()

            If CurrentTime - lastClickTime < 300 And Abs(clickPos - lastClickPos) <= 1
                SelectWordAt(clickPos)
                lastClickTime = 0
            Else
                cursorPos = clickPos
                selectionStart = clickPos
                selectionEnd = clickPos
                dragging = True
                lastClickTime = CurrentTime
                lastClickPos = clickPos
            EndIf
            
            Return True
        EndIf
        
        ' Handle selection dragging
        If dragging
            If down
                Local dragPos:Int = GetCharIndexAtX(mx)
                selectionEnd = dragPos
                cursorPos = dragPos
                EnsureCursorVisible()
                Return True
            Else
                dragging = False
                If selectionStart = selectionEnd
                    selectionStart = -1
                    selectionEnd = -1
                EndIf
            EndIf
        EndIf
        
        ' Lose focus when clicking outside (but ignore if clicking another TextInput)
        If hit And Not over And focused
            LoseFocus()
        EndIf
        
        ' NOTE: Keyboard input is now handled in GuiUpdate/GuiRefresh
        ' to ensure it works even when mouse is over another widget   
        Return over Or focused
    End Method
    
    ' Properly removes focus and resets selection/scroll
    Method LoseFocus()
        focused = False
        scrollOffset = 0
        selectionStart = -1
        selectionEnd = -1

        If g_FocusedTextInput = Self
            g_FocusedTextInput = Null
        EndIf
    End Method
    
    ' Handles all keyboard input: shortcuts, navigation, deletion, typing
    Method HandleKeyboard()
        Local ctrl:Int = KeyDown(KEY_LCONTROL) Or KeyDown(KEY_RCONTROL)
        Local shift:Int = KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT)
        Local CurrentTime:Int = MilliSecs()
        
        If ctrl And KeyHit(KEY_A)
            SelectAll()
            Return
        EndIf
        
        If ctrl And KeyHit(KEY_C)
            CopyToClipboard()
            Return
        EndIf
        
        If ctrl And KeyHit(KEY_X)
            CopyToClipboard()
            DeleteSelection()
            Return
        EndIf
        
        If ctrl And KeyHit(KEY_V)
            PasteFromClipboard()
            Return
        EndIf
        
        ' Backspace with repeat support
        If KeyDown(KEY_BACKSPACE)
            If KeyHit(KEY_BACKSPACE) Or CheckKeyRepeat(KEY_BACKSPACE, CurrentTime)
                If HasSelection()
                    DeleteSelection()
                ElseIf cursorPos > 0
                    text = text[..cursorPos-1] + text[cursorPos..]
                    cursorPos :- 1
                    OnTextChanged()
                EndIf
                ResetCursorBlink()
            EndIf
            Return
        EndIf
        
        ' Delete with repeat support
        If KeyDown(KEY_DELETE)
            If KeyHit(KEY_DELETE) Or CheckKeyRepeat(KEY_DELETE, CurrentTime)
                If HasSelection()
                    DeleteSelection()
                ElseIf cursorPos < text.Length
                    text = text[..cursorPos] + text[cursorPos+1..]
                    OnTextChanged()
                EndIf
                ResetCursorBlink()
            EndIf
            Return
        EndIf
        
        ' Arrow keys navigation with selection support AND KEY REPEAT
        If KeyDown(KEY_LEFT)
            If KeyHit(KEY_LEFT) Or CheckKeyRepeat(KEY_LEFT, CurrentTime)
                If shift
                    If selectionStart = -1
                        selectionStart = cursorPos
                        selectionEnd = cursorPos
                    EndIf
                    If cursorPos > 0
                        cursorPos :- 1
                        selectionEnd = cursorPos
                    EndIf
                Else
                    If HasSelection()
                        cursorPos = MinInt(selectionStart, selectionEnd)
                        ClearSelection()
                    ElseIf cursorPos > 0
                        cursorPos :- 1
                    EndIf
                EndIf
                EnsureCursorVisible()
                ResetCursorBlink()
            EndIf
            Return
        EndIf
        
        If KeyDown(KEY_RIGHT)
            If KeyHit(KEY_RIGHT) Or CheckKeyRepeat(KEY_RIGHT, CurrentTime)
                If shift
                    If selectionStart = -1
                        selectionStart = cursorPos
                        selectionEnd = cursorPos
                    EndIf
                    If cursorPos < text.Length
                        cursorPos :+ 1
                        selectionEnd = cursorPos
                    EndIf
                Else
                    If HasSelection()
                        cursorPos = MaxInt(selectionStart, selectionEnd)
                        ClearSelection()
                    ElseIf cursorPos < text.Length
                        cursorPos :+ 1
                    EndIf
                EndIf
                EnsureCursorVisible()
                ResetCursorBlink()
            EndIf
            Return
        EndIf
        
        ' Reset key repeat if no navigation key is held
        If Not KeyDown(KEY_LEFT) And Not KeyDown(KEY_RIGHT) And Not KeyDown(KEY_BACKSPACE) And Not KeyDown(KEY_DELETE) And Not KeyDown(KEY_HOME) And Not KeyDown(KEY_END)
            ResetKeyRepeat()
        EndIf
        
        If KeyDown(KEY_HOME)
            If KeyHit(KEY_HOME) Or CheckKeyRepeat(KEY_HOME, CurrentTime)
                If shift
                    If selectionStart = -1
                        selectionStart = cursorPos
                        selectionEnd = cursorPos
                    EndIf
                    cursorPos = 0
                    selectionEnd = 0
                Else
                    cursorPos = 0
                    ClearSelection()
                EndIf
                EnsureCursorVisible()
                ResetCursorBlink()
            EndIf
            Return
        EndIf
        
        If KeyDown(KEY_END)
            If KeyHit(KEY_END) Or CheckKeyRepeat(KEY_END, CurrentTime)
                If shift
                    If selectionStart = -1
                        selectionStart = cursorPos
                        selectionEnd = cursorPos
                    EndIf
                    cursorPos = text.Length
                    selectionEnd = text.Length
                Else
                    cursorPos = text.Length
                    ClearSelection()
                EndIf
                EnsureCursorVisible()
                ResetCursorBlink()
            EndIf
            Return
        EndIf
        
        If KeyHit(KEY_ENTER)
            LoseFocus()
            Local ev:TEvent = New TEvent
            ev.target = Self
            ev.eventType = "Submit"
            events.AddLast(ev)
            Return
        EndIf
        
        ' Normal printable character input
        ' Process ALL characters in the buffer (loop until empty)
        Local key:Int = GetChar()
        While key <> 0
            If key >= 32 And key < 127
                If maxLength > 0 And text.Length >= maxLength
                    key = GetChar()
                    Continue
                EndIf
                
                If HasSelection()
                    DeleteSelection()
                EndIf
                
                text = text[..cursorPos] + Chr(key) + text[cursorPos..]
                cursorPos :+ 1
                EnsureCursorVisible()
                OnTextChanged()
                ResetCursorBlink()
            EndIf
            key = GetChar()
        Wend
    End Method
    
    ' Converts mouse X coordinate to character index under the cursor
    Method GetCharIndexAtX:Int(mx:Int)
        Local padding:Int = 4
        Local displayText:String = GetDisplayText()
        Local relX:Int = mx + scrollOffset - padding
        
        If relX <= 0 Return 0
        
        For Local i:Int = 0 To displayText.Length
            Local charX:Int = TWidget.GuiTextWidth(displayText[..i])
            If charX >= relX
                If i > 0
                    Local prevX:Int = TWidget.GuiTextWidth(displayText[..i-1])
                    If relX - prevX < charX - relX
                        Return i - 1
                    EndIf
                EndIf
                Return i
            EndIf
        Next
        
        Return displayText.Length
    End Method
    
    ' Returns the text to display (masked with * if password mode is active)
    Method GetDisplayText:String()
        If passwordMode
            Local masked:String = ""

            For Local i:Int = 0 Until text.Length
                masked :+ "*"
            Next

            Return masked
        EndIf
        Return text
    End Method
    
    ' Adjusts scrollOffset so the cursor remains visible in the field
    Method EnsureCursorVisible()
        Local padding:Int = 4
        Local displayText:String = GetDisplayText()
        Local cursorX:Int = TWidget.GuiTextWidth(displayText[..cursorPos])
        Local visibleWidth:Int = rect.w - padding * 2
        
        If cursorX - scrollOffset > visibleWidth - 10
            scrollOffset = cursorX - visibleWidth + 10
        ElseIf cursorX - scrollOffset < 10
            scrollOffset = MaxInt(0, cursorX - 10)
        EndIf
    End Method
    
    ' Checks if there is an active text selection
    Method HasSelection:Int()
        Return selectionStart >= 0 And selectionEnd >= 0 And selectionStart <> selectionEnd
    End Method
    
    ' Clears the current text selection
    Method ClearSelection()
        selectionStart = -1
        selectionEnd = -1
    End Method
    
    ' Deletes the selected text and updates cursor position
    Method DeleteSelection()
        If Not HasSelection() Return
        
        Local selStart:Int = MinInt(selectionStart, selectionEnd)
        Local selEnd:Int = MaxInt(selectionStart, selectionEnd)
        
        text = text[..selStart] + text[selEnd..]
        cursorPos = selStart
        ClearSelection()
        OnTextChanged()
    End Method
    
    ' Returns the currently selected text (empty string if no selection)
    Method GetSelectedText:String()
        If Not HasSelection() Return ""
        
        Local selStart:Int = MinInt(selectionStart, selectionEnd)
        Local selEnd:Int = MaxInt(selectionStart, selectionEnd)
        
        Return text[selStart..selEnd]
    End Method
    
    ' Selects all text in the field
    Method SelectAll()
        selectionStart = 0
        selectionEnd = text.Length
        cursorPos = text.Length
    End Method
    
    ' Selects the word at the given cursor position (used for double-click)
    Method SelectWordAt(pos:Int)
        Local startPos:Int = pos
        Local endPos:Int = pos
        
        While startPos > 0 And IsWordChar(text[startPos - 1])
            startPos :- 1
        Wend
        
        While endPos < text.Length And IsWordChar(text[endPos])
            endPos :+ 1
        Wend
        
        selectionStart = startPos
        selectionEnd = endPos
        cursorPos = endPos
    End Method
    
    ' Helper: checks if a character is considered part of a word
    Method IsWordChar:Int(char:Int)
        Return (char >= 65 And char <= 90) Or (char >= 97 And char <= 122) Or (char >= 48 And char <= 57) Or char = 95
    End Method
    
    ' Copies selected text to clipboard (currently commented)
    Method CopyToClipboard()
        If HasSelection()
            ' SetClipboardText(GetSelectedText())
        EndIf
    End Method
    
    ' Pastes text from clipboard and handles max length
    Method PasteFromClipboard()
        Local clipText:String = "" ' GetClipboardText()
        If clipText.Length = 0 Return
        
        clipText = clipText.Replace("~r", "").Replace("~n", "")
        
        If HasSelection()
            DeleteSelection()
        EndIf
        
        If maxLength > 0
            Local available:Int = maxLength - text.Length
            If clipText.Length > available
                clipText = clipText[..available]
            EndIf
        EndIf
        
        text = text[..cursorPos] + clipText + text[cursorPos..]
        cursorPos :+ clipText.Length
        EnsureCursorVisible()
        OnTextChanged()
    End Method
    
    ' Resets the cursor blink timer to make it visible immediately
    Method ResetCursorBlink()
        cursorBlink = 0
        cursorVisible = True
    End Method
    
    ' Called when text content changes - fires "Change" event
    Method OnTextChanged()
        Local ev:TEvent = New TEvent
        ev.target = Self
        ev.eventType = "Change"
        events.AddLast(ev)
    End Method
    
    ' Sets new text content and adjusts cursor/selection/scroll
    Method SetText(newText:String)
        text = newText
        cursorPos = MinInt(cursorPos, text.Length)
        ClearSelection()
        scrollOffset = 0
    End Method
    
    ' Returns the current text content
    Method GetText:String()
        Return text
    End Method
    
    ' Sets the placeholder text shown when field is empty
    Method SetPlaceholder(placeholderText:String)
        placeholder = placeholderText
    End Method
    
    ' Sets the maximum allowed length of text
    Method SetMaxLength(Length:Int)
        maxLength = Length
    End Method
    
    ' Enables/disables password mode (displays * instead of characters)
    Method SetPasswordMode(enabled:Int)
        passwordMode = enabled
    End Method
    
    ' Sets or removes focus programmatically
    Method SetFocus(focus:Int)
        If focus
            If g_FocusedTextInput <> Null And g_FocusedTextInput <> Self
                g_FocusedTextInput.LoseFocus()
            EndIf
            focused = True
            g_FocusedTextInput = Self
            ResetCursorBlink()
            ResetKeyRepeat()
            
            ' Clear keyboard buffer to avoid ghost characters
            FlushKeys()
        Else
            LoseFocus()
        EndIf
    End Method
    
    ' Returns whether this text input currently has focus
    Method IsFocused:Int()
        Return focused
    End Method
    
    ' Checks if a "Change" event occurred since last clear
    Method TextChanged:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "Change" Then Return True
        Next
        Return False
    End Method
    
    ' Checks if a "Submit" event occurred (Enter pressed)
    Method WasSubmitted:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "Submit" Then Return True
        Next
        Return False
    End Method
    
    ' Clears all pending events for this widget
    Method ClearEvents()
        events.Clear()
    End Method
    
    ' =========================================================================
    '                         KEY REPEAT METHODS
    ' =========================================================================
    
    ' Check if a key should repeat (returns True if action should be performed)
    Method CheckKeyRepeat:Int(key:Int, CurrentTime:Int)
        ' If this is a new key, start tracking it
        If keyRepeatKey <> key
            keyRepeatKey = key
            keyRepeatStartTime = CurrentTime
            keyRepeatLastTime = CurrentTime
            keyRepeatActive = False
            Return False  ' First press handled by KeyHit
        EndIf
        
        ' Check if we're past the initial delay
        Local elapsed:Int = CurrentTime - keyRepeatStartTime
        If elapsed < KEY_REPEAT_DELAY
            Return False  ' Still in initial delay
        EndIf
        
        ' We're in repeat mode - check if enough time has passed since last repeat
        Local timeSinceLastRepeat:Int = CurrentTime - keyRepeatLastTime
        If timeSinceLastRepeat >= KEY_REPEAT_INTERVAL
            keyRepeatLastTime = CurrentTime
            keyRepeatActive = True
            Return True  ' Trigger repeat action
        EndIf
        
        Return False
    End Method
    
    ' Reset key repeat state (call when key is released or focus lost)
    Method ResetKeyRepeat()
        keyRepeatKey = 0
        keyRepeatStartTime = 0
        keyRepeatLastTime = 0
        keyRepeatActive = False
    End Method
    
    ' Helper: returns the smaller of two integers
    Function MinInt:Int(a:Int, b:Int)
        If a < b Return a
        Return b
    End Function
    
    ' Helper: returns the larger of two integers
    Function MaxInt:Int(a:Int, b:Int)
        If a > b Return a
        Return b
    End Function
End Type