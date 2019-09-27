Option Strict On

Imports System.Data.Entity
Imports System.IO
Imports AccuPay.Entity
Imports log4net
Imports OfficeOpenXml
Imports OfficeOpenXml.Style

Public Class PayrollSummaryExcelFormatReportProvider
    Implements IReportProvider

    Private Const ONEVALUE As Integer = 1

#Region "Vairable declarations"

    Private errlogger As ILog = LogManager.GetLogger("LoggerWork")

    Private Const BonusColumnSuffix As String = "(Bonus)"
    Private Const TotalBonusColumnName As String = "Bonus"

    Private Const AllowanceColumnSuffix As String = "(Alw.)"
    Private Const TotalAllowanceColumnName As String = "Allowance"

    Private Const LoanColumnSuffix As String = "(Loan)"
    Private Const TotalLoanColumnName As String = "Loan"

    Private Const AdjustmentColumnSuffix As String = "(Adj.)"
    Private Const TotalAdjustmentColumnName As String = "Adj."

    Dim margin_size() As Decimal = New Decimal() {0.25D, 0.75D, 0.3D}

    Private pp_rowid_from,
        pp_rowid_to As Object

    Private is_actual As Boolean = False

    Private sal_distrib As String = "Cash"

    Private returnvalue() As Object

    Private Const EmployeeRowIDColumnName As String = "EmployeeRowID"
    Private Const PaystubIdColumnName As String = "PaystubId"

#End Region

#Region "Properties"

    Property PayperiodIDFrom As Object

        Get
            Return pp_rowid_from
        End Get

        Set(value As Object)
            pp_rowid_from = value
        End Set

    End Property

    Property PayperiodIDTo As Object

        Get
            Return pp_rowid_to
        End Get

        Set(value As Object)
            pp_rowid_to = value
        End Set

    End Property

    Property IsActual As Boolean

        Get
            Return is_actual
        End Get

        Set(value As Boolean)
            is_actual = value
        End Set

    End Property

    Property SalaryDistribution As String

        Get
            Return sal_distrib
        End Get

        Set(value As String)
            sal_distrib = value
        End Set

    End Property

    Public Property Name As String = "" Implements IReportProvider.Name

    Public Property GotescoReportName As String = String.Empty Implements IReportProvider.GotescoReportName

    Public Property IsFreeRangeOfDate As Boolean Implements IReportProvider.IsFreeRangeOfDate

#End Region

