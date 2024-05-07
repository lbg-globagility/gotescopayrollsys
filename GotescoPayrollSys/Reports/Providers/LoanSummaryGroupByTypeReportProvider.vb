Imports CrystalDecisions.CrystalReports.Engine

Public Class LoanSummaryGroupByTypeReportProvider
    Implements IReportProvider

    Public Property Name As String = "Loan Summary Report" Implements IReportProvider.Name

    Public Property GotescoReportName As String = "Employee Loan Summary Report" Implements IReportProvider.GotescoReportName

    Public Property IsFreeRangeOfDate As Boolean Implements IReportProvider.IsFreeRangeOfDate

    Public Sub Run() Implements IReportProvider.Run
        Dim form As New PayPeriodsSelectionDialog(z_OrganizationID, True)
        If Not form.ShowDialog() = DialogResult.OK Then Return

        Dim selectedPayPeriodIds = form.SelectedPayPeriodIds
        Dim selectedLoanTypeIds = form.SelectedLoanTypeIds
        Dim loanTypeID = If(selectedLoanTypeIds?.FirstOrDefault(), 0)
        Dim startDate = form.StartDate
        Dim endDate = form.EndDate
        Dim loanTypeIds = String.Join(",", selectedLoanTypeIds)

        Dim params = New Object() {org_rowid, startDate, endDate, loanTypeID, loanTypeIds}

        Dim sql As _
            New SQL("CALL RPT_LoansByType(?og_rowid, ?date_f, ?date_t, ?loan_typeid, ?loan_typeids);",
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
                              endDate.Value.ToLongDateString)

            objText = DirectCast(rptdoc.ReportDefinition.Sections(1).ReportObjects("txtReportTitle"), TextObject)

            objText.Text =
                String.Concat("LOAN REPORT - SUMMARY",
                              " (",
                              LoanNames(loanTypeID).Replace(",", "/"),
                              ")")

            Dim crvwr As New CrysRepForm

            crvwr.crysrepvwr.ReportSource = rptdoc

            crvwr.Show()
        Catch ex As Exception

            MsgBox(getErrExcptn(ex, Name))
        End Try
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