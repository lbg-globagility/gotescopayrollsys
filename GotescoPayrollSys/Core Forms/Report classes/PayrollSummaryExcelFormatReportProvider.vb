Option Strict On
Imports System.IO
Imports CrystalDecisions.CrystalReports.Engine
Imports OfficeOpenXml
Imports OfficeOpenXml.Style
Imports log4net

Public Class PayrollSummaryExcelFormatReportProvider
    Implements IReportProvider

#Region "Vairable declarations"

    Private errlogger As ILog = LogManager.GetLogger("LoggerWork")

    Private basic_alphabet() As String =
        New String() {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
                      "AA", "AB"}

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

#End Region

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

                        Dim col_count = (dt.Columns.Count - 1)

                        Dim rowindex = 1
                        wsheet.Row(rowindex).Style.Font.Bold = True
                        wsheet.Cells(rowindex, 2).Value = report_header

                        rowindex = 2
                        wsheet.Row(rowindex).Style.Font.Bold = True
                        wsheet.Cells(rowindex, 2).Value = report_cutoff

                        rowindex = 3

                        Dim dtcolindx = 1
                        For Each dcol As DataColumn In dt.Columns

                            wsheet.Cells(rowindex, dtcolindx).Value = dcol.ColumnName
                            dtcolindx += 1
                            wsheet.Row(rowindex).Style.Font.Bold = True
                        Next

                        rowindex += 1
                        Dim details_start_rowindex = rowindex

                        Dim emp_payroll =
                            dt.Select(String.Concat("DivisionName='", division_name, "'"))

                        For Each drow As DataRow In emp_payroll 'dt.Rows
                            For col = 0 To col_count

                                Dim colindx = (col + 1)

                                wsheet.Cells(rowindex, colindx).Value =
                                    drow(dt.Columns(col).ColumnName)
                            Next
                            rowindex += 1
                        Next

                        wsheet.DeleteColumn(1)

                        Dim sum_cell_range = String.Join(":",
                                                         String.Concat("C", rowindex),
                                                         String.Concat("V", rowindex))
                        ''FromRow, FromColumn, ToRow, ToColumn
                        'wsheet.Cells(sum_cell_range).Formula = String.Format("SUBTOTAL(9,{0})") ', New ExcelAddress(2, 3, 4, 3).Address)

                        wsheet.Cells(sum_cell_range).Formula =
                                String.Format("SUM({0})",
                                              New ExcelAddress(details_start_rowindex,
                                                               3,
                                                               (rowindex - 1),
                                                               3).Address) 'column_headers.Count

                        wsheet.Cells(sum_cell_range).Style.Font.Bold = True

                        wsheet.PrinterSettings.Orientation = eOrientation.Landscape

                        wsheet.PrinterSettings.PaperSize = ePaperSize.Legal

                        wsheet.PrinterSettings.TopMargin = margin_size(1)
                        wsheet.PrinterSettings.BottomMargin = margin_size(1)
                        wsheet.PrinterSettings.LeftMargin = margin_size(0)
                        wsheet.PrinterSettings.RightMargin = margin_size(0)

                        wsheet.Cells.AutoFitColumns(2, 22.71)

                        wsheet.Cells("A1").AutoFitColumns(4.9, 5.3)

                        wsheet.DeleteColumn(23)

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

    Private Sub Runs()

        Static last_cell_column As String = basic_alphabet.Last

        Dim bool_result As Short = Convert.ToInt16(is_actual) 'Convert.ToInt16(SalaryActualDeclared)

        Dim parameters() As Object = ProcedureParameters()

        Dim param_item_count = parameters.Count

        Dim sql_print_employee_profiles As New SQL("CALL PAYROLLSUMMARY2(?og_rowid, ?min_pp_rowid, ?max_pp_rowid, ?is_actual, ?salaray_distrib);",
                                                   parameters)

        Dim str_salary_distrib_type As String = CStr(parameters(param_item_count - 1))

        Static one_value As Integer = 1

        Try

            Dim ds As New DataSet

            'Dim dt As New DataTable

            'dt = sql_print_employee_profiles.GetFoundRows.Tables(0)
            ds = sql_print_employee_profiles.GetFoundRows

            If sql_print_employee_profiles.HasError Then

                Throw sql_print_employee_profiles.ErrorException
            Else

                Static report_name As String = "PayrollSummary"

                Static temp_path As String = Path.GetTempPath()

                Dim str_period As String =
                    String.Concat("SELECT CONCAT_WS(',', pp.PayFromDate, ppd.PayToDate) `Result`",
                                  " FROM payperiod pp",
                                  " INNER JOIN payperiod ppd ON ppd.RowID = ", parameters(1),
                                  " WHERE pp.RowID = ", parameters(2))

                Dim pp_sql As New SQL(str_period)

                Dim cut_offs = Split(CStr(pp_sql.GetFoundRow), ",")

                Dim short_dates() As String =
                    New String() {CDate(cut_offs(0)).ToShortDateString,
                                  CDate(cut_offs(1)).ToShortDateString}

                Dim temp_file As String =
                    String.Concat(temp_path,
                                  orgNam,
                                  report_name, str_salary_distrib_type.Replace(" ", ""), "Report",
                                  String.Concat(short_dates(0).Replace("/", "-"), "TO", short_dates(1).Replace("/", "-")),
                                  ".xlsx")

                Dim date_range As String =
                    String.Concat("for the period of ", short_dates(0), " to ", short_dates(1))

                Dim newFile = New FileInfo(temp_file)

                If newFile.Exists Then
                    newFile.Delete()
                    newFile = New FileInfo(temp_file)
                End If

                'preferred_excel_font.Name = "Source Sans Pro Regular"
                'preferred_excel_font.Name = preferred_font.Name

                Using excl_pkg = New ExcelPackage(newFile)

                    Dim ii = 0

                    Dim tbl_withrows =
                        ds.Tables.OfType(Of DataTable).Where(Function(dt) dt.Rows.Count > 0)

                    For Each dtbl As DataTable In tbl_withrows

                        Dim worksheet As ExcelWorksheet =
                                excl_pkg.Workbook.Worksheets.Add(String.Concat(report_name, ii))

                        worksheet.Cells.Style.Font.Size = font_size

                        Dim cell1 = worksheet.Cells(1, one_value)

                        cell1.Value = orgNam.ToUpper
                        cell1.Style.Font.Bold = True

                        Dim cell2 = worksheet.Cells(2, one_value)

                        cell2.Value = date_range

                        Dim row_indx As Integer = 5

                        Dim col_index As Integer = one_value

                        'For Each dtcol As DataColumn In dt.Columns
                        '    worksheet.Cells(row_indx, col_index).Value = dtcol.ColumnName
                        '    col_index += one_value
                        'Next

                        For Each str_header As String In column_headers
                            Dim cell_row5 = worksheet.Cells(row_indx, col_index)
                            cell_row5.Value = str_header
                            cell_row5.Style.Font.Bold = True

                            col_index += one_value
                        Next

                        row_indx += one_value

                        Dim details_start_rowindex = row_indx

                        Dim details_last_rowindex = 0

                        Dim last_cell_range As String = String.Empty

                        For Each dtrow As DataRow In dtbl.Rows

                            Dim cell3 = worksheet.Cells(3, one_value)

                            Dim division_name = dtrow("DatCol1").ToString

                            cell3.Value =
                                String.Concat("Division: ", division_name)

                            If division_name.Length > 0 Then

                                worksheet.Name = division_name

                            End If

                            Dim row_array = dtrow.ItemArray

                            Dim i = 0

                            'For Each rowval In row_array

                            'Next

                            For Each cell_val As String In cell_mapped_text_value

                                Dim excl_colrow As String =
                                        String.Concat(basic_alphabet(i),
                                                      row_indx)

                                Dim _cells = worksheet.Cells(excl_colrow)

                                _cells.Value = dtrow(cell_val)

                                i += one_value

                            Next

                            '********************

                            For Each cell_val As String In cell_mapped_decim_value

                                Dim excl_colrow As String =
                                        String.Concat(basic_alphabet(i),
                                                      row_indx)

                                last_cell_range = basic_alphabet(i)

                                Dim _cells = worksheet.Cells(excl_colrow)

                                _cells.Value = dtrow(cell_val)

                                _cells.Style.HorizontalAlignment = ExcelHorizontalAlignment.Right

                                i += one_value

                            Next

                            details_last_rowindex = row_indx

                            row_indx += one_value

                        Next

                        'last_cell_range = String.Concat(last_cell_range, (row_indx + 1))

                        Dim sum_cell_range = String.Join(":",
                                                             String.Concat("C", row_indx),
                                                             String.Concat(last_cell_column, row_indx))
                        ''FromRow, FromColumn, ToRow, ToColumn
                        'worksheet.Cells(sum_cell_range).Formula = String.Format("SUBTOTAL(9,{0})") ', New ExcelAddress(2, 3, 4, 3).Address)

                        worksheet.Cells(sum_cell_range).Formula =
                                String.Format("SUM({0})",
                                              New ExcelAddress(details_start_rowindex,
                                                               3,
                                                               details_last_rowindex,
                                                               3).Address) 'column_headers.Count

                        worksheet.Cells(sum_cell_range).Style.Font.Bold = True

                        worksheet.PrinterSettings.Orientation = eOrientation.Landscape

                        worksheet.PrinterSettings.PaperSize = ePaperSize.Legal

                        worksheet.PrinterSettings.TopMargin = margin_size(1)
                        worksheet.PrinterSettings.BottomMargin = margin_size(1)
                        worksheet.PrinterSettings.LeftMargin = margin_size(0)
                        worksheet.PrinterSettings.RightMargin = margin_size(0)

                        worksheet.Cells.AutoFitColumns(2, 22.71)

                        worksheet.Cells("A1").AutoFitColumns(4.9, 5.3)

                        excl_pkg.Save()

                        ii += 1

                    Next

                End Using

                Process.Start(temp_file)

            End If
        Catch ex As Exception
            MsgBox(getErrExcptn(ex, Me.Name))
        End Try

    End Sub

    Private Function SalaryActualDeclared() As SalaryActualization

        Dim time_logformat As SalaryActualization

        MessageBoxManager.OK = "Declared"

        MessageBoxManager.Cancel = "Actual"

        MessageBoxManager.Register()

        Dim custom_prompt =
            MessageBox.Show("",
                            "",
                            MessageBoxButtons.OKCancel,
                            MessageBoxIcon.None,
                            MessageBoxDefaultButton.Button2)

        If custom_prompt = Windows.Forms.DialogResult.OK Then
            time_logformat = SalaryActualization.Declared
        ElseIf custom_prompt = Windows.Forms.DialogResult.Cancel Then
            time_logformat = SalaryActualization.Actual
        End If

        MessageBoxManager.Unregister()

        Return time_logformat

    End Function

End Class

Public Enum SalaryActualization As Short
    Declared = 0
    Actual = 1

End Enum