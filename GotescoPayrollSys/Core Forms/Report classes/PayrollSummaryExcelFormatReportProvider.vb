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

    Private Const PositiveAdjustmentColumnSuffix As String = "(Adj. +)"
    Private Const TotalPositiveAdjustmentColumnName As String = "Adjustment ( +)"

    Private Const NegativeAdjustmentColumnSuffix As String = "(Adj. -)"
    Private Const TotalNegativeAdjustmentColumnName As String = "Adj. (-)"

    Private Const EmployeeRowIDColumnName As String = "EmployeeRowID"
    Private Const PaystubIdColumnName As String = "PaystubId"
    Private Const FIRST_WORKSHEET_NAME As String = "Sheet1"
    Private Const SECOND_WORKSHEET_NAME As String = "Sheet2"

    Private Shared Function GetReportColumns(workSheetName As String) As ReadOnlyCollection(Of ReportColumn)
        Const basicRateColumnHeaderText As String = "BASIC RATE"
        Const allowanceRateColumnHeaderText As String = "ALLOW RATE"

        Const absentAmountSourceName As String = "AbsentAmount"
        Const lateAmountSourceName As String = "LateAmount"
        Const underTimeAmountSourceName As String = "UndertimeAmount"

        Const netPayColumnHeaderText As String = "NET PAY"
        Dim reportColumns = New List(Of ReportColumn)({
                New ReportColumn("PAY PERIOD", "PayperiodDescription", ColumnType.Text),
                New ReportColumn("Code", "EmployeeNumber", ColumnType.Text),
                New ReportColumn("FULL NAME", "LastName", ColumnType.Text, headerColumnSpan:=2),
                New ReportColumn("", "FirstName", ColumnType.Text),
                New ReportColumn("EMP. TYPE", "EmployeeType", ColumnType.Text),
                New ReportColumn("Work days/year", "WorkDaysPerYear", ColumnType.Text),
                New ReportColumn(basicRateColumnHeaderText, "DeclaredSalary", [optional]:=True),
                New ReportColumn(allowanceRateColumnHeaderText, "UndeclaredSalary", [optional]:=True),
                New ReportColumn("HRS", "AbsentHours", parentHeader:="ABSENT", [optional]:=True),
                New ReportColumn("AMOUNT", absentAmountSourceName, parentHeader:="ABSENT", [optional]:=True),
                New ReportColumn("HRS", "LateHours", parentHeader:="TARDINESS", [optional]:=True),
                New ReportColumn("AMOUNT", lateAmountSourceName, parentHeader:="TARDINESS", [optional]:=True),
                New ReportColumn("HRS", "UndertimeHours", parentHeader:="UNDERTIME", [optional]:=True),
                New ReportColumn("AMOUNT", underTimeAmountSourceName, parentHeader:="UNDERTIME", [optional]:=True),
                New ReportColumn("HRS", "RegularHours", parentHeader:="REGULAR"),
                New ReportColumn("AMOUNT", "RegularAmount", parentHeader:="REGULAR"),
                New ReportColumn("HRS", "OvertimeHours", parentHeader:="OVERTIME", [optional]:=True),
                New ReportColumn("AMOUNT", "OvertimeAmount", parentHeader:="OVERTIME", [optional]:=True),
                New ReportColumn("HRS", "NightDifferentialOTHours", parentHeader:="Night Diff OT", [optional]:=True),
                New ReportColumn("AMOUNT", "NightDifferentialOTAmount", parentHeader:="Night Diff OT", [optional]:=True),
                New ReportColumn("HRS", "RestDayHours", parentHeader:="Rest Day OT", [optional]:=True),
                New ReportColumn("AMOUNT", "RestDayAmount", parentHeader:="Rest Day OT", [optional]:=True),
                New ReportColumn("HRS", "HolidayHours", parentHeader:="Paid Holiday", [optional]:=True),
                New ReportColumn("AMOUNT", "HolidayAmount", parentHeader:="Paid Holiday", [optional]:=True),
                New ReportColumn("HRS", "LeaveHours", parentHeader:="Paid Leave", [optional]:=True),
                New ReportColumn("VL-AMT", "VacationLeaveAmount", parentHeader:="Paid Leave", [optional]:=True),
                New ReportColumn("SL/SIL-AMT", "SickLeaveAmount", parentHeader:="Paid Leave", [optional]:=True),
                New ReportColumn("MATERNITY-AMT", "MaternityLeaveAmount", parentHeader:="Paid Leave", [optional]:=True),
                New ReportColumn("OTHERS-AMT", "OtherLeaveAmount", parentHeader:="Paid Leave", [optional]:=True),
                New ReportColumn("ADDL VL-AMT", "AdditionalVLAmount", parentHeader:="Paid Leave", [optional]:=True),
                New ReportColumn("TOTAL LEAVE AMOUNT", "LeaveAmount", parentHeader:="Paid Leave", [optional]:=True),
                New ReportColumn(TotalAllowanceColumnName, TotalAllowanceColumnName, [optional]:=True, isBreakdown:=True),
                New ReportColumn(TotalBonusColumnName, TotalBonusColumnName, [optional]:=True, isBreakdown:=True),
                New ReportColumn(TotalPositiveAdjustmentColumnName, TotalPositiveAdjustmentColumnName, [optional]:=True, isBreakdown:=True),
                New ReportColumn("TOTAL EARNINGS", "TotalEarnings"),
                New ReportColumn("SSS", "SSS", parentHeader:="PREMIUM", [optional]:=True),
                New ReportColumn("NHIP", "PhilHealth", parentHeader:="PREMIUM", [optional]:=True),
                New ReportColumn("PAG", "HDMF", parentHeader:="PREMIUM", [optional]:=True),
                New ReportColumn("WTAX", "WithholdingTax", [optional]:=True),
                New ReportColumn(TotalLoanColumnName, TotalLoanColumnName, [optional]:=True, isBreakdown:=True),
                New ReportColumn(TotalNegativeAdjustmentColumnName, TotalNegativeAdjustmentColumnName, [optional]:=True, isBreakdown:=True),
                New ReportColumn(netPayColumnHeaderText, "Net")
            })

        If workSheetName = FIRST_WORKSHEET_NAME Then
            Dim basicRateReportColumn = reportColumns.OfType(Of ReportColumn).
                Where(Function(rc) rc.Name = basicRateColumnHeaderText).
                FirstOrDefault
            If basicRateReportColumn IsNot Nothing Then
                Dim reportColumn = reportColumns.IndexOf(basicRateReportColumn)
                With reportColumns(reportColumn)
                    .Name = "MONTHLY BASIC RATE"
                    .Source = "MonthlySalary"
                End With
            End If

            Dim netPayReportColumn = reportColumns.OfType(Of ReportColumn).
                Where(Function(rc) rc.Name = netPayColumnHeaderText).
                FirstOrDefault
            If netPayReportColumn IsNot Nothing Then
                Dim reportColumn = reportColumns.IndexOf(netPayReportColumn)
                reportColumns(reportColumn).Source = "CustomNet"
            End If

            Dim excludedReportColumns = reportColumns.OfType(Of ReportColumn).
                Where(Function(rc) {allowanceRateColumnHeaderText, TotalAllowanceColumnName}.Contains(rc.Name)).
                ToList()

            excludedReportColumns.
                ForEach(Sub(rc)
                            reportColumns.Remove(rc)
                        End Sub)

        ElseIf workSheetName = SECOND_WORKSHEET_NAME Then

            Dim absentAmountReportColumn = reportColumns.OfType(Of ReportColumn).
                Where(Function(rc) rc.Source = absentAmountSourceName).
                FirstOrDefault
            If absentAmountReportColumn IsNot Nothing Then
                Dim reportColumn = reportColumns.IndexOf(absentAmountReportColumn)
                reportColumns(reportColumn).Source = "AbsentAmountWithAllowance"
            End If

            Dim lateAmountReportColumn = reportColumns.OfType(Of ReportColumn).
                Where(Function(rc) rc.Source = lateAmountSourceName).
                FirstOrDefault
            If lateAmountReportColumn IsNot Nothing Then
                Dim reportColumn = reportColumns.IndexOf(lateAmountReportColumn)
                reportColumns(reportColumn).Source = "LateAmountWithAllowance"
            End If

            Dim underTimeAmountReportColumn = reportColumns.OfType(Of ReportColumn).
                Where(Function(rc) rc.Source = underTimeAmountSourceName).
                FirstOrDefault
            If underTimeAmountReportColumn IsNot Nothing Then
                Dim reportColumn = reportColumns.IndexOf(underTimeAmountReportColumn)
                reportColumns(reportColumn).Source = "UndertimeAmountWithAllowance"
            End If

        End If

        Return New ReadOnlyCollection(Of ReportColumn)(reportColumns)
    End Function

    Dim margin_size() As Decimal = New Decimal() {0.25D, 0.75D, 0.3D}

    Private pp_rowid_from,
        pp_rowid_to As Object

    Private is_actual As Boolean = False

    Private sal_distrib As String = "Cash"

    Private returnvalue() As Object

