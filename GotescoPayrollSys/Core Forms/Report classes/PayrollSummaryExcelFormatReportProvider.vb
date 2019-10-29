Option Strict On

Imports System.Collections.ObjectModel
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

    Private Const EmployeeRowIDColumnName As String = "EmployeeRowID"
    Private Const PaystubIdColumnName As String = "PaystubId"

    Private ReadOnly _reportColumns As IReadOnlyCollection(Of ReportColumn) = GetReportColumns()

    Private Shared Function GetReportColumns() As ReadOnlyCollection(Of ReportColumn)

        Dim reportColumns = New List(Of ReportColumn)({
                New ReportColumn("", "LastName", ColumnType.Text),
                New ReportColumn("", "FirstName", ColumnType.Text),
                New ReportColumn("HRS", "LateHours"),
                New ReportColumn("TARDINESS", "LateAmount"),
                New ReportColumn("HRS", "AbsentHours"),
                New ReportColumn("ABSENT", "AbsentAmount"),
                New ReportColumn("HRS", "LeaveHours"),
                New ReportColumn("LEAVE BASIC", "LeaveAmount"),
                New ReportColumn("OT HRS", "OvertimeHours"),
                New ReportColumn("AMOUNT OT", "OvertimeAmount"),
                New ReportColumn("ND Pay", "NightDiffPay"),
                New ReportColumn(TotalBonusColumnName, TotalBonusColumnName),
                New ReportColumn("SALARIES BASIC", "GrossWithoutAllowance"),
                New ReportColumn(TotalAllowanceColumnName, TotalAllowanceColumnName),
                New ReportColumn("SSS", "SSS"),
                New ReportColumn("NHIP", "PhilHealth"),
                New ReportColumn("PAG", "HDMF"),
                New ReportColumn("WTAX", "WithholdingTax"),
                New ReportColumn(TotalLoanColumnName, TotalLoanColumnName),
                New ReportColumn(TotalAdjustmentColumnName, TotalAdjustmentColumnName),
                New ReportColumn("NET", "Net")
            })

        Return New ReadOnlyCollection(Of ReportColumn)(reportColumns)
    End Function


    Dim margin_size() As Decimal = New Decimal() {0.25D, 0.75D, 0.3D}

    Private pp_rowid_from,
        pp_rowid_to As Object

    Private is_actual As Boolean = False

    Private sal_distrib As String = "Cash"

    Private returnvalue() As Object

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

                    Dim workSheetName = "Sheet1"

                    Dim wsheet = xcl.Workbook.Worksheets(workSheetName)

                    If wsheet IsNot Nothing Then
                        xcl.Workbook.Worksheets.Delete(wsheet)
                    End If

                    wsheet = xcl.Workbook.Worksheets.Add(workSheetName)

                    Dim adjustedDataColumns = AddBreakdownColumnHeaders(New List(Of ReportColumn)(_reportColumns))

                    Dim rowindex = ONEVALUE
                    wsheet.Row(rowindex).Style.Font.Bold = True
                    wsheet.Cells(rowindex, ONEVALUE).Value = report_header

                    rowindex += ONEVALUE
                    wsheet.Row(rowindex).Style.Font.Bold = True
                    wsheet.Cells(rowindex, ONEVALUE).Value = report_cutoff

                    rowindex += ONEVALUE

                    Dim dtcolindx = ONEVALUE
                    'Headers
                    For Each dcol In adjustedDataColumns

                        wsheet.Cells(rowindex, dtcolindx).Value = dcol.Name
                        dtcolindx += ONEVALUE
                        wsheet.Row(rowindex).Style.Font.Bold = True
                    Next

                    rowindex += ONEVALUE
                    Dim details_start_rowindex = rowindex

                    'Details
                    For Each drow As DataRow In dt.Rows
                        Dim dataColumnIndex = ONEVALUE
                        For Each dataColumn In adjustedDataColumns

                            Dim cell = wsheet.Cells(rowindex, dataColumnIndex)
                            cell.Value = GetCellValue(drow, dataColumn, dt.Columns.OfType(Of DataColumn))

                            dataColumnIndex += ONEVALUE

                            If dataColumn.Type = ColumnType.Numeric Then
                                cell.Style.Numberformat.Format = "_(* #,##0.00_);_(* (#,##0.00);_(* ??_);_(@_)"
                                cell.Style.HorizontalAlignment = ExcelHorizontalAlignment.Right
                            End If
                        Next
                        rowindex += ONEVALUE
                    Next


                    Dim lastColumnLetter = GetExcelColumnName(adjustedDataColumns.Count)

                    Dim sum_cell_range = String.Join(":",
                                                         String.Concat("C", rowindex),
                                                         String.Concat(lastColumnLetter, rowindex))
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

    Private Function GetCellValue(drow As DataRow,
                                  reportColumn As ReportColumn,
                                  dataColumns As IEnumerable(Of DataColumn)) As Object

        Dim sourceName = reportColumn.Source
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

            Return _loans.
                    Where(Function(l) l.LoanName.ToUpper = productName.ToUpper).
                    Where(Function(l) l.EmployeeId = employeeId).
                    Sum(Function(l) l.DeductionAmount)
            'Where(Function(l) l.PaystubId = paystubId).


        ElseIf sourceName.EndsWith(AdjustmentColumnSuffix) Then

            If _adjustments Is Nothing Then Return 0

            Dim productName = GetPaystubItemColumnFromName(sourceName, AdjustmentColumnSuffix)

            Return _adjustments.
                    Where(Function(a) a.Product.PartNo.ToUpper = productName.ToUpper).
                    Where(Function(a) a.Paystub.EmployeeID.Value = employeeId).
                    Where(Function(a) a.Paystub.RowID.Value = paystubId).
                    Sum(Function(a) a.PayAmount)

        End If


        If dataColumns.Where(Function(c) c.ColumnName = reportColumn.Source).Any Then
            Return drow(reportColumn.Source)

        End If

        Return String.Empty

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

        _loans = GetLoans(startingPayPeriod.RowID)

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

    Private Function AddBreakdownColumnHeaders(dataColumns As IList(Of ReportColumn)) _
        As IList(Of ReportColumn)

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
                        dataColumns As IList(Of ReportColumn),
                        paystubItems As List(Of PaystubItem),
                        totalPaystubItemColumnName As String,
                        paystubItemColumnSuffix As String) _
                        As IList(Of ReportColumn)

        If paystubItems Is Nothing OrElse paystubItems.Count = 0 Then Return dataColumns

        Dim totalPaystubColumn = dataColumns.
                                        Where(Function(p) p.Name = totalPaystubItemColumnName).
                                        FirstOrDefault

        If totalPaystubColumn Is Nothing Then Return dataColumns

        Dim groupedPaystubItems = paystubItems.GroupBy(Function(a) a.ProductID).ToList

        Dim totalPaystubItemColumnIndex = dataColumns.IndexOf(totalPaystubColumn)

        dataColumns.Remove(totalPaystubColumn)

        'add the paystub item columns
        Dim index = totalPaystubItemColumnIndex
        For Each paystubItem In groupedPaystubItems

            Dim paystubItemName = GetPaystubItemName(paystubItem(0).Product?.Name, paystubItemColumnSuffix)

            dataColumns.Insert(index, New ReportColumn(paystubItemName))

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

    Private Function AddLoansColumnHeaders(dataColumns As IList(Of ReportColumn)) _
        As IList(Of ReportColumn)

        If _loans Is Nothing OrElse _loans.Count = 0 Then Return dataColumns

        Dim totalLoanColumn = dataColumns.
                                        Where(Function(p) p.Name = TotalLoanColumnName).
                                        FirstOrDefault

        If totalLoanColumn Is Nothing Then Return dataColumns

        Dim groupedLoans = _loans.GroupBy(Function(a) a.ProductId).ToList

        Dim totalLoanColumnIndex = dataColumns.IndexOf(totalLoanColumn)

        dataColumns.Remove(totalLoanColumn)

        'add the loan columns
        Dim index = totalLoanColumnIndex
        For Each loan In groupedLoans

            Dim loanName = GetPaystubItemName(loan(0).LoanName, LoanColumnSuffix)

            dataColumns.Insert(index, New ReportColumn(loanName))

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

    Private Function AddAdjustmentsColumnHeaders(dataColumns As IList(Of ReportColumn)) _
        As IList(Of ReportColumn)

        If _adjustments Is Nothing OrElse _adjustments.Count = 0 Then Return dataColumns

        Dim totalAdjustmentColumn = dataColumns.
                                        Where(Function(p) p.Name = TotalAdjustmentColumnName).
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

            dataColumns.Insert(index, New ReportColumn(adjustmentName))

            index += 1
        Next

        Return dataColumns

    End Function

#End Region

#Region "Private Classes"
    Private Class ReportColumn

        Public Property Name As String
        Public Property Type As ColumnType
        Public Property Source As String
        Public Property [Optional] As Boolean

        Public Sub New(name As String,
                       Optional source As String = "",
                       Optional type As ColumnType = ColumnType.Numeric,
                       Optional [optional] As Boolean = False)
            Me.Name = name
            Me.Source = source
            Me.Type = type
            Me.Optional = [optional]
        End Sub

    End Class

    Private Enum ColumnType
        Text
        Numeric
    End Enum
#End Region

End Class