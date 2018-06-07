'Option Strict On

Imports CrystalDecisions.CrystalReports.Engine

Public Class LeaveLedgerReportProvider
    Implements IReportProvider

    Public Property GotescoReportName As String = "Employee Leave Ledger" Implements IReportProvider.GotescoReportName

    Public Property Name As String = "Leave Ledger" Implements IReportProvider.Name

    Public Sub Run() Implements IReportProvider.Run
        Dim dateSelector As New PayrollSummaDateSelection()

        If Not dateSelector.ShowDialog = Windows.Forms.DialogResult.OK Then
            Return
        End If

        Dim dateFrom = dateSelector.DateFrom
        Dim dateTo = dateSelector.DateTo

        Dim sql_print_leaveledger_reports As _
            New SQL("CALL RPT_leave_ledger(?OrganizID, ?paramDateFrom, ?paramDateTo, ?PayPeriodDateFromID, ?PayPeriodDateToID);",
                    New Object() {org_rowid, MYSQLDateFormat(dateFrom), MYSQLDateFormat(dateTo), dateSelector.PayPeriodFromID, dateSelector.PayPeriodToID})

        Dim data As New DataTable '= DirectCast(callProcAsDatTab(params, "RPT_leave_ledger"), DataTable)

        Try
            data = sql_print_leaveledger_reports.GetFoundRows.Tables.OfType(Of DataTable).First

            If sql_print_leaveledger_reports.HasError Then

                Throw sql_print_leaveledger_reports.ErrorException
            Else
                Dim report = New Employee_Leave_Ledger()
                report.SetDataSource(data)

                Dim title = DirectCast(report.ReportDefinition.Sections(1).ReportObjects("txtCutoffDate"), TextObject)

                Dim dateFromTitle = Convert.ToDateTime(Date.Parse(Convert.ToString(dateFrom))).ToShortDateString
                Dim dateToTitle = Convert.ToDateTime(Date.Parse(Convert.ToString(dateTo))).ToShortDateString

                title.Text = String.Concat("From ", dateFromTitle, " to ", dateToTitle)

                Dim viewer As New CrysRepForm()
                viewer.crysrepvwr.ReportSource = report
                viewer.Show()
            End If
        Catch ex As Exception

            MsgBox(getErrExcptn(ex, Me.Name))
        End Try
    End Sub

    Public Property IsFreeRangeOfDate As Boolean Implements IReportProvider.IsFreeRangeOfDate
End Class