#Region "Methods"

    Private Function ProcedureParameters() As Object()

        If pp_rowid_from Is Nothing Then

            returnvalue =
                New Object() {org_rowid,
                              pp_rowid_from,
                              pp_rowid_to,
                              is_actual,
                              sal_distrib}
        Else

            Dim n_PayrollSummaDateSelection As New PayrollSummaDateSelection

            n_PayrollSummaDateSelection.ReportIndex = 6

            If n_PayrollSummaDateSelection.ShowDialog = Windows.Forms.DialogResult.OK Then

                returnvalue =
                    New Object() {org_rowid,
                                  n_PayrollSummaDateSelection.PayPeriodFromID,
                                  n_PayrollSummaDateSelection.PayPeriodToID,
                                  is_actual,
                                  n_PayrollSummaDateSelection.cboStringParameter.Text}

            End If

        End If

        Return returnvalue

    End Function

    Public Sub Run() Implements IReportProvider.Run

        Dim n_PayrollSummaDateSelection As New PayrollSummaDateSelection

        n_PayrollSummaDateSelection.ReportIndex = 6

        If n_PayrollSummaDateSelection.ShowDialog = Windows.Forms.DialogResult.OK Then

            Dim cash_or_depo As String = n_PayrollSummaDateSelection.cboStringParameter.Text

            Dim parameters = New Object() {org_rowid,
                                           n_PayrollSummaDateSelection.DateFromID,
                                           n_PayrollSummaDateSelection.DateToID,
                                           is_actual,
                                           cash_or_depo}

            Dim sql As New SQL("CALL PAYROLLSUMMARY(?ps_OrganizationID, ?ps_PayPeriodID1, ?ps_PayPeriodID2, ?psi_undeclared, ?strSalaryDistrib);",
                               parameters)

            Try

                Dim dt As New DataTable
                'dt = sql.GetFoundRows.Tables(0)
                dt = sql.GetFoundRows.Tables.OfType(Of DataTable).FirstOrDefault

                Dim ndt =
                    (From row In dt.AsEnumerable
                     Group By val = Convert.ToString(row("DivisionName"))
                     Into Group
                     Where val.Length > 0
                     Select val)

                'Dim rpt As New PayrollSumma
                'rpt.SetDataSource(dt)

                'Dim crvwr As New CrysRepForm
                'crvwr.crysrepvwr.ReportSource = rpt
                'crvwr.Show()

                Dim fullpathfile As String =
                    String.Concat(Path.GetTempPath,
                                  "payrollsummary_", cash_or_depo.Replace(" ", "").ToLower,
                                  ".xlsx")

                Dim report_header As String =
                    Convert.ToString(New SQL(String.Concat("SELECT CONCAT('PAYROLL SUMMARY REPORT - ', og.Name) `Result`",
                                          " FROM organization og WHERE og.RowID = ", org_rowid, ";")).GetFoundRow)

                Dim report_cutoff As String =
                        Convert.ToString(New SQL(String.Concat("SELECT CONCAT('for the period of '",
                                              ", CONCAT_WS(' to ', DATE_FORMAT(pp.PayFromDate, '%c/%e/%Y'), DATE_FORMAT(pp.PayToDate, '%c/%e/%Y')))",
                                              " `Cutoff`",
                                              " FROM payperiod pp WHERE pp.RowID = ?p_rowid LIMIT 1;"),
                            New Object() {n_PayrollSummaDateSelection.DateFromID}).GetFoundRow)

                InitializeBreakdowns(n_PayrollSummaDateSelection, dt)

                Dim nfile As New FileInfo(fullpathfile)

                If nfile.Exists Then
                    nfile.Delete()
                End If

                Using xcl As New ExcelPackage(nfile)

                    For Each division_name In ndt
                        Dim wsheet = xcl.Workbook.Worksheets(division_name)

                        If wsheet IsNot Nothing Then
                            xcl.Workbook.Worksheets.Delete(wsheet)
                        End If

                        wsheet = xcl.Workbook.Worksheets.Add(division_name)

                        Dim hiddenColumns = {"RowID", EmployeeRowIDColumnName, PaystubIdColumnName}
                        Dim dataColumns = dt.Columns.OfType(Of DataColumn).Where(Function(d) Not hiddenColumns.Contains(d.ColumnName))
                        Dim adjustedDataColumns = AddBreakdownColumnHeaders(New List(Of DataColumn)(dataColumns))

                        Dim rowindex = ONEVALUE
                        wsheet.Row(rowindex).Style.Font.Bold = True
                        wsheet.Cells(rowindex, ONEVALUE).Value = report_header

                        rowindex += ONEVALUE
                        wsheet.Row(rowindex).Style.Font.Bold = True
                        wsheet.Cells(rowindex, ONEVALUE).Value = report_cutoff

                        rowindex += ONEVALUE

                        Dim dtcolindx = ONEVALUE
                        For Each dcol In adjustedDataColumns

                            wsheet.Cells(rowindex, dtcolindx).Value = dcol.ColumnName
                            dtcolindx += ONEVALUE
                            wsheet.Row(rowindex).Style.Font.Bold = True
                        Next

                        rowindex += ONEVALUE
                        Dim details_start_rowindex = rowindex

                        Dim emp_payroll =
                            dt.Select(String.Concat("DivisionName='", division_name, "'"))

                        For Each drow As DataRow In emp_payroll
                            Dim dataColumnIndex = ONEVALUE
                            For Each dataColumn In adjustedDataColumns

                                wsheet.
                                    Cells(rowindex, dataColumnIndex).
                                    Value = GetCellValue(drow, dataColumn)

                                dataColumnIndex += ONEVALUE
                            Next
                            rowindex += ONEVALUE
                        Next

                        'wsheet.DeleteColumn(oneValue)


                        Dim lastColumnLetter = GetExcelColumnName(adjustedDataColumns.Count - 1) '-1 to avoid using sum on DivisionName column

                        Dim sum_cell_range = String.Join(":",
                                                         String.Concat("C", rowindex),
                                                         String.Concat(lastColumnLetter, rowindex))
                        ''FromRow, FromColumn, ToRow, ToColumn
                        'wsheet.Cells(sum_cell_range).Formula = String.Format("SUBTOTAL(9,{0})") ', New ExcelAddress(2, 3, 4, 3).Address)

                        wsheet.Cells(sum_cell_range).Formula =
                                String.Format("SUM({0})",
                                              New ExcelAddress(details_start_rowindex,
                                                               3,
                                                               (rowindex - ONEVALUE),
                                                               3).Address) 'column_headers.Count

                        wsheet.Cells(sum_cell_range).Style.Font.Bold = True

                        wsheet.PrinterSettings.Orientation = eOrientation.Landscape

                        wsheet.PrinterSettings.PaperSize = ePaperSize.Legal

                        wsheet.PrinterSettings.TopMargin = margin_size(ONEVALUE)
                        wsheet.PrinterSettings.BottomMargin = margin_size(ONEVALUE)
                        wsheet.PrinterSettings.LeftMargin = margin_size(0)
                        wsheet.PrinterSettings.RightMargin = margin_size(0)

                        wsheet.Cells.AutoFitColumns(2, 22.71)

                        wsheet.Cells("A1").AutoFitColumns(4.9, 5.3)

                        'wsheet.DeleteColumn(23)

                    Next

                    xcl.Save()
                End Using

                Process.Start(fullpathfile)
            Catch ex As Exception
                errlogger.Error("PrintPayrollSummary", ex)
                MsgBox("Something went wrong, see log file.", MsgBoxStyle.Critical)
            End Try

        End If

    End Sub

    Private Function GetExcelColumnName(columnNumber As Integer) As String
        Dim dividend As Integer = columnNumber
        Dim columnName As String = String.Empty
        Dim modulo As Integer

        While dividend > 0
            modulo = (dividend - 1) Mod 26
            columnName = Convert.ToChar(65 + modulo).ToString() & columnName
            dividend = CInt((dividend - modulo) / 26)
        End While

        Return columnName
    End Function

    Private Function GetCellValue(drow As DataRow, dataColumn As DataColumn) As Object

        Dim sourceName = dataColumn.ColumnName
        Dim employeeId = Convert.ToInt32(drow(EmployeeRowIDColumnName))
        Dim paystubId = Convert.ToInt32(drow(PaystubIdColumnName))

        If sourceName.EndsWith(BonusColumnSuffix) OrElse
            sourceName.EndsWith(AllowanceColumnSuffix) Then

            Dim productName = String.Empty
            Dim paystubItems As New List(Of PaystubItem)

            If sourceName.EndsWith(BonusColumnSuffix) Then

                productName = GetPaystubItemColumnFromName(sourceName, BonusColumnSuffix)
                paystubItems = _bonuses

            ElseIf sourceName.EndsWith(AllowanceColumnSuffix) Then

                productName = GetPaystubItemColumnFromName(sourceName, AllowanceColumnSuffix)
                paystubItems = _allowances

            End If

            Return paystubItems.
                        Where(Function(a) a.Product.PartNo.ToUpper = productName.ToUpper).
                        Where(Function(a) a.Paystub.EmployeeID.Value = employeeId).
                        Where(Function(a) a.Paystub.RowID.Value = paystubId).
                        Sum(Function(a) a.PayAmount)

        ElseIf sourceName.EndsWith(LoanColumnSuffix) Then

            If _loans Is Nothing Then Return 0

            Dim productName = GetPaystubItemColumnFromName(sourceName, LoanColumnSuffix)

            'Dim lean = _loans.
            '        Where(Function(l) l.EmployeeId = employeeId).
            '        Where(Function(l) l.PaystubId = paystubId).
            '        ToList

            Return _loans.
                    Where(Function(l) l.LoanName.ToUpper = productName.ToUpper).
                    Where(Function(l) l.EmployeeId = employeeId).
                    Where(Function(l) l.PaystubId = paystubId).
                    Sum(Function(l) l.DeductionAmount)


        ElseIf sourceName.EndsWith(AdjustmentColumnSuffix) Then

            If _adjustments Is Nothing Then Return 0

            Dim productName = GetPaystubItemColumnFromName(sourceName, AdjustmentColumnSuffix)

            Return _adjustments.
                    Where(Function(a) a.Product.PartNo.ToUpper = productName.ToUpper).
                    Where(Function(a) a.Paystub.EmployeeID.Value = employeeId).
                    Where(Function(a) a.Paystub.RowID.Value = paystubId).
                    Sum(Function(a) a.PayAmount)

        End If

        Return drow(dataColumn.ColumnName)
    End Function

