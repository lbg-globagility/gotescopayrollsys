'Option Strict On
Imports NHotkey.WindowsForms
Imports NHotkey

Public Class TimeEntryLogs

#Region "Variables"

    'Private mod1 As New Model1

    'Private _timeentrylogs As IQueryable(Of TimeEntryLogsPerCutOff) = mod1.TimeEntryLogsPerCutOff.OfType(Of TimeEntryLogsPerCutOff)()

    Private this_year As Integer = Now.Year

    Const twenty As Integer = 20

    Private page_num As Integer = 0

    Private organization_rowid As Integer = 1

    Private e_uniq_id, e_primkey As String

    Private timelog_row As DataGridViewCell 'DataGridViewRow

    Private str_query_insupd_timeentrylogs As String =
        "SELECT INSUPD_timeentrylogs(?og_id, ?emp_unique_key, ?timestamp_log, ?max_importid);"

    Dim thefilepath As String = String.Empty

#End Region

#Region "Event Handlers"

    Sub New()

        ' This call is required by the designer.
        InitializeComponent()

        ' Add any initialization after the InitializeComponent() call.

    End Sub

    Sub TimeEntryLogs()

    End Sub

    Protected Overrides Sub OnLoad(e As EventArgs)

        HotkeyManager.Current.AddOrReplace("MacroKey_Control_R", (Keys.Control + Keys.R), AddressOf MacroKey_ContrlKey_RKey)

        PrevYear.Text = (this_year - 1)
        NxtYear.Text = (this_year + 1)

        MyBase.OnLoad(e)

        'organization_rowid = 1 'org_rowid
        'user_row_id = 1

        lblYear.Text = this_year
    End Sub

    Private Sub Last_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles Last.LinkClicked
        SetPageNumber(Last)
    End Sub

    Private Sub Nxt_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles Nxt.LinkClicked
        SetPageNumber(Nxt)
    End Sub

    Private Sub Prev_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles Prev.LinkClicked
        SetPageNumber(Prev)
    End Sub

    Private Sub First_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles First.LinkClicked
        SetPageNumber(First)
    End Sub

    Private Sub NxtYear_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles NxtYear.LinkClicked
        'Dim obj_lnklbl = DirectCast(sender, LinkLabel)

        Dim arithmet_operatr = Convert.ToInt32(sender.AccessibleDescription)

        this_year += (arithmet_operatr)

        lblYear.Text = this_year
    End Sub

    Private Sub PrevYear_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles PrevYear.LinkClicked
        'Dim obj_lnklbl = DirectCast(sender, LinkLabel)

        Dim arithmet_operatr = Convert.ToInt32(sender.AccessibleDescription)

        this_year += (arithmet_operatr)

        lblYear.Text = this_year
    End Sub

    Private Sub Year_TextChanged(sender As Object, e As EventArgs) Handles PrevYear.TextChanged, NxtYear.TextChanged

        'linkNxt.Text = (current_year + 1) & " →"
        'linkPrev.Text = "← " & (current_year - 1)

    End Sub

    Private Sub lblYear_Click(sender As Object, e As EventArgs) Handles lblYear.Click

    End Sub

    Private Sub lblYear_TextChanged(sender As Object, e As EventArgs) Handles lblYear.TextChanged

        LoadPayPeriods()

        ChangeYearLinkLableCaption()

        Static once As Boolean = True

        If once Then
            LoadEmployees(0)
        Else

        End If

        'Dim _col = DataGridViewX2.Columns.OfType(Of DataGridViewColumn).FirstOrDefault

        'DataGridViewX2.CurrentCell =
        '    DataGridViewX2.Rows.OfType(Of DataGridViewRow).FirstOrDefault.Cells(0) '_col.Index
    End Sub

    Private Sub DataGridViewX1_CellContentClick(sender As Object, e As DataGridViewCellEventArgs) Handles DataGridViewX1.CellContentClick

    End Sub

    Private Sub DataGridViewX1_CurrentCellChanged(sender As Object, e As EventArgs) Handles DataGridViewX1.CurrentCellChanged

        If DataGridViewX2.RowCount > 0 Then

            DataGridViewX2_CurrentCellChanged(DataGridViewX2, New EventArgs)

        End If

    End Sub


    Private Sub PayPeriodAndEmployee_CurrentCellChanged(sender As Object, e As EventArgs) _
        Handles DataGridViewX1.CurrentCellChanged,
        DataGridViewX2.CurrentCellChanged

    End Sub


    Private Sub DataGridViewX2_CellContentClick(sender As Object, e As DataGridViewCellEventArgs) Handles DataGridViewX2.CellContentClick

    End Sub

    Private Sub DataGridViewX2_CurrentCellChanged(sender As Object, e As EventArgs) Handles DataGridViewX2.CurrentCellChanged

        LoadTimeLogs()

    End Sub

    Private Sub tsbtnCancel_Click(sender As Object, e As EventArgs) Handles tsbtnCancel.Click

        DataGridViewX3.EndEdit()

        tsbtnCancel.Enabled = False
        Try

            timelog_row =
                DataGridViewX3.SelectedCells.OfType(Of DataGridViewCell).Where(Function(dgcel) dgcel.Selected).FirstOrDefault

            Dim _rowindex = 0
            If timelog_row Is Nothing Then
                _rowindex = 0
            Else
                _rowindex = timelog_row.RowIndex
            End If

            DataGridViewX2_CurrentCellChanged(DataGridViewX2, New EventArgs)

            If _rowindex > 0 Then
                'Dim _col =
                '    DataGridViewX3.Columns.OfType(Of DataGridViewColumn).Where(Function(dgcol) dgcol.Visible).LastOrDefault

                'Dim dgcolname = _col.Name

                DataGridViewX3.CurrentCell =
                    DataGridViewX3.Item(timelog_row.ColumnIndex, _rowindex)
            End If

        Catch ex As Exception
            ErrorNotif(ex)
        Finally
            tsbtnCancel.Enabled = True
        End Try

    End Sub

    Private Sub TimeEntryLogs_FormClosing(sender As Object, e As FormClosingEventArgs) Handles MyBase.FormClosing

    End Sub

    Private Sub Button1_Click(sender As Object, e As EventArgs) Handles Button1.Click
        SearchEmployees()
    End Sub

    Private Sub TextBox1_KeyPress(sender As Object, e As KeyPressEventArgs) Handles TextBox1.KeyPress
        Dim e_asc = Asc(e.KeyChar)

        If e_asc = 13 Then
            Button1_Click(Button1, New EventArgs)
        End If
    End Sub

    Private Sub TextBox1_TextChanged(sender As Object, e As EventArgs) Handles TextBox1.TextChanged

    End Sub

    Private Sub tsbtnClose_Click(sender As Object, e As EventArgs) Handles tsbtnClose.Click
        Close()
    End Sub

    Private Sub tsbtnAudittrail_Click(sender As Object, e As EventArgs) Handles tsbtnAudittrail.Click

    End Sub

    Private Sub tsbtndel_Click(sender As Object, e As EventArgs) Handles tsbtndel.Click

        DataGridViewX3.EndEdit()

        tsbtndel.Enabled = False

        Dim dgvrows =
            DataGridViewX3.Rows.OfType(Of DataGridViewRow).
            Where(Function(dgvrow) dgvrow.IsNewRow = False And
                      dgvrow.Selected)

        If dgvrows.Count = 0 Then
            Return
        End If

        Try
            Dim prompt =
                MessageBox.Show(String.Concat("Delete ", dgvrows.Count, " time log(s) ?"),
                                "Confirm deleting time logs",
                                MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question)

            Dim _agrees = (prompt = Windows.Forms.DialogResult.Yes)

            If e_primkey IsNot Nothing And _agrees Then

                Dim _count = 0

                Using _mod = New Model1

                    For Each dgrow In dgvrows

                        Dim tl_date =
                            CDate(dgrow.Cells(colDateValue.Index).Value)

                        Dim var_erowid = Convert.ToInt32(e_primkey)

                        Dim timelog_record =
                            _mod.EmployeeTimeEntryDetails.OfType(Of EmployeeTimeEntryDetails).
                            Where(Function(etd) etd.OrganizationId = organization_rowid And
                                      etd.EmployeeId = var_erowid And
                                      etd.DateValue = tl_date)

                        For Each _item In timelog_record.ToList
                            _count += 1
                        Next
                        Console.WriteLine(_count)

                        Dim should_update_record As Boolean = (_count > 0)

                        If should_update_record Then
                            For Each etd In timelog_record

                                _mod.EmployeeTimeEntryDetails.Remove(etd)
                                _mod.Entry(etd).State = Entity.EntityState.Deleted

                            Next

                        End If

                        DataGridViewX3.Rows.Remove(dgrow)
                    Next

                    _mod.SaveChanges()
                End Using

                Dim ct As New CustomBalloonToolTip(Label3, "Deleting time logs")
                If _count > 1 Then
                    ct.ShowInfoBallon("Time logs removed successfully.")
                ElseIf _count > 0 Then
                    ct.ShowInfoBallon("Time log removed successfully.")
                End If

            End If

        Catch ex As Exception
            ErrorNotif(ex)
        Finally

            tsbtndel.Enabled = True

        End Try

    End Sub

    Private Sub tsbtnSave_Click(sender As Object, e As EventArgs) Handles tsbtnSave.Click

        DataGridViewX3.EndEdit()

        tsbtnSave.Enabled = False

        Try

            Dim row_errors =
                DataGridViewX3.Rows.OfType(Of DataGridViewRow).
                Where(Function(dgrow) dgrow.Cells(colTimeIn.Name).ErrorText.Length > 0 Or
                          dgrow.Cells(colTimeOut.Name).ErrorText.Length > 0)

            Dim has_errors As Boolean = (row_errors.Count > 0)

            If has_errors Then
                Dim ct As New CustomBalloonToolTip(Label1, "Saving time logs")
                ct.ShowWarningBallon("Please correct the error first.")

                DataGridViewX3.CurrentCell = row_errors.FirstOrDefault.Cells(0)
                Return
            End If

        Catch ex As Exception
            ErrorNotif(ex)
        End Try

        Dim dgvrows =
            DataGridViewX3.Rows.OfType(Of DataGridViewRow).
            Where(Function(dgvrow) dgvrow.Cells(WasEdited.Index).Value = True)

        Try
            If e_primkey IsNot Nothing Then
                Using _mod = New Model1

                    For Each dgrow In dgvrows

                        Dim time_in_input =
                            dgrow.Cells(colTimeIn.Name).Value

                        Dim time_out_input =
                            dgrow.Cells(colTimeOut.Name).Value

                        Dim time_in, time_out As TimeSpan?

                        If time_in_input IsNot Nothing Then
                            Dim _date = Convert.ToDateTime(time_in_input)
                            time_in = New TimeSpan(_date.Hour, _date.Minute, 0)
                        End If

                        If time_out_input IsNot Nothing Then
                            Dim _date = Convert.ToDateTime(time_out_input)
                            time_out = New TimeSpan(_date.Hour, _date.Minute, 0)
                        End If

                        Dim tl_date =
                            CDate(dgrow.Cells(colDateValue.Index).Value)

                        Dim var_erowid = Convert.ToInt32(e_primkey)

                        Dim timelog_record =
                            _mod.EmployeeTimeEntryDetails.OfType(Of EmployeeTimeEntryDetails).
                            Where(Function(etd) etd.OrganizationId = organization_rowid And
                                      etd.EmployeeId = var_erowid And
                                      etd.DateValue = tl_date)

                        Dim _count = 0
                        For Each _item In timelog_record.ToList
                            _count += 1
                        Next
                        Console.WriteLine(_count)

                        Dim should_update_record As Boolean = (_count > 0)

                        Dim ted =
                                    New EmployeeTimeEntryDetails _
                                    With {.EmployeeId = var_erowid,
                                          .TimeIn = time_in,
                                          .TimeOut = time_out,
                                          .DateValue = tl_date,
                                          .OrganizationId = organization_rowid}

                        If should_update_record Then
                            ted.LastUpd = Now
                            ted.LastUpdBy = user_row_id

                            _mod.Entry(ted).State = Entity.EntityState.Modified
                        Else
                            ted.Created = Now
                            ted.CreatedBy = user_row_id
                        End If

                        _mod.EmployeeTimeEntryDetails.Add(ted)

                    Next

                    _mod.SaveChanges()
                End Using

                Dim ct As New CustomBalloonToolTip(Label1, "Saving time logs")
                ct.ShowInfoBallon("Changes saved successfully.")

            End If

        Catch ex As Exception
            ErrorNotif(ex)
        Finally

            tsbtnSave.Enabled = True

        End Try

    End Sub

    Private Sub tsbtnImport_Click(sender As Object, e As EventArgs) Handles tsbtnImport.Click

        Static employeeleaveRowID As Integer = -1

        Try
            Dim browsefile As OpenFileDialog = New OpenFileDialog()
            browsefile.Filter =
                String.Concat("Text Documents (*.txt)|*.txt",
                              "|All files (*.*)|*.*")

            If browsefile.ShowDialog() = Windows.Forms.DialogResult.OK Then

                thefilepath = browsefile.FileName

                Dim ct As New CustomBalloonToolTip(Label2, "Importing time logs")
                ct.ShowInfoBallon("Please wait while the system doing the importation.")

                bgworkTypicalImport.RunWorkerAsync()

            Else

            End If
        Catch ex As Exception
            MsgBox(ex.Message & " Error on file initialization")
        Finally
            'AddHandler dgvetentdet.SelectionChanged, AddressOf dgvetentdet_SelectionChanged
        End Try

    End Sub

    Private Sub bgworkTypicalImport_DoWork(sender As Object, e As System.ComponentModel.DoWorkEventArgs) Handles bgworkTypicalImport.DoWork

        Dim import_id =
            ImportConventionalFormatTimeLogs()

        Dim param_values =
            New Object() {org_rowid,
                          user_row_id,
                          DBNull.Value,
                          DBNull.Value,
                          import_id}

        Dim sql As New SQL("CALL BULK_INSUPD_employeetimeentrydetails(?og_id, ?user_id, ?from_date, ?to_date, ?id_import);",
                           param_values)
        sql.ExecuteQuery()

        If sql.HasError Then
            Throw sql.ErrorException
        End If

    End Sub

    Private Sub bgworkTypicalImport_ProgressChanged(sender As Object, e As System.ComponentModel.ProgressChangedEventArgs) Handles bgworkTypicalImport.ProgressChanged

        ToolStripProgressBar1.Value = e.ProgressPercentage

    End Sub

    Private Sub bgworkTypicalImport_RunWorkerCompleted(sender As Object, e As System.ComponentModel.RunWorkerCompletedEventArgs) Handles bgworkTypicalImport.RunWorkerCompleted

        If e.Error IsNot Nothing Then
            ErrorNotif(e.Error)
        ElseIf e.Cancelled Then

        Else
            Dim ct As New CustomBalloonToolTip(Label2, "Importing time logs")
            ct.ShowInfoBallon("Time logs imported successfully.")

            DataGridViewX2_CurrentCellChanged(DataGridViewX2, New EventArgs)

        End If

    End Sub

    Private Sub tsbtnNew_Click(sender As Object, e As EventArgs) Handles tsbtnNew.Click

        DataGridViewX3.EndEdit()

        Dim has_newrow =
            DataGridViewX3.Rows.OfType(Of DataGridViewRow).Where(Function(dgrow) dgrow.IsNewRow).FirstOrDefault

        If has_newrow IsNot Nothing Then
            DataGridViewX3.CurrentCell = DataGridViewX3.Item(0, has_newrow.Index)
        End If

    End Sub

    Private Sub DataGridViewX3_CellContentClick(sender As Object, e As DataGridViewCellEventArgs) Handles DataGridViewX3.CellContentClick

    End Sub

    Private Sub DataGridViewX3_CellEndEdit(sender As Object, e As DataGridViewCellEventArgs) Handles DataGridViewX3.CellEndEdit

        Dim colName As String = DataGridViewX3.Columns(e.ColumnIndex).Name

        Dim rowindx = e.RowIndex

        Dim _cols = New String() {colTimeIn.Name, colTimeOut.Name}

        If _cols.Contains(colName) Then

            If Trim(DataGridViewX3.Item(colName, rowindx).Value) <> "" Then
                Dim dateobj As Object = Trim(DataGridViewX3.Item(colName, rowindx).Value).Replace(" ", ":")

                Dim ampm As String = Nothing

                Try
                    If dateobj.ToString.Contains("A") Or _
                        dateobj.ToString.Contains("P") Or _
                        dateobj.ToString.Contains("M") Then

                        ampm = " " & StrReverse(getStrBetween(StrReverse(dateobj.ToString), "", ":"))
                        ampm = Microsoft.VisualBasic.Left(ampm, 2) & "M"
                        dateobj = dateobj.ToString.Replace(":", " ")
                        dateobj = Trim(dateobj.ToString.Substring(0, 5)) 'dateobj.ToString.Substring(0, 4)
                        dateobj = dateobj.ToString.Replace(" ", ":")

                    End If

                    Dim valtime As DateTime = DateTime.Parse(dateobj).ToString("hh:mm tt")
                    If ampm = Nothing Then
                        DataGridViewX3.Item(colName, rowindx).Value = valtime.ToShortTimeString
                    Else
                        DataGridViewX3.Item(colName, rowindx).Value = Trim(valtime.ToShortTimeString.Substring(0, 5)) & ampm
                    End If

                    DataGridViewX3.Item(colName, rowindx).ErrorText = Nothing
                Catch ex As Exception
                    Try
                        dateobj = dateobj.ToString.Replace(":", " ")
                        dateobj = Trim(dateobj.ToString.Substring(0, 5))
                        dateobj = dateobj.ToString.Replace(" ", ":")

                        Dim valtime As DateTime = DateTime.Parse(dateobj).ToString("HH:mm")

                        DataGridViewX3.Item(colName, rowindx).Value = valtime.ToShortTimeString

                        DataGridViewX3.Item(colName, rowindx).ErrorText = Nothing
                    Catch ex_1 As Exception

                        DataGridViewX3.Item(colName, rowindx).ErrorText = "     Invalid time value"
                    End Try
                End Try

            Else

                DataGridViewX3.Item(colName, rowindx).ErrorText = Nothing
            End If

            DataGridViewX3.Item(WasEdited.Index, e.RowIndex).Value = True
        End If

    End Sub

    Private Sub MacroKey_ContrlKey_RKey(sender As Object, e As HotkeyEventArgs)
        DataGridViewX1.Focus()
        DataGridViewX2.Focus()

        Dim _bool = tsbtnCancel.Enabled

        If _bool Then
            tsbtnCancel_Click(tsbtnCancel, New EventArgs)
            'Button1_Click(Button1, New EventArgs)

        End If
        
    End Sub

