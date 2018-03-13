Imports MySql.Data.MySqlClient

Public Class EmployeeShiftEntryForm
    Dim IsNew As Integer = 0
    Dim rowid As Integer

    Private Sub fillemplyeelist()
        'If dgvEmplist.Rows.Count = 0 Then
        'ElseCOALESCE(StreetAddress1,' ')
        Dim dt As New DataTable

        If TextBox4.Text.Trim.Length = 0 Then

            dt = getDataTableForSQL("Select concat(COALESCE(Lastname, ' '),' ', COALESCE(Firstname, ' '), ' ', COALESCE(MiddleName, ' ')) as name, EmployeeID, RowID from employee where organizationID = '" & z_OrganizationID & "' ORDER BY RowID DESC;")

        Else

            dt = getDataTableForSQL("Select concat(COALESCE(Lastname, ' '),' ', COALESCE(Firstname, ' '), ' ', COALESCE(MiddleName, ' ')) as name" & _
                                    ", EmployeeID" & _
                                    ", RowID" & _
                                    " from employee" & _
                                    " where organizationID = '" & z_OrganizationID & "'" & _
                                    " AND EmployeeID = '" & TextBox4.Text & "'" & _
                                    " ORDER BY RowID DESC;")

        End If

        dgvEmpList.Rows.Clear()
        For Each drow As DataRow In dt.Rows
            Dim n As Integer = dgvEmpList.Rows.Add()
            With drow

                dgvEmpList.Rows.Item(n).Cells(c_EmployeeID.Index).Value = .Item("EmployeeID").ToString
                'txtempid.Text = .Item("EmployeeID").ToString
                dgvEmpList.Rows.Item(n).Cells(c_EmployeeName.Index).Value = .Item("Name").ToString
                dgvEmpList.Rows.Item(n).Cells(c_ID.Index).Value = .Item("RowID").ToString
            End With
        Next
        'End If

    End Sub

    Dim currentselectedEmpRowID = Nothing

    Private Sub fillemplyeelistselected()
        'If dgvEmplist.Rows.Count = 0 Then
        'ElseCOALESCE(StreetAddress1,' ')

        currentselectedEmpRowID = dgvEmpList.CurrentRow.Cells(c_ID.Index).Value

        Dim dt As New DataTable
        dt = getDataTableForSQL("Select concat(COALESCE(Lastname, ' '),' ', COALESCE(Firstname, ' '), ' ', COALESCE(MiddleName, ' ')) as name, EmployeeID, RowID from employee where organizationID = '" & z_OrganizationID & "' And RowID = '" & dgvEmpList.CurrentRow.Cells(c_ID.Index).Value & "'")

        For Each drow As DataRow In dt.Rows

            With drow

                txtEmpID.Text = .Item("EmployeeID").ToString
                'txtempid.Text = .Item("EmployeeID").ToString
                txtEmpName.Text = .Item("Name").ToString
                rowid = .Item("RowID").ToString
            End With
        Next
        'End If

    End Sub

    Private Sub fillemployeeshift()

        'Dim new_link = New System.Windows.Forms.LinkLabel.Link()

        'new_link.Name = "First"

        'Link_Paging(First, New LinkLabelLinkClickedEventArgs(new_link))

        If Not dgvEmpList.Rows.Count = 0 Then
            'If dgvEmpList.Rows.Count = -1 Then
            Dim dt As New DataTable
            dt = getDataTableForSQL("select concat(COALESCE(ee.Lastname, ' '),' ', COALESCE(ee.Firstname, ' '), ' ', COALESCE(ee.MiddleName, ' ')) as name, " & _
                                    "ee.EmployeeID, es.EffectiveFrom, es.EffectiveTo, COALESCE(TIME_FORMAT(s.TimeFrom, '%h:%i:%s %p'),'') timef, COALESCE(TIME_FORMAT(s.TimeTo, '%h:%i:%s %p'),'') timet, es.RowID from employeeshift es " & _
                                    "left join shift s on es.ShiftID = s.RowID " & _
                                    "inner join employee ee on es.EmployeeID = ee.RowID " & _
                                    "where es.OrganizationID = '" & z_OrganizationID & "' And ee.RowID = '" & dgvEmpList.CurrentRow.Cells(c_ID.Index).Value & "'" & _
                                    " ORDER BY es.EffectiveFrom, es.EffectiveTo" &
                                    " LIMIT " & pagenumber & ",20;")
            dgvEmpShiftList.Rows.Clear()
            For Each drow As DataRow In dt.Rows
                Dim n As Integer = dgvEmpShiftList.Rows.Add()
                With drow
                    dgvEmpShiftList.Rows.Item(n).Cells(c_empIDShift.Index).Value = .Item("EmployeeID").ToString
                    dgvEmpShiftList.Rows.Item(n).Cells(c_EmpnameShift.Index).Value = .Item("Name").ToString
                    dgvEmpShiftList.Rows.Item(n).Cells(c_TimeFrom.Index).Value = .Item("timef").ToString
                    dgvEmpShiftList.Rows.Item(n).Cells(c_TimeTo.Index).Value = .Item("timet").ToString
                    dgvEmpShiftList.Rows.Item(n).Cells(c_DateFrom.Index).Value = CDate(.Item("EffectiveFrom")).ToString("MM/dd/yyyy")
                    dgvEmpShiftList.Rows.Item(n).Cells(c_DateTo.Index).Value = CDate(.Item("Effectiveto")).ToString("MM/dd/yyyy")
                    dgvEmpShiftList.Rows.Item(n).Cells(c_RowIDShift.Index).Value = .Item("RowID").ToString
                End With
            Next
        End If




    End Sub

    Private Sub fillemployeeshiftSelected()

        cboshiftlist.SelectedIndex = -1

        cboshiftlist.Text = ""

        If Not dgvEmpShiftList.Rows.Count = 0 Then
            Dim dt As New DataTable
            '",DATE_FORMAT(es.EffectiveFrom,'%c/%e/%Y') 'EffectiveFrom'" &
            '",DATE_FORMAT(es.EffectiveTo,'%c/%e/%Y') AS EffectiveTo" &
            dt = getDataTableForSQL("select concat(COALESCE(ee.Lastname, ' '),' ', COALESCE(ee.Firstname, ' '), ' ', COALESCE(ee.MiddleName, ' ')) as name" & _
                                    ",ee.EmployeeID" &
                                    ",es.EffectiveFrom" &
                                    ",es.EffectiveTo" &
                                    ",COALESCE(es.ShiftID,'') 'ShiftID'" &
                                    ",es.ShiftID AS ShiftRowID" &
                                    ",es.NightShift, es.RestDay" &
                                    ",IFNULL(TIME_FORMAT(s.TimeFrom, '%l:%i %p'),'') timef" &
                                    ",IFNULL(TIME_FORMAT(s.TimeTo, '%l:%i %p'),'') timet" &
                                    ",s.RowID AS ShiftRowID" &
                                    ",es.RowID from employeeshift es " & _
                                    "left join shift s on es.ShiftID = s.RowID " & _
                                    "inner join employee ee on es.EmployeeID = ee.RowID " & _
                                    "where es.OrganizationID = '" & z_OrganizationID & "' And es.RowID = '" & dgvEmpShiftList.CurrentRow.Cells(c_RowIDShift.Index).Value & "'")

            '",IF(s.TimeFrom IS NULL,'',TIMESTAMP(CONCAT(CURDATE(),' ',s.TimeFrom))) AS  timef" &
            '",IF(s.TimeTo IS NULL,'',TIMESTAMP(CONCAT(CURDATE(),' ',s.TimeTo))) AS  timef" &
            For Each drow As DataRow In dt.Rows
                'Dim timefrom, timeto As DateTime

                With drow

                    txtEmpID.Text = .Item("EmployeeID").ToString
                    txtEmpName.Text = .Item("Name").ToString
                    
                    Try
                        'cboshiftlist.Text = Format(CDate(.Item("timef")), "h:mm tt") & " TO " & Format(CDate(.Item("timet")), "h:mm tt")
                        If IsDBNull(.Item("ShiftRowID")) Then
                            cboshiftlist.SelectedIndex = -1
                            cboshiftlist.Text = String.Empty
                        Else
                            cboshiftlist.Text = .Item("timef") & " TO " & .Item("timet")
                        End If
                    Catch ex As Exception
                        cboshiftlist.SelectedIndex = -1
                        cboshiftlist.Text = String.Empty
                    End Try

                    'dtpTimeFrom.Text = .Item("timef").ToString
                    'dtpTimeTo.Text = .Item("timet").ToString
                    Try
                        dtpDateFrom.Value = .Item("EffectiveFrom") 'CDate(.Item("EffectiveFrom")).ToString(machineShortDateFormat)

                        dtpDateTo.Value = .Item("Effectiveto") 'CDate(.Item("Effectiveto")).ToString(machineShortDateFormat)

                    Catch ex As Exception
                        MsgBox(getErrExcptn(ex, Me.Name))

                    End Try

                    lblShiftID.Text = .Item("ShiftID").ToString
                    chkNightShift.Checked = IIf(If(IsDBNull(.Item("NightShift")), 0, .Item("NightShift")) = "1", True, False)

                    If IsDBNull(.Item("RestDay")) Then
                        chkrestday.Checked = False
                    Else
                        chkrestday.Checked = If(.Item("RestDay") = 1, True, False)
                    End If

                End With
            Next
        End If

    End Sub

    Private Sub EmployeeShiftEntryForm_FormClosing(sender As Object, e As FormClosingEventArgs) Handles Me.FormClosing

        myBalloon(, , lblSaveMsg, , , 1)

        If previousForm IsNot Nothing Then
            If previousForm.Name = Me.Name Then
                previousForm = Nothing
            End If
        End If

        dutyshift.Close()

        TimeAttendForm.listTimeAttendForm.Remove(Me.Name)
    End Sub

    Dim view_ID As Integer = Nothing

    Private Sub ShiftEntryForm_Load(sender As Object, e As EventArgs) Handles Me.Load
        fillemplyeelist()
        fillemployeeshift()
        fillemployeeshiftSelected()

        If dgvEmpList.RowCount <> 0 Then
            Dim dgvceleventarg As New DataGridViewCellEventArgs(c_EmployeeID.Index, 0)
            dgvEmpList_CellClick(sender, dgvceleventarg)
        End If

        'cboshiftlist.ContextMenu = New ContextMenu

        enlistToCboBox("SELECT CONCAT(TIME_FORMAT(TimeFrom,'%l:%i %p'), ' TO ', TIME_FORMAT(TimeTo,'%l:%i %p')) FROM shift WHERE OrganizationID='" & org_rowid & "' ORDER BY TimeFrom,TimeTo;", _
                       cboshiftlist)

        view_ID = VIEW_privilege("Employee Shift", org_rowid)

        Dim formuserprivilege = position_view_table.Select("ViewID = " & view_ID)

        If formuserprivilege.Count = 0 Then

            btnNew.Visible = 0
            btnSave.Visible = 0
            btnDelete.Visible = 0

        Else
            For Each drow In formuserprivilege
                If drow("ReadOnly").ToString = "Y" Then
                    'ToolStripButton2.Visible = 0
                    btnNew.Visible = 0
                    btnSave.Visible = 0
                    btnDelete.Visible = 0
                    dontUpdate = 1
                    Exit For
                Else
                    If drow("Creates").ToString = "N" Then
                        btnNew.Visible = 0
                    Else
                        btnNew.Visible = 1
                    End If

                    If drow("Deleting").ToString = "N" Then
                        btnDelete.Visible = 0
                    Else
                        btnDelete.Visible = 1
                    End If

                    If drow("Updates").ToString = "N" Then
                        dontUpdate = 1
                    Else
                        dontUpdate = 0
                    End If

                End If

            Next

        End If

    End Sub

    Private Sub btnClose_Click(sender As Object, e As EventArgs) Handles btnClose.Click
        Me.Close()

    End Sub

    Private Sub dgvEmpList_CellContentClick(sender As Object, e As DataGridViewCellEventArgs) Handles dgvEmpList.CellContentClick

    End Sub

    Dim lnk As LinkLabel.Link

    Private Sub dgvEmpList_CellClick(sender As Object, e As DataGridViewCellEventArgs) Handles dgvEmpList.CellClick

        chkNightShift.Checked = False

        chkrestday.Checked = False

        IsNew = 0

        Try
            fillemplyeelistselected()

            lnk = New LinkLabel.Link

            lnk.Name = "First"

            Link_Paging(First, New LinkLabelLinkClickedEventArgs(lnk))

            fillemployeeshiftSelected()
        Catch ex As Exception

            MsgBox(getErrExcptn(ex, Me.Name))

        End Try
    End Sub

    Private Sub dgvEmpShiftList_CellContentClick(sender As Object, e As DataGridViewCellEventArgs) Handles dgvEmpShiftList.CellContentClick

    End Sub

    Private Sub dgvEmpShiftList_CellClick(sender As Object, e As DataGridViewCellEventArgs) Handles dgvEmpShiftList.CellClick
        Try

            fillemployeeshiftSelected()
            btnDelete.Enabled = True
        Catch ex As Exception

        End Try
    End Sub

    Private Sub btnNew_Click(sender As Object, e As EventArgs) Handles btnNew.Click
        IsNew = 1
        lblShiftID.Text = 0
        dgvEmpList.Enabled = False
        dtpDateFrom.Value = Date.Now.ToString("MM/dd/yyyy")
        dtpDateTo.Value = Date.Now.ToString("MM/dd/yyyy")
        btnNew.Enabled = False

        chkNightShift.Checked = False

        chkrestday.Checked = False


        If dgvEmpList.RowCount <> 0 Then

            Dim empshiftmaxdate = _
                EXECQUER("SELECT IFNULL(ADDDATE(MAX(EffectiveTo), INTERVAL 1 DAY),'') 'empshiftmaxdate'" & _
                         " FROM employeeshift" & _
                         " WHERE EmployeeID=" & dgvEmpList.CurrentRow.Cells("c_ID").Value & _
                         " AND RestDay='0'" & _
                         " LIMIT 1;")


            If empshiftmaxdate = Nothing Then
                empshiftmaxdate = _
                EXECQUER("SELECT IFNULL(StartDate,CURRENT_DATE()) 'StartDate'" & _
                         " FROM employee" & _
                         " WHERE RowID='" & dgvEmpList.CurrentRow.Cells("c_ID").Value & _
                         "';")

                dtpDateFrom.MinDate = CDate(empshiftmaxdate).ToShortDateString

                'Else
                '    dtpDateFrom.MinDate = CDate(empshiftmaxdate).ToShortDateString

            End If

            Try
                dtpDateFrom.Value = CDate(empshiftmaxdate).ToShortDateString
            Catch ex As Exception
                Try
                    dtpDateFrom.Value = Date.Now.ToString("MM/dd/yyyy")
                Catch ex1 As Exception
                    dtpDateFrom.Value = dtpDateFrom.MinDate.ToShortDateString
                End Try
            End Try

        End If

    End Sub

    Dim dontUpdate As SByte = 0

    Public dutyShiftRowID As Integer = Nothing

    Private Sub btnSave_Click(sender As Object, e As EventArgs) Handles btnSave.Click

        If dgvEmpList.RowCount = 0 Then
            Exit Sub
        End If

        Dim shiftRowID = EXECQUER("SELECT RowID" & _
                                  " FROM shift" & _
                                  " WHERE CONCAT(TIME_FORMAT(TimeFrom,'%l:%i %p'), ' TO ', TIME_FORMAT(TimeTo,'%l:%i %p'))='" & cboshiftlist.Text & "'" & _
                                  " AND OrganizationID=" & org_rowid & ";")

        shiftRowID = If(shiftRowID.ToString.Length = 0, 0, shiftRowID)

        If chkrestday.Checked = 0 Then

            Dim dt As New DataTable
            dt = getDataTableForSQL("Select * From employeeshift where " & _
                                    " EmployeeID = '" & dgvEmpList.CurrentRow.Cells(c_ID.Index).Value & "' And OrganizationID = '" & z_OrganizationID & "'")

            For Each drow As DataRow In dt.Rows
                With drow
                    Dim startdate, enddate As Date
                    startdate = CDate(.Item("EffectiveFrom")).ToString("MM/dd/yyyy")
                    enddate = CDate(.Item("EffectiveTo")).ToString("MM/dd/yyyy")

                    Dim sdate, edate As Date

                    sdate = dtpDateFrom.Value.ToString("MM/dd/yyyy")
                    edate = dtpDateTo.Value.ToString("MM/dd/yyyy")

                    If sdate > startdate And edate < enddate Then
                        MsgBox("Date between " & startdate & " to " & edate & " is not allowed", MsgBoxStyle.Exclamation, "System Message.")
                        Exit Sub
                    End If

                End With

            Next

        End If

        If shiftRowID = 0 And chkrestday.Checked = False Then
            MsgBox("Please select a shift.", MsgBoxStyle.Exclamation, "System Message.")
            cboshiftlist.Focus()
            Exit Sub
        Else
            'lblShiftID.Text = 0
        End If

        Dim nightshift As Integer
        If chkNightShift.Checked = True Then
            nightshift = 1
        Else
            nightshift = 0
        End If

        Dim isrestday = If(chkrestday.Checked, "1", "0")

        If IsNew = 1 Then
            '                                                                                                                                                                 'Val(lblShiftID.Text)
            sp_employeeshiftentry(z_datetime, user_row_id, z_datetime, z_OrganizationID, user_row_id, dtpDateFrom.Value, dtpDateTo.Value, dgvEmpList.CurrentRow.Cells(c_ID.Index).Value, shiftRowID, nightshift, isrestday)


            dtpDateFrom.MinDate = CDate("1/1/1753").ToShortDateString

            dtpDateTo.MinDate = CDate("1/1/1753").ToShortDateString

            fillemployeeshift()

            fillemployeeshiftSelected()

            myBalloon("Successfully Save", "Saving...", lblSaveMsg, , -100)

        Else
            If dontUpdate = 1 Then
                Exit Sub
            ElseIf dgvEmpShiftList.RowCount = 0 Then
                Exit Sub
            End If
            '                                                                                            'Val(lblShiftID.Text)
            DirectCommand("UPDATE employeeshift SET lastupd = '" & z_datetime & "', " & _
                          "lastupdby = '" & user_row_id & "', EffectiveFrom = '" & dtpDateFrom.Value.ToString("yyyy-MM-dd") & "', " & _
                          "EffectiveTo = '" & dtpDateTo.Value.ToString("yyyy-MM-dd") & "', ShiftID = '" & shiftRowID & "', NightShift = '" & nightshift & "' " & _
                          ", RestDay = '" & isrestday & "' " & _
                          "Where RowID = '" & dgvEmpShiftList.CurrentRow.Cells(c_RowIDShift.Index).Value & "'")

            dtpDateFrom.MinDate = CDate("1/1/1753").ToShortDateString

            dtpDateTo.MinDate = CDate("1/1/1753").ToShortDateString

            fillemployeeshift()
            fillemployeeshiftSelected()
            myBalloon("Successfully Updated", "Updating...", lblSaveMsg, , -100)
        End If


        IsNew = 0
        lblShiftID.Text = 0
        dgvEmpList.Enabled = True
        btnNew.Enabled = True

        dtpDateFrom.MinDate = CDate("1/1/1753").ToShortDateString

    End Sub

    Private Sub lblShiftEntry_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles lblShiftEntry.LinkClicked
        'ShiftEntryForm.FormBorderStyle = Windows.Forms.FormBorderStyle.FixedDialog
        'ShiftEntryForm.Close()
        'ShiftEntryForm.ShowDialog()

        'dutyshift.Show()
        'dutyshift.BringToFront()

        Dim n_ShiftEntryForm As New ShiftEntryForm

        n_ShiftEntryForm.FormBorderStyle = Windows.Forms.FormBorderStyle.FixedDialog

        n_ShiftEntryForm.StartPosition = FormStartPosition.CenterScreen

        If n_ShiftEntryForm.ShowDialog = Windows.Forms.DialogResult.OK Then

            If n_ShiftEntryForm.ShiftRowID <> Nothing Then

                enlistToCboBox("SELECT CONCAT(TIME_FORMAT(TimeFrom,'%l:%i %p'), ' TO ', TIME_FORMAT(TimeTo,'%l:%i %p'))" & _
                               " FROM shift" & _
                               " WHERE OrganizationID='" & org_rowid & "'" & _
                               " ORDER BY TimeFrom,TimeTo;", _
                               cboshiftlist)

                cboshiftlist.Text = Format(CDate(n_ShiftEntryForm.ShiftTimeFrom), "h:mm tt") & " TO " & Format(CDate(n_ShiftEntryForm.ShiftTimeTo), "h:mm tt")

            End If

        End If

        'Dim newShiftEntryForm As New ShiftEntryForm
        'newShiftEntryForm.ShowDialog()

    End Sub

    Private Sub btnDelete_Click(sender As Object, e As EventArgs) Handles btnDelete.Click
        If dgvEmpShiftList.RowCount <> 0 Then
            btnDelete.Enabled = False

            Dim prompt = MessageBox.Show("Do you want to delete this employee shift ?", "Confirm deleting shift", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question)

            If prompt = Windows.Forms.DialogResult.Yes Then

                EXECQUER("UPDATE employeetimeentry SET EmployeeShiftID=NULL WHERE EmployeeShiftID='" & dgvEmpShiftList.CurrentRow.Cells("c_RowIDShift").Value & "' AND OrganizationID=" & org_rowid & ";" & _
                         "DELETE FROM employeeshift WHERE RowID='" & dgvEmpShiftList.CurrentRow.Cells("c_RowIDShift").Value & "';")

                'Else

                dgvEmpShiftList.Rows.Remove(dgvEmpShiftList.CurrentRow)

                'dgvEmpList_CellClick(sender, New DataGridViewCellEventArgs(c_EmployeeID.Index, dgvEmpList.CurrentRow.Index))

            End If

        End If
        btnDelete.Enabled = True

    End Sub

    Private Sub btnCancel_Click(sender As Object, e As EventArgs) Handles btnCancel.Click
        IsNew = 0
        dgvEmpList.Enabled = 1

        Dim dgvceleventarg As New DataGridViewCellEventArgs(c_EmployeeID.Index, _
                                                            0) 'dgvEmpList.CurrentRow.Index

        If dgvEmpList.RowCount <> 0 Then
            dgvEmpList_CellClick(sender, dgvceleventarg)
        End If

        btnNew.Enabled = True

        dtpDateFrom.MinDate = CDate("1/1/1753").ToShortDateString

    End Sub

    Private Sub btnAudittrail_Click(sender As Object, e As EventArgs) Handles btnAudittrail.Click
        showAuditTrail.Show()

        showAuditTrail.loadAudTrail(view_ID)

        showAuditTrail.BringToFront()

    End Sub

    Private Sub dgvEmpList_GotFocus(sender As Object, e As EventArgs) Handles dgvEmpList.GotFocus
        btnDelete.Enabled = False

    End Sub

    Private Sub dgvEmpShiftList_GotFocus(sender As Object, e As EventArgs) Handles dgvEmpShiftList.GotFocus
        btnDelete.Enabled = True

    End Sub

    Private Sub cboshiftlist_KeyPress(sender As Object, e As KeyPressEventArgs) Handles cboshiftlist.KeyPress
        Dim e_asc As String = Asc(e.KeyChar)

        If chkrestday.Checked Then
            If e_asc = 8 Then
                e.Handled = False
            Else
                e.Handled = True
            End If
        Else
            e.Handled = True
        End If

    End Sub

    Private Sub cboshiftlist_SelectedIndexChanged(sender As Object, e As EventArgs) Handles cboshiftlist.SelectedIndexChanged

    End Sub

    Dim filepath As String = String.Empty

    Private Sub tsbtnImportEmpShift_Click(sender As Object, e As EventArgs) Handles tsbtnImportEmpShift.Click

        Dim browsefile As OpenFileDialog = New OpenFileDialog()

        browsefile.Filter = "Microsoft Excel Workbook Documents 2007-13 (*.xlsx)|*.xlsx|" & _
                                  "Microsoft Excel Documents 97-2003 (*.xls)|*.xls"

        If browsefile.ShowDialog() = Windows.Forms.DialogResult.OK Then

            filepath = IO.Path.GetFullPath(browsefile.FileName)

            Panel1.Enabled = False

            Panel2.Enabled = False

            ToolStripProgressBar1.Visible = True

            MDIPrimaryForm.Showmainbutton.Enabled = False

            Panel2.Enabled = False

            Panel1.Enabled = False

            bgEmpShiftImport.RunWorkerAsync()

        End If

    End Sub

    Private Sub bgEmpShiftImport_DoWork(sender As Object, e As System.ComponentModel.DoWorkEventArgs) Handles bgEmpShiftImport.DoWork

        backgroundworking = 1

        'IMPORT_employeeshift

        'EmployeeID
        'OrganizID
        'CreatedLastUpdBy
        'i_TimeFrom
        'i_TimeTo
        'i_DateFrom
        'i_DateTo

        Dim catchDT = _
                    getWorkBookAsDataSet(filepath, _
                                         Me.Name)

        If catchDT Is Nothing Then

        Else

            'For Each dtbl As DataTable In catchDT.Tables
            '    MsgBox(dtbl.TableName)
            '    'MsgBox(dtbl.Rows.Count)

            '    Dim tblname = dtbl.TableName
            '    '"'Employee DependentsS'"
            '    '"'Employee Salary$'"
            '    'Employees$
            'Next

            'Dim input_box = InputBox("What is the ordinal number of worksheet to be use ?", _
            '                         "Select the worksheet", _
            '                         1)

            'Dim table_name = Nothing

            'If input_box = Nothing Then
            '    table_name = catchDT.Tables(Val(input_box)).Name
            'Else
            '    table_name = catchDT.Tables(Val(input_box)).Name
            'End If

            Dim dtEmpShift = catchDT.Tables("'Employee Shift$'") 'Employee Shift

            If dtEmpShift IsNot Nothing Then

                Dim i = 1

                For Each drow As DataRow In dtEmpShift.Rows

                    Dim time_from = Nothing

                    Try
                        time_from = Format(CDate(drow(1)), "HH:mm")
                    Catch ex As Exception
                        time_from = DBNull.Value
                    End Try

                    Dim time_to = Nothing

                    Try
                        time_to = Format(CDate(drow(2)), "HH:mm")
                    Catch ex As Exception
                        time_to = DBNull.Value
                    End Try

                    IMPORT_employeeshift(drow(0), _
                                         time_from, _
                                         time_to, _
                                         drow(3), _
                                         drow(4), _
                                         drow(5))

                    Dim progressresult = (i / dtEmpShift.Rows.Count) * 100

                    bgEmpShiftImport.ReportProgress(CInt(progressresult))

                    i += 1

                Next

            End If

        End If

        EXECQUER("DELETE FROM shift WHERE OrganizationID='" & org_rowid & "' AND TimeFrom IS NULL AND TimeTo IS NULL;" & _
                 "ALTER TABLE shift AUTO_INCREMENT = 0;")

    End Sub

    Private Sub bgEmpShiftImport_ProgressChanged(sender As Object, e As System.ComponentModel.ProgressChangedEventArgs) Handles bgEmpShiftImport.ProgressChanged
        ToolStripProgressBar1.Value = CType(e.ProgressPercentage, Integer)
    End Sub

    Private Sub bgEmpShiftImport_RunWorkerCompleted(sender As Object, e As System.ComponentModel.RunWorkerCompletedEventArgs) Handles bgEmpShiftImport.RunWorkerCompleted

        If e.Error IsNot Nothing Then
            MessageBox.Show("Error: " & e.Error.Message)
        ElseIf e.Cancelled Then
            MessageBox.Show("Background work cancelled.")
        Else

        End If

        Panel1.Enabled = True

        Panel2.Enabled = True

        ToolStripProgressBar1.Visible = False

        backgroundworking = 0

        enlistToCboBox("SELECT CONCAT(TIME_FORMAT(TimeFrom,'%l:%i %p'), ' TO ', IF(TimeTo IS NULL, '', TIME_FORMAT(TimeTo,'%l:%i %p')))" & _
                       " FROM shift" & _
                       " WHERE OrganizationID='" & org_rowid & "'" & _
                       " ORDER BY TimeFrom,TimeTo;", _
                       cboshiftlist)

        If dgvEmpList.RowCount <> 0 Then
            Dim dgvceleventarg As New DataGridViewCellEventArgs(c_EmployeeID.Index, 0)
            dgvEmpList_CellClick(sender, dgvceleventarg)
        End If

        MDIPrimaryForm.Showmainbutton.Enabled = True

        Panel2.Enabled = True

        Panel1.Enabled = True

    End Sub

    Dim dataread As MySqlDataReader

    Private Sub IMPORT_employeeshift(Optional i_EmployeeID As Object = Nothing, _
                                     Optional i_TimeFrom As Object = Nothing, _
                                     Optional i_TimeTo As Object = Nothing, _
                                     Optional i_DateFrom As Object = Nothing, _
                                     Optional i_DateTo As Object = Nothing, _
                                     Optional i_SchedType As Object = Nothing)

        Try

            If conn.State = ConnectionState.Open Then

                conn.Close()

            End If

            cmd = New MySqlCommand("IMPORT_employeeshift", conn)

            conn.Open()

            With cmd

                .Parameters.Clear()

                .CommandType = CommandType.StoredProcedure

                .Parameters.AddWithValue("i_EmployeeID", i_EmployeeID)

                .Parameters.AddWithValue("OrganizID", org_rowid)

                .Parameters.AddWithValue("CreatedLastUpdBy", user_row_id)

                Dim ii = MilitTime(i_TimeFrom)

                .Parameters.AddWithValue("i_TimeFrom", ii)

                Dim iii = MilitTime(i_TimeTo)

                .Parameters.AddWithValue("i_TimeTo", iii)

                .Parameters.AddWithValue("i_DateFrom", If(i_DateFrom = Nothing, DBNull.Value, Format(CDate(i_DateFrom), "yyyy-MM-dd")))

                .Parameters.AddWithValue("i_DateTo", If(i_DateTo = Nothing, DBNull.Value, Format(CDate(i_DateTo), "yyyy-MM-dd")))

                Dim schedtypevalue = Nothing

                Try
                    If i_SchedType Is Nothing Then
                        schedtypevalue = ""
                    ElseIf IsDBNull(i_SchedType) Then
                        schedtypevalue = ""
                    Else
                        schedtypevalue = If(i_SchedType = Nothing, DBNull.Value, CStr(i_SchedType))
                    End If
                Catch ex As Exception
                    schedtypevalue = ""
                End Try

                .Parameters.AddWithValue("i_SchedType", schedtypevalue)

                'dataread =
                .ExecuteNonQuery()

            End With

        Catch ex As Exception

            MsgBox(getErrExcptn(ex, Me.Name))

        End Try

    End Sub

    Function MilitTime(ByVal timeval As Object) As Object

        Dim retrnObj As Object

        retrnObj = New Object

        Try

            'If timeval Is Nothing Then
            '    retrnObj = DBNull.Value
            'Else
            If timeval = Nothing Then
                retrnObj = DBNull.Value
            ElseIf IsDBNull(timeval) Then
                retrnObj = DBNull.Value
            Else

                Dim endtime As Object = timeval

                If endtime.ToString.Contains("P") Then

                    Dim hrs As String = If(Val(getStrBetween(endtime, "", ":")) = 12, 12, Val(getStrBetween(endtime, "", ":")) + 12)

                    Dim mins As String = StrReverse(getStrBetween(StrReverse(endtime.ToString), "", ":"))

                    mins = getStrBetween(mins, "", " ")

                    retrnObj = hrs & ":" & mins

                ElseIf endtime.ToString.Contains("A") Then

                    Dim i As Integer = StrReverse(endtime).ToString.IndexOf(" ")

                    endtime = endtime.ToString.Replace("A", "")

                    'Dim i As Integer = StrReverse("3:15 AM").ToString.IndexOf(" ")

                    ''endtime = endtime.ToString.Replace("A", "")

                    'MsgBox(Trim(StrReverse(StrReverse("3:15 AM").ToString.Substring(i, ("3:15 AM").ToString.Length - i))).Length)

                    Dim amTime As String = Trim(StrReverse(StrReverse(endtime.ToString).Substring(i, _
                                                                                      endtime.ToString.Length - i)
                                              )
                                   )

                    amTime = If(getStrBetween(amTime, "", ":") = "12", _
                                24 & ":" & StrReverse(getStrBetween(StrReverse(amTime), "", ":")), _
                                amTime)

                    retrnObj = amTime

                Else
                    retrnObj = endtime

                End If

            End If

        Catch ex As Exception
            retrnObj = DBNull.Value
        End Try

        Return retrnObj

    End Function

    Private Sub TextBox4_KeyPress(sender As Object, e As KeyPressEventArgs) Handles TextBox4.KeyPress

        Dim e_asc = Asc(e.KeyChar)

        If e_asc = 13 Then

            fillemplyeelist()

            If dgvEmpList.RowCount <> 0 Then
                dgvEmpList_CellClick(sender, New DataGridViewCellEventArgs(c_EmployeeID.Index, 0))

            End If

        End If

    End Sub

    Private Sub TextBox4_TextChanged(sender As Object, e As EventArgs) Handles TextBox4.TextChanged

    End Sub

    Dim pagenumber As Integer = 0

    Private Sub Link_Paging(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles First.LinkClicked, Prev.LinkClicked,
                                                                                            Nxt.LinkClicked, Last.LinkClicked

        Dim sendrname As String = DirectCast(sender, LinkLabel).Name

        If sendrname = "First" Then
            pagenumber = 0
        ElseIf sendrname = "Prev" Then

            Dim modcent = pagenumber Mod 20

            If modcent = 0 Then

                pagenumber -= 20

            Else

                pagenumber -= modcent

            End If

            If pagenumber < 0 Then

                pagenumber = 0

            End If

        ElseIf sendrname = "Nxt" Then

            Dim modcent = pagenumber Mod 20

            If modcent = 0 Then
                pagenumber += 20

            Else
                pagenumber -= modcent

                pagenumber += 20

            End If
        ElseIf sendrname = "Last" Then
            Dim lastpage = Val(EXECQUER("SELECT COUNT(RowID) / 20 FROM employeeshift WHERE OrganizationID='" & org_rowid & "' AND EmployeeID='" & currentselectedEmpRowID & "';"))

            Dim remender = lastpage Mod 1

            pagenumber = (lastpage - remender) * 20

            If pagenumber - 20 < 20 Then
                'pagenumber = 0

            End If

            'pagenumber = If(lastpage - 20 >= 20, _
            '                lastpage - 20, _
            '                lastpage)

        End If

        If dgvEmpList.RowCount <> 0 Then

            fillemployeeshift()
            'dgvEmpList_CellClick(sender, New DataGridViewCellEventArgs(c_EmployeeID.Index, 0))

        End If

    End Sub
    'Private Sub Link_Paging(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles First.LinkClicked, Prev.LinkClicked,
    '                                                                                        Nxt.LinkClicked, Last.LinkClicked

    '    dgvEmpShiftList.Rows.Clear()

    '    Dim sendrname As String = DirectCast(sender, LinkLabel).Name

    '    If sendrname = "First" Then
    '        pagenumber = 0
    '    ElseIf sendrname = "Prev" Then
    '        If pagenumber - 50 < 0 Then
    '            pagenumber = 0
    '        Else : pagenumber -= 50
    '        End If
    '    ElseIf sendrname = "Nxt" Then
    '        pagenumber += 50
    '    ElseIf sendrname = "Last" Then

    '        Dim lastpage = Val(EXECQUER("SELECT COUNT(RowID) / 50 FROM employeeshift WHERE OrganizationID=" & orgztnID & " AND EmployeeID='" & dgvEmpList.Tag & "';"))

    '        Dim remender = lastpage Mod 1

    '        pagenumber = (lastpage - remender) * 50

    '        'pagenumber = If(lastpage - 50 >= 50, _
    '        '                lastpage - 50, _
    '        '                lastpage)

    '    End If

    '    Dim n_ReadSQLProcedureToDatatable As _
    '        New ReadSQLProcedureToDatatable("VIEW_employeeshift",
    '                                        orgztnID,
    '                                        ValNoComma(dgvEmpList.Tag),
    '                                        pagenumber)

    '    Dim empshifttable As New DataTable

    '    empshifttable = n_ReadSQLProcedureToDatatable.ResultTable

    '    For Each drow As DataRow In empshifttable.Rows

    '        Dim rowArray = drow.ItemArray

    '        dgvEmpShiftList.Rows.Add(rowArray)

    '    Next

    '    dgvEmpShiftList.PerformLayout()

    '    empshifttable.Dispose()

    'End Sub
End Class