#End Region

#Region "Breakdowns Helper"

    Private _allowances As List(Of PaystubItem)

    Private _bonuses As List(Of PaystubItem)

    Public Function GetStartingPayPeriod(
                        payrollSummaDateSelection As PayrollSummaDateSelection) _
                        As PayPeriod

        Using context As New DatabaseContext

            If payrollSummaDateSelection.PayPeriodFromID IsNot Nothing Then

                Dim payPeriodFromId = Convert.ToInt32(payrollSummaDateSelection.PayPeriodFromID)

                Return context.PayPeriods.
                                Where(Function(p) p.RowID = payPeriodFromId).
                                FirstOrDefault
            End If

            Return Nothing

        End Using
    End Function

    Public Function GetEndingPayPeriod(
                        payrollSummaDateSelection As PayrollSummaDateSelection) _
                        As PayPeriod

        Using context As New DatabaseContext

            If payrollSummaDateSelection.PayPeriodToID IsNot Nothing Then

                Dim payPeriodToId = Convert.ToInt32(payrollSummaDateSelection.PayPeriodToID)

                Return context.PayPeriods.
                                Where(Function(p) p.RowID = payPeriodToId).
                                FirstOrDefault
            End If

            Return Nothing

        End Using
    End Function

    Private Sub InitializeBreakdowns(n_PayrollSummaDateSelection As PayrollSummaDateSelection, dt As DataTable)

        Dim employeeIds = GetEmployeeIds(dt.Rows.OfType(Of DataRow).ToList())
        Dim startingPayPeriod = GetStartingPayPeriod(n_PayrollSummaDateSelection)
        Dim endingPayPeriod = GetEndingPayPeriod(n_PayrollSummaDateSelection)

        If startingPayPeriod?.PayFromDate Is Nothing OrElse endingPayPeriod?.PayToDate Is Nothing Then

            Throw New ArgumentException("Cannot fetch pay period data.")

        End If

        '_loans = GetPayStubItems(startingPayPeriod, endingPayPeriod, employeeIds, ProductConstant.LoanTypeCategory)

        '_loans = GetLoans(startingPayPeriod.RowID)

        _allowances = GetPayStubItems(startingPayPeriod, endingPayPeriod, employeeIds, ProductConstant.AllowanceTypeCategory)

        _bonuses = GetPayStubItems(startingPayPeriod, endingPayPeriod, employeeIds, ProductConstant.BonusCategory)

        _adjustments = GetPaystubAdjustments(startingPayPeriod, endingPayPeriod, employeeIds)
    End Sub
    Private Function GetBasePaystubItemQuery(query As IQueryable(Of PaystubItem), PayFromDate As Date, PayToDate As Date, employeeIds As Integer(), productCategory As String) As IQueryable(Of PaystubItem)

        Return query.Include(Function(p) p.Product).
                    Include(Function(p) p.Paystub).
                    Include(Function(p) p.Paystub.PayPeriod).
                    Where(Function(p) p.Paystub.PayPeriod.PayFromDate.Value >= PayFromDate).
                    Where(Function(p) p.Paystub.PayPeriod.PayToDate.Value <= PayToDate).
                    Where(Function(p) employeeIds.Contains(p.Paystub.EmployeeID.Value)).
                    Where(Function(p) p.OrganizationID.Value = z_OrganizationID).
                    Where(Function(p) p.Product.CategoryText = productCategory).
                    Where(Function(p) p.PayAmount <> 0)

    End Function

    Public Function GetPayStubItems(
                            startingPayPeriod As PayPeriod,
                            endingPayPeriod As PayPeriod,
                            employeeIds As Integer(),
                            productCategory As String) _
                            As List(Of PaystubItem)

        Using context As New DatabaseContext

            If startingPayPeriod?.PayFromDate Is Nothing OrElse endingPayPeriod?.PayToDate Is Nothing Then

                Throw New ArgumentException("Cannot fetch pay period data.")

            End If

            Dim paystubItemQuery = GetBasePaystubItemQuery(
                                        context.PayStubItems,
                                        startingPayPeriod.PayFromDate.Value,
                                        endingPayPeriod.PayToDate.Value,
                                        employeeIds,
                                        productCategory)

            Return paystubItemQuery.ToList

        End Using
    End Function

    Private Function GetEmployeeIds(allEmployees As ICollection(Of DataRow)) As Integer()

        Dim employeeIdsArray(allEmployees.Count - 1) As Integer

        For index = 0 To employeeIdsArray.Count - 1
            employeeIdsArray(index) = CInt(allEmployees(index)(EmployeeRowIDColumnName))
        Next

        Return employeeIdsArray
    End Function

    Private Function AddBreakdownColumnHeaders(dataColumns As IList(Of DataColumn)) _
        As IList(Of DataColumn)

        'bonuses
        dataColumns = AddPaystubColumnHeaders(
                            dataColumns,
                            _bonuses,
                            TotalBonusColumnName,
                            BonusColumnSuffix)

        'allowances
        dataColumns = AddPaystubColumnHeaders(
                            dataColumns,
                            _allowances,
                            TotalAllowanceColumnName,
                            AllowanceColumnSuffix)

        'loans
        dataColumns = AddLoansColumnHeaders(dataColumns)

        'adjustments
        dataColumns = AddAdjustmentsColumnHeaders(dataColumns)

        Return dataColumns
    End Function

    Private Function AddPaystubColumnHeaders(
                        dataColumns As IList(Of DataColumn),
                        paystubItems As List(Of PaystubItem),
                        totalPaystubItemColumnName As String,
                        paystubItemColumnSuffix As String) _
                        As IList(Of DataColumn)

        If paystubItems Is Nothing OrElse paystubItems.Count = 0 Then Return dataColumns

        Dim totalPaystubColumn = dataColumns.
                                        Where(Function(p) p.ColumnName = totalPaystubItemColumnName).
                                        FirstOrDefault

        If totalPaystubColumn Is Nothing Then Return dataColumns

        Dim groupedPaystubItems = paystubItems.GroupBy(Function(a) a.ProductID).ToList

        Dim totalPaystubItemColumnIndex = dataColumns.IndexOf(totalPaystubColumn)

        dataColumns.Remove(totalPaystubColumn)

        'add the paystub item columns
        Dim index = totalPaystubItemColumnIndex
        For Each paystubItem In groupedPaystubItems

            Dim paystubItemName = GetPaystubItemName(paystubItem(0).Product?.Name, paystubItemColumnSuffix)

            dataColumns.Insert(index, New DataColumn(paystubItemName))

            index += 1
        Next

        Return dataColumns

    End Function

    Private Shared Function GetPaystubItemName(name As String, paystubItemColumnSuffix As String) As String

        If String.IsNullOrWhiteSpace(name) Then Return Nothing

        Return $"{name} {paystubItemColumnSuffix}"

    End Function

    Private Shared Function GetPaystubItemColumnFromName(column As String, columnSuffix As String) As String

        Return column.Replace($" {columnSuffix}", "")

    End Function