#End Region

#Region "Functions & Methods"

    Private Sub LoadPayPeriods()

        Try
            Using _mod = New Model1

                Dim _payperiods =
                    (From t In _mod.TimeEntryLogsPerCutOff
                     Where t.YearValue = this_year And t.OrganizationId = organization_rowid
                     Group By t.PayPeriodID
                     Into tl = Group
                     Let uniquepayperiod = tl.FirstOrDefault
                     Select New With {.PayFromDate = uniquepayperiod.PayFromDate,
                                      .PayToDate = uniquepayperiod.PayToDate}
                     )

                DataGridViewX1.DataSource = _payperiods.ToList

            End Using

        Catch ex As Exception
            ErrorNotif(ex)
        End Try

    End Sub

    Private Sub LoadEmployees(_page As Integer)
        DataGridViewX2.Rows.Clear()
        If _page < 0 Then
            _page = 0
            page_num = 0
        End If

        Try
            Using _mod = New Model1
                Dim _employees =
                    (From e In _mod.EmployeeEntity
                     Where e.OrganizationID = organization_rowid
                     Let employeeinfo = e
                     Select New With {.Employee_ID = employeeinfo.EmployeeID,
                                      .Full_Name = employeeinfo.FullName,
                                      .EPrimaryKey = employeeinfo.RowID}
                     ).
                 OrderBy(Function(e) e.Full_Name).
                 Skip(_page).Take(twenty)

                'DataGridViewX2.AutoGenerateColumns = False
                'DataGridViewX2.DataSource = _employees.ToList
                For Each _employee In _employees.ToList

                    DataGridViewX2.Rows.Add(_employee.Employee_ID,
                                            _employee.Full_Name,
                                            _employee.EPrimaryKey)
                Next

            End Using

        Catch ex As Exception
            ErrorNotif(ex)
        End Try
    End Sub

    Private Sub SearchEmployees()
        DataGridViewX2.Rows.Clear()
        Dim str_search As String

        str_search = TextBox1.Text.Trim

        If str_search.Length > 0 Then
            Try
                Using _mod = New Model1
                    Dim _employees =
                        (From e In _mod.EmployeeEntity
                         Where e.OrganizationID = organization_rowid And
                         e.FullName.Contains(str_search)
                         Let employeeinfo = e
                         Select New With {.Employee_ID = employeeinfo.EmployeeID,
                                          .Full_Name = employeeinfo.FullName,
                                          .EPrimaryKey = employeeinfo.RowID}
                         ).
                     OrderBy(Function(e) e.Full_Name)

                    'DataGridViewX2.DataSource = _employees.ToList
                    For Each _employee In _employees.ToList

                        DataGridViewX2.Rows.Add(_employee.Employee_ID,
                                                _employee.Full_Name,
                                                _employee.EPrimaryKey)
                    Next

                End Using

            Catch ex As Exception
                ErrorNotif(ex)
            End Try
        Else
            First_LinkClicked(First, New LinkLabelLinkClickedEventArgs(New LinkLabel.Link))
        End If

    End Sub

    Private Sub LoadTimeLogs()

        DataGridViewX3.Rows.Clear()

        Try
            Using _mod = New Model1

                Dim datef, datet As Date?

                Dim pp_curr_row = DataGridViewX1.Rows.OfType(Of DataGridViewRow).Where(Function(dgvr) dgvr.Selected).FirstOrDefault

                If pp_curr_row IsNot Nothing Then
                    datef = Date.Parse(pp_curr_row.Cells(0).Value).ToShortDateString
                    datet = Date.Parse(pp_curr_row.Cells(1).Value).ToShortDateString
                End If


                Dim emp_curr_row = DataGridViewX2.Rows.OfType(Of DataGridViewRow).Where(Function(dgvr) dgvr.Selected).FirstOrDefault

                e_uniq_id = Nothing
                e_primkey = Nothing
                If emp_curr_row IsNot Nothing Then
                    e_uniq_id = Convert.ToString(emp_curr_row.Cells(0).Value)
                    e_primkey = Convert.ToString(emp_curr_row.Cells(2).Value)

                End If


                Dim _timelogs =
                    (From t In _mod.TimeEntryLogsPerCutOff
                     Where t.YearValue = this_year And
                     t.OrganizationId = organization_rowid And
                     String.Equals(t.EmployeeUniqueKey, e_uniq_id) And
                     (t.DateValue >= datef And t.DateValue <= datet)
                     Order By t.DateValue
                     Let timeloginfo = t
                     Select New With {.Time_In = timeloginfo.TimeInText,
                                      .Time_Out = timeloginfo.TimeOutText,
                                      .Date_Attended = timeloginfo.DateValue}
                     )

                'DataGridViewX3.DataSource = _timelogs.ToList
                For Each _item In _timelogs.ToList

                    DataGridViewX3.Rows.Add(_item.Time_In,
                                            _item.Time_Out,
                                            _item.Date_Attended)
                Next

            End Using
        Catch ex As Exception
            ErrorNotif(ex)
        End Try
    End Sub

    Private Sub SetPageNumber(lnklabel As LinkLabel)

        If Last.Name = lnklabel.Name Then
            Using _mod = New Model1
                Dim _employees =
                    (From e In _mod.EmployeeEntity
                     Where e.OrganizationID = organization_rowid
                     )

                Dim e_count = _employees.ToList.Count

                page_num = (e_count - (e_count Mod twenty))

            End Using

        ElseIf First.Name = lnklabel.Name Then
            page_num = 0
        Else
            page_num += (twenty * Convert.ToInt32(lnklabel.AccessibleDescription))
        End If

        LoadEmployees(page_num)
    End Sub

    Private Sub ChangeYearLinkLableCaption()
        Dim lnklbl =
            Panel6.Controls.OfType(Of LinkLabel)()

        For Each l In lnklbl
            l.Text = (this_year + Convert.ToInt32(l.AccessibleDescription))
        Next

    End Sub

    Private Sub ErrorNotif(ex As Exception)

        Static exempted_msg() As String = New String() {"No row can be added to a DataGridView control that does not have columns. Columns must be added first."}

        If exempted_msg.Contains(ex.Message) = False Then
            MsgBox("Something went wrong, see log file.", MsgBoxStyle.Critical)

            Dim st As StackTrace = New StackTrace(ex, True)
            Dim sf As StackFrame = st.GetFrame(st.FrameCount - 1)

            _logger.Error(sf.GetMethod.Name, ex)
        End If

    End Sub

    Private Function ImportConventionalFormatTimeLogs() As Integer

        Dim return_value As Integer = 0

        Dim max_importid = New SQL(String.Concat("SELECT MAX(ImportID) FROM timeentrylogs WHERE OrganizationID=", org_rowid, ";")).GetFoundRow
        max_importid = (Convert.ToDouble(max_importid) + 1)

        Dim emp_unique_key, datetime_attended As Object

        Dim parser = New TimeInTimeOutParser()
        Dim timeEntries = parser.ParseConventionalTimeLogs(thefilepath)

        Dim i = 1

        Dim line_content_count As Integer = timeEntries.Count

        Console.WriteLine(line_content_count)

        For Each timeEntry In timeEntries

            emp_unique_key =
                timeEntry.EmployeUniqueKey

            datetime_attended =
                timeEntry.DateAndTime

            Dim param_values =
                New Object() {org_rowid,
                              emp_unique_key,
                              Convert.ToString(datetime_attended),
                              max_importid}

            Dim sql As New SQL(str_query_insupd_timeentrylogs,
                               param_values)
            sql.ExecuteQuery()

            If sql.HasError Then

                MsgBox(sql.ErrorMessage)

            End If

            return_value = ((i / line_content_count) * 100)

            bgworkTypicalImport.
                ReportProgress(return_value)

            i += 1

        Next

        'Return return_value
        Return max_importid

    End Function
#End Region

#Region "Properties"

#End Region

End Class