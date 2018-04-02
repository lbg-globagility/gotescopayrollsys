Imports System.Drawing
Imports System.Text
Imports System.Windows.Forms

Public Class CustomBalloonToolTip
    Inherits ToolTip

    Private ui_caller As Control

    Sub New(objui As Control, prompt_title As String)
        ui_caller = objui

        MyBase.IsBalloon = True
        MyBase.OwnerDraw = True
        MyBase.ToolTipTitle = prompt_title
    End Sub

    Sub ShowBallon(prompt_caption As String, Optional _duration As Integer = 3000)
        MyBase.ToolTipIcon = ToolTipIcon.None
        MyBase.UseAnimation = True

        Dim g As Graphics = ui_caller.CreateGraphics

        Dim _width = Convert.ToInt32(g.MeasureString(ui_caller.Text, ui_caller.Font).Width)
        g.Dispose()

        MyBase.Show(String.Empty, ui_caller, 0)
        MyBase.Show(prompt_caption,
                    ui_caller,
                    _width,
                    ui_caller.Height - 3,
                    _duration)

    End Sub

    Sub ShowInfoBallon(prompt_caption As String, Optional _duration As Integer = 3000)
        MyBase.ToolTipIcon = ToolTipIcon.Info
        MyBase.UseAnimation = True

        Dim g As Graphics = ui_caller.CreateGraphics

        Dim _width = Convert.ToInt32(g.MeasureString(ui_caller.Text, ui_caller.Font).Width)
        g.Dispose()

        MyBase.Show(String.Empty, ui_caller, 0)
        MyBase.Show(prompt_caption,
                    ui_caller,
                    _width,
                    ui_caller.Height - 3,
                    _duration)

    End Sub

    Sub ShowErrorBallon(prompt_caption As String, Optional _duration As Integer = 3000)
        MyBase.ToolTipIcon = ToolTipIcon.Error
        MyBase.UseAnimation = True

        Dim g As Graphics = ui_caller.CreateGraphics

        Dim _width = Convert.ToInt32(g.MeasureString(ui_caller.Text, ui_caller.Font).Width)
        g.Dispose()

        MyBase.Show(String.Empty, ui_caller, 0)
        MyBase.Show(prompt_caption,
                    ui_caller,
                    _width,
                    ui_caller.Height - 3,
                    _duration)

    End Sub

    Sub ShowWarningBallon(prompt_caption As String, Optional _duration As Integer = 3000)
        MyBase.ToolTipIcon = ToolTipIcon.Warning
        MyBase.UseAnimation = True

        Dim g As Graphics = ui_caller.CreateGraphics

        Dim _width = Convert.ToInt32(g.MeasureString(ui_caller.Text, ui_caller.Font).Width)
        g.Dispose()

        MyBase.Show(String.Empty, ui_caller, 0)
        MyBase.Show(prompt_caption,
                    ui_caller,
                    _width,
                    ui_caller.Height - 3,
                    _duration)

    End Sub

End Class
