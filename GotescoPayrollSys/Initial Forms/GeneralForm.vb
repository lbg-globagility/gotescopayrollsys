Public Class GeneralForm

    Public listGeneralForm As New List(Of String)

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
            Formname.KeyPreview = True
            Formname.TopLevel = False
            If listGeneralForm.Contains(FName) Then
                Formname.Show()
                Formname.BringToFront()
                Formname.Focus()
            Else
                PanelGeneral.Controls.Add(Formname)
                listGeneralForm.Add(Formname.Name)

                Formname.Show()
                Formname.BringToFront()
                Formname.Focus()
                'Formname.Location = New Point((PanelGeneral.Width / 2) - (Formname.Width / 2), (PanelGeneral.Height / 2) - (Formname.Height / 2))
                'Formname.Anchor = AnchorStyles.Top And AnchorStyles.Bottom And AnchorStyles.Right And AnchorStyles.Left
                'Formname.WindowState = FormWindowState.Maximized
                Formname.Dock = DockStyle.Fill
            End If
        Catch ex As Exception
            MsgBox(getErrExcptn(ex, Me.Name))

        End Try

    End Sub

    Private Sub GeneralForm_FormClosing(sender As Object, e As FormClosingEventArgs) Handles Me.FormClosing

        For Each objctrl As Control In PanelGeneral.Controls
            If TypeOf objctrl Is Form Then
                DirectCast(objctrl, Form).Close()

            End If
        Next

    End Sub

    Private Sub GeneralForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load

    End Sub

    Private Sub UserToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles UserToolStripMenuItem.Click

        ChangeForm(UsersForm, "Users")
        previousForm = UsersForm

        'If FormLeft.Contains("Users") Then
        '    FormLeft.Remove("Users")

        '    FormLeft.Add("Users")
        'Else
        '    FormLeft.Add("Users")
        'End If

        'If FormLeft.Count = 0 Then
        '    MDIPrimaryForm.text = "Welcome"
        'Else
        '    MDIPrimaryForm.text = "Welcome to " & FormLeft.Item(FormLeft.Count - 1)
        'End If

    End Sub

    Private Sub ListOfValueToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles ListOfValueToolStripMenuItem.Click

        ChangeForm(ListOfValueForm, "List of value")
        previousForm = ListOfValueForm

        'If FormLeft.Contains("List of value") Then
        '    FormLeft.Remove("List of value")

        '    FormLeft.Add("List of value")
        'Else
        '    FormLeft.Add("List of value")
        'End If

        'If FormLeft.Count = 0 Then
        '    MDIPrimaryForm.text = "Welcome"
        'Else
        '    MDIPrimaryForm.text = "Welcome to " & FormLeft.Item(FormLeft.Count - 1)
        'End If

    End Sub

    Private Sub OrganizationToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles OrganizationToolStripMenuItem.Click

        ChangeForm(OrganizationForm, "Organization")
        previousForm = OrganizationForm

        'If FormLeft.Contains("Organization") Then
        '    FormLeft.Remove("Organization")

        '    FormLeft.Add("Organization")
        'Else
        '    FormLeft.Add("Organization")
        'End If

        'If FormLeft.Count = 0 Then
        '    MDIPrimaryForm.text = "Welcome"
        'Else
        '    MDIPrimaryForm.text = "Welcome to " & FormLeft.Item(FormLeft.Count - 1)
        'End If

    End Sub

    Private Sub SupplierToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles SupplierToolStripMenuItem.Click

        'ChangeForm(UserPrivilegeForm)
        ChangeForm(userprivil, "User Privilege")

        previousForm = userprivil

        'If FormLeft.Contains("User Privilege") Then
        '    FormLeft.Remove("User Privilege")

        '    FormLeft.Add("User Privilege")
        'Else
        '    FormLeft.Add("User Privilege")
        'End If

        'If FormLeft.Count = 0 Then
        '    MDIPrimaryForm.text = "Welcome"
        'Else
        '    MDIPrimaryForm.text = "Welcome to " & FormLeft.Item(FormLeft.Count - 1)
        'End If

    End Sub

    Private Sub PhilHealthTableToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles PhilHealthTableToolStripMenuItem.Click

        ChangeForm(PhiHealth, "PhilHealth Contribution Table")
        previousForm = PhiHealth

        'If FormLeft.Contains("PhilHealth Contribution Table") Then
        '    FormLeft.Remove("PhilHealth Contribution Table")

        '    FormLeft.Add("PhilHealth Contribution Table")
        'Else
        '    FormLeft.Add("PhilHealth Contribution Table")
        'End If

        'If FormLeft.Count = 0 Then
        '    MDIPrimaryForm.text = "Welcome"
        'Else
        '    MDIPrimaryForm.text = "Welcome to " & FormLeft.Item(FormLeft.Count - 1)
        'End If

    End Sub

    Private Sub SSSTableToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles SSSTableToolStripMenuItem.Click

        ChangeForm(SSSCntrib, "SSS Contribution Table")
        previousForm = SSSCntrib

        'If FormLeft.Contains("SSS Contribution Table") Then
        '    FormLeft.Remove("SSS Contribution Table")

        '    FormLeft.Add("SSS Contribution Table")
        'Else
        '    FormLeft.Add("SSS Contribution Table")
        'End If

        'If FormLeft.Count = 0 Then
        '    MDIPrimaryForm.text = "Welcome"
        'Else
        '    MDIPrimaryForm.text = "Welcome to " & FormLeft.Item(FormLeft.Count - 1)
        'End If

    End Sub

    Private Sub WithholdingTaxToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles WithholdingTaxToolStripMenuItem.Click

        ChangeForm(Revised_Withholding_Tax_Tables, "Withholding Tax Table")
        previousForm = Revised_Withholding_Tax_Tables

        'If FormLeft.Contains("Withholding tax table") Then
        '    FormLeft.Remove("Withholding tax table")

        '    FormLeft.Add("Withholding tax table")
        'Else
        '    FormLeft.Add("Withholding tax table")
        'End If

        'If FormLeft.Count = 0 Then
        '    MDIPrimaryForm.text = "Welcome"
        'Else
        '    MDIPrimaryForm.text = "Welcome to " & FormLeft.Item(FormLeft.Count - 1)
        'End If

    End Sub

    Private Sub DutyShiftingToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles DutyShiftingToolStripMenuItem.Click

        ChangeForm(ShiftEntryForm, "Duty shifting")
        previousForm = ShiftEntryForm

        'If FormLeft.Contains("Duty shifting") Then
        '    FormLeft.Remove("Duty shifting")

        '    FormLeft.Add("Duty shifting")
        'Else
        '    FormLeft.Add("Duty shifting")
        'End If

        'If FormLeft.Count = 0 Then
        '    MDIPrimaryForm.text = "Welcome"
        'Else
        '    MDIPrimaryForm.text = "Welcome to " & FormLeft.Item(FormLeft.Count - 1)
        'End If

    End Sub

    Private Sub PayRateToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles PayRateToolStripMenuItem.Click

        ChangeForm(Payrate, "Pay rate")
        previousForm = Payrate

        'If FormLeft.Contains("Pay rate") Then
        '    FormLeft.Remove("Pay rate")

        '    FormLeft.Add("Pay rate")
        'Else
        '    FormLeft.Add("Pay rate")
        'End If

        'If FormLeft.Count = 0 Then
        '    MDIPrimaryForm.text = "Welcome"
        'Else
        '    MDIPrimaryForm.text = "Welcome to " & FormLeft.Item(FormLeft.Count - 1)
        'End If

    End Sub

    Sub reloadViewPrivilege()

        Dim hasPositionViewUpdate = EXECQUER("SELECT EXISTS(SELECT" & _
                                             " RowID" & _
                                             " FROM position_view" & _
                                             " WHERE OrganizationID='" & orgztnID & "'" & _
                                             " AND (DATE_FORMAT(Created,'%Y-%m-%d') = CURDATE()" & _
                                             " OR DATE_FORMAT(LastUpd,'%Y-%m-%d') = CURDATE()));")

        If hasPositionViewUpdate = "1" Then

            position_view_table = retAsDatTbl("SELECT *" & _
                                              " FROM position_view" & _
                                              " WHERE PositionID=(SELECT PositionID FROM user WHERE RowID=" & z_User & ")" & _
                                              " AND OrganizationID='" & orgztnID & "';")

        End If

    End Sub

    Private Sub AgencyToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles AgencyToolStripMenuItem.Click

        Dim n_UserAccessRights As New UserAccessRights(Agency.ViewIdentification)

        'If n_UserAccessRights.ResultValue(AccessRightName.HasReadOnly) Then
        '    'Agency
        ChangeForm(Agency, "Agency")
        previousForm = Agency

        'End If

    End Sub

End Class