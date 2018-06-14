Imports System.Xml.XPath
Imports System.Collections.ObjectModel
Imports CrystalDecisions.CrystalReports.Engine
Imports System.IO
Imports System.Text.RegularExpressions

Public Class ReportsList

    Private Sub ReportsList_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        Dim providers = New Collection(Of IReportProvider) From {
            New AttendanceSheetReportProvider(),
            New SalaryIncreaseHistoryReportProvider(),
            New EmploymentRecordReportProvider(),
            New EmployeeIdentificationNumberReportProvider(),
            New EmployeeOffenseReportProvider(),
            New PayrollLedgerReportProvider(),
            New LeaveLedgerReportProvider(),
            New PagIBIGMonthlyReportProvider(),
            New ThirteenthMonthPayReportProvider(),
            New ThirteenthMonthSummaryReportProvider(),
            New LoanSummaryReportProvider(),
            New LoanSummaryByTypeReportProvider(),
            New LoanSummaryGroupByTypeReportProvider(),
            New EmployeeProfilesReportProvider(),
            New PhilHealthReportProvider(),
            New SSSMonthlyReportProvider(),
            New TaxReportProvider(),
            New PostEmploymentClearanceReportProvider(),
            New AgencyFeeReportProvider(),
            New LeaveBalanceSummaryReportProvider(),
            New FiledLeavesReportProvider()
        }

        Dim _providers =
            providers.OfType(Of IReportProvider).Where(Function(p) p.GotescoReportName.Length > 0)

        Dim str_quer As String =
            String.Concat("SELECT REPLACE(l.DisplayValue, '\'', '') `DisplayValue`",
                          " FROM listofval l",
                          " INNER JOIN `user` u ON u.RowID=", user_row_id,
                          " INNER JOIN position_view pv ON pv.PositionID = u.PositionID AND pv.OrganizationID = ", org_rowid, " AND pv.ReadOnly = 'Y'",
                          " INNER JOIN `view` v ON v.RowID=pv.ViewID AND v.ViewName=l.DisplayValue",
                          " WHERE l.`Type` = 'Report List'",
                          " AND l.Active = 'Yes';")

        For Each provider In _providers 'providers
            Dim dataTable =
                New SQL(str_quer).GetFoundRows.Tables(0)
            'New SQL("SELECT REPLACE(l.DisplayValue, '\'', '') `DisplayValue` FROM listofval l WHERE l.`Type` = 'Report List';").GetFoundRows.Tables(0)
            'New SQL("SELECT l.DisplayValue FROM listofval l WHERE l.`Type` = 'ReportProviders';").GetFoundRows.Tables(0)

            'Dim type = provider.GetType().Name
            Dim type = provider.GotescoReportName

            Dim str_query = OutputText.Display("DisplayValue = '{0}'", type.Replace("'", ""))

            Dim found = dataTable.Select(str_query).Count >= 1

            If found Then
                Dim newListItem = New ListViewItem(provider.Name)
                newListItem.Tag = provider

                lvMainMenu.Items.Add(newListItem)
            End If
        Next
    End Sub

    Private Sub lvMainMenu_KeyDown(sender As Object, e As KeyEventArgs) Handles lvMainMenu.KeyDown
        If lvMainMenu.Items.Count > 0 Then
            If e.KeyCode = Keys.Enter Then
                report_maker()
            End If
        End If
    End Sub

    Private Sub lvMainMenu_MouseDoubleClick(sender As Object, e As MouseEventArgs) Handles lvMainMenu.MouseDoubleClick
        If lvMainMenu.Items.Count > 0 And e.Button = Windows.Forms.MouseButtons.Left Then
            report_maker()
        End If
    End Sub

    Sub report_maker()
        Dim n_listviewitem As New ListViewItem

        Try
            n_listviewitem = lvMainMenu.SelectedItems(0)
        Catch ex As Exception
            MsgBox(getErrExcptn(ex, Me.Name))
            Exit Sub
        End Try

        If TypeOf n_listviewitem.Tag Is IReportProvider Then
            Dim provider = DirectCast(n_listviewitem.Tag, IReportProvider)

            Try
                provider.Run()
            Catch ex As NotImplementedException
                MsgBox(String.Concat("Report Is Not Yet Done: ", ex.Message), MsgBoxStyle.OkOnly)
            End Try
        End If
    End Sub

    Private Sub Open_Remote_Connection(Optional strComputer As String = "GLOBAL-A-PC\Users\Public\Downloads\Test1.txt",
                                       Optional strUsername As String = Nothing,
                                       Optional strPassword As String = Nothing)
        '//====================================================================================
        '//using NET USE to open a connection to the remote computer
        '//with the specified credentials. if we dont do this first, File.Copy will fail
        '//====================================================================================
        Dim ProcessStartInfo As New System.Diagnostics.ProcessStartInfo
        ProcessStartInfo.FileName = "net"
        ProcessStartInfo.Arguments = "use \\" & strComputer & "\c$ /USER:" & strUsername & " " & strPassword
        ProcessStartInfo.WindowStyle = ProcessWindowStyle.Maximized 'Hidden
        System.Diagnostics.Process.Start(ProcessStartInfo)

        '//============================================================================
        '//wait 2 seconds to let the above command complete or the copy will still fail
        '//============================================================================
        System.Threading.Thread.Sleep(2000)

    End Sub

End Class