'Option Strict On

Public Class TimeEntryLogs

#Region "Variables"

    'Private mod1 As New Model1

    'Private _timeentrylogs As IQueryable(Of TimeEntryLogsPerCutOff) = mod1.TimeEntryLogsPerCutOff.OfType(Of TimeEntryLogsPerCutOff)()

    Private this_year As Integer = Now.Year

    Const twenty As Integer = 20

    Private page_num As Integer = 0

    Private organization_rowid As Integer = 1

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
        Console.WriteLine("DataGridViewX1_CurrentCellChanged")
    End Sub

    Private Sub DataGridViewX2_CellContentClick(sender As Object, e As DataGridViewCellEventArgs) Handles DataGridViewX2.CellContentClick

    End Sub

    Private Sub DataGridViewX2_CurrentCellChanged(sender As Object, e As EventArgs) Handles DataGridViewX2.CurrentCellChanged
        Console.WriteLine("DataGridViewX2_CurrentCellChanged")
    End Sub

    Private Sub TimeEntryLogs_FormClosing(sender As Object, e As FormClosingEventArgs) Handles MyBase.FormClosing

    End Sub

#End Region

#Region "Functions & Methods"

    Private Sub LoadPayPeriods()

        Dim _payperiods As IQueryable(Of TimeEntryLogsPerCutOff)

        Try
            Using _mod = New Model1

                _payperiods =
                    (From t In _mod.TimeEntryLogsPerCutOff
                     Order By t.MonthValue Descending, t.OrdinalValue Descending
                     Where t.YearValue = this_year And t.OrganizationId = organization_rowid
                     Group By t.PayPeriodID
                     Into tl = Group
                     Let uniquepayperiod = tl.FirstOrDefault
                     Select New With {.PayFromDate = uniquepayperiod.PayFromDate,
                                      .PayToDate = uniquepayperiod.PayToDate}
                     )

            End Using

            DataGridViewX1.DataSource = _payperiods.ToList

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
                    (From t In _mod.TimeEntryLogsPerCutOff
                     Where t.YearValue = this_year And t.OrganizationId = organization_rowid
                     Group By t.EmployeeID
                     Into tl = Group
                     Let employeeinfo = tl.FirstOrDefault
                     Select New With {.Employee_ID = employeeinfo.EmployeeUniqueKey,
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

        Try
            Using _mod = New Model1
                Dim _employees =
                    (From t In _mod.TimeEntryLogsPerCutOff
                     Where t.YearValue = this_year And
                     t.OrganizationId = organization_rowid And
                     (t.EmployeeUniqueKey.Contains(str_search) Or t.FullName.Contains(str_search))
                     Group By t.EmployeeID
                     Into tl = Group
                     Let employeeinfo = tl.FirstOrDefault
                     Select New With {.Employee_ID = employeeinfo.EmployeeUniqueKey,
                                      .Full_Name = employeeinfo.FullName}
                     ).
                    OrderBy(Function(e) e.Full_Name)

                DataGridViewX2.DataSource = _employees.ToList

            End Using

        Catch ex As Exception
            ErrorNotif(ex)
        End Try
    End Sub

    Private Sub LoadTimeLogs()

        Try
            Using _mod = New Model1

                Dim datef, datet As Date?

                Dim pp_curr_row = DataGridViewX1.Rows.OfType(Of DataGridViewRow).Where(Function(dgvr) dgvr.Selected).FirstOrDefault

                If pp_curr_row IsNot Nothing Then
                    datef = Date.Parse(pp_curr_row.Cells(0).Value)
                    datet = Date.Parse(pp_curr_row.Cells(1).Value)
                End If


                Dim e_uniq_id As String

                Dim emp_curr_row = DataGridViewX2.Rows.OfType(Of DataGridViewRow).Where(Function(dgvr) dgvr.Selected).FirstOrDefault

                If emp_curr_row IsNot Nothing Then
                    e_uniq_id = Date.Parse(pp_curr_row.Cells(0).Value)

                End If


                Dim _timelogs =
                    (From t In _mod.TimeEntryLogsPerCutOff
                     Where t.YearValue = this_year And
                     t.OrganizationId = organization_rowid And
                     t.EmployeeUniqueKey = e_uniq_id And
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
                (From t In _mod.TimeEntryLogsPerCutOff
                 Order By t.FullName
                 Where t.YearValue = this_year And t.OrganizationId = organization_rowid
                 Group By t.EmployeeID
                 Into tl = Group
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
        _logger.Error("LoadPayPeriods", ex)
    End Sub

#End Region

#Region "Properties"

#End Region

End Class