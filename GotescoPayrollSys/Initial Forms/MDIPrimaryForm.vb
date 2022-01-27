Imports System.Threading
Imports log4net
Imports MySql.Data.MySqlClient

Public Class MDIPrimaryForm
    Private Shared logger As ILog = LogManager.GetLogger("LoggerWork")

    Dim DefaultFontStyle = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))

    Dim ExemptedForms As New List(Of String)

    Private versionNo As String

    Private str_quer_restricted_user As String =
        String.Concat("SELECT (NOT ISNULL(pv.RowID)) `pv.RowID`",
                      " FROM position_view pv",
                      " INNER JOIN `user` u ON u.RowID=?u_rowid AND pv.PositionID=u.PositionID",
                      " INNER JOIN `view` v ON v.RowID=pv.ViewID",
                      " AND v.OrganizationID=pv.OrganizationID",
                      " WHERE pv.OrganizationID=?og_rowid",
                      " AND pv.Creates='N'",
                      " AND pv.ReadOnly='N'",
                      " AND pv.Updates='N'",
                      " AND pv.Deleting='N'",
                      " HAVING COUNT(v.RowID) = COUNT(pv.RowID);")

    Protected Overrides Sub OnLoad(e As EventArgs)

        Dim sql As New SQL(str_quer_restricted_user,
                           New Object() {user_row_id, org_rowid})

        SplitContainer1.Visible = (Not CBool(Convert.ToInt16(sql.GetFoundRow)))

        maintslabel.Text = String.Empty

        With ExemptedForms
            .Add("MDIPrimaryForm")
            .Add("MetroLogin")
            .Add("FormReports")
            .Add("GeneralForm")
            .Add("HomeForm")
            .Add("HRISForm")
            .Add("PayrollForm")
            .Add("TimeAttendForm")
        End With

        SplitContainer1.SplitterWidth = 6

        SplitContainer2.SplitterWidth = 6

        Panel2.Font = DefaultFontStyle

        Panel3.Font = DefaultFontStyle

        Panel4.Font = DefaultFontStyle

        Panel5.Font = DefaultFontStyle

        Panel6.Font = DefaultFontStyle

        Panel7.Font = DefaultFontStyle

        'Panel10.Location = New Point(4, 3)

        'Panel8.Location = New Point(457, 3)

        'Panel9.Location = New Point(910, 3)

        Panel11.Font = DefaultFontStyle

        Panel12.Font = DefaultFontStyle

        Panel13.Font = DefaultFontStyle

        Panel14.Font = DefaultFontStyle

        Panel15.Font = DefaultFontStyle

        Panel1.Focus()

        CreateSalaryForSeniorCitizensAsync()

        LoadVersionNo()

        MyBase.OnLoad(e)

        MetroLogin.Hide()

    End Sub

    Private Async Sub CreateSalaryForSeniorCitizensAsync()
        Using command =
            New MySqlCommand(String.Concat("CALL CREATE_employeesalary_senior_citizen('", org_rowid, "','", user_row_id, "');"),
                             New MySqlConnection(mysql_conn_text))
            With command
                Await .Connection.OpenAsync()
                Await .ExecuteNonQueryAsync()
            End With
        End Using
    End Sub

    Dim listofGroup As New List(Of String)

    Public Sub ChangeForm(ByVal Formname As Form)
        Try
            Application.DoEvents()
            Dim FName As String = Formname.Name
            Formname.TopLevel = False

            If listofGroup.Contains(FName) Then
                'If Formname.Dock = DockStyle.None Then
                '    Formname.Dock = DockStyle.Fill
                'End If

                Formname.Show()
                Formname.BringToFront()
            Else
                Panel1.Controls.Add(Formname)
                listofGroup.Add(Formname.Name)

                Formname.Show()
                Formname.BringToFront()

                'Formname.Location = New Point((Panel1.Width / 2) - (Formname.Width / 2), (Panel1.Height / 2) - (Formname.Height / 2))
                'Formname.Anchor = AnchorStyles.Top And AnchorStyles.Bottom And AnchorStyles.Right And AnchorStyles.Left
                'Formname.WindowState = FormWindowState.Maximized

            End If

            Formname.Dock = DockStyle.Fill
        Catch ex As Exception
            MsgBox(getErrExcptn(ex, Name))
        Finally

            Panel8.Visible = False
            Panel9.Visible = False
            Panel10.Visible = False

            Panel1.PerformLayout()

        End Try

    End Sub

    Private Sub Timer1_Tick(sender As Object, e As EventArgs) Handles Timer1.Tick
        lblTime.Text = TimeOfDay
    End Sub

    Dim ClosingForm As Form = Nothing 'New

    Private Async Sub MDIPrimaryForm_FormClosingAsync(sender As Object, e As FormClosingEventArgs) Handles MyBase.FormClosing
        'Dim prompt = MsgBox("Do you want to log out ?", MsgBoxStyle.YesNo, "Confirmation")

        LockTime()

        If backgroundworking = 1 Then
            e.Cancel = True
        Else

            'MessageBoxManager.No = "Yes,and quit"

            'MessageBoxManager.Register()

            Dim prompt = MessageBox.Show("Do you want to log out ?", "Confirm logging out", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question)

            If prompt = MsgBoxResult.Yes Then

                position_view_table = Nothing

                e.Cancel = False

                ''Close all forms that remains open

                Dim listofExtraFrm As Form()

                Dim listofExtraForm As New List(Of String)

                listofExtraForm.Add("CrysVwr")
                listofExtraForm.Add("dutyshift")
                listofExtraForm.Add("leavtyp")
                listofExtraForm.Add("LoanType")
                listofExtraForm.Add("newEmpStat")
                listofExtraForm.Add("newEmpType")
                listofExtraForm.Add("newPostion")
                listofExtraForm.Add("newProdAllowa")
                listofExtraForm.Add("newProdBonus")
                listofExtraForm.Add("SelectFromEmployee")
                listofExtraForm.Add("selectPayPeriod")
                listofExtraForm.Add("viewtotallow")
                listofExtraForm.Add("viewtotbon")
                listofExtraForm.Add("viewtotloan")
                listofExtraForm.Add("FindingForm")

                listofExtraForm.Add("AddListOfValueForm")
                listofExtraForm.Add("AddPostionForm")

                listofExtraForm.Add("GeneralForm")
                listofExtraForm.Add("HRISForm")
                listofExtraForm.Add("PayrollForm")
                listofExtraForm.Add("TimeAttendForm")

                ReDim listofExtraFrm(My.Application.OpenForms.Count - 1)

                Dim itemindex = 0

                For Each f As Form In My.Application.OpenForms

                    Dim frmName = f.Name

                    If ExemptedForms.Contains(frmName) Then
                        Continue For
                    Else

                        If listofExtraForm.Contains(frmName) Then
                            Continue For
                            'ReDim Preserve listofExtraFrm(itemindex + 1)

                            'f.Close()
                        Else
                            If frmName.Trim.Length > 0 Then
                                listofExtraFrm(itemindex) = f
                                itemindex += 1

                            End If

                        End If

                    End If

                Next

                Dim openform_count = listofExtraFrm.GetUpperBound(0)

                For ii = 0 To listofExtraFrm.GetUpperBound(0)

                    If listofExtraFrm(ii) Is Nothing Then
                        Continue For
                    Else
                        'ClosingForm = New Form

                        ClosingForm = listofExtraFrm(ii)

                        'Dim frmName = ClosingForm.Name

                        'ClosingForm.Dispose()

                        ClosingForm.Close()

                    End If

                Next

                Await LogOutUserAsync()

                If openform_count >= 5 Then
                    Thread.Sleep(1175)
                End If

                With MetroLogin

                    .Show()

                    .txtbxUserID.Clear()

                    .txtbxPword.Clear()

                    .txtbxUserID.Focus()

                    .PhotoImages.Image = Nothing

                    .cbxorganiz.SelectedIndex = -1

                    .ReloadOrganization()

                    If Debugger.IsAttached Then
                        .AssignDefaultCredentials()
                    End If
                End With

                MessageBoxManager.Unregister()

            ElseIf prompt = MsgBoxResult.No Then

                e.Cancel = True

                'MessageBoxManager.Unregister()

                'MetroLogin.Close()
            Else
                e.Cancel = True

                'MessageBoxManager.Unregister()

            End If

        End If

    End Sub

    Private Shared Async Function LogOutUserAsync() As Tasks.Task
        Using connection As New MySqlConnection(connectionString),
            command As New MySqlCommand("UPDATE `user` SET InSession='0', LastUpd=CURRENT_TIMESTAMP(), LastUpdBy=@userRowID WHERE RowID=@userRowID;", connection)

            command.Parameters.AddWithValue("@userRowID", user_row_id)

            Await connection.OpenAsync()
            Try
                Dim i = Await command.ExecuteNonQueryAsync()
            Catch ex As Exception
                logger.Error("LogOutUserFailed", ex)
                Dim errMsg = String.Concat("Oops! something went wrong, please", Environment.NewLine, "contact ", My.Resources.SystemDeveloper, " for assistance.")
                MessageBox.Show(errMsg, "Log out failed", MessageBoxButtons.OK, MessageBoxIcon.Error)
            End Try
        End Using
    End Function

    Private Sub CenterMe()
        'Dim g As Graphics = Me.CreateGraphics()
        'Dim startingPoint As Double = (Me.Width / 2) - (g.MeasureString(Me.Text.Trim, Me.Font).Width / 2)
        'Dim widthOfASpace As Double = g.MeasureString(" ", Me.Font).Width
        'Dim tmp As String = " "
        'Dim tmpWidth As Double = 0
        'Do
        '    tmp += " "
        '    tmpWidth += widthOfASpace
        'Loop While (tmpWidth + widthOfASpace) < startingPoint

        'Me.Text = tmp & Me.Text.Trim & tmp

        'Me.Refresh()

    End Sub

    Private Sub MDIPrimaryForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load

        If dbnow = Nothing Then
            dbnow = EXECQUER(CURDATE_MDY)
        End If

        ToolStripButton3.Text = "Time &&" & vbNewLine & "Attendance"

        ToolStripButton3.ToolTipText = "Time & Attendance"

        '123, 24

        lblTime.Text = TimeOfDay
        'lblUser.Text = Z_UserName
        lblUser.Text = userFirstName &
                       If(userLastName = Nothing, "", " " & userLastName)

        lblPosition.Text = z_postName

        ToolStripButton0_Click(sender, e)

        PictureBox1.Image = ImageList1.Images(1)

    End Sub

    'Trebuchet MS
    'Segoe UI

    Dim selectedButtonFont = New System.Drawing.Font("Trebuchet MS", 9.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))

    Dim unselectedButtonFont = New System.Drawing.Font("Trebuchet MS", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))

    Dim isHome As SByte = 0

    Private Sub ToolStripButton0_Click(sender As Object, e As EventArgs) Handles ToolStripButton0.Click

        UnlockTime()

        'Static str_once As String = Nothing

        'If str_once <> orgNam Then
        '    str_once = orgNam

        'End If

        Text = orgNam

        GeneralForm.Hide()
        'GeneralForm.Dock = DockStyle.None
        'GeneralForm.Size = New Size(1, 1)

        HRISForm.Hide()
        'HRISForm.Dock = DockStyle.None
        'HRISForm.Size = New Size(1, 1)

        PayrollForm.Hide()
        'PayrollForm.Dock = DockStyle.None
        'PayrollForm.Size = New Size(1, 1)

        TimeAttendForm.Hide()
        'TimeAttendForm.Dock = DockStyle.None
        'TimeAttendForm.Size = New Size(1, 1)

        FormReports.Hide()
        'FormReports.Dock = DockStyle.None
        'FormReports.Size = New Size(1, 1)

        'GeneralForm.Dock = DockStyle.None
        'HRISForm.Dock = DockStyle.None
        'PayrollForm.Dock = DockStyle.None
        'TimeAttendForm.Dock = DockStyle.None
        'FormReports.Dock = DockStyle.None

        ToolStripButton0.BackColor = Color.FromArgb(255, 255, 255)

        ToolStripButton1.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton2.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton3.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton4.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton5.BackColor = Color.FromArgb(194, 228, 255)

        ToolStripButton0.Font = selectedButtonFont

        ToolStripButton1.Font = unselectedButtonFont
        ToolStripButton2.Font = unselectedButtonFont
        ToolStripButton3.Font = unselectedButtonFont
        ToolStripButton4.Font = unselectedButtonFont
        ToolStripButton5.Font = unselectedButtonFont

        'Static once As SByte = 0
        'If once = 0 Then
        '    once = 1
        '    'Me.Text = "Welcome"

        'Else
        '    Me.Text = ""

        'End If

        Panel8.Visible = True
        Panel9.Visible = True
        Panel10.Visible = True

        Panel1.PerformLayout()

    End Sub

    Sub Panel1ReAutoScroll(Optional sender_obj As Object = Nothing)

        Static senderobj As Object = Nothing

        Static once As SByte = 0

        If sender_obj IsNot Nothing Then

            If once = 0 Then

                once = 1

                If senderobj Is Nothing Then

                    senderobj = ToolStripButton0

                End If

            End If

            If senderobj.Name <> sender_obj.Name Then

                senderobj = sender_obj

                If Panel1.AutoScroll Then
                    Panel1.AutoScroll = False
                Else
                    Panel1.AutoScroll = True
                End If

            End If

        End If

    End Sub

    Sub ToolStripButton1_Click(sender As Object, e As EventArgs) Handles ToolStripButton1.Click

        isHome = 0

        LockTime()

        ChangeForm(GeneralForm)

        'Me.Text = "General"

        'If GeneralForm.listGeneralForm.Count <> 0 Then
        '    Me.Text = "General - " & GeneralForm.listGeneralForm.Item(GeneralForm.listGeneralForm.Count - 1)
        'End If

        HRISForm.Hide()
        PayrollForm.Hide()
        TimeAttendForm.Hide()

        FormReports.Hide()

        ToolStripButton0.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton2.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton3.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton4.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton5.BackColor = Color.FromArgb(194, 228, 255)

        ToolStripButton1.BackColor = Color.FromArgb(255, 255, 255)

        ToolStripButton1.Font = selectedButtonFont

        ToolStripButton0.Font = unselectedButtonFont
        ToolStripButton2.Font = unselectedButtonFont
        ToolStripButton3.Font = unselectedButtonFont
        ToolStripButton4.Font = unselectedButtonFont
        ToolStripButton5.Font = unselectedButtonFont

        refresh_previousForm(0, sender, e)

        'If FormLeft.Count = 0 Then
        '    Me.Text = "Welcome"
        'Else
        '    Me.Text = "Welcome to " & FormLeft.Item(FormLeft.Count - 1)
        'End If

        Panel1.PerformLayout()

    End Sub

    Sub ToolStripButton3_Click(sender As Object, e As EventArgs) Handles ToolStripButton3.Click

        isHome = 0

        LockTime()

        ChangeForm(TimeAttendForm)

        GeneralForm.Hide()
        HRISForm.Hide()
        PayrollForm.Hide()

        FormReports.Hide()

        ToolStripButton0.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton1.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton2.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton4.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton5.BackColor = Color.FromArgb(194, 228, 255)

        ToolStripButton3.BackColor = Color.FromArgb(255, 255, 255)

        ToolStripButton3.Font = selectedButtonFont

        ToolStripButton0.Font = unselectedButtonFont
        ToolStripButton1.Font = unselectedButtonFont
        ToolStripButton2.Font = unselectedButtonFont
        ToolStripButton4.Font = unselectedButtonFont
        ToolStripButton5.Font = unselectedButtonFont

        refresh_previousForm(2, sender, e)

        Panel1.PerformLayout()

    End Sub

    Private Sub Panel1_Scroll(sender As Object, e As ScrollEventArgs) Handles Panel1.Scroll

        Dim scroll_x, scroll_y As Integer

        scroll_x = 0

        scroll_y = 0

        Static previous_scroller As ScrollOrientation

        'If e.Type = ScrollEventType.ThumbPosition Then

        '    Position = New Point(scroll_x, scroll_y)

        'Else
        '    previous_scroller = e.ScrollOrientation

        If previous_scroller = ScrollOrientation.HorizontalScroll Then

            scroll_x = e.NewValue
        Else

            scroll_y = e.NewValue

        End If

        'Position = New Point(scroll_x, scroll_y)

        'End If

        'Me.Text = e.Type.ToString

    End Sub

    Private Sub MDIPrimaryForm_Resize(sender As Object, e As EventArgs) Handles MyBase.Resize
        'Me.Text = Me.Width & " is width" & Panel1.Width & " is panel width"

        CenterMe()

        Width_resolution = Width

        Height_resolution = Height

        Static once As SByte = 0

        'If Me.Size = Me.MinimumSize Then

        '    ' = True

        '    Panel10.Location = New Point(4, 3)

        '    Panel8.Location = New Point(457, 3)

        '    Panel9.Location = New Point(910, 3)

        '    'Panel10.Anchor = AnchorStyles.None

        '    'Panel8.Anchor = AnchorStyles.None

        '    'Panel9.Anchor = AnchorStyles.None

        '    Panel10.Size = New Size(448, 521)

        '    Panel8.Size = New Size(448, 521)

        '    Panel9.Size = New Size(438, 521)

        '    dgvEvaluationRegular.Size = New Size(300, 246)

        'Else

        '    'Dim CurrentPoint As System.Drawing.Point
        '    'CurrentPoint = Position()

        '    'Position = New Point(Math.Abs(Position.X), Math.Abs(CurrentPoint.Y))

        '    Panel10.Location = New Point(4, 3)

        '    Panel8.Location = New Point(457, 3)

        '    Panel9.Location = New Point(910, 3)

        '    'Panel10.Anchor = AnchorStyles.Top And AnchorStyles.Bottom And AnchorStyles.Left

        '    'Panel8.Anchor = AnchorStyles.Top And AnchorStyles.Bottom ' And AnchorStyles.Left

        '    'Panel9.Anchor = AnchorStyles.Top And AnchorStyles.Bottom ' And AnchorStyles.Left

        '    'Panel10.Anchor = AnchorStyles.None

        '    'Panel8.Anchor = AnchorStyles.None

        '    'Panel9.Anchor = AnchorStyles.None

        '    Panel10.Size = New Size(448, 521 + (Height_resolution - Me.MinimumSize.Height))

        '    Panel8.Size = New Size(448, 521 + (Height_resolution - Me.MinimumSize.Height))

        '    Panel9.Size = New Size(438, 521 + (Height_resolution - Me.MinimumSize.Height))

        '    'For Each objctrl As Object In Panel1.Controls

        '    '    'If TypeOf objctrl Is DataGridView Then

        '    '    '    With DirectCast(objctrl, DataGridView)

        '    '    '        .Anchor = AnchorStyles.Right

        '    '    '    End With

        '    '    'ElseIf TypeOf objctrl Is Label Then

        '    '    '    With DirectCast(objctrl, Label)

        '    '    '        .Anchor = AnchorStyles.Right

        '    '    '    End With
        '    '    'Else
        '    '    '    Continue For
        '    '    'End If

        '    'Next

        '    'dgvEvaluationRegular.Anchor = AnchorStyles.Right  ' AndAlso AnchorStyles.Left

        'End If

        'Panel1.PerformLayout()

    End Sub

    Private Sub Panel1_Paint(sender As Object, e As PaintEventArgs) Handles Panel1.Paint

    End Sub

    Private Sub Panel1_Resize(sender As Object, e As EventArgs) Handles Panel1.Resize
        'For Each panelcontrl As Control In Panel1.Controls
        '    If TypeOf panelcontrl Is Form Then
        '        panelcontrl.Width = Panel1.Width
        '    End If
        'Next
    End Sub

    Dim theemployeetable As New DataTable

    Sub refresh_previousForm(Optional groupindex As Object = 0,
                             Optional sndr As Object = 0,
                             Optional ee As EventArgs = Nothing)

        Static once As SByte = 0
        If once = 0 Then
            'once = 1

            Exit Sub

        End If

        Static countchanges As Integer = -1
        'SELECT RowID,CreatedBy,Created,LastUpdBy,LastUpd,OrganizationID,Salutation,FirstName,MiddleName,LastName,Surname,EmployeeID,TINNo,SSSNo,HDMFNo,PhilHealthNo,EmploymentStatus,EmailAddress,WorkPhone,HomePhone,MobilePhone,HomeAddress,Nickname,JobTitle,Gender,EmployeeType,MaritalStatus,Birthdate,StartDate,TerminationDate,PositionID,PayFrequencyID,NoOfDependents,UndertimeOverride,OvertimeOverride,NewEmployeeFlag,LeaveBalance,SickLeaveBalance,MaternityLeaveBalance,LeaveAllowance,SickLeaveAllowance,MaternityLeaveAllowance,LeavePerPayPeriod,SickLeavePerPayPeriod,MaternityLeavePerPayPeriod FROM employee;

        'theemployeetable = retAsDatTbl("SELECT RowID" & _
        '                               ",CreatedBy" & _
        '                               ",Created" & _
        '                               ",LastUpdBy" & _
        '                               ",LastUpd" & _
        '                               ",OrganizationID" & _
        '                               ",Salutation" & _
        '                               ",FirstName" & _
        '                               ",MiddleName" & _
        '                               ",LastName" & _
        '                               ",Surname" & _
        '                               ",EmployeeID" & _
        '                               ",TINNo" & _
        '                               ",SSSNo" & _
        '                               ",HDMFNo" & _
        '                               ",PhilHealthNo" & _
        '                               ",EmploymentStatus" & _
        '                               ",EmailAddress" & _
        '                               ",WorkPhone" & _
        '                               ",HomePhone" & _
        '                               ",MobilePhone" & _
        '                               ",HomeAddress" & _
        '                               ",Nickname" & _
        '                               ",JobTitle" & _
        '                               ",Gender" & _
        '                               ",EmployeeType" & _
        '                               ",MaritalStatus" & _
        '                               ",Birthdate" & _
        '                               ",StartDate" & _
        '                               ",TerminationDate" & _
        '                               ",PositionID" & _
        '                               ",PayFrequencyID" & _
        '                               ",NoOfDependents" & _
        '                               ",UndertimeOverride" & _
        '                               ",OvertimeOverride" & _
        '                               ",NewEmployeeFlag" & _
        '                               ",LeaveBalance" & _
        '                               ",SickLeaveBalance" & _
        '                               ",MaternityLeaveBalance" & _
        '                               ",LeaveAllowance" & _
        '                               ",SickLeaveAllowance" & _
        '                               ",MaternityLeaveAllowance" & _
        '                               ",LeavePerPayPeriod" & _
        '                               ",SickLeavePerPayPeriod" & _
        '                               ",MaternityLeavePerPayPeriod" & _
        '                               " FROM employee" & _
        '                               " WHERE DATE_FORMAT(LastUpd,'%Y-%m-%d')=CURRENT_DATE();")

        'If theemployeetable.Rows.Count <> 0 Then

        'Else

        'End If

        If previousForm IsNot Nothing Then
            'previousForm = Nothing

            If groupindex = 0 Then 'General

                If previousForm.Name = "UsersFrom" Then

                ElseIf previousForm.Name = "ListOfValueForm" Then

                ElseIf previousForm.Name = "OrganizatinoForm" Then

                ElseIf previousForm.Name = "UserPrivilegeForm" Then

                ElseIf previousForm.Name = "PhilHealht" Then

                ElseIf previousForm.Name = "SSSCntrib" Then

                ElseIf previousForm.Name = "Payrate" Then

                ElseIf previousForm.Name = "ShiftEntryForm" Then

                ElseIf previousForm.Name = "userprivil" Then

                ElseIf previousForm.Name = "Revised_Withholding_Tax_Tables" Then

                End If

            ElseIf groupindex = 1 Then 'HRIS

                If previousForm.Name = "Employee" Then

                    With EmployeeForm

                        Select Case .tabIndx
                            Case 0 'Checklist

                            Case 1 'Personal Profile
                                If .listofEditDepen.Count = 0 Then
                                    .SearchEmoloyee_Click(sndr, ee)
                                Else

                                End If

                            Case 2 'Awards
                                If .listofEditRowAward.Count = 0 Then
                                    .SearchEmoloyee_Click(sndr, ee)
                                Else

                                End If

                            Case 3 'Certification
                                If .listofEditRowCert.Count = 0 Then
                                    .SearchEmoloyee_Click(sndr, ee)
                                Else

                                End If

                            Case 4 'Leave
                                If .listofEditRowleave.Count = 0 Then
                                    .SearchEmoloyee_Click(sndr, ee)
                                Else

                                End If

                            Case 5 'Medicla Profile
                                If .listofEditedmedprod.Count = 0 Then
                                    .SearchEmoloyee_Click(sndr, ee)
                                Else

                                End If

                            Case 6 'Disciplinary action

                            Case 7 'Educational Background

                            Case 8 'Previous Employer

                            Case 9 'Promotion

                            Case 10 'Loan Schedule

                            Case 11 'Loan History

                            Case 12 'Salary
                                If .listofEditEmpSal.Count = 0 Then
                                    .SearchEmoloyee_Click(sndr, ee)
                                Else

                                End If

                            Case 13 'Pay slip
                                If .listofEditedmedprod.Count = 0 Then
                                    .SearchEmoloyee_Click(sndr, ee)
                                Else

                                End If

                            Case 14 'Allowance
                                If .listofEditEmpAllow.Count = 0 Then
                                    .SearchEmoloyee_Click(sndr, ee)
                                Else

                                End If

                            Case 15 'Overtime
                                If .listofEditRowEmpOT.Count = 0 Then
                                    .SearchEmoloyee_Click(sndr, ee)
                                Else

                                End If

                            Case 16 'Official business
                                If .listofEditRowOBF.Count = 0 Then
                                    .SearchEmoloyee_Click(sndr, ee)
                                Else

                                End If

                            Case 17 'Bonus
                                If .listofEditRowBon.Count = 0 Then
                                    .SearchEmoloyee_Click(sndr, ee)
                                Else

                                End If

                            Case 18 'Attachment
                                If .listofEditRoweatt.Count = 0 Then
                                    .SearchEmoloyee_Click(sndr, ee)
                                Else

                                End If

                        End Select

                    End With

                ElseIf previousForm.Name = "Positn" Then

                ElseIf previousForm.Name = "EmpPosition" Then

                ElseIf previousForm.Name = "DivisionForm" Then

                End If

            ElseIf groupindex = 2 Then 'Time Attendance

                If previousForm.Name = "ShiftEntryForm" Then

                ElseIf previousForm.Name = "EmployeeShiftEntryForm" Then

                ElseIf previousForm.Name = "Payrate" Then 'ShiftEntryForm

                ElseIf previousForm.Name = "EmpTimeDetail" Then

                ElseIf previousForm.Name = "EmpTimeEntry" Then

                    If Application.OpenForms().OfType(Of TimEntduration).Any Then
                        If TimEntduration.bgWork.IsBusy Then
                        Else
                            EmpTimeEntry.btnRerfresh_Click(sndr, ee)
                        End If

                    End If

                End If

            ElseIf groupindex = 3 Then 'Payroll
                If previousForm.Name = "Paystub" Then
                    With PayStubForm

                        If .bgworkgenpayroll.IsBusy Then
                        Else
                            .btnrefresh_Click(sndr, ee)
                            'For Each drow As DataRow In theemployeetable.Rows

                            '    For Each dgvrow As DataGridViewRow In .dgvemployees.Rows
                            '        If dgvrow.Cells("RowID").Value = drow("RowID").ToString Then

                            '            dgvrow.Cells("EmployeeID").Value = drow("EmployeeID").ToString
                            '            dgvrow.Cells("FirstName").Value = drow("FirstName").ToString
                            '            dgvrow.Cells("MiddleName").Value = If(IsDBNull(drow("MiddleName")), "", drow("MiddleName").ToString)
                            '            dgvrow.Cells("LastName").Value = drow("LastName").ToString
                            '            dgvrow.Cells("Surname").Value = If(IsDBNull(drow("Surname")), "", drow("Surname").ToString)
                            '            dgvrow.Cells("NickName").Value = If(IsDBNull(drow("Nickname")), "", drow("Nickname").ToString)
                            '            dgvrow.Cells("MaritStat").Value = drow("MaritalStatus").ToString
                            '            dgvrow.Cells("NoOfDepen").Value = drow("NoOfDependents").ToString
                            '            dgvrow.Cells("Bdate").Value = If(IsDBNull(drow("Birthdate")), "", drow("Birthdate").ToString)
                            '            dgvrow.Cells("Startdate").Value = drow("RowID").ToString
                            '            dgvrow.Cells("JobTitle").Value = If(IsDBNull(drow("JobTitle")), "", drow("JobTitle").ToString)
                            '            dgvrow.Cells("Position").Value = drow("RowID").ToString
                            '            dgvrow.Cells("Salutation").Value = If(IsDBNull(drow("Salutation")), "", drow("Salutation").ToString)
                            '            dgvrow.Cells("TIN").Value = drow("TINNo").ToString
                            '            dgvrow.Cells("SSSNo").Value = drow("SSSNo").ToString
                            '            dgvrow.Cells("HDMFNo").Value = drow("HDMFNo").ToString
                            '            dgvrow.Cells("PHHNo").Value = drow("PhilHealthNo").ToString
                            '            dgvrow.Cells("WorkNo").Value = If(IsDBNull(drow("WorkPhone")), "", drow("WorkPhone").ToString)
                            '            dgvrow.Cells("HomeNo").Value = If(IsDBNull(drow("HomePhone")), "", drow("HomePhone").ToString)
                            '            dgvrow.Cells("MobileNo").Value = If(IsDBNull(drow("MobilPhone")), "", drow("MobilPhone").ToString)
                            '            dgvrow.Cells("HomeAdd").Value = If(IsDBNull(drow("HomeAddress")), "", drow("HomeAddress").ToString)
                            '            dgvrow.Cells("EmailAdd").Value = If(IsDBNull(drow("EmailAddress")), "", drow("EmailAddress").ToString)
                            '            dgvrow.Cells("Gender").Value = If(drow("Gender").ToString = "M", "Male", "Female")
                            '            dgvrow.Cells("EmploymentStat").Value = drow("RowID").ToString
                            '            dgvrow.Cells("PayFreq").Value = drow("PayFrequencyID").ToString
                            '            dgvrow.Cells("UndertimeOverride").Value = drow("UndertimeOverride").ToString
                            '            dgvrow.Cells("OvertimeOverride").Value = drow("OvertimeOverride").ToString
                            '            dgvrow.Cells("PositionID").Value = If(IsDBNull(drow("PositionID")), "", drow("PositionID").ToString)
                            '            dgvrow.Cells("PayFreqID").Value = drow("RowID").ToString
                            '            dgvrow.Cells("EmployeeType").Value = drow("PayFrequencyID").ToString
                            '            dgvrow.Cells("LeaveBal").Value = drow("RowID").ToString
                            '            dgvrow.Cells("SickBal").Value = drow("RowID").ToString
                            '            dgvrow.Cells("MaternBal").Value = drow("RowID").ToString
                            '            dgvrow.Cells("LeaveAllow").Value = drow("RowID").ToString
                            '            dgvrow.Cells("SickAllow").Value = drow("RowID").ToString
                            '            dgvrow.Cells("MaternAllow").Value = drow("RowID").ToString
                            '            dgvrow.Cells("Leavepayp").Value = drow("RowID").ToString
                            '            dgvrow.Cells("Sickpayp").Value = drow("RowID").ToString
                            '            dgvrow.Cells("Maternpayp").Value = drow("RowID").ToString
                            '            dgvrow.Cells("fstatRowID").Value = drow("RowID").ToString
                            '            dgvrow.Cells("Image").Value = drow("RowID")
                            '            dgvrow.Cells("lastupd").Value = Format(CDate(drow("LastUpd")), "MM-dd-yyyy")
                            '            dgvrow.Cells("lastupdby").Value = EXECQUER(USERNameStrPropr & z_User)

                            '            Exit For
                            '        End If
                            '    Next
                            'Next

                        End If

                    End With

                End If

            End If

            'previousForm = UsersFrom
            'previousForm = ListOfValueForm
            'previousForm = OrganizatinoForm
            'previousForm = UserPrivilegeForm
            'previousForm = PhilHealht
            'previousForm = SSSCntrib
            'previousForm = Revised_Withholding_Tax_Tables
            'previousForm = Positn
            'previousForm = DivisionForm
            'previousForm = Paystub
            'previousForm = ShiftEntryForm
            'previousForm = EmployeeShiftEntryForm
            'previousForm = Payrate
            'previousForm = EmpTimeDetail
            'previousForm = EmpTimeEntry

            countchanges = theemployeetable.Rows.Count
        Else

        End If

    End Sub

    Sub ToolStripButton5_Click(sender As Object, e As EventArgs) Handles ToolStripButton4.Click

        isHome = 0

        LockTime()

        ChangeForm(PayrollForm)

        GeneralForm.Hide()
        HRISForm.Hide()
        TimeAttendForm.Hide()

        FormReports.Hide()

        ToolStripButton0.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton1.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton2.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton3.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton5.BackColor = Color.FromArgb(194, 228, 255)

        ToolStripButton4.BackColor = Color.FromArgb(255, 255, 255)

        ToolStripButton4.Font = selectedButtonFont

        ToolStripButton0.Font = unselectedButtonFont
        ToolStripButton1.Font = unselectedButtonFont
        ToolStripButton2.Font = unselectedButtonFont
        ToolStripButton3.Font = unselectedButtonFont
        ToolStripButton5.Font = unselectedButtonFont

        refresh_previousForm(3, sender, e)

        Panel1.PerformLayout()

    End Sub

    Private Sub ToolStripButton4_Click(sender As Object, e As EventArgs) Handles ToolStripButton2.Click

        isHome = 0

        LockTime()

        ChangeForm(HRISForm)

        GeneralForm.Hide()
        PayrollForm.Hide()
        TimeAttendForm.Hide()

        FormReports.Hide()

        ToolStripButton0.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton1.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton3.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton4.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton5.BackColor = Color.FromArgb(194, 228, 255)

        ToolStripButton2.BackColor = Color.FromArgb(255, 255, 255)

        ToolStripButton2.Font = selectedButtonFont

        ToolStripButton0.Font = unselectedButtonFont
        ToolStripButton1.Font = unselectedButtonFont
        ToolStripButton3.Font = unselectedButtonFont
        ToolStripButton4.Font = unselectedButtonFont
        ToolStripButton5.Font = unselectedButtonFont

        If HRISForm.listHRISForm.Count < 0 Then

            Dim indx = HRISForm.listHRISForm.Count - 1

            If HRISForm.listHRISForm.Item(indx) = "Employee" Then
                Select Case EmployeeForm.tabctrlemp.SelectedIndex
                    Case 0

                    Case 1
                        With EmployeeForm
                            If .tsbtnNewEmp.Enabled = True Then
                                Dim isTableChange = EXECQUER("SELECT EXISTS(SELECT RowID" &
                                                             " FROM position" &
                                                             " WHERE CURRENT_DATE()" &
                                                             " IN (DATE_FORMAT(Created,'%Y-%m-%d'),DATE_FORMAT(LastUpd,'%Y-%m-%d'))" &
                                                             " AND OrganizationID=" & org_rowid & " LIMIT 1);")

                                If isTableChange = 1 Then

                                End If

                            End If

                        End With

                    Case 2

                    Case 3

                    Case 4

                    Case 5

                    Case 6

                    Case 7

                    Case 8

                    Case 9

                    Case 10

                    Case 11

                    Case 12

                    Case 13

                    Case 14

                    Case 15

                    Case 16

                    Case 17

                    Case 18

                End Select

            ElseIf HRISForm.listHRISForm.Item(indx) = "EmpPosition" Then
                'MsgBox("EmpPosition")
            ElseIf HRISForm.listHRISForm.Item(indx) = "DivisionForm" Then
                'MsgBox("DivisionForm")
            End If

        End If

        refresh_previousForm(1, sender, e)

        Panel1.PerformLayout()

    End Sub

    'Toggling pin status

    Private Sub Pin_UnPin(sender As Object, e As EventArgs)

        Static once As SByte = 0

        If once = 0 Then
            once = 1
            'ToolStripButton5.Image.Tag = 1
        End If

        ImageList1.Images(0).Tag = 1
        ImageList1.Images(1).Tag = 2

        'If ToolStripButton5.Image.Tag = 1 Then 'Unhide toolstrip
        '    ToolStripButton5.Image = ImageList1.Images(1)
        '    ToolStripButton5.Image.Tag = 0

        'Else '                                  'Hide toolstrip
        '    ToolStripButton5.Image = ImageList1.Images(0)
        '    ToolStripButton5.Image.Tag = 1

        'End If

    End Sub

    Private Sub PictureBox1_Click(sender As Object, e As EventArgs) Handles PictureBox1.Click

        Static once As SByte = 0

        If once = 0 Then
            once = 1
            PictureBox1.Image.Tag = 1
        End If

        ImageList1.Images(0).Tag = 1
        ImageList1.Images(1).Tag = 2

        If PictureBox1.Image.Tag = 1 Then 'Hide toolstrip
            PictureBox1.Image = ImageList1.Images(0)
            PictureBox1.Image.Tag = 0

            Showmainbutton.Dock = DockStyle.None
        Else '                             'Show toolstrip
            PictureBox1.Image = ImageList1.Images(1)
            PictureBox1.Image.Tag = 1

            Showmainbutton.Dock = DockStyle.Left

        End If

    End Sub

    Protected Overrides Function ProcessCmdKey(ByRef msg As Message, keyData As Keys) As Boolean

        If keyData = Keys.F5 And isHome = 1 Then

            'DashBoardReloader()

            Timer2_Tick(Timer2, New EventArgs)

            Return True
        Else

            Return MyBase.ProcessCmdKey(msg, keyData)

        End If

    End Function

    Private Sub ToolStripButton5_Click_1(sender As Object, e As EventArgs) Handles ToolStripButton5.Click

        isHome = 0

        LockTime()

        ChangeForm(FormReports)

        GeneralForm.Hide()
        HRISForm.Hide()
        TimeAttendForm.Hide()

        ToolStripButton0.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton1.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton2.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton3.BackColor = Color.FromArgb(194, 228, 255)
        ToolStripButton4.BackColor = Color.FromArgb(194, 228, 255)

        ToolStripButton5.BackColor = Color.FromArgb(255, 255, 255)

        ToolStripButton5.Font = selectedButtonFont

        ToolStripButton0.Font = unselectedButtonFont
        ToolStripButton1.Font = unselectedButtonFont
        ToolStripButton2.Font = unselectedButtonFont
        ToolStripButton3.Font = unselectedButtonFont
        ToolStripButton4.Font = unselectedButtonFont

        Panel1.PerformLayout()

    End Sub

    Private Sub MDIPrimaryForm_TextChanged(sender As Object, e As EventArgs) Handles MyBase.TextChanged

        CenterMe()

    End Sub

    Delegate Sub HelloDelegate(ByVal s As String)

    Sub SayHello(ByVal s As String)
        Console.WriteLine("Hello, " & s)
    End Sub

    Dim hello As HelloDelegate = AddressOf SayHello

    'Private Sub Button1_Click(sender As Object, e As EventArgs) Handles Button1.Click
    '    hello("Hello to you")
    'End Sub

    Private Sub dgvLeavePending_CellClick(sender As Object, e As DataGridViewCellEventArgs) Handles dgvLeavePending.CellClick

    End Sub

    Private Sub dgvLeavePending_CellContentClick(sender As Object, e As DataGridViewCellEventArgs) Handles dgvLeavePending.CellContentClick

    End Sub

    Private Sub dgvLeavePending_CellContentDoubleClick(sender As Object, e As DataGridViewCellEventArgs) Handles dgvLeavePending.CellContentDoubleClick

        'If dgvLeavePending.RowCount <> 0 Then
        '    'EditToolStripMenuItem_Click(sender, e)
        'Else
        '    'AddToolStripMenuItem_Click(sender, e)
        'End If

    End Sub

    Private Sub dgvLeavePending_DoubleClick(sender As Object, e As EventArgs) Handles dgvLeavePending.DoubleClick

    End Sub

    Sub LockTime()
        Timer2.Stop()
        bgDashBoardReloader.CancelAsync()
        Timer2.Enabled = False
    End Sub

    Sub UnlockTime()

        Timer2.Enabled = True

        Timer2.Start()

        Static once As SByte = 0

        If once = 0 Then

            once = 1

            Timer2_Tick(Timer2, New EventArgs)
        Else

            If isHome = 0 Then
                isHome = 1

                Timer2_Tick(Timer2, New EventArgs)

            End If

        End If

    End Sub

    Private Sub Timer2_Tick(ByVal sender As Object, ByVal e As System.EventArgs) 'Handles Timer2.Tick

        TimeTick += 1

        If TimeTick = 1 Then ' the timer now succeeds 60 seconds

            TimeTick = 0

            LockTime()

            If bgDashBoardReloader.IsBusy = False Then

                dgvAge21Depen.Enabled = False

                dgvBDayCeleb.Enabled = False

                dgvEvaluateProbat.Enabled = False

                dgvRegularization.Enabled = False

                dgvEvaluationRegular.Enabled = False

                dgvLeavePending.Enabled = False

                dgvLoanBalance.Enabled = False

                dgvOBPending.Enabled = False

                dgvOTPending.Enabled = False

                bgDashBoardReloader.RunWorkerAsync()

            End If

        End If

    End Sub

    Dim n_bgwAge21Dependents = Nothing

    Dim n_bgwBDayCelebrant = Nothing

    Dim n_bgwForEvaluation = Nothing

    Dim n_bgwForRegularization = Nothing

    Dim n_bgwForEvaluationRegular = Nothing

    Dim n_bgwLeavePending = Nothing

    Dim n_bgwOBPending = Nothing

    Dim n_bgwOTPending = Nothing

    Dim n_bgwLoanBalances = Nothing

    Dim n_bgwNegaPaySlips = Nothing

    Dim n_bgwLackRequirements = Nothing

    Private Sub bgDashBoardReloader_DoWork(sender As Object, e As System.ComponentModel.DoWorkEventArgs) Handles bgDashBoardReloader.DoWork
        backgroundworking = 1

        'Static once As SByte = 0

        'If once = 0 Then

        'End If

        Dim params(0, 1) As Object

        params(0, 0) = "OrganizID"

        params(0, 1) = org_rowid

        n_bgwAge21Dependents = New DashBoardDataExtractor(params,
                                                          "DBoard_Age21Dependents").getDataTable

        'n_bgwAge21Dependents = n_bgwAge21Dependents.getDataTable

        n_bgwBDayCelebrant = New DashBoardDataExtractor(params,
                                                        "DBoard_BirthdayCelebrantThisMonth").getDataTable

        'n_bgwBDayCelebrant = n_bgwBDayCelebrant.getDataTable

        n_bgwForEvaluation = New DashBoardDataExtractor(params,
                                                        "DBoard_ForEvaluation").getDataTable

        'n_bgwForEvaluation = n_bgwForEvaluation.getDataTable

        n_bgwForRegularization = New DashBoardDataExtractor(params,
                                                        "DBoard_ForRegularization").getDataTable

        'n_bgwForRegularization = n_bgwForRegularization.getDataTable

        n_bgwForEvaluationRegular = New DashBoardDataExtractor(params,
                                                        "DBoard_ForEvaluationRegular").getDataTable

        'n_bgwForEvaluationRegular = n_bgwForEvaluationRegular.getDataTable

        n_bgwLeavePending = New DashBoardDataExtractor(params,
                                                        "DBoard_LeavePending").getDataTable

        'n_bgwLeavePending = n_bgwLeavePending.getDataTable

        n_bgwOBPending = New DashBoardDataExtractor(params,
                                                        "DBoard_OBPending").getDataTable

        'n_bgwOBPending = n_bgwOBPending.getDataTable

        n_bgwOTPending = New DashBoardDataExtractor(params,
                                                        "DBoard_OTPending").getDataTable

        'n_bgwOTPending = n_bgwOTPending.getDataTable

        n_bgwLoanBalances = New DashBoardDataExtractor(params,
                                                        "DBoard_LoanBalances").getDataTable

        'n_bgwLoanBalances = n_bgwLoanBalances.getDataTable

        n_bgwNegaPaySlips = New DashBoardDataExtractor(params,
                                                        "DBoard_NegativePaySlips").getDataTable

        'n_bgwNegaPaySlips = n_bgwNegaPaySlips.getDataTable

        n_bgwLackRequirements = New DashBoardDataExtractor(params,
                                                        "DBoard_EmployeeLackRequirements").getDataTable

        'n_bgwLackRequirements = n_bgwLackRequirements.getDataTable

        Dim n_ExecuteQuery As _
            New ExecuteQuery("CALL INCREASE_employee_leave_TwoToFiveYearService('" & org_rowid & "');")

        n_ExecuteQuery =
            New ExecuteQuery("CALL INCREASE_employee_leave_FiveToTenYearService('" & org_rowid & "');")

        n_ExecuteQuery =
            New ExecuteQuery("CALL INCREASE_employee_leave_TenToFifteenYearService('" & org_rowid & "');")

    End Sub

    Private Sub bgDashBoardReloader_ProgressChanged(sender As Object, e As System.ComponentModel.ProgressChangedEventArgs) Handles bgDashBoardReloader.ProgressChanged

    End Sub

    Private Sub bgDashBoardReloader_RunWorkerCompleted(sender As Object, e As System.ComponentModel.RunWorkerCompletedEventArgs) Handles bgDashBoardReloader.RunWorkerCompleted

        If e.Error IsNot Nothing Then
            MsgBox("Error: " & vbNewLine & e.Error.Message)
            'MessageBox.Show
        ElseIf e.Cancelled Then
            MsgBox("Background work cancelled.",
                   MsgBoxStyle.Exclamation)
        Else

        End If

        UnlockTime()

        Static once As SByte = 0

        Dim dattbl = InstantiateDatatable(n_bgwAge21Dependents)

        PopulateDGVwithDatTbl(dgvAge21Depen,
                              dattbl)

        dattbl = InstantiateDatatable(n_bgwBDayCelebrant)

        PopulateDGVwithDatTbl(dgvBDayCeleb,
                              dattbl)

        dattbl = InstantiateDatatable(n_bgwForEvaluation)

        PopulateDGVwithDatTbl(dgvEvaluateProbat,
                              dattbl)

        dattbl = InstantiateDatatable(n_bgwForRegularization)

        PopulateDGVwithDatTbl(dgvRegularization,
                              dattbl)

        dattbl = InstantiateDatatable(n_bgwForEvaluationRegular)

        PopulateDGVwithDatTbl(dgvEvaluationRegular,
                              dattbl)

        dattbl = InstantiateDatatable(n_bgwLeavePending)

        PopulateDGVwithDatTbl(dgvLeavePending,
                              dattbl)

        dattbl = InstantiateDatatable(n_bgwLoanBalances)

        PopulateDGVwithDatTbl(dgvLoanBalance,
                              dattbl)

        dattbl = InstantiateDatatable(n_bgwOBPending)

        PopulateDGVwithDatTbl(dgvOBPending,
                              dattbl)

        dattbl = InstantiateDatatable(n_bgwOTPending)

        PopulateDGVwithDatTbl(dgvOTPending,
                              dattbl)

        dattbl = InstantiateDatatable(n_bgwNegaPaySlips)

        PopulateDGVwithDatTbl(dgvnegaPaySlip,
                              dattbl)

        dattbl = InstantiateDatatable(n_bgwLackRequirements)

        PopulateDGVwithDatTbl(dgvLackRequirements,
                              dattbl)

        dgvAge21Depen.Enabled = True

        dgvBDayCeleb.Enabled = True

        dgvEvaluateProbat.Enabled = True

        dgvRegularization.Enabled = True

        dgvEvaluationRegular.Enabled = True

        dgvLeavePending.Enabled = True

        dgvLoanBalance.Enabled = True

        dgvOBPending.Enabled = True

        dgvOTPending.Enabled = True

        dgvnegaPaySlip.Enabled = True

        dgvLackRequirements.Enabled = True

        If once = 0 Then

            once = 1

            'For Each ctrl As Control In Panel8.Controls

            '    If TypeOf ctrl Is CollapsibleGroupBox Then

            '        Dim obj = DirectCast(ctrl, CollapsibleGroupBox)

            '        obj.ToggleCollapsed()

            '    Else
            '        Continue For
            '    End If

            'Next

            Panel8.PerformLayout()

            'For Each ctrl As Control In Panel9.Controls

            '    If TypeOf ctrl Is CollapsibleGroupBox Then

            '        Dim obj = DirectCast(ctrl, CollapsibleGroupBox)

            '        obj.ToggleCollapsed()

            '    Else
            '        Continue For
            '    End If

            'Next

            Panel9.PerformLayout()

            AddHandler NotifyIcon1.DoubleClick, AddressOf NotifyIcon1_Click
        Else

            NotifyIcon1.Visible = True

            NotifyIcon1.ShowBalloonTip(30000)

        End If

        backgroundworking = 0

        LoginForm.Hide()

    End Sub

    Private Sub NotifyIcon1_Click(sender As Object, e As EventArgs)

        ToolStripButton0_Click(sender, e)

    End Sub

    Private Sub ctmenLeave_Opening(sender As Object, e As System.ComponentModel.CancelEventArgs) Handles ctmenLeave.Opening

        If dgvLeavePending.RowCount <> 0 Then

            EditToolStripMenuItem.Enabled = True
        Else

            EditToolStripMenuItem.Enabled = False

        End If
        '
    End Sub

    Private Sub EditToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles EditToolStripMenuItem.Click

        EditToolStripMenuItem.Enabled = False

        Dim n_LeaveForm As New LeaveForm

        With n_LeaveForm

            .LeaveRowID = dgvLeavePending.CurrentRow.Cells("LvRowID").Value

            .Show()

        End With

        EditToolStripMenuItem.Enabled = True

    End Sub

    Private Sub AddToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles AddToolStripMenuItem.Click

        AddToolStripMenuItem.Enabled = False

        Dim n_LeaveForm As New LeaveForm

        With n_LeaveForm

            '.LeaveRowID = dgvLeavePending.CurrentRow.Cells("").Value

            .Show()

        End With

        AddToolStripMenuItem.Enabled = True

    End Sub

    Private Sub CollapsibleGroupBox_DoubleClick(sender As Object, e As EventArgs) Handles CollapsibleGroupBox1.DoubleClick ', _
        'CollapsibleGroupBox2.DoubleClick, _
        'CollapsibleGroupBox3.DoubleClick, _
        'CollapsibleGroupBox4.DoubleClick, _
        'CollapsibleGroupBox5.DoubleClick, _
        'CollapsibleGroupBox6.DoubleClick

        'Dim catchSender As New CollapsibleGroupBox

        'catchSender = DirectCast(sender, CollapsibleGroupBox)

        'CollapsibleGroupBox1.ToggleCollapsed()

    End Sub

    Private Sub CollapsibleGroupBox2_DoubleClick(sender As Object, e As EventArgs) Handles CollapsibleGroupBox2.DoubleClick
        'CollapsibleGroupBox2.ToggleCollapsed()
    End Sub

    Private Sub CollapsibleGroupBox3_DoubleClick(sender As Object, e As EventArgs) Handles CollapsibleGroupBox3.DoubleClick
        'CollapsibleGroupBox3.ToggleCollapsed()
    End Sub

    Private Sub CollapsibleGroupBox4_DoubleClick(sender As Object, e As EventArgs) Handles CollapsibleGroupBox4.DoubleClick
        'CollapsibleGroupBox4.ToggleCollapsed()
    End Sub

    Private Sub CollapsibleGroupBox5_DoubleClick(sender As Object, e As EventArgs) Handles CollapsibleGroupBox5.DoubleClick
        'CollapsibleGroupBox5.ToggleCollapsed()
    End Sub

    Private Sub CollapsibleGroupBox6_DoubleClick(sender As Object, e As EventArgs) Handles CollapsibleGroupBox6.DoubleClick
        'CollapsibleGroupBox6.ToggleCollapsed()
    End Sub

    Private Sub Panel10_Paint(sender As Object, e As PaintEventArgs) Handles Panel10.Paint

    End Sub

    Private Sub SplitContainer1_Panel1_Paint(sender As Object, e As PaintEventArgs) Handles SplitContainer1.Panel1.Paint

    End Sub

    Protected Overrides Sub OnActivated(e As EventArgs)

        MyBase.OnActivated(e)

    End Sub

    Protected Overrides Sub OnDeactivate(e As EventArgs)

        MyBase.OnDeactivate(e)

    End Sub

    Private Sub Panel9_Paint(sender As Object, e As PaintEventArgs) Handles Panel9.Paint

    End Sub

    Dim bgwork_errormsg As String = String.Empty

    Private Sub maintslabel_TextChanged(sender As Object, e As EventArgs) Handles maintslabel.TextChanged

    End Sub

    Sub CaptionMainFormStatus(str_caption As String)
        maintslabel.Text = str_caption

        maintslabel.Visible = (maintslabel.Text.Length > 0)

    End Sub

    Private Sub LoadVersionNo()

        Dim n_aboutversion As New AboutAndVersion
        Dim version_code As String = n_aboutversion.VersionCode
        tslblVersion.Text = String.Concat("version ", version_code)

    End Sub