#End Region

#Region "Loan Breakdown"

    Private _loans As List(Of LoanModel)

    Private Class LoanModel

        Public Property ProductId As Integer
        Public Property LoanName As String
        Public Property LoanNumber As String

        Public Property DeductionAmount As Decimal

        Public Property EmployeeId As Integer
        Public Property PaystubId As Integer

    End Class

    Private Function GetLoans(payPeriodId As Integer) As List(Of LoanModel)

        Dim loans = New SQL("CALL GET_employeeloanschedules_ofthisperiod_not_summed(?og_rowid, ?pp_rowid);",
                        New Object() {org_rowid, payPeriodId}).GetFoundRows.Tables.OfType(Of DataTable).First

        Dim loanModels As New List(Of LoanModel)

        For Each loan As DataRow In loans.Rows
            loanModels.Add(New LoanModel() With {
            .ProductId = CInt(loan("LoanTypeID")),
            .LoanName = loan("ProductName").ToString,
            .LoanNumber = loan("LoanNumber").ToString,
            .DeductionAmount = CDec(loan("ProperDeductAmount")),
            .EmployeeId = CInt(loan("EmployeeID")),
            .PaystubId = CInt(loan("PaystubID"))
            })

        Next

        Return loanModels

    End Function

    Private Function AddLoansColumnHeaders(dataColumns As IList(Of DataColumn)) _
        As IList(Of DataColumn)

        If _loans Is Nothing OrElse _loans.Count = 0 Then Return dataColumns

        Dim totalLoanColumn = dataColumns.
                                        Where(Function(p) p.ColumnName = TotalLoanColumnName).
                                        FirstOrDefault

        If totalLoanColumn Is Nothing Then Return dataColumns

        Dim groupedLoans = _loans.GroupBy(Function(a) a.ProductId).ToList

        Dim totalLoanColumnIndex = dataColumns.IndexOf(totalLoanColumn)

        dataColumns.Remove(totalLoanColumn)

        'add the loan columns
        Dim index = totalLoanColumnIndex
        For Each loan In groupedLoans

            Dim loanName = GetPaystubItemName(loan(0).LoanName, LoanColumnSuffix)

            dataColumns.Insert(index, New DataColumn(loanName))

            index += 1
        Next

        Return dataColumns

    End Function
