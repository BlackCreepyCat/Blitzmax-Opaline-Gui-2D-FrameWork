' =============================================================================
'                           TEXTAREA WIDGET (version corrigée - COMPLET)
' =============================================================================
' Multi-line editable text area with cursor, selection, scrolling
' CORRECTION : scrollbar vertical ne dépasse plus après Ctrl+X / suppressions massives
' =============================================================================

Global g_FocusedTextArea:TTextArea = Null

Type TTextArea Extends TWidget
    ' Text storage - each line is a separate string
    Field lines:TList = New TList
    
    ' Cursor position (line and column)
    Field cursorLine:Int = 0
    Field cursorCol:Int = 0
    
    ' Selection (start and end positions)
    Field selStartLine:Int = -1
    Field selStartCol:Int = -1
    Field selEndLine:Int = -1
    Field selEndCol:Int = -1
    
    ' Scroll position
    Field scrollX:Int = 0
    Field scrollY:Int = 0
    Field maxScrollX:Int = 0  ' Maximum horizontal scroll
    
    ' View metrics
    Field visibleLines:Int = 1
    Field lineHeight:Int = 20
    Field charWidth:Int = 8
    Field maxLineWidth:Int = 0  ' Width of longest line in pixels
    
    ' State
    Field focused:Int = False
    Field hover:Int = False
    Field dragging:Int = False
    Field cursorBlink:Int = 0
    Field cursorVisible:Int = True
    
    ' Scrollbar dragging state
    Field draggingVScroll:Int = False
    Field draggingHScroll:Int = False
    Field scrollDragOffset:Int = 0
    
    ' Options
    Field isReadOnly:Int = False
    Field wordWrap:Int = False  ' TODO: implement word wrap
    Field tabSize:Int = 4
    Field maxLines:Int = 0      ' 0 = unlimited
    Field showLineNumbers:Int = False
    Field lineNumberWidth:Int = 40
    
    ' Scrollbar options
    Field scrollbarWidth:Int = 14
    Field showHScrollbar:Int = True   ' Show horizontal scrollbar when needed
    Field showVScrollbar:Int = True   ' Show vertical scrollbar when needed
    
    ' Scrollbar colors
    Field scrollBgR:Int = 30, scrollBgG:Int = 30, scrollBgB:Int = 40
    Field scrollThumbR:Int = 80, scrollThumbG:Int = 80, scrollThumbB:Int = 100
    Field scrollThumbHoverR:Int = 100, scrollThumbHoverG:Int = 100, scrollThumbHoverB:Int = 130
    Field scrollThumbDragR:Int = 120, scrollThumbDragG:Int = 120, scrollThumbDragB:Int = 150
    
    ' Scrollbar hover state
    Field hoverVScroll:Int = False
    Field hoverHScroll:Int = False
    
    ' Events
    Field events:TList = New TList
    
    ' Colors
    Field bgR:Int = COLOR_TEXTINPUT_BG_R
    Field bgG:Int = COLOR_TEXTINPUT_BG_G
    Field bgB:Int = COLOR_TEXTINPUT_BG_B
    Field textR:Int = COLOR_TEXTINPUT_TEXT_R
    Field textG:Int = COLOR_TEXTINPUT_TEXT_G
    Field textB:Int = COLOR_TEXTINPUT_TEXT_B
    Field lineNumR:Int = 100, lineNumG:Int = 100, lineNumB:Int = 120
    Field lineNumBgR:Int = 35, lineNumBgG:Int = 35, lineNumBgB:Int = 45
    
    ' Padding
    Field padding:Int = 4
    
    ' =========================================================================
    '                         CONSTRUCTOR
    ' =========================================================================
    Method New(x:Int, y:Int, w:Int, h:Int, initialText:String = "")
        Super.New(x, y, w, h)
        
        ' Initialize with at least one empty line
        If initialText.Length > 0
            SetText(initialText)
        Else
            lines.AddLast("")
        EndIf
        
        ' Calculate visible lines based on height
        UpdateMetrics()
    End Method
    
    ' =========================================================================
    '                         METRICS & SCROLLBARS
    ' =========================================================================
    
    Method UpdateMetrics()
        SetImageFont(Gui_SystemFont)
        lineHeight = TextHeight("Xg") + 2
        charWidth = TextWidth("X")
        
        ' Calculate content area (accounting for scrollbars)
        Local contentHeight:Int = rect.h - padding * 2
        Local contentWidth:Int = rect.w - padding * 2
        If showLineNumbers Then contentWidth :- lineNumberWidth
        
        ' Première estimation
        visibleLines = contentHeight / lineHeight
        If visibleLines < 1 Then visibleLines = 1
        
        Local needsV:Int = NeedsVScrollbar()
        Local needsH:Int = NeedsHScrollbar()
        
        If needsV Then contentWidth :- scrollbarWidth
        If needsH Then contentHeight :- scrollbarWidth
        
        ' Recalcul si interdépendance change
        If needsV <> NeedsVScrollbar() Or needsH <> NeedsHScrollbar()
            visibleLines = contentHeight / lineHeight
            If visibleLines < 1 Then visibleLines = 1
        EndIf
        
        UpdateMaxLineWidth()
    End Method
    
    Method UpdateMaxLineWidth()
        SetImageFont(Gui_SystemFont)
        maxLineWidth = 0
        For Local line:String = EachIn lines
            Local w:Int = TextWidth(line)
            If w > maxLineWidth Then maxLineWidth = w
        Next
        
        Local contentWidth:Int = GetContentWidth()
        maxScrollX = Max(0, maxLineWidth - contentWidth + charWidth * 2)
    End Method
    
    Method GetContentWidth:Int()
        Local w:Int = rect.w - padding * 2
        If showLineNumbers Then w :- lineNumberWidth
        If NeedsVScrollbar() Then w :- scrollbarWidth
        Return Max(10, w)
    End Method
    
    Method GetContentHeight:Int()
        Local h:Int = rect.h - padding * 2
        If NeedsHScrollbar() Then h :- scrollbarWidth
        Return Max(10, h)
    End Method
    
    Method NeedsVScrollbar:Int()
        Return showVScrollbar And (lines.Count() > visibleLines Or scrollY > 0)
    End Method
    
    Method NeedsHScrollbar:Int()
        If Not showHScrollbar Then Return False
        Local contentWidth:Int = rect.w - padding * 2
        If showLineNumbers Then contentWidth :- lineNumberWidth
        If NeedsVScrollbar() Then contentWidth :- scrollbarWidth
        Return maxLineWidth > contentWidth
    End Method
    
    ' =========================================================================
    '                         HELPER APRÈS MODIFICATION TEXTE
    ' =========================================================================
    Method AfterTextEdit()
        UpdateMaxLineWidth()
        UpdateMetrics()
        EnsureCursorVisible()
        FireChangeEvent()
    End Method
    
    ' =========================================================================
    '                         TEXT MANAGEMENT
    ' =========================================================================
    
    Method SetText(text:String)
        lines.Clear()
        
        Local parts:String[] = text.Split("~n")
        For Local part:String = EachIn parts
            part = part.Replace("~r", "")
            lines.AddLast(part)
        Next
        
        If lines.Count() = 0 Then lines.AddLast("")
        
        cursorLine = 0
        cursorCol = 0
        ClearSelection()
        scrollX = 0
        scrollY = 0
        
        AfterTextEdit()
    End Method
    
    Method GetText:String()
        Local result:String = ""
        Local first:Int = True
        For Local line:String = EachIn lines
            If Not first Then result :+ "~n"
            result :+ line
            first = False
        Next
        Return result
    End Method
    
    Method GetLine:String(index:Int)
        If index < 0 Or index >= lines.Count() Then Return ""
        Local i:Int = 0
        For Local line:String = EachIn lines
            If i = index Then Return line
            i :+ 1
        Next
        Return ""
    End Method
    
    Method SetLine(index:Int, text:String)
        If index < 0 Or index >= lines.Count() Then Return
        
        Local newLines:TList = New TList
        Local i:Int = 0
        For Local line:String = EachIn lines
            If i = index
                newLines.AddLast(text)
            Else
                newLines.AddLast(line)
            EndIf
            i :+ 1
        Next
        lines = newLines
        AfterTextEdit()
    End Method
    
    Method GetLineCount:Int()
        Return lines.Count()
    End Method
    
    Method InsertText(text:String)
        If isReadOnly Then Return
        
        If HasSelection() Then DeleteSelection()
        
        Local parts:String[] = text.Split("~n")
        
        Local currentLine:String = GetLine(cursorLine)
        Local beforeCursor:String = currentLine[..cursorCol]
        Local afterCursor:String = currentLine[cursorCol..]
        
        If parts.Length = 1
            SetLine(cursorLine, beforeCursor + parts[0] + afterCursor)
            cursorCol :+ parts[0].Length
        Else
            SetLine(cursorLine, beforeCursor + parts[0])
            
            For Local i:Int = 1 Until parts.Length - 1
                cursorLine :+ 1
                InsertLineAt(cursorLine, parts[i])
            Next
            
            cursorLine :+ 1
            InsertLineAt(cursorLine, parts[parts.Length - 1] + afterCursor)
            cursorCol = parts[parts.Length - 1].Length
        EndIf
        
        AfterTextEdit()
    End Method
    
    Method InsertLineAt(index:Int, text:String)
        If index < 0 Then index = 0
        If index >= lines.Count()
            lines.AddLast(text)
        Else
            Local newLines:TList = New TList
            Local i:Int = 0
            For Local line:String = EachIn lines
                If i = index Then newLines.AddLast(text)
                newLines.AddLast(line)
                i :+ 1
            Next
            lines = newLines
        EndIf
        AfterTextEdit()
    End Method
    
    Method RemoveLineAt(index:Int)
        If index < 0 Or index >= lines.Count() Then Return
        If lines.Count() <= 1
            SetLine(0, "")
            Return
        EndIf
        
        Local newLines:TList = New TList
        Local i:Int = 0
        For Local line:String = EachIn lines
            If i <> index Then newLines.AddLast(line)
            i :+ 1
        Next
        lines = newLines
        
        AfterTextEdit()
    End Method
    
    ' =========================================================================
    '                         SELECTION
    ' =========================================================================
    
    Method HasSelection:Int()
        Return selStartLine >= 0 And selStartCol >= 0
    End Method
    
    Method ClearSelection()
        selStartLine = -1
        selStartCol = -1
        selEndLine = -1
        selEndCol = -1
    End Method
    
    Method StartSelection()
        If Not HasSelection()
            selStartLine = cursorLine
            selStartCol = cursorCol
            selEndLine = cursorLine
            selEndCol = cursorCol
        EndIf
    End Method
    
    Method UpdateSelection()
        selEndLine = cursorLine
        selEndCol = cursorCol
    End Method
    
    Method GetNormalizedSelection(startLine:Int Var, startCol:Int Var, endLine:Int Var, endCol:Int Var)
        If selStartLine < selEndLine Or (selStartLine = selEndLine And selStartCol <= selEndCol)
            startLine = selStartLine
            startCol = selStartCol
            endLine = selEndLine
            endCol = selEndCol
        Else
            startLine = selEndLine
            startCol = selEndCol
            endLine = selStartLine
            endCol = selStartCol
        EndIf
    End Method
    
    Method GetSelectedText:String()
        If Not HasSelection() Then Return ""
        
        Local startLine:Int, startCol:Int, endLine:Int, endCol:Int
        GetNormalizedSelection(startLine, startCol, endLine, endCol)
        
        If startLine = endLine
            Local line:String = GetLine(startLine)
            Return line[startCol..endCol]
        Else
            Local result:String = GetLine(startLine)[startCol..]
            For Local i:Int = startLine + 1 Until endLine
                result :+ "~n" + GetLine(i)
            Next
            result :+ "~n" + GetLine(endLine)[..endCol]
            Return result
        EndIf
    End Method
    
    Method DeleteSelection()
        If Not HasSelection() Then Return
        
        Local startLine:Int, startCol:Int, endLine:Int, endCol:Int
        GetNormalizedSelection(startLine, startCol, endLine, endCol)
        
        If startLine = endLine
            Local line:String = GetLine(startLine)
            SetLine(startLine, line[..startCol] + line[endCol..])
            cursorCol = startCol
        Else
            Local firstLine:String = GetLine(startLine)[..startCol]
            Local lastLine:String = GetLine(endLine)[endCol..]
            
            SetLine(startLine, firstLine + lastLine)
            
            For Local i:Int = endLine To startLine + 1 Step -1
                RemoveLineAt(i)
            Next
            
            cursorLine = startLine
            cursorCol = startCol
        EndIf
        
        ClearSelection()
        
        AfterTextEdit()  ' FIX PRINCIPAL
    End Method
    
    Method SelectAll()
        selStartLine = 0
        selStartCol = 0
        selEndLine = lines.Count() - 1
        selEndCol = GetLine(selEndLine).Length
        cursorLine = selEndLine
        cursorCol = selEndCol
    End Method
    
    ' =========================================================================
    '                         CURSOR MANAGEMENT
    ' =========================================================================
    
    Method EnsureCursorVisible()
        ' Vertical scrolling - reclamp strict
        Local maxScrollY:Int = Max(0, lines.Count() - visibleLines)
        If cursorLine < scrollY
            scrollY = cursorLine
        ElseIf cursorLine >= scrollY + visibleLines
            scrollY = cursorLine - visibleLines + 1
        EndIf
        scrollY = Max(0, Min(scrollY, maxScrollY))
        
        ' Horizontal scrolling
        SetImageFont(Gui_SystemFont)
        Local line:String = GetLine(cursorLine)
        Local cursorX:Int = TextWidth(line[..cursorCol])
        Local contentWidth:Int = GetContentWidth()
        
        If cursorX - scrollX < 0
            scrollX = Max(0, cursorX - 20)
        ElseIf cursorX - scrollX > contentWidth - 20
            scrollX = cursorX - contentWidth + 20
        EndIf
        
        scrollX = Max(0, Min(scrollX, maxScrollX))
    End Method
    
    Method MoveCursorTo(line:Int, col:Int, extendSelection:Int = False)
        If extendSelection Then StartSelection()
        
        cursorLine = Max(0, Min(line, lines.Count() - 1))
        
        Local lineText:String = GetLine(cursorLine)
        cursorCol = Max(0, Min(col, lineText.Length))
        
        If extendSelection Then UpdateSelection()
        
        EnsureCursorVisible()
        ResetCursorBlink()
    End Method
    
    Method ResetCursorBlink()
        cursorBlink = 0
        cursorVisible = True
    End Method
    
    ' =========================================================================
    '                         SCROLLBAR HELPERS
    ' =========================================================================
    
    Method GetVScrollbarRect(bx:Int Var, by:Int Var, bw:Int Var, bh:Int Var)
        bx = rect.w - scrollbarWidth
        by = 0
        bw = scrollbarWidth
        bh = rect.h
        If NeedsHScrollbar() Then bh :- scrollbarWidth
    End Method
    
    Method GetVScrollThumbRect(tx:Int Var, ty:Int Var, tw:Int Var, th:Int Var)
        Local bx:Int, by:Int, bw:Int, bh:Int
        GetVScrollbarRect(bx, by, bw, bh)
        
        Local totalLines:Int = lines.Count()
        Local trackHeight:Int = bh - 4
        
        th = Max(20, trackHeight * visibleLines / Max(1, totalLines))
        tw = bw - 4
        tx = bx + 2
        
        Local scrollRange:Int = Max(0, totalLines - visibleLines)
        If scrollRange > 0
            ty = by + 2 + (trackHeight - th) * scrollY / scrollRange
        Else
            ty = by + 2
        EndIf
    End Method
    
    Method GetHScrollbarRect(bx:Int Var, by:Int Var, bw:Int Var, bh:Int Var)
        bx = 0
        If showLineNumbers Then bx = lineNumberWidth
        by = rect.h - scrollbarWidth
        bw = rect.w - bx
        If NeedsVScrollbar() Then bw :- scrollbarWidth
        bh = scrollbarWidth
    End Method
    
    Method GetHScrollThumbRect(tx:Int Var, ty:Int Var, tw:Int Var, th:Int Var)
        Local bx:Int, by:Int, bw:Int, bh:Int
        GetHScrollbarRect(bx, by, bw, bh)
        
        Local contentWidth:Int = GetContentWidth()
        Local trackWidth:Int = bw - 4
        
        If maxLineWidth > 0
            tw = Max(20, trackWidth * contentWidth / (maxLineWidth + charWidth * 2))
        Else
            tw = trackWidth
        EndIf
        th = bh - 4
        ty = by + 2
        
        If maxScrollX > 0
            tx = bx + 2 + (trackWidth - tw) * scrollX / maxScrollX
        Else
            tx = bx + 2
        EndIf
    End Method
    
    ' =========================================================================
    '                         KEYBOARD HANDLING
    ' =========================================================================
    
    Method HandleKeyboard()
        If Not focused Then Return
        
        Local shift:Int = KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT)
        Local ctrl:Int = KeyDown(KEY_LCONTROL) Or KeyDown(KEY_RCONTROL)
        
        ' Ctrl+A - Select All
        If ctrl And KeyHit(KEY_A)
            SelectAll()
            Return
        EndIf
        
        ' Ctrl+C - Copy
        If ctrl And KeyHit(KEY_C)
            If HasSelection()
				ClipboardSetText(Gui_Clipboard, GetSelectedText())
            EndIf
            Return
        EndIf
        
        ' Ctrl+X - Cut
        If ctrl And KeyHit(KEY_X)
            If HasSelection() And Not isReadOnly
                ClipboardSetText(Gui_Clipboard, GetSelectedText())
                DeleteSelection()
            EndIf
            Return
        EndIf
        
        ' Ctrl+V - Paste
        If ctrl And KeyHit(KEY_V)
            If Not isReadOnly
                Local clip:String = ClipboardText(Gui_Clipboard)
                If clip.Length > 0
                    InsertText(clip)
                EndIf
            EndIf
            Return
        EndIf
        
        ' Arrow keys
        If KeyHit(KEY_UP)
            If Not shift Then ClearSelection()
            If cursorLine > 0
                If shift Then StartSelection()
                cursorLine :- 1
                cursorCol = Min(cursorCol, GetLine(cursorLine).Length)
                If shift Then UpdateSelection()
            EndIf
            EnsureCursorVisible()
            ResetCursorBlink()
            Return
        EndIf
        
        If KeyHit(KEY_DOWN)
            If Not shift Then ClearSelection()
            If cursorLine < lines.Count() - 1
                If shift Then StartSelection()
                cursorLine :+ 1
                cursorCol = Min(cursorCol, GetLine(cursorLine).Length)
                If shift Then UpdateSelection()
            EndIf
            EnsureCursorVisible()
            ResetCursorBlink()
            Return
        EndIf
        
        If KeyHit(KEY_LEFT)
            If shift Then StartSelection() Else If HasSelection() Then ClearSelection()
            
            If cursorCol > 0
                cursorCol :- 1
            ElseIf cursorLine > 0
                cursorLine :- 1
                cursorCol = GetLine(cursorLine).Length
            EndIf
            
            If shift Then UpdateSelection()
            EnsureCursorVisible()
            ResetCursorBlink()
            Return
        EndIf
        
        If KeyHit(KEY_RIGHT)
            If shift Then StartSelection() Else If HasSelection() Then ClearSelection()
            
            Local lineLen:Int = GetLine(cursorLine).Length
            If cursorCol < lineLen
                cursorCol :+ 1
            ElseIf cursorLine < lines.Count() - 1
                cursorLine :+ 1
                cursorCol = 0
            EndIf
            
            If shift Then UpdateSelection()
            EnsureCursorVisible()
            ResetCursorBlink()
            Return
        EndIf
        
        ' Home/End
        If KeyHit(KEY_HOME)
            If shift Then StartSelection() Else ClearSelection()
            If ctrl
                cursorLine = 0
            EndIf
            cursorCol = 0
            If shift Then UpdateSelection()
            EnsureCursorVisible()
            ResetCursorBlink()
            Return
        EndIf
        
        If KeyHit(KEY_END)
            If shift Then StartSelection() Else ClearSelection()
            If ctrl
                cursorLine = lines.Count() - 1
            EndIf
            cursorCol = GetLine(cursorLine).Length
            If shift Then UpdateSelection()
            EnsureCursorVisible()
            ResetCursorBlink()
            Return
        EndIf
        
        ' Page Up/Down
        If KeyHit(KEY_PAGEUP)
            If shift Then StartSelection() Else ClearSelection()
            cursorLine = Max(0, cursorLine - visibleLines)
            cursorCol = Min(cursorCol, GetLine(cursorLine).Length)
            If shift Then UpdateSelection()
            EnsureCursorVisible()
            ResetCursorBlink()
            Return
        EndIf
        
        If KeyHit(KEY_PAGEDOWN)
            If shift Then StartSelection() Else ClearSelection()
            cursorLine = Min(lines.Count() - 1, cursorLine + visibleLines)
            cursorCol = Min(cursorCol, GetLine(cursorLine).Length)
            If shift Then UpdateSelection()
            EnsureCursorVisible()
            ResetCursorBlink()
            Return
        EndIf
        
        ' Backspace
        If KeyHit(KEY_BACKSPACE) And Not isReadOnly
            If HasSelection()
                DeleteSelection()
            ElseIf cursorCol > 0
                Local line:String = GetLine(cursorLine)
                SetLine(cursorLine, line[..cursorCol-1] + line[cursorCol..])
                cursorCol :- 1
            ElseIf cursorLine > 0
                Local prevLine:String = GetLine(cursorLine - 1)
                Local currentLine:String = GetLine(cursorLine)
                cursorCol = prevLine.Length
                SetLine(cursorLine - 1, prevLine + currentLine)
                RemoveLineAt(cursorLine)
                cursorLine :- 1
            EndIf
            EnsureCursorVisible()
            ResetCursorBlink()
            AfterTextEdit()
            Return
        EndIf
        
        ' Delete
        If KeyHit(KEY_DELETE) And Not isReadOnly
            If HasSelection()
                DeleteSelection()
            Else
                Local line:String = GetLine(cursorLine)
                If cursorCol < line.Length
                    SetLine(cursorLine, line[..cursorCol] + line[cursorCol+1..])
                ElseIf cursorLine < lines.Count() - 1
                    Local nextLine:String = GetLine(cursorLine + 1)
                    SetLine(cursorLine, line + nextLine)
                    RemoveLineAt(cursorLine + 1)
                EndIf
            EndIf
            EnsureCursorVisible()
            ResetCursorBlink()
            AfterTextEdit()
            Return
        EndIf
        
        ' Enter - insert new line
        If KeyHit(KEY_ENTER) And Not isReadOnly
            If HasSelection() Then DeleteSelection()
            
            Local line:String = GetLine(cursorLine)
            Local beforeCursor:String = line[..cursorCol]
            Local afterCursor:String = line[cursorCol..]
            
            SetLine(cursorLine, beforeCursor)
            cursorLine :+ 1
            InsertLineAt(cursorLine, afterCursor)
            cursorCol = 0
            
            EnsureCursorVisible()
            ResetCursorBlink()
            AfterTextEdit()
            Return
        EndIf
        
        ' Tab
        If KeyHit(KEY_TAB) And Not isReadOnly
            If HasSelection() Then DeleteSelection()
            Local spaces:String = ""
            For Local i:Int = 0 Until tabSize
                spaces :+ " "
            Next
            InsertText(spaces)
            Return
        EndIf
        
        ' Normal character input
        Local key:Int = GetChar()
        While key <> 0
            If key >= 32 And key < 127 And Not isReadOnly
                If HasSelection() Then DeleteSelection()
                
                Local line:String = GetLine(cursorLine)
                SetLine(cursorLine, line[..cursorCol] + Chr(key) + line[cursorCol..])
                cursorCol :+ 1
                
                EnsureCursorVisible()
                ResetCursorBlink()
                AfterTextEdit()
            EndIf
            key = GetChar()
        Wend
    End Method
    
    ' =========================================================================
    '                         MOUSE HANDLING
    ' =========================================================================
    
    Method GetPositionFromMouse:Int[](mx:Int, my:Int)
        SetImageFont(Gui_SystemFont)
        
        Local contentX:Int = padding
        If showLineNumbers Then contentX :+ lineNumberWidth
        
        Local relY:Int = my - padding
        Local clickLine:Int = scrollY + relY / lineHeight
        clickLine = Max(0, Min(clickLine, lines.Count() - 1))
        
        Local relX:Int = mx - contentX + scrollX
        Local line:String = GetLine(clickLine)
        Local clickCol:Int = 0
        
        For Local i:Int = 0 To line.Length
            Local w:Int = TextWidth(line[..i])
            If w >= relX
                If i > 0
                    Local prevW:Int = TextWidth(line[..i-1])
                    If relX - prevW < w - relX
                        clickCol = i - 1
                    Else
                        clickCol = i
                    EndIf
                Else
                    clickCol = 0
                EndIf
                Exit
            EndIf
            clickCol = i
        Next
        
        Return [clickLine, clickCol]
    End Method
    
    ' =========================================================================
    '                         UPDATE
    ' =========================================================================
    
    Method Update:Int(mx:Int, my:Int)
        If Not visible Then Return False
        
        UpdateMetrics()
        
        Local over:Int = (mx >= 0 And mx < rect.w And my >= 0 And my < rect.h)
        hover = over
        
        Local hit:Int = GuiMouse.Hit()
        Local down:Int = GuiMouse.Down()
        Local released:Int = GuiMouse.Released()
        
        hoverVScroll = False
        hoverHScroll = False
        
        If over And NeedsVScrollbar()
            Local bx:Int, by:Int, bw:Int, bh:Int
            GetVScrollbarRect(bx, by, bw, bh)
            If mx >= bx And mx < bx + bw And my >= by And my < by + bh
                hoverVScroll = True
            EndIf
        EndIf
        
        If over And NeedsHScrollbar()
            Local bx:Int, by:Int, bw:Int, bh:Int
            GetHScrollbarRect(bx, by, bw, bh)
            If mx >= bx And mx < bx + bw And my >= by And my < by + bh
                hoverHScroll = True
            EndIf
        EndIf
        
        If draggingVScroll
            If down
                Local bx:Int, by:Int, bw:Int, bh:Int
                GetVScrollbarRect(bx, by, bw, bh)
                
                Local tx:Int, ty:Int, tw:Int, th:Int
                GetVScrollThumbRect(tx, ty, tw, th)
                
                Local trackHeight:Int = bh - 4
                Local thumbRange:Int = trackHeight - th
                
                If thumbRange > 0
                    Local newThumbY:Int = my - scrollDragOffset - (by + 2)
                    newThumbY = Max(0, Min(newThumbY, thumbRange))
                    
                    Local scrollRange:Int = lines.Count() - visibleLines
                    scrollY = newThumbY * scrollRange / thumbRange
                    scrollY = Max(0, Min(scrollY, scrollRange))
                EndIf
                Return True
            Else
                draggingVScroll = False
            EndIf
        EndIf
        
        If draggingHScroll
            If down
                Local bx:Int, by:Int, bw:Int, bh:Int
                GetHScrollbarRect(bx, by, bw, bh)
                
                Local tx:Int, ty:Int, tw:Int, th:Int
                GetHScrollThumbRect(tx, ty, tw, th)
                
                Local trackWidth:Int = bw - 4
                Local thumbRange:Int = trackWidth - tw
                
                If thumbRange > 0
                    Local newThumbX:Int = mx - scrollDragOffset - (bx + 2)
                    newThumbX = Max(0, Min(newThumbX, thumbRange))
                    
                    scrollX = newThumbX * maxScrollX / thumbRange
                    scrollX = Max(0, Min(scrollX, maxScrollX))
                EndIf
                Return True
            Else
                draggingHScroll = False
            EndIf
        EndIf
        
        If hit And over
            If NeedsVScrollbar() And hoverVScroll
                Local tx:Int, ty:Int, tw:Int, th:Int
                GetVScrollThumbRect(tx, ty, tw, th)
                
                If mx >= tx And mx < tx + tw And my >= ty And my < ty + th
                    draggingVScroll = True
                    scrollDragOffset = my - ty
                Else
                    Local bx:Int, by:Int, bw:Int, bh:Int
                    GetVScrollbarRect(bx, by, bw, bh)
                    If my < ty
                        scrollY = Max(0, scrollY - visibleLines)
                    Else
                        scrollY = Min(lines.Count() - visibleLines, scrollY + visibleLines)
                    EndIf
                EndIf
                Return True
            EndIf
            
            If NeedsHScrollbar() And hoverHScroll
                Local tx:Int, ty:Int, tw:Int, th:Int
                GetHScrollThumbRect(tx, ty, tw, th)
                
                If mx >= tx And mx < tx + tw And my >= ty And my < ty + th
                    draggingHScroll = True
                    scrollDragOffset = mx - tx
                Else
                    Local contentWidth:Int = GetContentWidth()
                    If mx < tx
                        scrollX = Max(0, scrollX - contentWidth)
                    Else
                        scrollX = Min(maxScrollX, scrollX + contentWidth)
                    EndIf
                EndIf
                Return True
            EndIf
        EndIf
        
        Local inContentArea:Int = over And Not hoverVScroll And Not hoverHScroll
        
        If inContentArea And hit And draggedWindow = Null
            If g_FocusedTextArea <> Null And g_FocusedTextArea <> Self
                g_FocusedTextArea.LoseFocus()
            EndIf
            If g_FocusedTextInput <> Null
                g_FocusedTextInput.focused = False
                g_FocusedTextInput = Null
            EndIf
            
            focused = True
            g_FocusedTextArea = Self
            
            Local pos:Int[] = GetPositionFromMouse(mx, my)
            
            If KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT)
                StartSelection()
                cursorLine = pos[0]
                cursorCol = pos[1]
                UpdateSelection()
            Else
                ClearSelection()
                cursorLine = pos[0]
                cursorCol = pos[1]
                dragging = True
                StartSelection()
            EndIf
            
            ResetCursorBlink()
            FlushKeys()
            Return True
        EndIf
        
        If dragging And down
            Local pos:Int[] = GetPositionFromMouse(mx, my)
            cursorLine = pos[0]
            cursorCol = pos[1]
            UpdateSelection()
            EnsureCursorVisible()
            Return True
        EndIf
        
        If dragging And released
            dragging = False
            If selStartLine = selEndLine And selStartCol = selEndCol
                ClearSelection()
            EndIf
        EndIf
        
        If over
            Local wheel:Int = GuiMouse.WheelIdle()
            If wheel <> 0
                scrollY = Max(0, Min(scrollY - wheel * 3, Max(0, lines.Count() - visibleLines)))
                Return True
            EndIf
        EndIf
        
        If hit And Not over And focused
            LoseFocus()
        EndIf
        
        If focused
            cursorBlink :+ 1
            If cursorBlink >= 30
                cursorBlink = 0
                cursorVisible = Not cursorVisible
            EndIf
        EndIf
        
        Return over And (hit Or down)
    End Method
    
    Method LoseFocus()
        focused = False
        dragging = False
        If g_FocusedTextArea = Self
            g_FocusedTextArea = Null
        EndIf
    End Method
    
    ' =========================================================================
    '                         DRAW
    ' =========================================================================
    
    Method Draw(px:Int=0, py:Int=0)
        If Not visible Then Return
        
        UpdateMetrics()
        
        Local ax:Int = px + rect.x
        Local ay:Int = py + rect.y
        
        If focused
            TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, 3, bgR + 10, bgG + 10, bgB + 10)
        Else
            TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, 3, bgR, bgG, bgB)
        EndIf
        
        Local contentX:Int = ax + padding
        Local contentY:Int = ay + padding
        Local contentW:Int = GetContentWidth()
        Local contentH:Int = GetContentHeight()
        
        If showLineNumbers
            TWidget.GuiDrawRect(ax, ay, lineNumberWidth, rect.h, 1, lineNumBgR, lineNumBgG, lineNumBgB)
            contentX :+ lineNumberWidth
        EndIf
        
        TWidget.GuiSetViewport(contentX, contentY, contentW, contentH)
        
        SetImageFont(Gui_SystemFont)
        
        Local y:Int = contentY
        For Local i:Int = scrollY Until Min(scrollY + visibleLines + 1, lines.Count())
            Local line:String = GetLine(i)
            Local lineY:Int = y
            
            If HasSelection()
                DrawLineSelection(i, contentX, lineY, line)
            EndIf
            
            SetColor(textR, textG, textB)
            DrawText(line, contentX - scrollX, lineY)
            
            If focused And cursorVisible And i = cursorLine
                Local cursorDrawX:Int = contentX - scrollX + TextWidth(line[..cursorCol])
                SetColor(COLOR_TEXTINPUT_CURSOR_R, COLOR_TEXTINPUT_CURSOR_G, COLOR_TEXTINPUT_CURSOR_B)
                DrawLine(cursorDrawX, lineY, cursorDrawX, lineY + lineHeight - 2)
            EndIf
            
            y :+ lineHeight
        Next
        
        TWidget.GuiSetViewport(0, 0, GraphicsWidth(), GraphicsHeight())
        
        If showLineNumbers
            TWidget.GuiSetViewport(ax + 2, contentY, lineNumberWidth - 4, contentH)
            Local y2:Int = contentY
            For Local i:Int = scrollY Until Min(scrollY + visibleLines + 1, lines.Count())
                SetColor(lineNumR, lineNumG, lineNumB)
                Local numStr:String = String(i + 1)
                DrawText(numStr, ax + lineNumberWidth - 6 - TextWidth(numStr), y2)
                y2 :+ lineHeight
            Next
            TWidget.GuiSetViewport(0, 0, GraphicsWidth(), GraphicsHeight())
        EndIf
        
        If NeedsVScrollbar()
            Local bx:Int, by:Int, bw:Int, bh:Int
            GetVScrollbarRect(bx, by, bw, bh)
            
            SetColor(scrollBgR, scrollBgG, scrollBgB)
            DrawRect(ax + bx, ay + by, bw, bh)
            
            Local tx:Int, ty:Int, tw:Int, th:Int
            GetVScrollThumbRect(tx, ty, tw, th)
            
            If draggingVScroll
                SetColor(scrollThumbDragR, scrollThumbDragG, scrollThumbDragB)
            ElseIf hoverVScroll
                SetColor(scrollThumbHoverR, scrollThumbHoverG, scrollThumbHoverB)
            Else
                SetColor(scrollThumbR, scrollThumbG, scrollThumbB)
            EndIf
            DrawRect(ax + tx, ay + ty, tw, th)
        EndIf
        
        If NeedsHScrollbar()
            Local bx:Int, by:Int, bw:Int, bh:Int
            GetHScrollbarRect(bx, by, bw, bh)
            
            SetColor(scrollBgR, scrollBgG, scrollBgB)
            DrawRect(ax + bx, ay + by, bw, bh)
            
            Local tx:Int, ty:Int, tw:Int, th:Int
            GetHScrollThumbRect(tx, ty, tw, th)
            
            If draggingHScroll
                SetColor(scrollThumbDragR, scrollThumbDragG, scrollThumbDragB)
            ElseIf hoverHScroll
                SetColor(scrollThumbHoverR, scrollThumbHoverG, scrollThumbHoverB)
            Else
                SetColor(scrollThumbR, scrollThumbG, scrollThumbB)
            EndIf
            DrawRect(ax + tx, ay + ty, tw, th)
        EndIf
        
        If NeedsVScrollbar() And NeedsHScrollbar()
            SetColor(scrollBgR, scrollBgG, scrollBgB)
            DrawRect(ax + rect.w - scrollbarWidth, ay + rect.h - scrollbarWidth, scrollbarWidth, scrollbarWidth)
        EndIf
        
        SetColor(255, 255, 255)
    End Method
    
    Method DrawLineSelection(lineIndex:Int, contentX:Int, lineY:Int, lineText:String)
        Local startLine:Int, startCol:Int, endLine:Int, endCol:Int
        GetNormalizedSelection(startLine, startCol, endLine, endCol)
        
        If lineIndex < startLine Or lineIndex > endLine Then Return
        
        Local selStartX:Int, selEndX:Int
        
        If lineIndex = startLine And lineIndex = endLine
            selStartX = contentX - scrollX + TextWidth(lineText[..startCol])
            selEndX = contentX - scrollX + TextWidth(lineText[..endCol])
        ElseIf lineIndex = startLine
            selStartX = contentX - scrollX + TextWidth(lineText[..startCol])
            selEndX = contentX - scrollX + TextWidth(lineText) + charWidth
        ElseIf lineIndex = endLine
            selStartX = contentX - scrollX
            selEndX = contentX - scrollX + TextWidth(lineText[..endCol])
        Else
            selStartX = contentX - scrollX
            selEndX = contentX - scrollX + TextWidth(lineText) + charWidth
        EndIf
        
        SetColor(COLOR_TEXTINPUT_SELECTION_R, COLOR_TEXTINPUT_SELECTION_G, COLOR_TEXTINPUT_SELECTION_B)
        DrawRect(selStartX, lineY, selEndX - selStartX, lineHeight)
    End Method
    
    ' =========================================================================
    '                         EVENTS
    ' =========================================================================
    
    Method FireChangeEvent()
        Local ev:TEvent = New TEvent
        ev.target = Self
        ev.eventType = "Change"
        events.AddLast(ev)
    End Method
    
    Method TextChanged:Int()
        For Local ev:TEvent = EachIn events
            If ev.eventType = "Change" Then Return True
        Next
        Return False
    End Method
    
    Method ClearEvents()
        events.Clear()
    End Method
    
    ' =========================================================================
    '                         OPTIONS
    ' =========================================================================
    
    Method SetReadOnlyMode(ro:Int)
        isReadOnly = ro
    End Method
    
    Method GetReadOnlyMode:Int()
        Return isReadOnly
    End Method
    
    Method SetShowLineNumbers(show:Int)
        showLineNumbers = show
    End Method
    
    Method SetTabSize(size:Int)
        tabSize = Max(1, size)
    End Method
    
    Method SetScrollbarWidth(w:Int)
        scrollbarWidth = Max(8, Min(w, 30))
    End Method
    
    Method GetScrollbarWidth:Int()
        Return scrollbarWidth
    End Method
    
    Method SetShowHScrollbar(show:Int)
        showHScrollbar = show
    End Method
    
    Method SetShowVScrollbar(show:Int)
        showVScrollbar = show
    End Method
End Type