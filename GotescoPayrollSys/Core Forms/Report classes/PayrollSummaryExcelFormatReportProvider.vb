Option Strict On

Imports System.IO
Imports log4net
Imports OfficeOpenXml
Imports OfficeOpenXml.Style

Public Class PayrollSummaryExcelFormatReportProvider
    Implements IReportProvider

    Private Const ONEVALUE As Integer = 1

#Region "Vairable declarations"

    Private errlogger As ILog = LogManager.GetLogger("LoggerWork")

    Private basic_alphabet() As String =
        New String() {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
                      "AA", "AB", "AC"}

    Private column_headers() As String =
        New String() {"Code",
                      "Full name",
                      "Rate",
                      "Hrs",
                      "BasicPay",
                      "OTHrs",
                      "OT",
                      "Holiday",
                      "NDiff",
                      "NDiff OT",
                      "R.dayPay",
                      "UT",
                      "Late",
                      "Absent",
                      "Allowance",
                      "Bonus",
                      "Gross",
                      "SSS",
                      "Ph.Health",
                      "HDMF",
                      "Taxable",
                      "W.Tax",
                      "Loan",
                      "A.fee",
                      "Adj.",
                      "Net",
                      "13th",
                      "Total"}

    Private cell_mapped_text_value() As String =
        New String() {"DatCol2",
                      "DatCol3"}

    Private cell_mapped_decim_value() As String =
        New String() {"DatCol43",
                      "DatCol41",
                      "DatCol21",
                      "DatCol44",
                      "DatCol37",
                      "DatCol36",
                      "DatCol35",
                      "DatCol38",
                      "DatCol46",
                      "DatCol34",
                      "DatCol33",
                      "DatCol32",
                      "DatCol31",
                      "DatCol30",
                      "DatCol22",
                      "DatCol25",
                      "DatCol27",
                      "DatCol28",
                      "DatCol24",
                      "DatCol26",
                      "DatCol29",
                      "DatCol39",
                      "DatCol45",
                      "DatCol23",
                      "DatCol40",
                      "DatCol42"}

    Private preferred_font As Font =
        New System.Drawing.Font("Source Sans Pro", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))

    Private preferred_excel_font As ExcelFont

    Private font_size As Single = 8

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

                        Dim dataColumns = dt.Columns.OfType(Of DataColumn).Where(Function(d) Not d.ColumnName = "RowID")

                        Dim rowindex = ONEVALUE
                        wsheet.Row(rowindex).Style.Font.Bold = True
                        wsheet.Cells(rowindex, ONEVALUE).Value = report_header

                        rowindex += ONEVALUE
                        wsheet.Row(rowindex).Style.Font.Bold = True
                        wsheet.Cells(rowindex, ONEVALUE).Value = report_cutoff

                        rowindex += ONEVALUE

                        Dim dtcolindx = ONEVALUE
                        For Each dcol In dataColumns

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
                            For Each dataColumn In dataColumns
                                wsheet.Cells(rowindex, dataColumnIndex).Value =
                                    drow(dataColumn.ColumnName)
                                dataColumnIndex += ONEVALUE
                            Next
                            rowindex += ONEVALUE
                        Next

                        'wsheet.DeleteColumn(oneValue)

                        Dim sum_cell_range = String.Join(":",
                                                         String.Concat("C", rowindex),
                                                         String.Concat("W", rowindex))
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

#End Region

End Class