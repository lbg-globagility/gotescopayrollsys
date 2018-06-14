Public Class LoanSummaryGroupByTypeReportProvider
    Implements IReportProvider

    Public Property Name As String = "Loan Summary Report" Implements IReportProvider.Name

    Public Property GotescoReportName As String = "Employee Loan Summary Report" Implements IReportProvider.GotescoReportName

    Public Property IsFreeRangeOfDate As Boolean Implements IReportProvider.IsFreeRangeOfDate

    Public Sub Run() Implements IReportProvider.Run

        Dim n_PayrollSummaDateSelection As New PayPeriodSelectionWithLoanTypes

        If n_PayrollSummaDateSelection.ShowDialog = Windows.Forms.DialogResult.OK Then

            Dim date_from, date_to, _loanTypeID As Object

            date_from = n_PayrollSummaDateSelection.DateFrom
            date_to = n_PayrollSummaDateSelection.DateTo
            _loanTypeID = n_PayrollSummaDateSelection.LoanTypeId

            Dim params = New Object() {org_rowid, date_from, date_to, _loanTypeID}

            Dim sql As _
                New SQL("CALL RPT_LoansByType(?og_rowid, ?date_f, ?date_t, ?loan_typeid);",
                        params)

            Try
                Dim rptdoc = New LoanSummaryGroupByType

                Dim dt As New DataTable
                dt = sql.GetFoundRows.Tables.OfType(Of DataTable).First

                rptdoc.SetDataSource(dt)

                Dim crvwr As New CrysRepForm

                crvwr.crysrepvwr.ReportSource = rptdoc

                crvwr.Show()
            Catch ex As Exception

                MsgBox(getErrExcptn(ex, Me.Name))
            End Try

        End If

    End Sub

End Class