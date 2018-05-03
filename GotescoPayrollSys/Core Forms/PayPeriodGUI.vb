Imports System.Threading.Tasks
Imports System.Threading

Public Class PayPeriodGUI

#Region "Enum"

    Public Enum PurposeAs As Int16
        Payroll = 0
        TimeEntry = 1

    End Enum

#End Region

#Region "Variables"

    Private view_payp_query As String =
        String.Concat("CALL VIEW_payp(?og_id",
                      ", ADDDATE(STR_TO_DATE('0000-01-01', @@date_format), INTERVAL ?selected_year YEAR)",
                      ", ?format_key",
                      ", ?pay_freqtype);")

    Private yearnow = 0 'CDate(dbnow).Year

    Private selectedButtonFont = New System.Drawing.Font("Trebuchet MS", 9.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))

    Private unselectedButtonFont = New System.Drawing.Font("Trebuchet MS", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))

    Private orgpayfreqID = Nothing

    Private str_employee_rec_checker As String = "SELECT EXISTS(SELECT RowID FROM employee WHERE OrganizationID=?og_id LIMIT 1);"

    Private og_payfreq_rowid As String = "SELECT PayFrequencyID FROM organization WHERE RowID=?og_id;"

    Private m_PayFreqType = ""

    Private this_rowid As Object = Nothing

    Private this_datefrom As Object = Nothing

    Private this_dateto As Object = Nothing

    Private numofweekdays = 0

    Private numofweekends = 0

    Private paypFrom = Nothing

    Private paypTo = Nothing

    Private PriorPayPeriodID As String = String.Empty

    Private CurrentPayPeriodID As String = String.Empty

    Private NextPayPeriodID As String = String.Empty

    Private includes_13month_calc As Boolean = False

    Private prior_rowid As Object = Nothing

    Private next_rowid As Object = Nothing

    Private upd_minwage_valofpayperiod As String =
        String.Concat("UPDATE payperiod",
                      " SET",
                      " MinWageValue=?min_wageval",
                      ",LastUpd     =CURRENT_TIMESTAMP()",
                      ",LastUpdBy   =?user_rowid",
                      " WHERE RowID =?pp_rowid;")

    Dim quer_empPayFreq = ""

    Dim prior_value As Object = Nothing

    Dim as_purpose As PurposeAs = PurposeAs.Payroll

    Dim divis_rowid As Object = Nothing

#End Region

#Region "Properties"

    ReadOnly Property RowID As Object

        Get
            Return this_rowid

        End Get

    End Property

    ReadOnly Property PayDateFrom As Object

        Get
            Return this_datefrom

        End Get

    End Property

    ReadOnly Property PayDateTo As Object

        Get
            Return this_dateto

        End Get

    End Property

    ReadOnly Property IsExec13monthCalc As Boolean

        Get
            Return includes_13month_calc

        End Get

    End Property

    ReadOnly Property PreceedingRowID As Object

        Get
            Return prior_rowid

        End Get

    End Property

    ReadOnly Property ProceedingRowID As Object

        Get
            Return next_rowid

        End Get

    End Property

    Property PayFreqType As String

        Get
            Return m_PayFreqType
        End Get

        Set(value As String)
            m_PayFreqType = value
        End Set

    End Property

    Property AsPurpose As PurposeAs

        Get
            Return as_purpose

        End Get

        Set(value As PurposeAs)
            as_purpose = value

        End Set

    End Property

    ReadOnly Property DivisionRowID As Object

        Get
            Return divis_rowid

        End Get

    End Property

#End Region

