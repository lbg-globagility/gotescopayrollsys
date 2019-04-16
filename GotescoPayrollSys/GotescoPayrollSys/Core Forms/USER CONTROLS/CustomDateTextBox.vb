Imports System.Threading


Public Class CustomDateTextBox

    Inherits CustomObject.TextBox

    Private Timer2 As New System.Windows.Forms.Timer

    Private tooltip As New System.Windows.Forms.ToolTip

    Dim balloon_x = Me.Width - 17

    Dim balloon_y = Me.Height - 93

    Sub New()

        CustomDateTextBox()

    End Sub

    Dim _ErrorTitle As String = "Invalid date value"

    Property ErrorTitle As String

        Get
            Return _ErrorTitle

        End Get

        Set(value As String)
            _ErrorTitle = value

        End Set

    End Property

    Dim _ErrorContent As String = "Input was unrecognized as date"

    Property ErrorContent As String

        Get
            Return _ErrorContent

        End Get

        Set(value As String)
            _ErrorContent = value

        End Set

    End Property

    Sub CustomDateTextBox()

        'Me.ErrorProvider1.ContainerControl = Me

        Me.tooltip.ToolTipIcon = System.Windows.Forms.ToolTipIcon.[Error]

        Me.tooltip.IsBalloon = True

        Me.tooltip.ToolTipTitle = ErrorTitle

        Me.Timer2.Enabled = True

        Me.Timer2.Interval = 60

        AddHandler MyBase.OnUserStopTyping, AddressOf MyBase_OnUserStopTyping

        AddHandler Timer2.Tick, AddressOf Timer2_Tick

    End Sub

    Dim catchvalue As Object = MyBase.Text

    Dim returnvalue As Object = Nothing

    Dim doneTyping As Boolean = False

    Private Sub MyBase_OnUserStopTyping(sender As Object, e As EventArgs)

        catchvalue = MyBase.Text.Trim

        doneTyping = True

    End Sub

    Private Sub StartTimer(agree As Boolean)

        If agree Then
            Timer2.Start()
        Else
            Timer2.Stop()
        End If
        
        Timer2.Enabled = agree

    End Sub

    Private Sub Timer2_Tick(sender As Object, e As EventArgs)

        If doneTyping _
            And MyBase.Text.Trim.Length > 0 Then

            StartTimer(False)

            doneTyping = False

            returnvalue = Nothing

            Try
                returnvalue = CDate(catchvalue).ToShortDateString

            Catch ex As Exception
                returnvalue = Nothing

            Finally

                If returnvalue = Nothing Then

                    tooltip.Show(_ErrorContent,
                                 Me,
                                 balloon_x,
                                 balloon_y,
                                 2980)

                Else

                    MyBase.Text = returnvalue

                    tooltip.Hide(Me)

                End If
                
                StartTimer(True)

            End Try

        End If

    End Sub

    Protected Overrides Sub Dispose(disposing As Boolean)

        tooltip.Active = False

        tooltip.Hide(Me)

        tooltip.Dispose()

        MyBase.Dispose(disposing)

    End Sub

    Protected Overrides Sub OnGotFocus(e As EventArgs)

        doneTyping = False

        StartTimer(True)

        MyBase.OnGotFocus(e)

    End Sub

    Protected Overrides Sub OnLeave(e As EventArgs)

        doneTyping = True

        StartTimer(False)

        MyBase.OnLeave(e)

    End Sub

End Class