End Class

Public Class DashBoardDataExtractor

    Dim datatab As New DataTable

    Sub New(Optional ParamsCollection As Array = Nothing,
            Optional ProcedureName As String = Nothing)

        'Dim n_callProcAsDatTable As New callProcAsDatTable

        'datatab = New DataTable

        datatab = callProcAsDatTbl(ParamsCollection,
                                   ProcedureName)

    End Sub

    Public ReadOnly Property getDataTable As DataTable

        Get
            Return datatab

        End Get

    End Property

    Function callProcAsDatTbl(Optional ParamsCollection As Array = Nothing,
                                      Optional ProcedureName As String = Nothing) As Object

        Dim returnvalue = Nothing

        Dim mysqlda As New MySqlDataAdapter()

        Dim new_conn As New MySqlConnection

        new_conn.ConnectionString = db_connectinstring

        Try

            If new_conn.State = ConnectionState.Open Then : new_conn.Close() : End If

            new_conn.Open()

            Dim ds As New DataSet()

            With mysqlda

                .SelectCommand = New MySqlCommand(ProcedureName, new_conn)

                .SelectCommand.CommandType = CommandType.StoredProcedure

                .SelectCommand.Parameters.Clear()

                For e = 0 To ParamsCollection.GetUpperBound(0) ' - 1

                    Dim paramName As String = ParamsCollection(e, 0)

                    Dim paramVal As Object = ParamsCollection(e, 1)

                    .SelectCommand.Parameters.AddWithValue(paramName, paramVal)

                Next

                .Fill(ds, "Table0")

            End With

            Dim dt As DataTable = ds.Tables("Table0")

            returnvalue = dt

            hasERR = 0
        Catch ex As Exception
            hasERR = 1

            MsgBox(getErrExcptn(ex, ProcedureName), MsgBoxStyle.Critical)

            returnvalue = Nothing
        Finally

            mysqlda.Dispose()

            new_conn.Close()

            new_conn.Dispose()

        End Try

        Return returnvalue

    End Function