#Region "Methods"

    Sub New()

        ' This call is required by the designer.
        InitializeComponent()

        ' Add any initialization after the InitializeComponent() call.

        Me.StartPosition = FormStartPosition.CenterScreen

    End Sub

    Protected Overrides Sub OnLoad(e As EventArgs)
        Me.DialogResult = Windows.Forms.DialogResult.None

        If Convert.ToInt32(org_rowid) = 0 Then
            org_rowid = 1

        End If

        Dim n_db As New SQL("SELECT YEAR( CURDATE() );")
        yearnow = Convert.ToInt32(n_db.GetFoundRow)

        SetProperUserInterface()

        MyBase.OnLoad(e)

    End Sub

    Protected Overrides Function ProcessCmdKey(ByRef msg As Message, keyData As Keys) As Boolean

        Dim n_link As New System.Windows.Forms.LinkLabel.Link

        If keyData = Keys.Escape _
            And dgvpaypers.IsCurrentCellInEditMode = False Then

            Button2_Click(Button2, New EventArgs)

            Return True

            'ElseIf keyData = Keys.Left Then

            '    n_link.Name = "linkPrev"

            '    linkPrev_LinkClicked(linkPrev, New LinkLabelLinkClickedEventArgs(n_link))

            '    Return True

            'ElseIf keyData = Keys.Right Then

            '    n_link.Name = "linkNxt"

            '    linkNxt_LinkClicked(linkNxt, New LinkLabelLinkClickedEventArgs(n_link))

            '    Return True
        Else

            Return MyBase.ProcessCmdKey(msg, keyData)

        End If

    End Function

    Private Sub AssignProperties(dgvrow_indx As Integer)

        With dgvpaypers.Rows(dgvrow_indx)

            this_rowid = .Cells("Column1").Value

            this_datefrom = .Cells("Column2").Value

            this_dateto = .Cells("Column3").Value

        End With

    End Sub

    Private Sub ResetProperties()

        this_rowid = Nothing

        this_datefrom = Nothing

        this_dateto = Nothing

    End Sub

    Private Sub SetProperUserInterface()

        Dim bool_result As Boolean =
            Convert.ToInt16(CBool(as_purpose = PurposeAs.Payroll))

        'Select Case as_purpose

        '    Case PurposeAs.Payroll

        '    Case PurposeAs.EmployeeTimeEntry

        'End Select

        chkbx13monCalcInclude.Visible = bool_result

        pnlDivision.Visible = (Not bool_result)

    End Sub

#End Region

