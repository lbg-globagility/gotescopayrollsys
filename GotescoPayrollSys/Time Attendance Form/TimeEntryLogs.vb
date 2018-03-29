'Option Strict On

Public Class TimeEntryLogs

#Region "Variables"

    'Private mod1 As New Model1

    'Private _timeentrylogs As IQueryable(Of TimeEntryLogsPerCutOff) = mod1.TimeEntryLogsPerCutOff.OfType(Of TimeEntryLogsPerCutOff)()

    Private this_year As Integer = Now.Year

    Const twenty As Integer = 20

    Private page_num As Integer = 0

    Private organization_rowid As Integer = 1

    Private e_uniq_id As String

#End Region

#Region "Event Handlers"

    Protected Overrides Sub OnLoad(e As EventArgs)
        
        PrevYear.Text = (this_year - 1)
        NxtYear.Text = (this_year + 1)

        MyBase.OnLoad(e)

        organization_rowid = 1 'org_rowid


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

#End Region

#Region "Functions & Methods"

    Private Sub LoadPayPeriods()

        Try
            Using _mod = New Model1

                Dim _payperiods =
                    (From t In _mod.TimeEntryLogsPerCutOff
                     Order By t.PayFromDate Descending,t.PayToDate
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
                                      .Full_Name = employeeinfo.FullName}
                     ).
                 OrderBy(Function(e) e.Full_Name).
                 Skip(_page).Take(twenty)

                DataGridViewX2.DataSource = _employees.ToList

            End Using

        Catch ex As Exception
            ErrorNotif(ex)
        End Try
    End Sub

    Private Sub SearchEmployees()

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
                                          .Full_Name = employeeinfo.FullName}
                         ).
                     OrderBy(Function(e) e.Full_Name)

                    DataGridViewX2.DataSource = _employees.ToList

                End Using

            Catch ex As Exception
                ErrorNotif(ex)
            End Try
        Else
            First_LinkClicked(First, New LinkLabelLinkClickedEventArgs(New LinkLabel.Link))
        End If

    End Sub

    Private Sub LoadTimeLogs()

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
                If emp_curr_row IsNot Nothing Then
                    e_uniq_id = Convert.ToString(emp_curr_row.Cells(0).Value)

                End If


                Dim _timelogs =
                    (From t In _mod.TimeEntryLogsPerCutOff
                     Where t.YearValue = this_year And
                     t.OrganizationId = organization_rowid And
                     String.Equals(t.EmployeeUniqueKey, e_uniq_id) And
                     (t.DateValue >= datef And t.DateValue <= datet)
                     Let timeloginfo = t
                     Select New With {.Time_In = timeloginfo.TimeIn,
                                      .Time_Out = timeloginfo.TimeOut,
                                      .Date_Attended = timeloginfo.DateValue}
                     )

                DataGridViewX3.DataSource = _timelogs.ToList

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
        MsgBox("Something went wrong, see log file.", MsgBoxStyle.Critical)

        Dim st As StackTrace = New StackTrace(ex, True)
        Dim sf As StackFrame = st.GetFrame(st.FrameCount - 1)

        _logger.Error(sf.GetMethod.Name, ex)
    End Sub

#End Region

#Region "Properties"

#End Region

End Class