#End Region

#Region "Adjustment Breakdown"

    Private _adjustments As List(Of IAdjustment)

    Public Function GetPaystubAdjustments(
                            startingPayPeriod As PayPeriod,
                            endingPayPeriod As PayPeriod,
                            employeeIds As Integer()) _
                            As List(Of IAdjustment)

        Using context As New DatabaseContext

            If startingPayPeriod?.PayFromDate Is Nothing OrElse endingPayPeriod?.PayToDate Is Nothing Then

                Throw New ArgumentException("Cannot fetch pay period data.")

            End If

            Dim adjustmentQuery = GetBaseAdjustmentQuery(context.Adjustments.Where(Function(a) a.OrganizationID.Value = z_OrganizationID), startingPayPeriod.PayFromDate.Value, endingPayPeriod.PayToDate.Value, employeeIds)
            Dim actualAdjustmentQuery = GetBaseAdjustmentQuery(context.ActualAdjustments.Where(Function(a) a.OrganizationID.Value = z_OrganizationID), startingPayPeriod.PayFromDate.Value, endingPayPeriod.PayToDate.Value, employeeIds)

            If IsActual Then

                Return New List(Of IAdjustment)(actualAdjustmentQuery.ToList)

            Else
                Return New List(Of IAdjustment)(adjustmentQuery.ToList)

            End If

        End Using
    End Function

    Private Function GetBaseAdjustmentQuery(query As IQueryable(Of IAdjustment), PayFromDate As Date, PayToDate As Date, employeeIds As Integer()) As IQueryable(Of IAdjustment)

        Return query.Include(Function(p) p.Product).
                    Include(Function(p) p.Paystub).
                    Include(Function(p) p.Paystub.PayPeriod).
                    Where(Function(p) p.Paystub.PayPeriod.PayFromDate.Value >= PayFromDate).
                    Where(Function(p) p.Paystub.PayPeriod.PayToDate.Value <= PayToDate).
                    Where(Function(p) employeeIds.Contains(p.Paystub.EmployeeID.Value))

    End Function

    Private Function AddAdjustmentsColumnHeaders(dataColumns As IList(Of DataColumn)) _
        As IList(Of DataColumn)

        If _adjustments Is Nothing OrElse _adjustments.Count = 0 Then Return dataColumns

        Dim totalAdjustmentColumn = dataColumns.
                                        Where(Function(p) p.ColumnName = TotalAdjustmentColumnName).
                                        FirstOrDefault

        If totalAdjustmentColumn Is Nothing Then Return dataColumns

        Dim groupedAdjustments = _adjustments.GroupBy(Function(a) a.ProductID).ToList

        Dim totalAdjustmentColumnIndex = dataColumns.IndexOf(totalAdjustmentColumn)

        dataColumns.Remove(totalAdjustmentColumn)

        'add the adjustment columns
        Dim index = totalAdjustmentColumnIndex
        For Each adjustment In groupedAdjustments

            Dim adjustmentName = GetPaystubItemName(
                                    adjustment(0).Product?.Name,
                                    AdjustmentColumnSuffix)

            dataColumns.Insert(index, New DataColumn(adjustmentName))

            index += 1
        Next

        Return dataColumns

    End Function

#End Region

End Class