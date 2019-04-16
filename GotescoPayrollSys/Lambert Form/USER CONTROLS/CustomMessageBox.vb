
Imports System.Text
Imports System.Runtime.InteropServices
Imports System.Security.Permissions

<Assembly: SecurityPermission(SecurityAction.RequestMinimum, UnmanagedCode:=True)> 

Namespace System.Windows.Forms
    Public Class CustomMessageBox
        Public Shared Function Show(text As String, uTimeout As UInteger) As DialogResult
            Setup("", uTimeout)
            Return MessageBox.Show(text)
        End Function

        Public Shared Function Show(text As String, caption As String, uTimeout As UInteger) As DialogResult
            Setup(caption, uTimeout)
            Return MessageBox.Show(text, caption)
        End Function

        Public Shared Function Show(text As String, caption As String, buttons As MessageBoxButtons, uTimeout As UInteger) As DialogResult
            Setup(caption, uTimeout)
            Return MessageBox.Show(text, caption, buttons)
        End Function

        Public Shared Function Show(text As String, caption As String, buttons As MessageBoxButtons, icon As MessageBoxIcon, uTimeout As UInteger) As DialogResult
            Setup(caption, uTimeout)
            Return MessageBox.Show(text, caption, buttons, icon)
        End Function

        Public Shared Function Show(text As String, caption As String, buttons As MessageBoxButtons, icon As MessageBoxIcon, defButton As MessageBoxDefaultButton, uTimeout As UInteger) As DialogResult
            Setup(caption, uTimeout)
            Return MessageBox.Show(text, caption, buttons, icon, defButton)
        End Function

        Public Shared Function Show(text As String, caption As String, buttons As MessageBoxButtons, icon As MessageBoxIcon, defButton As MessageBoxDefaultButton, options As MessageBoxOptions, _
            uTimeout As UInteger) As DialogResult
            Setup(caption, uTimeout)
            Return MessageBox.Show(text, caption, buttons, icon, defButton, options)
        End Function

        Public Shared Function Show(owner As IWin32Window, text As String, uTimeout As UInteger) As DialogResult
            Setup("", uTimeout)
            Return MessageBox.Show(owner, text)
        End Function

        Public Shared Function Show(owner As IWin32Window, text As String, caption As String, uTimeout As UInteger) As DialogResult
            Setup(caption, uTimeout)
            Return MessageBox.Show(owner, text, caption)
        End Function

        Public Shared Function Show(owner As IWin32Window, text As String, caption As String, buttons As MessageBoxButtons, uTimeout As UInteger) As DialogResult
            Setup(caption, uTimeout)
            Return MessageBox.Show(owner, text, caption, buttons)
        End Function

        Public Shared Function Show(owner As IWin32Window, text As String, caption As String, buttons As MessageBoxButtons, icon As MessageBoxIcon, uTimeout As UInteger) As DialogResult
            Setup(caption, uTimeout)
            Return MessageBox.Show(owner, text, caption, buttons, icon)
        End Function

        Public Shared Function Show(owner As IWin32Window, text As String, caption As String, buttons As MessageBoxButtons, icon As MessageBoxIcon, defButton As MessageBoxDefaultButton, _
            uTimeout As UInteger) As DialogResult
            Setup(caption, uTimeout)
            Return MessageBox.Show(owner, text, caption, buttons, icon, defButton)
        End Function

        Public Shared Function Show(owner As IWin32Window, text As String, caption As String, buttons As MessageBoxButtons, icon As MessageBoxIcon, defButton As MessageBoxDefaultButton, _
            options As MessageBoxOptions, uTimeout As UInteger) As DialogResult
            Setup(caption, uTimeout)
            Return MessageBox.Show(owner, text, caption, buttons, icon, defButton, _
                options)
        End Function

        Public Delegate Function HookProc(nCode As Integer, wParam As IntPtr, lParam As IntPtr) As IntPtr
        Public Delegate Sub TimerProc(hWnd As IntPtr, uMsg As UInteger, nIDEvent As UIntPtr, dwTime As UInteger)

        Public Const WH_CALLWNDPROCRET As Integer = 12
        Public Const WM_DESTROY As Integer = &H2
        Public Const WM_INITDIALOG As Integer = &H110
        Public Const WM_TIMER As Integer = &H113
        Public Const WM_USER As Integer = &H400
        Public Const DM_GETDEFID As Integer = WM_USER + 0

        <DllImport("User32.dll")> _
        Public Shared Function SetTimer(hWnd As IntPtr, nIDEvent As UIntPtr, uElapse As UInteger, lpTimerFunc As TimerProc) As UIntPtr
        End Function

        <DllImport("User32.dll")> _
        Public Shared Function SendMessage(hWnd As IntPtr, Msg As Integer, wParam As IntPtr, lParam As IntPtr) As IntPtr
        End Function

        <DllImport("user32.dll")> _
        Public Shared Function SetWindowsHookEx(idHook As Integer, lpfn As HookProc, hInstance As IntPtr, threadId As Integer) As IntPtr
        End Function

        <DllImport("user32.dll")> _
        Public Shared Function UnhookWindowsHookEx(idHook As IntPtr) As Integer
        End Function

        <DllImport("user32.dll")> _
        Public Shared Function CallNextHookEx(idHook As IntPtr, nCode As Integer, wParam As IntPtr, lParam As IntPtr) As IntPtr
        End Function

        <DllImport("user32.dll")> _
        Public Shared Function GetWindowTextLength(hWnd As IntPtr) As Integer
        End Function

        <DllImport("user32.dll")> _
        Public Shared Function GetWindowText(hWnd As IntPtr, text As StringBuilder, maxLength As Integer) As Integer
        End Function

        <DllImport("user32.dll")> _
        Public Shared Function EndDialog(hDlg As IntPtr, nResult As IntPtr) As Integer
        End Function

        <StructLayout(LayoutKind.Sequential)> _
        Public Structure CWPRETSTRUCT
            Public lResult As IntPtr
            Public lParam As IntPtr
            Public wParam As IntPtr
            Public message As UInteger
            Public hwnd As IntPtr
        End Structure

        Private Const TimerID As Object = 42
        Private Shared _hookProc As HookProc
        Private Shared hookTimer As TimerProc
        Private Shared hookTimeout As UInteger
        Private Shared hookCaption As String
        Private Shared hHook As IntPtr

        Shared Sub New()
            _hookProc = New HookProc(AddressOf MessageBoxHookProc)
            hookTimer = New TimerProc(AddressOf MessageBoxTimerProc)
            hookTimeout = 0
            hookCaption = Nothing
            hHook = IntPtr.Zero
        End Sub

        Private Shared Sub Setup(caption As String, uTimeout As UInteger)
            If hHook <> IntPtr.Zero Then
                Throw New NotSupportedException("multiple calls are not supported")
            End If

            hookTimeout = uTimeout
            hookCaption = If(caption IsNot Nothing, caption, "")
            hHook = SetWindowsHookEx(WH_CALLWNDPROCRET, _hookProc, IntPtr.Zero, AppDomain.GetCurrentThreadId())
        End Sub

        Private Shared Function MessageBoxHookProc(nCode As Integer, wParam As IntPtr, lParam As IntPtr) As IntPtr
            If nCode < 0 Then
                Return CallNextHookEx(hHook, nCode, wParam, lParam)
            End If

            Dim msg As CWPRETSTRUCT = CType(Marshal.PtrToStructure(lParam, GetType(CWPRETSTRUCT)), CWPRETSTRUCT)
            Dim hook As IntPtr = hHook

            If hookCaption IsNot Nothing AndAlso msg.message = WM_INITDIALOG Then
                Dim nLength As Integer = GetWindowTextLength(msg.hwnd)
                Dim text As New StringBuilder(nLength + 1)

                GetWindowText(msg.hwnd, text, text.Capacity)

                If hookCaption = text.ToString() Then
                    hookCaption = Nothing
                    SetTimer(msg.hwnd, DirectCast(TimerID, UIntPtr), hookTimeout, hookTimer)
                    UnhookWindowsHookEx(hHook)
                    hHook = IntPtr.Zero
                End If
            End If

            Return CallNextHookEx(hook, nCode, wParam, lParam)
        End Function

        Private Shared Sub MessageBoxTimerProc(hWnd As IntPtr, uMsg As UInteger, nIDEvent As UIntPtr, dwTime As UInteger)
            If nIDEvent = DirectCast(TimerID, UIntPtr) Then
                Dim dw As Short = CShort(SendMessage(hWnd, DM_GETDEFID, IntPtr.Zero, IntPtr.Zero))

                EndDialog(hWnd, DirectCast(dw, IntPtr))
            End If
        End Sub
    End Class
End Namespace