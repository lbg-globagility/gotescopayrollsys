Public Class PayrollForm

    Public listPayrollForm As New List(Of String)

    Sub ChangeForm(ByVal Formname As Form, Optional ViewName As String = Nothing)

        reloadViewPrivilege()

        Dim view_ID = VIEW_privilege(ViewName, orgztnID)

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
            Application.DoEvents()
            Dim FName As String = Formname.Name
            Formname.TopLevel = False
            Formname.KeyPreview = True
            If listPayrollForm.Contains(FName) Then
                Formname.Show()
                Formname.BringToFront()
                Formname.Focus()
            Else
                PanelPayroll.Controls.Add(Formname)
                listPayrollForm.Add(Formname.Name)

                Formname.Show()
                Formname.BringToFront()
                Formname.Focus()
                'Formname.Location = New Point((PanelPayroll.Width / 2) - (Formname.Width / 2), (PanelPayroll.Height / 2) - (Formname.Height / 2))
                'Formname.Anchor = AnchorStyles.Top And AnchorStyles.Bottom And AnchorStyles.Right And AnchorStyles.Left
                'Formname.WindowState = FormWindowState.Maximized
                Formname.Dock = DockStyle.Fill
            End If
        Catch ex As Exception
            MsgBox(getErrExcptn(ex, Me.Name))
        End Try

    End Sub

    Sub PayrollToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles PayrollToolStripMenuItem.Click
        'ChangeForm(PayrollGenerateForm)
        ChangeForm(PayStub, "Employee Pay Slip")
        previousForm = PayStub
    End Sub

    Private Sub PayrollForm_FormClosing(sender As Object, e As FormClosingEventArgs) Handles Me.FormClosing

        For Each objctrl As Control In PanelPayroll.Controls
            If TypeOf objctrl Is Form Then
                DirectCast(objctrl, Form).Close()

            End If
        Next

    End Sub

    Private Sub PayrollForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load

    End Sub

    Sub reloadViewPrivilege()

        Dim hasPositionViewUpdate = EXECQUER("SELECT EXISTS(SELECT" & _
                                             " RowID" & _
                                             " FROM position_view" & _
                                             " WHERE OrganizationID='" & orgztnID & "'" & _
                                             " AND DATE_FORMAT(LastUpd,'%Y-%m-%d') = CURDATE());")

        If hasPositionViewUpdate = "1" Then

            position_view_table = retAsDatTbl("SELECT *" & _
                                              " FROM position_view" & _
                                              " WHERE PositionID=(SELECT PositionID FROM user WHERE RowID=" & z_User & ")" & _
                                              " AND OrganizationID='" & orgztnID & "';")

        End If

    End Sub

End Class