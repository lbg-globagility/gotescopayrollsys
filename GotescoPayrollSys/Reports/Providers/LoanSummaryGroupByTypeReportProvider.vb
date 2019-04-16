Imports CrystalDecisions.CrystalReports.Engine

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

                Dim objText As TextObject = Nothing

                objText = DirectCast(rptdoc.ReportDefinition.Sections(1).ReportObjects("PeriodDate"), TextObject)

                objText.Text =
                    String.Concat("As of ",
                                  DirectCast(date_to, Date).ToLongDateString)

                objText = DirectCast(rptdoc.ReportDefinition.Sections(1).ReportObjects("txtReportTitle"), TextObject)

                objText.Text =
                    String.Concat("LOAN REPORT - SUMMARY",
                                  " (",
                                  LoanNames(_loanTypeID).Replace(",", "/"),
                                  ")")

                Dim crvwr As New CrysRepForm

                crvwr.crysrepvwr.ReportSource = rptdoc

                crvwr.Show()
            Catch ex As Exception

                MsgBox(getErrExcptn(ex, Name))
            End Try

        End If

    End Sub

    Private Function LoanNames(LoanTypeId As Object) As String
        Dim query As String =
            String.Concat("SELECT GROUP_CONCAT(p.PartNo) `Result`",
                          " FROM product p",
                          " INNER JOIN category c ON c.CategoryName='Loan Type' AND c.RowID=p.CategoryID",
                          " WHERE p.OrganizationID=?og_rowid",
                          " AND p.RowID=IFNULL(?loantypeid, p.RowID)",
                          " AND p.ActiveData='1'",
                          " ORDER BY p.PartNo",
                          ";")

        Dim params = New Object() {org_rowid, LoanTypeId}

        Dim sql As New SQL(query, params)

        Dim returnvalue As String = ""

        Try
            returnvalue = sql.GetFoundRow

            If sql.HasError Then
                Throw sql.ErrorException
            End If
        Catch ex As Exception
            returnvalue = ""
            MsgBox(getErrExcptn(ex, MyBase.ToString))
        End Try

        Return returnvalue
    End Function

End Class