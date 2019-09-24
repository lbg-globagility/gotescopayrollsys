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

    Private Const adjustmentColumnName As String = "(Adj.)"
    Private Const totalAdjustmentColumnName As String = "Adj."

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


                Dim employeeIds = GetEmployeeIds(dt.Rows.OfType(Of DataRow).ToList())
                InitializeCurrentAdjustmentList(n_PayrollSummaDateSelection, employeeIds)

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
                        Dim adjustedDataColumns = AddAdjustmentsColumnHeaders(New List(Of DataColumn)(dataColumns))

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
                                wsheet.Cells(rowindex, dataColumnIndex).Value =
                                    GetCellValue(drow, dataColumn)
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

        If sourceName.EndsWith(adjustmentColumnName) Then

            If _adjustments Is Nothing Then Return 0

            Dim productName = GetAdjustmentColumnFromName(sourceName)
            Dim employeeId = Convert.ToInt32(drow(EmployeeRowIDColumnName))
            Dim paystubId = Convert.ToInt32(drow(PaystubIdColumnName))

            Dim adj = _adjustments.
                    Where(Function(a) a.Product.PartNo = productName).
                    Where(Function(a) a.Paystub.EmployeeID.Value = employeeId).
                    Where(Function(a) a.Paystub.RowID.Value = paystubId).
                    ToList

            Dim adjustment = _adjustments.
                    Where(Function(a) a.Product.PartNo = productName).
                    Where(Function(a) a.Paystub.EmployeeID.Value = employeeId).
                    Where(Function(a) a.Paystub.RowID.Value = paystubId).
                    Sum(Function(a) a.PayAmount)

            Return adjustment

        End If

        Return drow(dataColumn.ColumnName)
    End Function

#End Region

#Region "Adjustment Breakdown"

    Private _adjustments As List(Of IAdjustment)

    Public Sub InitializeCurrentAdjustmentList(
                            payrollSummaDateSelection As PayrollSummaDateSelection,
                            employeeIds As Integer())

        Using context As New DatabaseContext

            Dim payPeriodFrom As New PayPeriod
            Dim payPeriodTo As New PayPeriod

            If payrollSummaDateSelection.PayPeriodFromID IsNot Nothing Then

                Dim payPeriodFromId = Convert.ToInt32(payrollSummaDateSelection.PayPeriodFromID)

                payPeriodFrom = context.PayPeriods.
                                Where(Function(p) p.RowID = payPeriodFromId).
                                FirstOrDefault
            End If

            If payrollSummaDateSelection.PayPeriodToID IsNot Nothing Then

                Dim payPeriodToId = Convert.ToInt32(payrollSummaDateSelection.PayPeriodToID)

                payPeriodTo = context.PayPeriods.
                                Where(Function(p) p.RowID = payPeriodToId).
                                FirstOrDefault
            End If

            If payPeriodFrom?.PayFromDate Is Nothing OrElse payPeriodTo?.PayToDate Is Nothing Then

                Throw New ArgumentException("Cannot fetch pay period data.")

            End If

            Dim adjustmentQuery = GetBaseAdjustmentQuery(context.Adjustments.Where(Function(a) a.OrganizationID.Value = z_OrganizationID), payPeriodFrom.PayFromDate.Value, payPeriodTo.PayToDate.Value, employeeIds)
            Dim actualAdjustmentQuery = GetBaseAdjustmentQuery(context.ActualAdjustments.Where(Function(a) a.OrganizationID.Value = z_OrganizationID), payPeriodFrom.PayFromDate.Value, payPeriodTo.PayToDate.Value, employeeIds)

            If IsActual Then

                _adjustments = New List(Of IAdjustment)(actualAdjustmentQuery.ToList)

            Else
                _adjustments = New List(Of IAdjustment)(adjustmentQuery.ToList)

            End If

        End Using
    End Sub

    Private Function GetBaseAdjustmentQuery(query As IQueryable(Of IAdjustment), PayFromDate As Date, PayToDate As Date, employeeIds As Integer()) As IQueryable(Of IAdjustment)

        Return query.Include(Function(p) p.Product).
                    Include(Function(p) p.Paystub).
                    Include(Function(p) p.Paystub.PayPeriod).
                    Where(Function(p) p.Paystub.PayPeriod.PayFromDate.Value >= PayFromDate).
                    Where(Function(p) p.Paystub.PayPeriod.PayToDate.Value <= PayToDate).
                    Where(Function(p) employeeIds.Contains(p.Paystub.EmployeeID.Value))

    End Function

    Private Function GetEmployeeIds(allEmployees As ICollection(Of DataRow)) As Integer()

        Dim employeeIdsArray(allEmployees.Count - 1) As Integer

        For index = 0 To employeeIdsArray.Count - 1
            employeeIdsArray(index) = CInt(allEmployees(index)(EmployeeRowIDColumnName))
        Next

        Return employeeIdsArray
    End Function

    Private Function AddAdjustmentsColumnHeaders(dataColumns As IList(Of DataColumn)) _
        As IList(Of DataColumn)

        If _adjustments Is Nothing OrElse _adjustments.Count = 0 Then Return dataColumns

        Dim totalAdjustmentColumn = dataColumns.
                                        Where(Function(p) p.ColumnName = totalAdjustmentColumnName).
                                        FirstOrDefault

        If totalAdjustmentColumn Is Nothing Then Return dataColumns

        Dim groupedAdjustments = _adjustments.GroupBy(Function(a) a.ProductID).ToList

        Dim totalAdjustmentColumnIndex = dataColumns.IndexOf(totalAdjustmentColumn)

        dataColumns.Remove(totalAdjustmentColumn)

        'add the adjustment columns
        Dim index = totalAdjustmentColumnIndex
        For Each adjustment In groupedAdjustments

            Dim adjustmentName = GetAdjustmentName(adjustment(0).Product?.Name)

            dataColumns.Insert(index, New DataColumn(adjustmentName))

            index += 1
        Next

        Return dataColumns

    End Function

    Private Shared Function GetAdjustmentName(name As String) As String

        If String.IsNullOrWhiteSpace(name) Then Return Nothing

        Return $"{name} {adjustmentColumnName}"

    End Function

    Private Shared Function GetAdjustmentColumnFromName(column As String) As String

        Return column.Replace($" {adjustmentColumnName}", "")

    End Function

#End Region

End Class