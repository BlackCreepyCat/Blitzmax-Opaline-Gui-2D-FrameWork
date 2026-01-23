' =============================================================================
'                           TEXTAREA WIDGET (version corrigée - COMPLET)
' =============================================================================
' Multi-line editable text area with cursor, selection, scrolling
' CORRECTION : scrollbar vertical ne dépasse plus après Ctrl+X / suppressions massives
' =============================================================================

Global g_FocusedTextArea:TTextArea = Null

' Key repeat constants for TextArea (same as TextInput)
Const TEXTAREA_KEY_REPEAT_DELAY:Int = 500      ' Initial delay before repeat starts (ms)
Const TEXTAREA_KEY_REPEAT_INTERVAL:Int = 50    ' Interval between repeats (ms)

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
    
    ' Key repeat state for arrow keys
    Field keyRepeatKey:Int = 0           ' Currently repeating key (0 = none)
    Field keyRepeatStartTime:Int = 0     ' Time when key was first pressed
    Field keyRepeatLastTime:Int = 0      ' Time of last repeat
    Field keyRepeatActive:Int = False    ' Is repeat currently active?
    
    ' Options
    Field isReadOnly:Int = False
    Field wordWrap:Int = False  ' TODO: implement word wrap
    Field tabSize:Int = 4
    Field maxLines:Int = 0      ' 0 = unlimited
    Field showLineNumbers:Int = False
    Field lineNumberWidth:Int = 50
    
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
    Field lineNumBgR:Int = 40, lineNumBgG:Int = 40, lineNumBgB:Int = 50
    
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
		lineHeight = TWidget.GuiTextHeight("Xg") + 2
		charWidth = TWidget.GuiTextWidth("X")
		
		' Calcul de maxLineWidth (indépendant des scrollbars)
		maxLineWidth = 0
		For Local line:String = EachIn lines
			Local w:Int = TWidget.GuiTextWidth(line)
			If w > maxLineWidth Then maxLineWidth = w
		Next
		
		' Algorithme de convergence amélioré avec limite d'itérations
		Local converged:Int = False
		Local assumedNeedsV:Int = False
		Local assumedNeedsH:Int = False
		Local iterations:Int = 0
		Local maxIterations:Int = 5  ' Limite de sécurité
		
		While Not converged And iterations < maxIterations
			iterations :+ 1
			
			' Calcul de la hauteur de contenu disponible
			Local contentHeight:Int = rect.h - padding * 2
			If assumedNeedsH Then contentHeight :- scrollbarWidth
			
			visibleLines = contentHeight / lineHeight
			If visibleLines < 1 Then visibleLines = 1
			
			' Calcul temporaire de maxScrollY basé sur visibleLines actuel
			Local tempMaxScrollY:Int = Max(0, lines.Count() - visibleLines)
			Local tempScrollY:Int = Max(0, Min(scrollY, tempMaxScrollY))
			
			' Vérification si scrollbar verticale nécessaire
			' IMPORTANT: Utiliser tempScrollY recalculé pour éviter forçage avec valeur obsolète
			Local calcNeedsV:Int = showVScrollbar And (lines.Count() > visibleLines Or tempScrollY > 0)
			
			' Calcul de la largeur de contenu disponible
			Local contentWidth:Int = rect.w - padding * 2
			If showLineNumbers Then contentWidth :- lineNumberWidth
			If calcNeedsV Then contentWidth :- scrollbarWidth
			
			' Vérification si scrollbar horizontale nécessaire
			Local calcNeedsH:Int = showHScrollbar And (maxLineWidth > contentWidth)
			
			' Vérification de convergence
			If calcNeedsV = assumedNeedsV And calcNeedsH = assumedNeedsH
				converged = True
			Else
				assumedNeedsV = calcNeedsV
				assumedNeedsH = calcNeedsH
			EndIf
		Wend
		
		' Si pas convergé après maxIterations, forcer un état stable
		If Not converged
			' État le plus conservateur : afficher les deux scrollbars
			assumedNeedsV = True
			assumedNeedsH = True
			
			Local contentHeight:Int = rect.h - padding * 2 - scrollbarWidth
			visibleLines = contentHeight / lineHeight
			If visibleLines < 1 Then visibleLines = 1
		EndIf
		
		' Mise à jour finale de maxScrollX avec les valeurs cohérentes
		Local finalContentWidth:Int = rect.w - padding * 2
		If showLineNumbers Then finalContentWidth :- lineNumberWidth
		If NeedsVScrollbar() Then finalContentWidth :- scrollbarWidth
		maxScrollX = Max(0, maxLineWidth - finalContentWidth + charWidth * 2)
		
		' Reclamp final de scrollY et scrollX pour cohérence
		Local finalMaxScrollY:Int = Max(0, lines.Count() - visibleLines)
		scrollY = Max(0, Min(scrollY, finalMaxScrollY))
		scrollX = Max(0, Min(scrollX, maxScrollX))
	End Method

