Option Strict On

Imports CrystalDecisions.CrystalReports.Engine
Imports MySql.Data.MySqlClient

Public Class LoanSummaryReportProvider
    Implements IReportProvider

    Public Property Name As String = "Loan Payment Report" Implements IReportProvider.Name

    Public Property GotescoReportName As String = "Employee Loan Report" Implements IReportProvider.GotescoReportName

    Private ReadOnly stringType As Type = Type.GetType("System.String")
    Private ReadOnly decimalType As Type = Type.GetType("System.Decimal")

    Public Sub Run() Implements IReportProvider.Run
        Method3Async()
    End Sub

    Private Sub Method1()

        Dim n_PayrollSummaDateSelection As New PayPeriodSelectionWithLoanTypes

        If n_PayrollSummaDateSelection.ShowDialog = Windows.Forms.DialogResult.OK Then

            Dim date_from, date_to, _loanTypeID As Object

            date_from = n_PayrollSummaDateSelection.DateFrom
            date_to = n_PayrollSummaDateSelection.DateTo
            _loanTypeID = n_PayrollSummaDateSelection.LoanTypeId

            Dim sql_print_employee_loanreports As _
                New SQL("CALL RPT_loans(?og_rowid, ?date_f, ?date_t, ?loan_typeid);",
                        New Object() {org_rowid, date_from, date_to, _loanTypeID})

            Try

                Dim dt As New DataTable

                dt = sql_print_employee_loanreports.GetFoundRows.Tables(0)

                If sql_print_employee_loanreports.HasError Then

                    Throw sql_print_employee_loanreports.ErrorException
                Else

                    Dim rptdoc As New LoanReports

                    rptdoc.SetDataSource(dt)

                    Dim crvwr As New CrysRepForm

                    Dim objText As TextObject = Nothing

                    objText = DirectCast(rptdoc.ReportDefinition.Sections(1).ReportObjects("PeriodDate"), TextObject)

                    objText.Text =
                        String.Concat("for the period of ",
                                      DirectCast(date_from, Date).ToShortDateString,
                                       " to ",
                                      DirectCast(date_to, Date).ToShortDateString)

                    objText = DirectCast(rptdoc.ReportDefinition.Sections(1).ReportObjects("txtOrganizationName"), TextObject)

                    objText.Text = orgNam.ToUpper

                    crvwr.crysrepvwr.ReportSource = rptdoc

                    crvwr.Show()

                End If
            Catch ex As Exception

                MsgBox(getErrExcptn(ex, Name))
            Finally

            End Try

        End If

    End Sub

    Private Sub Method2()

        Dim n_PayrollSummaDateSelection As New PayPeriodSelectionWithLoanTypes

        If n_PayrollSummaDateSelection.ShowDialog = Windows.Forms.DialogResult.OK Then

            Dim date_from, date_to, _loanTypeID As Object

            date_from = n_PayrollSummaDateSelection.DateFrom
            date_to = n_PayrollSummaDateSelection.DateTo
            _loanTypeID = n_PayrollSummaDateSelection.LoanTypeId

            Dim sql_print_employee_loanreports As _
                New SQL("CALL RPT_loansummary(?og_rowid, ?date_f, ?date_t, ?loan_typeid);",
                        New Object() {org_rowid, date_from, date_to, _loanTypeID})

            Try

                Dim dt As New DataTable 'DS1.DatTbl2DataTable

                'dt = sql_print_employee_loanreports.GetFoundRows.Tables(0)
                sql_print_employee_loanreports.ExecuteQuery()

                If sql_print_employee_loanreports.HasError Then

                    Throw sql_print_employee_loanreports.ErrorException
                Else

                    Dim ds As New DataSet
                    ds = sql_print_employee_loanreports.GetFoundRows

                    Dim first_tbl As DataTable
                    first_tbl = ds.Tables(0)

                    'Console.WriteLine(dt.Columns.Count)
                    'dt.Columns.Clear()

                    'For Each col As DataColumn In first_tbl.Columns
                    '    Dim newcol As New DataColumn
                    '    newcol = col
                    '    Console.WriteLine(newcol.ColumnName)
                    '    dt.Columns.Add(newcol)
                    'Next

                    dt.Merge(first_tbl)

                    Dim tbl_withrows = ds.Tables.OfType(Of DataTable).Where(Function(dtt) dtt.Rows.Count > 0)

                    For Each dtbl As DataTable In tbl_withrows
                        For Each drow As DataRow In dtbl.Rows
                            Dim row_array = drow.ItemArray
                            dt.Rows.Add(row_array)
                        Next
                    Next

                    Dim rptdoc As New LoanReports

                    rptdoc.SetDataSource(dt)

                    Dim crvwr As New CrysRepForm

                    Dim objText As TextObject = Nothing

                    objText = DirectCast(rptdoc.ReportDefinition.Sections(1).ReportObjects("PeriodDate"), TextObject)

                    objText.Text =
                        String.Concat("for the period of ",
                                      DirectCast(date_from, Date).ToShortDateString,
                                      " to ",
                                      DirectCast(date_to, Date).ToShortDateString)

                    objText = DirectCast(rptdoc.ReportDefinition.Sections(1).ReportObjects("txtOrganizationName"), TextObject)

                    objText.Text = orgNam.ToUpper

                    crvwr.crysrepvwr.ReportSource = rptdoc

                    crvwr.Show()

                End If
            Catch ex As Exception

                MsgBox(getErrExcptn(ex, Name))
            Finally

            End Try

        End If

    End Sub

    Private Async Sub Method3Async()
        Dim n_PayrollSummaDateSelection As New PayPeriodSelectionWithLoanTypes

        If Not n_PayrollSummaDateSelection.ShowDialog = DialogResult.OK Then Return

        Dim dateFrom, dateTo, loanTypeID As Object

        dateFrom = n_PayrollSummaDateSelection.DateFrom
        dateTo = n_PayrollSummaDateSelection.DateTo
        loanTypeID = n_PayrollSummaDateSelection.LoanTypeId

        Dim queryText = String.Empty
        'Dim filtersLoanType = <![CDATA[INNER JOIN product p ON p.RowID=i.LoanTypeID]]>.Value
        'If Not IsDBNull(loanTypeID) Then filtersLoanType = <![CDATA[INNER JOIN product p ON p.RowID=i.LoanTypeID AND i.RowID=@loanTypeID]]>.Value

        queryText =
        <![CDATA[CALL `LoanPrediction`(@orgID);
            SELECT
            i.RowID
            , e.EmployeeID `DatCol1`
            , CONCAT_WS(', ', e.LastName, e.FirstName) `DatCol2`
            , p.PartNo `DatCol3`
            , i.ProperDeductAmount `DatCol4`
            , i.PayFromDate
            #, REPLACE(TRIM(TRAILING 0 FROM i.LoanBalance), ',', '')*1 `DatCol6`
            , i.LoanBalance `DatCol6`
            ,DATE_FORMAT(i.`PayToDate`, '%c/%e/%Y') `DatCol5`
            FROM (SELECT lp.*
                  FROM loanpredict lp
                  WHERE LCASE(lp.`Status`) IN ('in progress', 'complete')
                  AND lp.DiscontinuedDate IS NULL
                UNION
                  SELECT lp.*
                  FROM loanpredict lp
                  WHERE LCASE(lp.`Status`) = 'cancelled'
                  AND lp.DiscontinuedDate IS NOT NULL
                  ) i
            INNER JOIN employee e ON e.RowID=i.EmployeeID
            INNER JOIN product p ON p.RowID=i.LoanTypeID AND p.RowID=IFNULL(@loanTypeID, p.RowID)
            INNER JOIN paystub ps ON ps.EmployeeID=e.RowID AND ps.PayPeriodID=i.PayperiodID
            INNER JOIN paystubitem psi ON psi.PayStubID=ps.RowID AND psi.ProductID=p.RowID
            /*WHERE i.PayFromDate>=@dateFrom
            AND i.PayToDate<=@dateTo*/
            AND ((i.PayFromDate BETWEEN @dateFrom AND @dateTo)
                 AND (i.PayToDate BETWEEN @dateFrom AND @dateTo))
            ORDER BY CONCAT(e.LastName, e.FirstName), i.RowID, i.PayFromDate, i.PayToDate
            ;]]>.Value

        Dim columns =
            {New DataColumn("DatCol1", stringType),
            New DataColumn("DatCol2", stringType),
            New DataColumn("DatCol3", stringType),
            New DataColumn("DatCol4", decimalType),
            New DataColumn("DatCol5", stringType),
            New DataColumn("DatCol6", decimalType)}

        Dim dt As New DataTable
        dt.Columns.AddRange(columns)

        Dim succeed = False

        Using connection As New MySqlConnection(connectionString),
            command As New MySqlCommand(queryText, connection)

            With command.Parameters
                .AddWithValue("@orgID", org_rowid)
                .AddWithValue("@dateFrom", dateFrom)
                .AddWithValue("@dateTo", dateTo)
                .AddWithValue("@loanTypeID", loanTypeID) 'If(IsDBNull(loanTypeID), "NULL", loanTypeID)
            End With

            Await connection.OpenAsync()
            Try
                Dim reader = Await command.ExecuteReaderAsync()
                succeed = reader.HasRows

                While Await reader.ReadAsync()
                    dt.Rows.Add({reader.GetValue(Of String)(columns.First.ColumnName),
                                reader.GetValue(Of String)(columns(1).ColumnName),
                                reader.GetValue(Of String)(columns(2).ColumnName),
                                reader.GetValue(Of Decimal)(columns(3).ColumnName),
                                reader.GetValue(Of String)(columns(4).ColumnName),
                                reader.GetValue(Of Decimal)(columns.Last.ColumnName)})
                End While
            Catch ex As Exception
                MessageBox.Show($"Failed generating the Loan Payment report.{vbNewLine}{vbNewLine}{ex.Message}",
                                "Failed Loan Payment report", MessageBoxButtons.OK, MessageBoxIcon.Error)
            Finally

                If succeed Then
                    Dim rptdoc As New LoanReports

                    rptdoc.SetDataSource(dt)

                    Dim crvwr As New CrysRepForm

                    Dim objText As TextObject = Nothing

                    objText = DirectCast(rptdoc.ReportDefinition.Sections(1).ReportObjects("PeriodDate"), TextObject)

                    objText.Text =
                        String.Concat("for the period of ",
                                      DirectCast(dateFrom, Date).ToShortDateString,
                                      " to ",
                                      DirectCast(dateTo, Date).ToShortDateString)

                    objText = DirectCast(rptdoc.ReportDefinition.Sections(1).ReportObjects("txtOrganizationName"), TextObject)

                    objText.Text = orgNam.ToUpper

                    crvwr.crysrepvwr.ReportSource = rptdoc

                    crvwr.Show()
                End If

            End Try

        End Using
    End Sub

    Public Property IsFreeRangeOfDate As Boolean Implements IReportProvider.IsFreeRangeOfDate
End Class