#End Region

#Region "Constructor"
    Public Sub New(isActual As Boolean)
        Me.IsActual = isActual
    End Sub
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
    Public ReadOnly Property IsActual As Boolean

#End Region

#Region "Methods"

    Public Sub Run() Implements IReportProvider.Run

        Dim n_PayrollSummaDateSelection As New PayrollSummaDateSelection

        n_PayrollSummaDateSelection.ReportIndex = 6

        If n_PayrollSummaDateSelection.ShowDialog = Windows.Forms.DialogResult.OK Then

            Dim cash_or_depo As String = n_PayrollSummaDateSelection.cboStringParameter.Text

            Dim parameters = New Object() {org_rowid,
                                           n_PayrollSummaDateSelection.DateFromID,
                                           is_actual,
                                            cash_or_depo}

            Dim sql As New SQL("CALL PAYROLLSUMMARY3(?ps_OrganizationID, ?ps_PayPeriodID1, ?psi_undeclared, ?strSalaryDistrib);", '
                               parameters)

            Try

                Dim dt As New DataTable
                dt = sql.GetFoundRows.Tables.OfType(Of DataTable).FirstOrDefault

                Dim fullpathfile As String =
                    String.Concat(Path.GetTempPath,
                                  "payrollsummary_", cash_or_depo.Replace(" ", "").ToLower,
                                  ".xlsx")

                InitializeBreakdowns(n_PayrollSummaDateSelection, dt)

                Dim nfile As New FileInfo(fullpathfile)

                If nfile.Exists Then
                    nfile.Delete()
                End If

                Using xcl As New ExcelPackage(nfile)

                    WriteSheet(FIRST_WORKSHEET_NAME, n_PayrollSummaDateSelection, dt, xcl)

                    WriteSheet(SECOND_WORKSHEET_NAME, n_PayrollSummaDateSelection, dt, xcl)

                    xcl.Save()
                End Using

                Process.Start(fullpathfile)
            Catch ex As Exception
                errlogger.Error("PrintPayrollSummary", ex)
                MsgBox("Something went wrong, see log file.", MsgBoxStyle.Critical)
            End Try

        End If

    End Sub

    Private Sub WriteSheet(workSheetName As String, n_PayrollSummaDateSelection As PayrollSummaDateSelection, dt As DataTable, xcl As ExcelPackage)
        If String.IsNullOrWhiteSpace(workSheetName) Then
            Throw New ArgumentException($"'{NameOf(workSheetName)}' cannot be null or whitespace", NameOf(workSheetName))
        End If

        Dim wsheet = xcl.Workbook.Worksheets(workSheetName)

        If wsheet IsNot Nothing Then
            xcl.Workbook.Worksheets.Delete(wsheet)
        End If

        wsheet = xcl.Workbook.Worksheets.Add(workSheetName)

        Dim viewableColumns = GetViewableReportColumns(dt.Rows.OfType(Of DataRow).ToList(), GetReportColumns(workSheetName))
        Dim adjustedDataColumns = AddBreakdownColumnHeaders(New List(Of ReportColumn)(viewableColumns))

        Dim lastColumnLetter = GetExcelColumnName(adjustedDataColumns.Count)

        Dim rowindex = ONEVALUE


        rowindex = CreateHeaders(CInt(n_PayrollSummaDateSelection.DateFromID), wsheet, adjustedDataColumns, rowindex)

        Dim details_start_row_index As Integer = rowindex
        rowindex = CreateDetails(dt, wsheet, adjustedDataColumns, rowindex)
        CreateTotals(wsheet, lastColumnLetter, rowindex, details_start_row_index, adjustedDataColumns)

        'add border
        Dim border_cell_range_formula = String.Join(":",
                                             String.Concat("A", details_start_row_index),
                                             String.Concat(lastColumnLetter, rowindex))

        Dim border_cell_range = wsheet.Cells(border_cell_range_formula)
        AddCellBorder(border_cell_range)

        wsheet.PrinterSettings.Orientation = eOrientation.Landscape
        wsheet.PrinterSettings.PaperSize = ePaperSize.Legal
        wsheet.PrinterSettings.TopMargin = margin_size(ONEVALUE)
        wsheet.PrinterSettings.BottomMargin = margin_size(ONEVALUE)
        wsheet.PrinterSettings.LeftMargin = margin_size(0)
        wsheet.PrinterSettings.RightMargin = margin_size(0)

        wsheet.Cells.AutoFitColumns(2, 22.71)
    End Sub

    Private Function GetViewableReportColumns(allEmployees As ICollection(Of DataRow), adjustedDataColumns As IReadOnlyCollection(Of ReportColumn)) As List(Of ReportColumn)

        Dim viewableReportColumns = New List(Of ReportColumn)
        For Each reportColumn In adjustedDataColumns
            If reportColumn.Optional Then

                Dim hasValue = False

                If reportColumn.IsBreakDown Then

                    Select Case reportColumn.Name
                        Case TotalBonusColumnName : hasValue = _bonuses.Any()
                        Case TotalAllowanceColumnName : hasValue = _allowances.Any()
                        Case TotalLoanColumnName : hasValue = _loans.Any()
                        Case TotalNegativeAdjustmentColumnName : hasValue = _negativeAdjustments.Any()
                        Case TotalPositiveAdjustmentColumnName : hasValue = _positiveAdjustments.Any()

                        Case Else
                            hasValue = False
                    End Select
                Else

                    hasValue = allEmployees.
                                Any(Function(row) Not IsDBNull(row(reportColumn.Source)) AndAlso Not CDbl(row(reportColumn.Source)) = 0)
                End If

                If hasValue Then
                    viewableReportColumns.Add(reportColumn)
                End If
            Else
                viewableReportColumns.Add(reportColumn)
            End If
        Next

        Return viewableReportColumns

    End Function

    Private Shared Sub AddCellBorder(border_cell_range As ExcelRange)
        border_cell_range.Style.Border.Top.Style = ExcelBorderStyle.Thin
        border_cell_range.Style.Border.Left.Style = ExcelBorderStyle.Thin
        border_cell_range.Style.Border.Right.Style = ExcelBorderStyle.Thin
        border_cell_range.Style.Border.Bottom.Style = ExcelBorderStyle.Thin
    End Sub

    Private Sub CreateTotals(ByRef wsheet As ExcelWorksheet, lastColumnLetter As String, rowindex As Integer, ByRef details_start_row_index As Integer, adjustedDataColumns As IList(Of ReportColumn))


        Dim firstCellOfSummations = adjustedDataColumns.
                                    FirstOrDefault(Function(f) f.Type = ColumnType.Numeric)
        'add TOTAL label
        Dim TotalCellColumn = 4 'Column of First Name
        wsheet.Cells(rowindex, TotalCellColumn).Value = "TOTAL"
        'Add the sums
        Dim firstCellOfSummationsIndex = adjustedDataColumns.IndexOf(firstCellOfSummations) + 1 '+ 1 because excel start at 1 and not 0
        Dim sum_cell_range = String.Join(":",
                                String.Concat(GetExcelColumnName(firstCellOfSummationsIndex), rowindex),
                                String.Concat(lastColumnLetter, rowindex))
        wsheet.Cells(sum_cell_range).Formula =
                    String.Format("SUM({0})",
                                  New ExcelAddress(details_start_row_index,
                                                   firstCellOfSummationsIndex,
                                                   (rowindex - ONEVALUE),
                                                   firstCellOfSummationsIndex).Address) 'column_headers.Count
        wsheet.Cells(sum_cell_range).Style.Numberformat.Format = "#,##0.00_);(#,##0.00)"
    End Sub

    Private Function CreateDetails(dt As DataTable, wsheet As ExcelWorksheet, adjustedDataColumns As IList(Of ReportColumn), rowindex As Integer) As Integer
        For Each drow As DataRow In dt.Rows
            Dim dataColumnIndex = ONEVALUE
            For Each dataColumn In adjustedDataColumns

                Dim cell = wsheet.Cells(rowindex, dataColumnIndex)
                cell.Value = GetCellValue(drow, dataColumn, dt.Columns.OfType(Of DataColumn))

                dataColumnIndex += ONEVALUE

                If dataColumn.Type = ColumnType.Numeric Then
                    cell.Style.Numberformat.Format = "_(* #,##0.00_);_(* (#,##0.00);_(* ??_);_(@_)"
                    cell.Style.HorizontalAlignment = ExcelHorizontalAlignment.Right
                ElseIf dataColumn.Type = ColumnType.Text Then
                    cell.Style.HorizontalAlignment = ExcelHorizontalAlignment.Left
                End If
            Next
            rowindex += ONEVALUE
        Next

        Return rowindex
    End Function

    Private Function CreateHeaders(payPeriodId As Integer,
                                          ByRef wsheet As ExcelWorksheet,
                                          adjustedDataColumns As IList(Of ReportColumn),
                                          rowindex As Integer) As Integer

        Dim reportHeader As String = orgNam

        Dim reportCutoff As String

        Dim spaceAfterReportHeader = 2

        Dim currentPayPeriod As New PayPeriod
        Dim nextPayPeriod As New PayPeriod

        Using context As New DatabaseContext

            currentPayPeriod = context.PayPeriods.Find(payPeriodId)

            If currentPayPeriod Is Nothing Then
                Throw New Exception("Cannot find current payperiod.")
            End If

            nextPayPeriod = context.PayPeriods.
                                Where(Function(p) p.OrganizationID.Value = currentPayPeriod.OrganizationID.Value).
                                Where(Function(p) p.PayFrequencyID.Value = currentPayPeriod.PayFrequencyID.Value).
                                Where(Function(p) p.PayFromDate.Value > currentPayPeriod.PayFromDate.Value).
                                OrderBy(Function(p) p.PayFromDate).
                                FirstOrDefault
        End Using

        reportCutoff = $"for the period of {currentPayPeriod.PayFromDate.Value.ToShortDateString()} to {currentPayPeriod.PayToDate.Value.ToShortDateString()} "

        Dim column_start_header = 1
        wsheet.Row(rowindex).Style.Font.Bold = True
        wsheet.Cells(rowindex, column_start_header).Value = reportHeader

        rowindex += ONEVALUE
        wsheet.Row(rowindex).Style.Font.Bold = True
        wsheet.Cells(rowindex, column_start_header).Value = "PAYROLL SUMMARY REPORT - " & nextPayPeriod?.PayFromDate.Value.ToShortDateString()

        rowindex += ONEVALUE
        wsheet.Row(rowindex).Style.Font.Bold = True
        wsheet.Cells(rowindex, column_start_header).Value = reportCutoff

        rowindex += ONEVALUE + spaceAfterReportHeader

        Dim columnIndex = ONEVALUE
        'Headers
        rowindex = CreateParentDetailHeader(wsheet, adjustedDataColumns, rowindex)
        CreateDetailsHeader(wsheet, adjustedDataColumns, rowindex, columnIndex)

        rowindex += ONEVALUE


        Return rowindex
    End Function

    Private Function CreateParentDetailHeader(wsheet As ExcelWorksheet, adjustedDataColumns As IList(Of ReportColumn), rowindex As Integer) As Integer

        If (adjustedDataColumns.Where(Function(c) Not String.IsNullOrWhiteSpace(c.ParentHeader)).Any = False) Then
            Return rowindex
        End If

        Dim dataColumnIndex = ONEVALUE


        For index = 0 To adjustedDataColumns.Count - 1

            Dim currentReportColumn = adjustedDataColumns(index)

            If String.IsNullOrWhiteSpace(currentReportColumn.ParentHeader) Then
                Continue For
            End If

            dataColumnIndex = ONEVALUE + index

            Dim cell = wsheet.Cells(rowindex, dataColumnIndex)
            cell.Value = currentReportColumn.ParentHeader
            cell.Style.HorizontalAlignment = ExcelHorizontalAlignment.Center

            If String.IsNullOrEmpty(currentReportColumn.ParentHeader) Then
                AddCellBorder(cell)
                Continue For
            End If

            Dim parentHeaderSpan = adjustedDataColumns.
                            Where(Function(c) c.ParentHeader = currentReportColumn.ParentHeader).
                            Count

            Dim headerEndCellColumnIndex = dataColumnIndex + (parentHeaderSpan - 1) '- 1 because if starting Cell is A1 and end cell is C1, that will be a 3 column span.

            Dim mergedCell = wsheet.Cells(String.Join(":",
                        String.Concat(GetExcelColumnName(dataColumnIndex), rowindex),
                        String.Concat(GetExcelColumnName(headerEndCellColumnIndex), rowindex)))

            mergedCell.Merge = True
            AddCellBorder(mergedCell)

            index = headerEndCellColumnIndex - 1
        Next

        Return rowindex + ONEVALUE 'Because we added one row for the parent detail headers.
    End Function

    Private Sub CreateDetailsHeader(wsheet As ExcelWorksheet, adjustedDataColumns As IList(Of ReportColumn), rowindex As Integer, columnIndex As Integer)
        For Each column In adjustedDataColumns

            Dim headerCell = wsheet.Cells(rowindex, columnIndex)
            headerCell.Value = column.Name
            headerCell.Style.HorizontalAlignment = ExcelHorizontalAlignment.Center

            If column.HeaderColumnSpan > 1 Then

                Dim headerEndCellColumnIndex = columnIndex + (column.HeaderColumnSpan - 1) '- 1 because if starting Cell is A1 and end cell is C1, that will be a 3 column span.

                Dim mergedCell = wsheet.Cells(String.Join(":",
                            String.Concat(GetExcelColumnName(columnIndex), rowindex),
                            String.Concat(GetExcelColumnName(headerEndCellColumnIndex), rowindex)))

                mergedCell.Merge = True

                columnIndex = headerEndCellColumnIndex
            Else
                columnIndex += ONEVALUE
            End If

            AddCellBorder(headerCell)

        Next
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


        ElseIf sourceName.EndsWith(PositiveAdjustmentColumnSuffix) Then

            If _positiveAdjustments Is Nothing Then Return 0

            Dim productName = GetPaystubItemColumnFromName(sourceName, PositiveAdjustmentColumnSuffix)

            Return _positiveAdjustments.
                    Where(Function(a) a.Product.PartNo.ToUpper = productName.ToUpper).
                    Where(Function(a) a.Paystub.EmployeeID.Value = employeeId).
                    Where(Function(a) a.Paystub.RowID.Value = paystubId).
                    Sum(Function(a) a.PayAmount)

        ElseIf sourceName.EndsWith(NegativeAdjustmentColumnSuffix) Then

            If _negativeAdjustments Is Nothing Then Return 0

            Dim productName = GetPaystubItemColumnFromName(sourceName, NegativeAdjustmentColumnSuffix)

            Return _negativeAdjustments.
                    Where(Function(a) a.Product.PartNo.ToUpper = productName.ToUpper).
                    Where(Function(a) a.Paystub.EmployeeID.Value = employeeId).
                    Where(Function(a) a.Paystub.RowID.Value = paystubId).
                    Sum(Function(a) a.PayAmount)

        End If


        If dataColumns.Where(Function(c) c.ColumnName = reportColumn.Source).Any Then
            If reportColumn.Type = ColumnType.Numeric Then

                Dim value = drow(reportColumn.Source)
                Return If(IsDBNull(value) OrElse String.IsNullOrWhiteSpace(value.ToString()), 0, CDbl(drow(reportColumn.Source)))
            Else
                Return drow(reportColumn.Source)
            End If


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

        _loans = GetLoans(startingPayPeriod.RowID, employeeIds)

        _allowances = GetPayStubItems(startingPayPeriod, endingPayPeriod, employeeIds, ProductConstant.AllowanceTypeCategory)

        _bonuses = GetPayStubItems(startingPayPeriod, endingPayPeriod, employeeIds, ProductConstant.BonusCategory)

        Dim adjustments = GetPaystubAdjustments(startingPayPeriod, endingPayPeriod, employeeIds)

        _negativeAdjustments = adjustments.Where(Function(a) a.PayAmount < 0).ToList
        _positiveAdjustments = adjustments.Where(Function(a) a.PayAmount > 0).ToList
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

        'positive adjustments
        dataColumns = AddPositiveAdjustmentsColumnHeaders(dataColumns)

        'negative adjustments
        dataColumns = AddNegativeAdjustmentsColumnHeaders(dataColumns)

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

            dataColumns.Insert(index, New ReportColumn(paystubItemName, paystubItemName))

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

    Private Function GetLoans(payPeriodId As Integer, employeeIds As Integer()) As List(Of LoanModel)

        Dim loans = New SQL("CALL GET_employeeloanschedules_ofthisperiod_not_summed(?og_rowid, ?pp_rowid);",
                        New Object() {org_rowid, payPeriodId}).GetFoundRows.Tables.OfType(Of DataTable).First

        Dim loanModels As New List(Of LoanModel)

        For Each loan As DataRow In loans.Rows

            If Not employeeIds.Contains(CInt(loan("EmployeeID"))) Then
                Continue For
            End If

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

            dataColumns.Insert(index, New ReportColumn(loanName, loanName))

            index += 1
        Next

        Return dataColumns

    End Function
