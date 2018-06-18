Public Class DateRangeDialog

    Private Sub Button1_Click(sender As Object, e As EventArgs) Handles btnOK.Click
        DialogResult = Windows.Forms.DialogResult.OK
    End Sub

    Private Sub Button2_Click(sender As Object, e As EventArgs) Handles btnCancel.Click
        DialogResult = Windows.Forms.DialogResult.Cancel
    End Sub

    Private _DateFrom As Date = Today

    Public ReadOnly Property DateFrom() As Date

        Get
            Return _DateFrom
        End Get

    End Property

    Private _DateTo As Date = Today

    Public ReadOnly Property DateTo() As Date

        Get
            Return _DateTo
        End Get

    End Property

    Private Sub DateTimePicker1_ValueChanged(sender As Object, e As EventArgs) Handles DateTimePicker1.ValueChanged
        _DateFrom = DateTimePicker1.Value
    End Sub

    Private Sub DateTimePicker2_ValueChanged(sender As Object, e As EventArgs) Handles DateTimePicker2.ValueChanged
        _DateTo = DateTimePicker2.Value
    End Sub

    Private Sub DateTimePicker1_KeyPress(sender As Object, e As KeyPressEventArgs) Handles _
        DateTimePicker1.KeyPress,
        DateTimePicker2.KeyPress

        Dim enterkey = Asc(e.KeyChar)

        If enterkey = 13 Then
            btnOK.Focus()
            Button1_Click(btnOK, New EventArgs)
        End If
    End Sub

End Class