' =============================================================================
'           Méthode OnParentResize() à ajouter à TTextArea
' =============================================================================
' Cette méthode devrait être ajoutée pour gérer correctement le redimensionnement

Method OnParentResize(deltaW:Int, deltaH:Int)
    ' Appeler la méthode parente pour gérer les anchors
    Super.OnParentResize(deltaW, deltaH)
    
    ' Recalculer les métriques après redimensionnement
    UpdateMetrics()
    
    ' S'assurer que le curseur reste visible
    EnsureCursorVisible()
End Method
    Method UpdateMaxLineWidth()
        maxLineWidth = 0

        For Local line:String = EachIn lines
            Local w:Int = TWidget.GuiTextWidth(line)
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
        Local line:String = GetLine(cursorLine)
        Local cursorX:Int = TWidget.GuiTextWidth(line[..cursorCol])
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
                ClipboardSetText(Gui_Clipboard, GetSelectedText())  ' ← corrigé, ou utilise ta variable globale si différente
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
                Local clip:String = ClipboardText(Gui_Clipboard)  ' ← corrigé
                If clip.Length > 0
                    InsertText(clip)
                EndIf
            EndIf
            Return
        EndIf
        
        Local CurrentTime:Int = MilliSecs()
        
        ' Arrow keys with KEY REPEAT support
        If KeyDown(KEY_UP)
            If KeyHit(KEY_UP) Or CheckKeyRepeat(KEY_UP, CurrentTime)
                If Not shift Then ClearSelection()
                If cursorLine > 0
                    If shift Then StartSelection()
                    cursorLine :- 1
                    cursorCol = Min(cursorCol, GetLine(cursorLine).Length)
                    If shift Then UpdateSelection()
                EndIf
                EnsureCursorVisible()
                ResetCursorBlink()
            EndIf
            Return
        EndIf
        
        If KeyDown(KEY_DOWN)
            If KeyHit(KEY_DOWN) Or CheckKeyRepeat(KEY_DOWN, CurrentTime)
                If Not shift Then ClearSelection()
                If cursorLine < lines.Count() - 1
                    If shift Then StartSelection()
                    cursorLine :+ 1
                    cursorCol = Min(cursorCol, GetLine(cursorLine).Length)
                    If shift Then UpdateSelection()
                EndIf
                EnsureCursorVisible()
                ResetCursorBlink()
            EndIf
            Return
        EndIf
        
        If KeyDown(KEY_LEFT)
            If KeyHit(KEY_LEFT) Or CheckKeyRepeat(KEY_LEFT, CurrentTime)
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
            EndIf
            Return
        EndIf
        
        If KeyDown(KEY_RIGHT)
            If KeyHit(KEY_RIGHT) Or CheckKeyRepeat(KEY_RIGHT, CurrentTime)
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
            EndIf
            Return
        EndIf
        
        ' Reset key repeat if no navigation key is held
        If Not KeyDown(KEY_LEFT) And Not KeyDown(KEY_RIGHT) And Not KeyDown(KEY_UP) And Not KeyDown(KEY_DOWN) And Not KeyDown(KEY_BACKSPACE) And Not KeyDown(KEY_DELETE) And Not KeyDown(KEY_HOME) And Not KeyDown(KEY_END) And Not KeyDown(KEY_PAGEUP) And Not KeyDown(KEY_PAGEDOWN)
            ResetKeyRepeat()
        EndIf
        
        ' Home/End with repeat
        If KeyDown(KEY_HOME)
            If KeyHit(KEY_HOME) Or CheckKeyRepeat(KEY_HOME, CurrentTime)
                If shift Then StartSelection() Else ClearSelection()

                If ctrl
                    cursorLine = 0
                EndIf

                cursorCol = 0

                If shift Then UpdateSelection()

                EnsureCursorVisible()
                ResetCursorBlink()
            EndIf
            Return
        EndIf
        
        If KeyDown(KEY_END)
            If KeyHit(KEY_END) Or CheckKeyRepeat(KEY_END, CurrentTime)
                If shift Then StartSelection() Else ClearSelection()

                If ctrl
                    cursorLine = lines.Count() - 1
                EndIf

                cursorCol = GetLine(cursorLine).Length
                If shift Then UpdateSelection()

                EnsureCursorVisible()
                ResetCursorBlink()
            EndIf
            Return
        EndIf
        
        ' Page Up/Down with repeat
        If KeyDown(KEY_PAGEUP)
            If KeyHit(KEY_PAGEUP) Or CheckKeyRepeat(KEY_PAGEUP, CurrentTime)
                If shift Then StartSelection() Else ClearSelection()

                cursorLine = Max(0, cursorLine - visibleLines)
                cursorCol = Min(cursorCol, GetLine(cursorLine).Length)

                If shift Then UpdateSelection()
                EnsureCursorVisible()
                ResetCursorBlink()
            EndIf
            Return
        EndIf
        
        If KeyDown(KEY_PAGEDOWN)
            If KeyHit(KEY_PAGEDOWN) Or CheckKeyRepeat(KEY_PAGEDOWN, CurrentTime)
                If shift Then StartSelection() Else ClearSelection()
                cursorLine = Min(lines.Count() - 1, cursorLine + visibleLines)
                cursorCol = Min(cursorCol, GetLine(cursorLine).Length)
                If shift Then UpdateSelection()
            EndIf
            EnsureCursorVisible()
            ResetCursorBlink()
            Return
        EndIf
        
        ' Backspace with repeat support
        If KeyDown(KEY_BACKSPACE) And Not isReadOnly
            If KeyHit(KEY_BACKSPACE) Or CheckKeyRepeat(KEY_BACKSPACE, CurrentTime)
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
            EndIf
            Return
        EndIf
        
        ' Delete with repeat support
        If KeyDown(KEY_DELETE) And Not isReadOnly
            If KeyHit(KEY_DELETE) Or CheckKeyRepeat(KEY_DELETE, CurrentTime)
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
            EndIf
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
        Local contentX:Int = padding
        If showLineNumbers Then contentX :+ lineNumberWidth
        
        Local relY:Int = my - padding
        Local clickLine:Int = scrollY + relY / lineHeight
        clickLine = Max(0, Min(clickLine, lines.Count() - 1))
        
        Local relX:Int = mx - contentX + scrollX
        Local line:String = GetLine(clickLine)
        Local clickCol:Int = 0
        
        For Local i:Int = 0 To line.Length
            Local w:Int = TWidget.GuiTextWidth(line[..i])
            If w >= relX
                If i > 0
                    Local prevW:Int = TWidget.GuiTextWidth(line[..i-1])
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
            TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, 5, bgR + 10, bgG + 10, bgB + 10)
        Else
            TWidget.GuiDrawRect(ax, ay, rect.w, rect.h, 5, bgR, bgG, bgB)
        EndIf
        
        Local contentX:Int = ax + padding
        Local contentY:Int = ay + padding
        Local contentW:Int = GetContentWidth()
        Local contentH:Int = GetContentHeight()
        
		' Line number rectangle
        If showLineNumbers
            TWidget.GuiDrawRect(ax+2, ay+2, lineNumberWidth-4, rect.h-4, 1, lineNumBgR, lineNumBgG, lineNumBgB)
            contentX :+ lineNumberWidth
        EndIf
        
        TWidget.GuiSetViewport(contentX, contentY, contentW, contentH)
 
        Local y:Int = contentY
        For Local i:Int = scrollY Until Min(scrollY + visibleLines + 1, lines.Count())
            Local line:String = GetLine(i)
            Local lineY:Int = y
            
            If HasSelection()
                DrawLineSelection(i, contentX, lineY, line)
            EndIf

			TWidget.GuiDrawText(contentX - scrollX, lineY, String(line),TEXT_STYLE_SHADOW,textR, textG, textB)

            If focused And cursorVisible And i = cursorLine
                Local cursorDrawX:Int = contentX - scrollX + TWidget.GuiTextWidth(line[..cursorCol])
				TWidget.GuiDrawLine(cursorDrawX, lineY, cursorDrawX, lineY + lineHeight - 2, 1, COLOR_TEXTINPUT_CURSOR_R, COLOR_TEXTINPUT_CURSOR_G, COLOR_TEXTINPUT_CURSOR_B)
            EndIf
            
            y :+ lineHeight
        Next


        
        TWidget.GuiSetViewport(0, 0, GUI_GRAPHICSWIDTH, GUI_GRAPHICSHEIGHT)
        
        If showLineNumbers
            TWidget.GuiSetViewport(ax + 2, contentY, lineNumberWidth - 4, contentH)
            Local y2:Int = contentY

            For Local i:Int = scrollY Until Min(scrollY + visibleLines + 1, lines.Count())
                Local numStr:String = String(i + 1)
				TWidget.GuiDrawText(ax + lineNumberWidth - 6 - TWidget.GuiTextWidth(numStr), y2, String(numStr),TEXT_STYLE_SHADOW, lineNumR, lineNumG, lineNumB)
				
                y2 :+ lineHeight
            Next

            TWidget.GuiSetViewport(0, 0,GUI_GRAPHICSWIDTH, GUI_GRAPHICSHEIGHT)
        EndIf
        
		' Draw fake scrollbar V
        If NeedsVScrollbar()
            Local bx:Int, by:Int, bw:Int, bh:Int
            GetVScrollbarRect(bx, by, bw, bh)

			TWidget.GuiDrawRect(ax + bx - 2, ay + by + 2 , bw , bh - 4, 1, scrollBgR, scrollBgG, scrollBgB)

            Local tx:Int, ty:Int, tw:Int, th:Int
            GetVScrollThumbRect(tx, ty, tw, th)
            
            If draggingVScroll

				TWidget.GuiDrawRect(ax + tx - 3, ay + ty, tw + 3 , th, 1, scrollThumbDragR, scrollThumbDragG, scrollThumbDragB)
				
            ElseIf hoverVScroll
				TWidget.GuiDrawRect(ax + tx - 3 , ay + ty, tw + 3 , th, 1, scrollThumbDragR, scrollThumbDragG, scrollThumbDragB)
				
            Else
				TWidget.GuiDrawRect(ax + tx - 3 , ay + ty, tw + 3 , th, 1, scrollThumbDragR, scrollThumbDragG, scrollThumbDragB)
            EndIf
        EndIf
        
		' Draw fake scrollbar H
        If NeedsHScrollbar()
            Local bx:Int, by:Int, bw:Int, bh:Int
            GetHScrollbarRect(bx, by, bw, bh)

			TWidget.GuiDrawRect(ax + bx, ay + by, bw, bh, 1, scrollBgR, scrollBgG, scrollBgB)
            
            Local tx:Int, ty:Int, tw:Int, th:Int
            GetHScrollThumbRect(tx, ty, tw, th)
            
            If draggingHScroll
				TWidget.GuiDrawRect(ax + tx, ay + ty, tw, th, 1, scrollThumbDragR, scrollThumbDragG, scrollThumbDragB)
            ElseIf hoverHScroll
				TWidget.GuiDrawRect(ax + tx, ay + ty, tw, th, 1, scrollThumbHoverR, scrollThumbHoverG, scrollThumbHoverB)
            Else
				TWidget.GuiDrawRect(ax + tx, ay + ty, tw, th, 1, scrollThumbR, scrollThumbG, scrollThumbB)
            EndIf

        EndIf
		
		' Little rectangle at bottom right
        If NeedsVScrollbar() And NeedsHScrollbar()
			TWidget.GuiDrawRect(ax + rect.w - scrollbarWidth, ay + rect.h - scrollbarWidth, scrollbarWidth, scrollbarWidth, 1, scrollBgR, scrollBgG, scrollBgB)
        EndIf

    End Method
    
    Method DrawLineSelection(lineIndex:Int, contentX:Int, lineY:Int, lineText:String)
        Local startLine:Int, startCol:Int, endLine:Int, endCol:Int
        GetNormalizedSelection(startLine, startCol, endLine, endCol)
        
        If lineIndex < startLine Or lineIndex > endLine Then Return
        
        Local selStartX:Int, selEndX:Int
        
        If lineIndex = startLine And lineIndex = endLine
            selStartX = contentX - scrollX + TWidget.GuiTextWidth(lineText[..startCol])
            selEndX = contentX - scrollX + TWidget.GuiTextWidth(lineText[..endCol])
        ElseIf lineIndex = startLine
            selStartX = contentX - scrollX + TWidget.GuiTextWidth(lineText[..startCol])
            selEndX = contentX - scrollX + TWidget.GuiTextWidth(lineText) + charWidth
        ElseIf lineIndex = endLine
            selStartX = contentX - scrollX
            selEndX = contentX - scrollX + TWidget.GuiTextWidth(lineText[..endCol])
        Else
            selStartX = contentX - scrollX
            selEndX = contentX - scrollX + TWidget.GuiTextWidth(lineText) + charWidth
        EndIf

		TWidget.GuiDrawRect(selStartX, lineY, selEndX - selStartX, lineHeight, 1, COLOR_TEXTINPUT_SELECTION_R, COLOR_TEXTINPUT_SELECTION_G, COLOR_TEXTINPUT_SELECTION_B)
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
        If elapsed < TEXTAREA_KEY_REPEAT_DELAY
            Return False  ' Still in initial delay
        EndIf
        
        ' We're in repeat mode - check if enough time has passed since last repeat
        Local timeSinceLastRepeat:Int = CurrentTime - keyRepeatLastTime
        If timeSinceLastRepeat >= TEXTAREA_KEY_REPEAT_INTERVAL
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
End Type