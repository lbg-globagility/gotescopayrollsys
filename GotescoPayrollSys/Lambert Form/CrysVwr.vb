Public Class CrysVwr

    Private Sub CrysVwr_FormClosed(sender As Object, e As FormClosedEventArgs) Handles Me.FormClosed
        If CrystalReportViewer1.ReportSource IsNot Nothing Then
            CrystalReportViewer1.ReportSource.Dispose()
        End If
    End Sub

    Private Sub CrysVwr_Load(sender As Object, e As EventArgs) Handles MyBase.Load

    End Sub

    Private Sub CrysVwr_KeyDown(sender As Object, e As KeyEventArgs) Handles Me.KeyDown, CrystalReportViewer1.KeyDown
        If e.Control AndAlso e.KeyCode = Keys.W Then
            Me.Close()
        ElseIf e.Control AndAlso e.KeyCode = Keys.P Then
            CrystalReportViewer1.PrintReport()

        End If

    End Sub
    Private Sub CrysVwr_FormClosing(sender As Object, e As FormClosingEventArgs) Handles Me.FormClosing
        Dim result = MessageBox.Show("Do you want to Close " & Me.Text & " ?", "", MessageBoxButtons.YesNo, MessageBoxIcon.Exclamation)
        If result = DialogResult.No Then
            e.Cancel = True
        ElseIf result = DialogResult.Yes Then
            e.Cancel = False
            CrystalReportViewer1.ReportSource.Dispose()

        End If

    End Sub

End Class