' =============================================================================
'                              MESSAGE BOX
' =============================================================================
' Modal dialog boxes for user prompts (OK, Yes/No, Yes/No/Cancel, etc.)
' Uses callback function to return result
' =============================================================================

' -----------------------------------------------------------------------------
' MessageBox Types (button configurations)
' -----------------------------------------------------------------------------
Const MSGBOX_OK:Int = 0
Const MSGBOX_OK_CANCEL:Int = 1
Const MSGBOX_YES_NO:Int = 2
Const MSGBOX_YES_NO_CANCEL:Int = 3

' -----------------------------------------------------------------------------
' MessageBox Results
' -----------------------------------------------------------------------------
Const MSGBOX_RESULT_NONE:Int = -1
Const MSGBOX_RESULT_OK:Int = 0
Const MSGBOX_RESULT_CANCEL:Int = 1
Const MSGBOX_RESULT_YES:Int = 2
Const MSGBOX_RESULT_NO:Int = 3

' -----------------------------------------------------------------------------
' Global MessageBox State
' -----------------------------------------------------------------------------
Global g_ActiveMessageBox:TMessageBox = Null

' -----------------------------------------------------------------------------
' MessageBox Class
' -----------------------------------------------------------------------------
Type TMessageBox
    Field window:TWindow
    Field msgType:Int
    Field result:Int = MSGBOX_RESULT_NONE
    Field callback:Int(result:Int)  ' Callback function pointer
    
    ' Buttons
    Field btnOK:TButton
    Field btnCancel:TButton
    Field btnYes:TButton
    Field btnNo:TButton
    
    ' Labels
    Field lblTitle:TLabel
    Field lblMessage:TLabel
    
    ' =========================================================================
    '                         STATIC SHOW METHODS
    ' =========================================================================
    
    ' Show a message box with callback
    ' Parameters:
    '   title    - Window title
    '   message  - Message text
    '   msgType  - MSGBOX_OK, MSGBOX_OK_CANCEL, MSGBOX_YES_NO, MSGBOX_YES_NO_CANCEL
    '   callback - Function to call with result (can be Null)
    ' Returns: TMessageBox instance
    Function Show:TMessageBox(title:String, message:String, msgType:Int = MSGBOX_OK, callback:Int(result:Int) = Null)
        ' Close any existing message box
        If g_ActiveMessageBox Then g_ActiveMessageBox.Close()
        
        Local mb:TMessageBox = New TMessageBox
        mb.msgType = msgType
        mb.callback = callback
        
        ' Calculate window size based on message length
        Local msgWidth:Int = TextWidth(message) + 60
        Local titleWidth:Int = TextWidth(title) + 100
        Local winWidth:Int = Max(Max(msgWidth, titleWidth), 300)
        winWidth = Min(winWidth, 500)  ' Cap max width
        
        Local winHeight:Int = 120
        
        ' Create modal window (centered on screen)
        Local winX:Int = (GraphicsWidth() - winWidth) / 2
        Local winY:Int = (GraphicsHeight() - winHeight) / 2
        
        mb.window = New TWindow(winX, winY, winWidth, winHeight, title, False, False, False)
        mb.window.SetModalState(True)
        
        ' Add message label (centered)
        mb.lblMessage = New TLabel(10, 20, winWidth - 20, 30, message, LABEL_ALIGN_CENTER)
        mb.lblMessage.SetColor(240, 240, 255)
        mb.window.AddChild(mb.lblMessage)
        
        ' Create buttons based on type
        Local btnWidth:Int = 80
        Local btnHeight:Int = 32
        Local btnY:Int = 70
        Local btnSpacing:Int = 10
        
        Select msgType
            Case MSGBOX_OK
                ' Single OK button (centered)
                Local btnX:Int = (winWidth - btnWidth) / 2
                mb.btnOK = New TButton(btnX, btnY, btnWidth, btnHeight, "OK")
                mb.window.AddChild(mb.btnOK)
                
            Case MSGBOX_OK_CANCEL
                ' OK and Cancel buttons
                Local totalWidth:Int = btnWidth * 2 + btnSpacing
                Local startX:Int = (winWidth - totalWidth) / 2
                mb.btnOK = New TButton(startX, btnY, btnWidth, btnHeight, "OK")
                mb.btnCancel = New TButton(startX + btnWidth + btnSpacing, btnY, btnWidth, btnHeight, "Cancel")
                mb.window.AddChild(mb.btnOK)
                mb.window.AddChild(mb.btnCancel)
                
            Case MSGBOX_YES_NO
                ' Yes and No buttons
                Local totalWidth:Int = btnWidth * 2 + btnSpacing
                Local startX:Int = (winWidth - totalWidth) / 2
                mb.btnYes = New TButton(startX, btnY, btnWidth, btnHeight, "Yes")
                mb.btnNo = New TButton(startX + btnWidth + btnSpacing, btnY, btnWidth, btnHeight, "No")
                mb.window.AddChild(mb.btnYes)
                mb.window.AddChild(mb.btnNo)
                
            Case MSGBOX_YES_NO_CANCEL
                ' Yes, No and Cancel buttons
                Local totalWidth:Int = btnWidth * 3 + btnSpacing * 2
                Local startX:Int = (winWidth - totalWidth) / 2
                mb.btnYes = New TButton(startX, btnY, btnWidth, btnHeight, "Yes")
                mb.btnNo = New TButton(startX + btnWidth + btnSpacing, btnY, btnWidth, btnHeight, "No")
                mb.btnCancel = New TButton(startX + (btnWidth + btnSpacing) * 2, btnY, btnWidth, btnHeight, "Cancel")
                mb.window.AddChild(mb.btnYes)
                mb.window.AddChild(mb.btnNo)
                mb.window.AddChild(mb.btnCancel)
        End Select
        
        ' Add to root container
        If Gui_Root Then Gui_Root.AddChild(mb.window)
        
        g_ActiveMessageBox = mb
        Return mb
    End Function
    
    ' Convenience methods for common dialogs
    Function ShowOK:TMessageBox(title:String, message:String, callback:Int(result:Int) = Null)
        Return Show(title, message, MSGBOX_OK, callback)
    End Function
    
    Function ShowOKCancel:TMessageBox(title:String, message:String, callback:Int(result:Int) = Null)
        Return Show(title, message, MSGBOX_OK_CANCEL, callback)
    End Function
    
    Function ShowYesNo:TMessageBox(title:String, message:String, callback:Int(result:Int) = Null)
        Return Show(title, message, MSGBOX_YES_NO, callback)
    End Function
    
    Function ShowYesNoCancel:TMessageBox(title:String, message:String, callback:Int(result:Int) = Null)
        Return Show(title, message, MSGBOX_YES_NO_CANCEL, callback)
    End Function
    
    ' =========================================================================
    '                         UPDATE (call each frame)
    ' =========================================================================
    ' Check button clicks and trigger callback
    ' This is called automatically by GuiProcessMessageBox()
    Method Update:Int()
        If result <> MSGBOX_RESULT_NONE Then Return False  ' Already got result
        
        ' Check button clicks
        If btnOK And btnOK.WasClicked()
            result = MSGBOX_RESULT_OK
            TriggerCallback()
            Return True
        EndIf
        
        If btnCancel And btnCancel.WasClicked()
            result = MSGBOX_RESULT_CANCEL
            TriggerCallback()
            Return True
        EndIf
        
        If btnYes And btnYes.WasClicked()
            result = MSGBOX_RESULT_YES
            TriggerCallback()
            Return True
        EndIf
        
        If btnNo And btnNo.WasClicked()
            result = MSGBOX_RESULT_NO
            TriggerCallback()
            Return True
        EndIf
        
        Return False
    End Method
    
    ' Trigger the callback and close
    Method TriggerCallback()
        If callback Then callback(result)
        Close()
    End Method
    
    ' =========================================================================
    '                         UTILITY METHODS
    ' =========================================================================
    
    ' Check if a result has been selected
    Method HasResult:Int()
        Return result <> MSGBOX_RESULT_NONE
    End Method
    
    ' Get the result
    Method GetResult:Int()
        Return result
    End Method
    
    ' Close and cleanup the message box
    Method Close()
        If window
            window.Close()
            window = Null
        EndIf
        
        If g_ActiveMessageBox = Self
            g_ActiveMessageBox = Null
        EndIf
        
        btnOK = Null
        btnCancel = Null
        btnYes = Null
        btnNo = Null
    End Method
    
    ' =========================================================================
    '                    STATIC UPDATE FUNCTION
    ' =========================================================================
    ' Call this in your main loop OR it's called automatically by GuiRefresh
    Function UpdateActiveMessageBox()
        If g_ActiveMessageBox Then g_ActiveMessageBox.Update()
    End Function
    
    ' Check if a message box is currently active
    Function IsActive:Int()
        Return g_ActiveMessageBox <> Null
    End Function
    
    ' Get the active message box
    Function GetActive:TMessageBox()
        Return g_ActiveMessageBox
    End Function
End Type
