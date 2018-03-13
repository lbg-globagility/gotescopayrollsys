Public Class TimeAttendForm

    Public listTimeAttendForm As New List(Of String)

    Sub ChangeForm(ByVal Formname As Form, Optional ViewName As String = Nothing)

        reloadViewPrivilege()

        Dim view_ID = VIEW_privilege(ViewName, org_rowid)

        Dim formuserprivilege = position_view_table.Select("ViewID = " & view_ID)

        If formuserprivilege.Count <> 0 Then

            For Each drow In formuserprivilege

                If drow("ReadOnly").ToString = "Y" Then

                    'ChangeForm(Formname)
                    'previousForm = Formname

                    Exit For
                Else

                    If drow("Creates").ToString = "Y" _
                        Or drow("Updates").ToString = "Y" _
                        Or drow("Deleting").ToString = "Y" Then

                        'ChangeForm(Formname)
                        'previousForm = Formname

                        Exit For
                    Else
                        Exit Sub
                    End If

                End If

            Next
        Else
            Exit Sub
        End If

        Try
            For Each pb As Form In PanelTimeAttend.Controls.OfType(Of Form)() 'KeyPreview'Enabled
                If Formname.Name = pb.Name Then : Continue For : Else : pb.KeyPreview = False : End If
            Next
            Application.DoEvents()
            Dim FName As String = Formname.Name
            Formname.KeyPreview = True 'KeyPreview'Enabled
            Formname.TopLevel = False
            If listTimeAttendForm.Contains(FName) Then
                Formname.Show()
                Formname.BringToFront()
                Formname.Focus()
            Else
                PanelTimeAttend.Controls.Add(Formname)
                listTimeAttendForm.Add(Formname.Name)
                Formname.Show()
                Formname.BringToFront()
                Formname.Focus()
                'Formname.Location = New Point((PanelTimeAttend.Width / 2) - (Formname.Width / 2), (PanelTimeAttend.Height / 2) - (Formname.Height / 2))
                'Formname.Anchor = AnchorStyles.Top And AnchorStyles.Bottom And AnchorStyles.Right And AnchorStyles.Left
                'Formname.WindowState = FormWindowState.Maximized
                Formname.Dock = DockStyle.Fill
            End If
        Catch ex As Exception
            MsgBox(getErrExcptn(ex, Me.Name))
        End Try
    End Sub

    Private Sub TimeEntToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles TimeEntToolStripMenuItem.Click
        'ChangeForm(AttendanceTimeEntryForm)
        'EmployeeShiftEntryForm.FormBorderStyle = Windows.Forms.FormBorderStyle.None
        ChangeForm(EmployeeShiftEntryForm, "Employee Shift")
        previousForm = EmployeeShiftEntryForm
    End Sub

    Private Sub ToolStripMenuItem1_Click(sender As Object, e As EventArgs) Handles ToolStripMenuItem1.Click
        ChangeForm(EmployeeShiftControls, "Employee Shift")
        previousForm = EmployeeShiftControls
    End Sub

    Sub TimeEntryLogsToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles TimeEntryLogsToolStripMenuItem.Click
        ChangeForm(EmpTimeDetail, "Employee Time Entry logs")
        previousForm = EmpTimeDetail
    End Sub

    Sub TimeEntryToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles TimeEntryToolStripMenuItem.Click

        ChangeForm(EmpTimeEntry, "Employee Time Entry")
        previousForm = EmpTimeEntry
        'EmpTimeEntry.TabControl1.SelectedIndex = 0
        'EmpTimeEntry.tbpemptimeent_Enter(sender, e)
        'RemoveHandler EmpTimeEntry.dgvEmployi.SelectionChanged, AddressOf EmpTimeEntry.dgvEmployi_SelectionChanged
        EmpTimeEntry.dgvEmployi_SelectionChanged(sender, e)

        AddHandler EmpTimeEntry.dgvEmployi.SelectionChanged, AddressOf EmpTimeEntry.dgvEmployi_SelectionChanged

    End Sub

    Private Sub TimeAttendForm_FormClosing(sender As Object, e As FormClosingEventArgs) Handles Me.FormClosing

        For Each objctrl As Control In PanelTimeAttend.Controls
            If TypeOf objctrl Is Form Then
                DirectCast(objctrl, Form).Close()

            End If
        Next

    End Sub

    Private Sub TimeAttendForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load

    End Sub

    Sub reloadViewPrivilege()

        Dim hasPositionViewUpdate = EXECQUER("SELECT EXISTS(SELECT" & _
                                             " RowID" & _
                                             " FROM position_view" & _
                                             " WHERE OrganizationID='" & org_rowid & "'" & _
                                             " AND DATE_FORMAT(LastUpd,'%Y-%m-%d') = CURDATE());")

        If hasPositionViewUpdate = "1" Then

            position_view_table = retAsDatTbl("SELECT *" & _
                                              " FROM position_view" & _
                                              " WHERE PositionID=(SELECT PositionID FROM user WHERE RowID=" & user_row_id & ")" & _
                                              " AND OrganizationID='" & org_rowid & "';")

        End If

    End Sub

End Class