End Class

Public Class UserLog

    Dim syslogViewID = Nothing

    Sub New()
        syslogViewID = EXECQUER("SELECT RowID FROM `view` WHERE ViewName='Login Form' AND OrganizationID='" & org_rowid & "';")

    End Sub

    Sub Inn()

        INS_audittrail("System Log",
                       "",
                       "IN",
                       "",
                       "Log")

    End Sub

    Sub Out()

        EXECQUER("UPDATE `audittrail`" &
                 " SET NewValue='OUT'" &
                 " WHERE CreatedBy='" & user_row_id & "'" &
                 " AND OrganizationID='" & org_rowid & "'" &
                 " AND NewValue=''" &
                 " AND ViewID='" & syslogViewID & "';")

    End Sub

    Sub INS_audittrail(Optional au_FieldChanged = Nothing,
                       Optional au_ChangedRowID = Nothing,
                       Optional au_OldValue = Nothing,
                       Optional au_NewValue = Nothing,
                       Optional au_ActionPerformed = Nothing)

        Try
            If conn.State = ConnectionState.Open Then : conn.Close() : End If

            cmd = New MySqlCommand("INS_audittrail", conn)

            conn.Open()

            With cmd
                .Parameters.Clear()

                .CommandType = CommandType.StoredProcedure

                .Parameters.AddWithValue("au_CreatedBy", user_row_id)

                .Parameters.AddWithValue("au_LastUpdBy", user_row_id)

                .Parameters.AddWithValue("au_OrganizationID", org_rowid)

                .Parameters.AddWithValue("au_ViewID", syslogViewID)

                .Parameters.AddWithValue("au_FieldChanged", Trim(au_FieldChanged))

                .Parameters.AddWithValue("au_ChangedRowID", au_ChangedRowID)

                .Parameters.AddWithValue("au_OldValue", Trim(au_OldValue))

                .Parameters.AddWithValue("au_NewValue", Trim(au_NewValue))

                .Parameters.AddWithValue("au_ActionPerformed", Trim(au_ActionPerformed))

                Dim datread As MySqlDataReader

                datread = .ExecuteReader()

            End With
        Catch ex As Exception
            MsgBox(ex.Message & " " & "INS_audittrail", , "Error")
        Finally
            conn.Close()
            cmd.Dispose()

        End Try

    End Sub

End Class