#End Region

#Region "Adjustment Breakdown"

    Private _negativeAdjustments As List(Of IAdjustment)
    Private _positiveAdjustments As List(Of IAdjustment)

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

    Private Function AddPositiveAdjustmentsColumnHeaders(dataColumns As IList(Of ReportColumn)) _
        As IList(Of ReportColumn)

        If _positiveAdjustments Is Nothing OrElse _positiveAdjustments.Count = 0 Then Return dataColumns

        Dim totalAdjustmentColumn = dataColumns.
                                        Where(Function(p) p.Name = TotalPositiveAdjustmentColumnName).
                                        FirstOrDefault

        If totalAdjustmentColumn Is Nothing Then Return dataColumns

        Dim groupedAdjustments = _positiveAdjustments.GroupBy(Function(a) a.ProductID).ToList

        Dim totalAdjustmentColumnIndex = dataColumns.IndexOf(totalAdjustmentColumn)

        dataColumns.Remove(totalAdjustmentColumn)

        'add the adjustment columns
        Dim index = totalAdjustmentColumnIndex
        For Each adjustment In groupedAdjustments

            Dim adjustmentName = GetPaystubItemName(
                                    adjustment(0).Product?.Name,
                                    PositiveAdjustmentColumnSuffix)

            dataColumns.Insert(index, New ReportColumn(adjustmentName, adjustmentName))

            index += 1
        Next

        Return dataColumns

    End Function
    Private Function AddNegativeAdjustmentsColumnHeaders(dataColumns As IList(Of ReportColumn)) _
        As IList(Of ReportColumn)

        If _negativeAdjustments Is Nothing OrElse _negativeAdjustments.Count = 0 Then Return dataColumns

        Dim totalAdjustmentColumn = dataColumns.
                                        Where(Function(p) p.Name = TotalNegativeAdjustmentColumnName).
                                        FirstOrDefault

        If totalAdjustmentColumn Is Nothing Then Return dataColumns

        Dim groupedAdjustments = _negativeAdjustments.GroupBy(Function(a) a.ProductID).ToList

        Dim totalAdjustmentColumnIndex = dataColumns.IndexOf(totalAdjustmentColumn)

        dataColumns.Remove(totalAdjustmentColumn)

        'add the adjustment columns
        Dim index = totalAdjustmentColumnIndex
        For Each adjustment In groupedAdjustments

            Dim adjustmentName = GetPaystubItemName(
                                    adjustment(0).Product?.Name,
                                    NegativeAdjustmentColumnSuffix)

            dataColumns.Insert(index, New ReportColumn(adjustmentName, adjustmentName))

            index += 1
        Next

        Return dataColumns

    End Function

#End Region

#Region "Private Classes"
    Private Class ReportColumn

        Public Property Name As String
        Public Property HeaderColumnSpan As Integer
        Public Property ParentHeader As String
        Public Property Type As ColumnType
        Public Property Source As String
        Public Property [Optional] As Boolean
        Public Property IsBreakDown As Boolean

        Public Sub New(name As String,
                       source As String,
                       Optional type As ColumnType = ColumnType.Numeric,
                       Optional [optional] As Boolean = False,
                       Optional headerColumnSpan As Integer = 1,
                       Optional parentHeader As String = Nothing,
                       Optional isBreakdown As Boolean = False)
            Me.Name = name
            Me.Source = source
            Me.Type = type
            Me.Optional = [optional]
            Me.HeaderColumnSpan = headerColumnSpan
            Me.ParentHeader = parentHeader
            Me.IsBreakDown = isBreakdown
        End Sub

    End Class

    Private Enum ColumnType
        Text
        Numeric
    End Enum
#End Region

End Class