#Region "Event handlers"

    Private Sub selectPayPeriod_FormClosing(sender As Object, e As FormClosingEventArgs) Handles Me.FormClosing

    End Sub

    Private Sub selectPayPeriod_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        'dbconn()

        linkPrev.Text = "← " & (yearnow - 1)
        linkNxt.Text = (yearnow + 1) & " →"

        'assign event handlers for ToolStripButton of payfrequencys
        For Each tsbtn As ToolStripButton In tstrip.Items.OfType(Of ToolStripButton)()
            AddHandler tsbtn.Click, AddressOf PayFreq_Changed

        Next

        'If first_sender IsNot Nothing Then
        PayFreq_Changed(ToolStripButton2, New EventArgs)
        'End If

        'gets the `PayFrequencyID` of this `organization`
        Dim _sql As New SQL(og_payfreq_rowid,
                            org_rowid)

        'stores the `PayFrequencyID` of this `organization`
        orgpayfreqID = Convert.ToInt32(_sql.GetFoundRow) 'EXECQUER("SELECT PayFrequencyID FROM organization WHERE RowID='" & orgztnID & "';")

    End Sub

    Sub PayFreq_Changed(sender As Object, e As EventArgs)

        quer_empPayFreq = ""

        Dim senderObj As New ToolStripButton

        Static prevObj As New ToolStripButton

        Static once As SByte = 0

        senderObj = DirectCast(sender, ToolStripButton)

        If once = 0 Then

            once = 1

            prevObj = senderObj

            senderObj.BackColor = Color.FromArgb(194, 228, 255)

            senderObj.Font = selectedButtonFont

            quer_empPayFreq = senderObj.Text

            VIEW_payp(yearnow, senderObj.Text)

            dgvpaypers_SelectionChanged(sender, e)

            Exit Sub

        End If

        If prevObj.Name = Nothing Then
        Else

            If prevObj.Name <> senderObj.Name Then

                prevObj.BackColor = Color.FromArgb(255, 255, 255)

                prevObj.Font = unselectedButtonFont

                prevObj = senderObj

            End If

        End If

        senderObj.BackColor = Color.FromArgb(194, 228, 255)

        senderObj.Font = selectedButtonFont

        quer_empPayFreq = senderObj.Text

        VIEW_payp(yearnow, senderObj.Text)

        dgvpaypers_SelectionChanged(sender, e)

    End Sub

    Sub VIEW_payp(Optional param_Date As Object = Nothing, _
                  Optional PayFreqType As Object = Nothing)

        'Dim params(3, 2) As Object

        'params(0, 0) = "payp_OrganizationID"
        'params(1, 0) = "param_Date"
        'params(2, 0) = "isotherformat"
        'params(3, 0) = "PayFreqType"

        'params(0, 1) = orgztnID
        'params(1, 1) = If(param_Date = Nothing, DBNull.Value, param_Date & "-01-01")
        'params(2, 1) = "0"
        'params(3, 1) = PayFreqType

        'EXEC_VIEW_PROCEDURE(params, _
        '                    "VIEW_payp", _
        '                    dgvpaypers)

        'Dim n_mysqlcmd As _
        '    New MySQLCommander(view_payp_query)

        Dim selected_date As String =
            String.Concat("'", param_Date, "-01-01", "'")

        'n_mysqlcmd.ParameterValueCollection =
        '    New Object() {orgztnID, selected_date, 0, PayFreqType}

        'Dim exec_cmd As _
        '    New MySQLExecuteCommand(n_mysqlcmd)

        Dim datset As New DataSet

        'datset = exec_cmd.GetFoundRows
        'Dim param_values = New Object() {orgztnID, selected_date, 0, PayFreqType}

        Dim param_values = New Object() {org_rowid, param_Date, 0, PayFreqType}
        Dim sql As New SQL(view_payp_query,
                           param_values)
        datset = sql.GetFoundRows

        Dim caught_tbl As New DataTable

        caught_tbl = datset.Tables(0)

        dgvpaypers.Rows.Clear()

        For Each drow As DataRow In caught_tbl.Rows
            Dim row_array = drow.ItemArray

            dgvpaypers.Rows.Add(row_array)

        Next

        datset.Dispose()

    End Sub

    Private Sub linkNxt_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles linkNxt.LinkClicked
        Panel2.Enabled = False
        yearnow = yearnow + 1

        linkNxt.Text = (yearnow + 1) & " →"
        linkPrev.Text = "← " & (yearnow - 1)

        VIEW_payp(yearnow, quer_empPayFreq)

        If dgvpaypers.RowCount <> 0 Then
            dgvpaypers_SelectionChanged(sender, e)
        Else
            lblpapyperiodval.Text = ""
        End If
        Panel2.Enabled = True
    End Sub

    Private Sub linkPrev_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles linkPrev.LinkClicked
        Panel2.Enabled = False
        yearnow = yearnow - 1

        linkPrev.Text = "← " & (yearnow - 1)
        linkNxt.Text = (yearnow + 1) & " →"

        VIEW_payp(yearnow, quer_empPayFreq)

        If dgvpaypers.RowCount <> 0 Then
            dgvpaypers_SelectionChanged(sender, e)
        Else
            lblpapyperiodval.Text = ""
        End If
        Panel2.Enabled = True

    End Sub

    Private Sub Button1_Click(sender As Object, e As EventArgs) Handles Button1.Click

        dgvpaypers.EndEdit()

        CurrentPayPeriodID = String.Empty

        PriorPayPeriodID = String.Empty

        NextPayPeriodID = String.Empty

        m_PayFreqType = quer_empPayFreq

        Dim id_value As Object = Nothing

        If dgvpaypers.RowCount > 0 Then

            With dgvpaypers.CurrentRow

                id_value = dgvpaypers.Item("Column1", 0).Value

                CurrentPayPeriodID = .Cells("Column1").Value

                Dim prior_index = .Index - 1

                If prior_index < 0 Then

                    PriorPayPeriodID = EXECQUER("SELECT pyp.RowID" & _
                                                " FROM payperiod pyp" & _
                                                " INNER JOIN payperiod pp ON pp.RowID='" & CurrentPayPeriodID & "'" & _
                                                " WHERE pyp.OrganizationID='" & org_rowid & "'" & _
                                                " AND pyp.TotalGrossSalary=pp.TotalGrossSalary" & _
                                                " AND pyp.RowID BETWEEN (" & CurrentPayPeriodID & " - 10)" & _
                                                " AND pp.RowID" & _
                                                " ORDER BY pyp.PayFromDate DESC,pyp.PayToDate DESC" & _
                                                " LIMIT 1,1;")
                Else
                    PriorPayPeriodID = dgvpaypers.Item("Column1", prior_index).Value

                End If

                Dim next_index = .Index + 1

                If next_index < dgvpaypers.RowCount Then
                    NextPayPeriodID = dgvpaypers.Item("Column1", next_index).Value
                Else

                    NextPayPeriodID = EXECQUER("SELECT pyp.RowID" & _
                                                " FROM payperiod pyp" & _
                                                " INNER JOIN payperiod pp ON pp.RowID='" & CurrentPayPeriodID & "'" & _
                                                " WHERE pyp.OrganizationID='" & org_rowid & "'" & _
                                                " AND pyp.TotalGrossSalary=pp.TotalGrossSalary" & _
                                                " AND pyp.RowID BETWEEN pp.RowID" & _
                                                " AND (" & CurrentPayPeriodID & " + 10)" & _
                                                " ORDER BY pyp.PayFromDate,pyp.PayToDate" & _
                                                " LIMIT 1,1;")

                End If

                'NextPayPeriodID

                paypFrom = Format(CDate(.Cells("Column2").Value), "yyyy-MM-dd")

                paypTo = Format(CDate(.Cells("Column3").Value), "yyyy-MM-dd")

                'Dim sel_yearDateFrom = CDate(paypFrom).Year

                'Dim sel_yearDateTo = CDate(paypTo).Year

                'Dim sel_year = If(sel_yearDateFrom > sel_yearDateTo, _
                '                  sel_yearDateFrom, _
                '                  sel_yearDateTo)

                numofweekdays = 0

                numofweekends = 0

                Dim date_diff = DateDiff(DateInterval.Day, CDate(paypFrom), CDate(paypTo))

                For i = 0 To date_diff

                    Dim DayOfWeek = CDate(paypFrom).AddDays(i)

                    If DayOfWeek.DayOfWeek = 0 Then 'System.DayOfWeek.Sunday
                        numofweekends += 1

                    ElseIf DayOfWeek.DayOfWeek = 6 Then 'System.DayOfWeek.Saturday
                        numofweekends += 1
                    Else
                        numofweekdays += 1

                    End If

                Next

                If chkbx13monCalcInclude.Checked Then 'Format(CDate(.Cells("Column3").Value), "MM") = "12"

                    Dim prompt = MessageBox.Show("Do you want to include the calculation of Thirteenth month pay ?", _
                                                 "Thirteenth month pay calculation", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Information)

                    If prompt = Windows.Forms.DialogResult.Yes Then

                    ElseIf prompt = Windows.Forms.DialogResult.No Then

                    ElseIf prompt = Windows.Forms.DialogResult.Cancel Then
                        Exit Sub

                    End If

                    'Else

                End If

            End With

            includes_13month_calc = (chkbx13monCalcInclude.Checked)

            divis_rowid = cboxDivisions.SelectedValue

            Me.DialogResult = Windows.Forms.DialogResult.OK

            Dim PayFreqRowID = EXECQUER("SELECT RowID FROM payfrequency WHERE PayFrequencyType='" & quer_empPayFreq & "';")

        End If

    End Sub

    Private Sub Button2_Click(sender As Object, e As EventArgs) Handles Button2.Click

        Me.Close()

    End Sub

    Private Sub dgvpaypers_CellBeginEdit(sender As Object, e As DataGridViewCellCancelEventArgs) Handles dgvpaypers.CellBeginEdit

        prior_value = ValNoComma(dgvpaypers.Item("PayPeriodMinWageValue", e.RowIndex).Value)

    End Sub

    Private Sub dgvpaypers_RowsAdded(sender As Object, e As DataGridViewRowsAddedEventArgs) Handles dgvpaypers.RowsAdded

        Dim month_column_name As String = "Column5"

        Dim is_even As Boolean = ((dgvpaypers.Item(month_column_name, e.RowIndex).Value Mod 2) = 0)

        Dim row_bg_color As Color

        If is_even Then
            row_bg_color = Color.FromArgb(240, 240, 240)
        Else
            row_bg_color = Color.FromArgb(255, 255, 255)
        End If

        'dgvpaypers.Item(month_column_name, e.RowIndex).Style.BackColor = row_bg_color

        dgvpaypers.Rows(e.RowIndex).DefaultCellStyle.BackColor = row_bg_color

    End Sub

    Private Sub dgvpaypers_CellContentClick(sender As Object, e As DataGridViewCellEventArgs) Handles dgvpaypers.CellContentClick

    End Sub

    Private Sub dgvpaypers_CellEndEdit(sender As Object, e As DataGridViewCellEventArgs) Handles dgvpaypers.CellEndEdit

        If e.RowIndex > -1 _
            And e.ColumnIndex > -1 Then

            Dim min_wage_val = ValNoComma(dgvpaypers.Item("PayPeriodMinWageValue", e.RowIndex).Value)

            If prior_value <> min_wage_val Then

                prior_value = ValNoComma(dgvpaypers.Item("PayPeriodMinWageValue", e.RowIndex).Value)

                'Dim n_ExecuteQuery As _
                '    New ExecuteQuery("UPDATE payperiod" &
                '                     " SET" &
                '                     " MinWageValue=" & min_wage_val & "" &
                '                     ",LastUpd=CURRENT_TIMESTAMP()" &
                '                     ",LastUpdBy='" & z_User & "'" &
                '                     " WHERE RowID='" & dgvpaypers.Item("Column1", e.RowIndex).Value & "';")

                UpdateMinWageValueOfPayPeriod(min_wage_val,
                                              dgvpaypers.Item("Column1", e.RowIndex).Value)

            End If
        Else

        End If

    End Sub

    Private Sub UpdateMinWageValueOfPayPeriod(min_wageval As Double,
                                              pp_rowid As Integer)

        Dim n_mysqlcmd As _
            New MySQLCommander(upd_minwage_valofpayperiod)

        n_mysqlcmd.ParameterValueCollection =
            New Object() {min_wageval,
                          user_row_id,
                          pp_rowid}

        Dim exec_cmd As _
            New MySQLExecuteCommand(n_mysqlcmd)

        exec_cmd.Execute()

        If exec_cmd.HasError Then

        End If

    End Sub

    Private Sub dgvpaypers_SelectionChanged(sender As Object, e As EventArgs) Handles dgvpaypers.SelectionChanged

        Static _year As Integer = 0

        If dgvpaypers.RowCount > 0 Then

            With dgvpaypers.CurrentRow

                AssignProperties(.Index)

                lblpapyperiodval.Text = ": from " & _
                    Trim(.Cells("Column2").Value) & _
                    " to " & _
                    Trim(.Cells("Column3").Value)

                'Column1
                'Column2
                'Column3

                paypFrom = Format(CDate(.Cells("Column2").Value), "yyyy-MM-dd")

                paypTo = Format(CDate(.Cells("Column3").Value), "yyyy-MM-dd")

                Dim date_diff = DateDiff(DateInterval.Day, CDate(paypFrom), CDate(paypTo))

                numofweekdays = 0

                For i = 0 To date_diff

                    Dim DayOfWeek = CDate(paypFrom).AddDays(i)

                    If DayOfWeek.DayOfWeek = 0 Then 'System.DayOfWeek.Sunday
                        numofweekends += 1

                    ElseIf DayOfWeek.DayOfWeek = 6 Then 'System.DayOfWeek.Saturday
                        numofweekends += 1
                    Else
                        numofweekdays += 1

                    End If

                Next

                If _year <> yearnow Then

                    _year = yearnow

                    Dim n_ExecuteQuery As _
                            New ExecuteQuery("SELECT EXISTS(SELECT RowID" & _
                                            " FROM paystub" & _
                                            " WHERE OrganizationID='" & org_rowid & "'" & _
                                            " AND ThirteenthMonthInclusion='1'" & _
                                            " AND (YEAR(PayFromDate)='" & yearnow & "' OR YEAR(PayToDate)='" & yearnow & "')" & _
                                            " LIMIT 1);")

                    Dim bool_decision = Not Convert.ToBoolean(CInt(n_ExecuteQuery.Result))

                    'If n_ExecuteQuery.Result = "1" Then

                    '    bool_decision = Convert.ToBoolean(CInt(n_ExecuteQuery.Result))

                    'Else

                    '    bool_decision = Convert.ToBoolean(CInt(n_ExecuteQuery.Result))

                    'End If

                    chkbx13monCalcInclude.Checked = False

                    chkbx13monCalcInclude.Enabled = bool_decision

                End If

            End With
        Else

            _year = 0

            paypFrom = Nothing

            paypTo = Nothing

            numofweekends = 0

            numofweekdays = 0

            lblpapyperiodval.Text = ""

            ResetProperties()

        End If

    End Sub

    Private Sub cboxDivisions_DropDown(sender As Object, e As EventArgs) Handles cboxDivisions.DropDown

        Static once As Boolean = False

        If once = False Then
            once = True
        Else
            Exit Sub
        End If

        Static cb_font As Font = cboxDivisions.Font

        'Dim cb_width As Integer = cboxDivisions.DropDownWidth

        Dim grp As Graphics = cboxDivisions.CreateGraphics()

        Dim vertScrollBarWidth As Integer = If(cboxDivisions.Items.Count > cboxDivisions.MaxDropDownItems, SystemInformation.VerticalScrollBarWidth, 0)

        Dim wiidth As Integer = 0

        Dim data_source As New DataTable

        data_source = cboxDivisions.DataSource

        Dim i = 0

        Dim drp_downwidhths As Integer()

        'Try

        '    ReDim drp_downwidhths(cboxDivisions.Items.Count - 1)

        'Catch ex As Exception

        'ReDim drp_downwidhths(data_source.Rows.Count - 1)
        ReDim drp_downwidhths(data_source.Rows.Count)

        'End Try

        For Each strRow As DataRow In data_source.Rows

            wiidth = CInt(grp.MeasureString(CStr(strRow(1)), cb_font).Width) + vertScrollBarWidth

            drp_downwidhths(i) = wiidth

            'If cb_width < wiidth Then
            '    wiidth = wiidth
            'End If

            i += 1

        Next

        Dim max_drp_downwidhth As Integer = 0

        Try
            max_drp_downwidhth = drp_downwidhths.Max
        Catch ex As Exception
            max_drp_downwidhth = cboxDivisions.Width
        Finally
            cboxDivisions.DropDownWidth = max_drp_downwidhth 'wiidth, cb_width

        End Try

    End Sub

    Private Sub cboxDivisions_SelectedIndexChanged(sender As Object, e As EventArgs) Handles cboxDivisions.SelectedIndexChanged

    End Sub

    Private Sub Load_Divisions(sender As Object, e As EventArgs) Handles cboxDivisions.VisibleChanged

        If cboxDivisions.Visible Then

            'Dim str_query As String =
            '    String.Concat("SELECT dv.RowID",
            '                  ",dv.Name",
            '                  " FROM employee e",
            '                  " INNER JOIN `position` pos ON pos.RowID=e.PositionID",
            '                  " INNER JOIN division dv ON dv.RowID=pos.DivisionId AND dv.OrganizationID=e.OrganizationID",
            '                  " WHERE e.OrganizationID=", orgztnID,
            '                  " GROUP BY dv.RowID",
            '                  " HAVING COUNT(e.RowID) > 0;")

            Dim str_query As String =
                String.Concat("SELECT i.RowID, i.Name",
                              " FROM (SELECT dv.RowID",
                              "		  ,dv.Name",
                              "		  FROM employee e",
                              "		  INNER JOIN `position` pos ON pos.RowID=e.PositionID",
                              "		  INNER JOIN division dv ON dv.RowID=pos.DivisionId AND dv.OrganizationID=e.OrganizationID",
                              "		  WHERE e.OrganizationID = ", org_rowid,
                              "		  GROUP BY dv.RowID",
                              "		  HAVING COUNT(e.RowID) > 0) i",
                              " UNION",
                              " SELECT 0 `RowID`, 'All' `Name`;")

            Dim sql As New SQL(str_query)

            Dim caught_table As New DataTable
            caught_table = sql.GetFoundRows.Tables(0)

            With caught_table

                cboxDivisions.ValueMember = .Columns(0).ColumnName

                cboxDivisions.DisplayMember = .Columns(1).ColumnName

                cboxDivisions.DataSource = caught_table

            End With

            Button1.Text = "Compute"

        End If

    End Sub

#End Region

End Class