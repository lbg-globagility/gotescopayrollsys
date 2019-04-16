
Public Class TrialForm

    Private Sub TextBox1_OnUserStopTyping(sender As Object, e As EventArgs) Handles TextBox1.OnUserStopTyping

    End Sub

    Private Sub TextBox1_TextChanged(sender As Object, e As EventArgs) Handles TextBox1.TextChanged

    End Sub

    Private Sub Timer1_Tick(sender As Object, e As EventArgs) Handles Timer1.Tick

    End Sub

    Private Sub Button1_Click(sender As Object, e As EventArgs) Handles Button1.Click

        Static once As Integer = 0

        Dim ii = 1

        For Each drow As DataRow In dtImage.Rows

            If once < ii Then

                once = ii

                Dim imgCon As New ImageConverter()

                'Dim alala = DirectCast(imgCon.ConvertTo(drow(0), GetType(Byte())), Byte())

                PictureBox1.Image = ConvByteToImage(DirectCast(drow(0), Byte()))

                ii += 1

                Exit For

            End If

            ii += 1

        Next

        If dtImage.Rows.Count = once Then
            once = 0
        End If

    End Sub

    Dim dtImage As New DataTable

    Protected Overrides Sub OnLoad(e As EventArgs)

        dtImage = New SQLQueryToDatatable("SELECT AttachedFile,RowID FROM employeeattachments;").ResultTable

        MyBase.OnLoad(e)

    End Sub

    Private Sub Button2_Click(sender As Object, e As EventArgs) Handles Button2.Click
        Static employeeleaveRowID As Integer = -1
        Try
            Dim browsefile As OpenFileDialog = New OpenFileDialog()
            browsefile.Filter = "JPEG(*.jpg)|*.jpg" '& _
            '"PNG(*.PNG)|*.png|" & _
            '"Bitmap(*.BMP)|*.bmp"
            If browsefile.ShowDialog() = Windows.Forms.DialogResult.OK Then

                PictureBox1.Image = Image.FromFile(browsefile.FileName)

                'For Each drow As DataRow In employeepix.Rows
                '    If drow("RowID").ToString = dgvEmp.CurrentRow.Cells("RowID").Value Then
                '        drow("Image") = If(empPic = Nothing, _
                '                           Nothing, _
                '                           convertFileToByte(empPic))

                '        If empPic = Nothing Then
                '        Else
                '            makefileGetPath(drow("Image"))
                '        End If

                '        Exit For

                '    End If
                'Next

            End If

        Catch ex As Exception
            MsgBox(getErrExcptn(ex, Me.Name), , "Unexpected Message")
        Finally
            'dgvempleave_SelectionChanged(sender, e)
            'AddHandler dgvempleave.SelectionChanged, AddressOf dgvempleave_SelectionChanged
        End Try
    End Sub

    Private Sub PictureBox1_AfterImageChanged(sender As Object, e As EventArgs) Handles PictureBox1.AfterImageChanged
        Dim ii = PictureBox1.Tag
    End Sub

    Private Sub NumericUpDown1_ValueChanged(sender As Object, e As EventArgs) Handles NumericUpDown1.ValueChanged

        Panel1.BackColor = Color.FromArgb(255, NumericUpDown1.Value, 0)

    End Sub

    Private Sub CustomDatePicker1_ValueChanged(sender As Object, e As EventArgs) Handles CustomDatePicker1.ValueChanged

        Try

            Label1.Text = CustomDatePicker1.Tag

        Catch ex As Exception

            Label1.Text = "Nothing"

        End Try

    End Sub

    Private Sub BackgroundWorker1_DoWork(sender As Object, e As System.ComponentModel.DoWorkEventArgs) Handles BackgroundWorker1.DoWork

    End Sub

    Private Sub BackgroundWorker1_ProgressChanged(sender As Object, e As System.ComponentModel.ProgressChangedEventArgs) Handles BackgroundWorker1.ProgressChanged

    End Sub

    Private Sub BackgroundWorker1_RunWorkerCompleted(sender As Object, e As System.ComponentModel.RunWorkerCompletedEventArgs) Handles BackgroundWorker1.RunWorkerCompleted

    End Sub

    Private Sub Timer2_Tick(sender As Object, e As EventArgs) Handles Timer2.Tick

    End Sub

    Private Sub ErrorProvider1_RightToLeftChanged(sender As Object, e As EventArgs) Handles ErrorProvider1.RightToLeftChanged

    End Sub

    Private Sub ToolTip1_Popup(sender As Object, e As PopupEventArgs) Handles ToolTip1.Popup

    End Sub

    Private Sub TrialForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load

    End Sub

    Private Sub Button3_Click(sender As Object, e As EventArgs) Handles Button3.Click
        'Try

        '    Dim ports As String() = IO.Ports.SerialPort.GetPortNames()

        '    For Each strval In ports
        '        MsgBox(strval)
        '    Next
        '    Dim SMSEngine = New SMSCOMMS("COM1")
        '    SMSEngine.Open()
        '    SMSEngine.SendSMS("09325491144", "SMS Testing")
        '    SMSEngine.Close()

        'Catch ex As Exception
        '    MsgBox(getErrExcptn(ex, Me.Name))
        'End Try

        DataGridViewMySQLTable1.AllowPagination = Not DataGridViewMySQLTable1.AllowPagination

    End Sub

    Private Sub DataGridViewX2_CellContentClick(sender As Object, e As DataGridViewCellEventArgs) Handles DataGridViewX2.CellContentClick

    End Sub

    Private Sub DataGridViewX2_SelectionChanged(sender As Object, e As EventArgs) Handles DataGridViewX2.SelectionChanged

    End Sub

    Private Sub Button4_Click(sender As Object, e As EventArgs) Handles Button4.Click

        Dim n_ShiftTemplater As _
            New ShiftTemplater

        If n_ShiftTemplater.ShowDialog = Windows.Forms.DialogResult.OK Then

        End If

    End Sub

End Class