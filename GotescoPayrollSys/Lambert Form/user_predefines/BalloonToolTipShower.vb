Imports System.Threading

Public Class BalloonToolTipShower

    Private Timer1 As New System.Windows.Forms.Timer

    Dim min_duration As Integer = 3000

    Dim thisBalloon_ToolTip As New ToolTip

    Dim min_sec As Integer = 0

    Sub New(Balloon_ToolTip As ToolTip,
            ToolTipStringContent As String,
            ToolTipStringTitle As String,
            objct As System.Windows.Forms.IWin32Window,
            Optional pt_x As Integer = 3000,
            Optional pt_y As Integer = 3000,
            Optional duration As Integer = 3000)

        min_duration = duration

        Balloon_ToolTip = New ToolTip

        thisBalloon_ToolTip = Balloon_ToolTip

        With Timer1
            .Interval = 1000
            min_sec = min_duration / .Interval
            .Enabled = False
            .Stop()
        End With

        With Balloon_ToolTip
            .IsBalloon = True
            .ToolTipTitle = ToolTipStringTitle
            .ToolTipIcon = ToolTipIcon.Info
            .Show(ToolTipStringContent, objct, pt_x, pt_y, duration)

            With Timer1
                AddHandler .Tick, AddressOf Timer1_Tick
                .Enabled = True
                .Start()
            End With

        End With

        Dim plusduration = duration + 1

        'Thread.Sleep(plusduration)

        'Balloon_ToolTip.Dispose()

        'With Timer1
        '    .Interval = 1000
        '    min_sec = min_duration / .Interval
        '    AddHandler Timer1.Tick, AddressOf Timer1_Tick
        '    .Enabled = True
        '    .Start()
        'End With

    End Sub

    Private Sub Timer1_Tick(sender As Object, e As EventArgs)

        Static count As SByte = 1

        count += 1

        If count > min_sec Then

            thisBalloon_ToolTip.Dispose()

            count = 0

            With Timer1

                .Enabled = False

                .Stop()

            End With

        End If

    End Sub

End Class