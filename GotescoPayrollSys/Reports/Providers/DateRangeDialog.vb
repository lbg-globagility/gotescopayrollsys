Public Class DateRangeDialog

    Private Sub Button1_Click(sender As Object, e As EventArgs) Handles Button1.Click
        DialogResult = Windows.Forms.DialogResult.OK
    End Sub

    Private Sub Button2_Click(sender As Object, e As EventArgs) Handles Button2.Click
        DialogResult = Windows.Forms.DialogResult.Cancel
    End Sub

    Private _DateFrom As Date

    Public ReadOnly Property DateFrom() As Date

        Get
            Return _DateFrom
        End Get

    End Property

    Private _DateTo As Date

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

End Class