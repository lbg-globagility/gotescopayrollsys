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

        Dim reportNames = _providers.Select(Function(r) r.GotescoReportName).ToList
        Dim _reportNames = String.Join(",", reportNames.ToArray)

        Dim str_quer As String =
            String.Concat("SELECT l.DisplayValue",
                          " FROM `user` u",
                          " INNER JOIN `position` upos ON upos.RowID=u.PositionID",
                          " INNER JOIN `position` pos ON pos.PositionName=upos.PositionName AND pos.OrganizationID=", org_rowid,
                          " INNER JOIN position_view pv ON pv.PositionID=pos.RowID AND pv.OrganizationID=pos.OrganizationID AND FIND_IN_SET('Y', CONCAT_WS(',', pv.ReadOnly, pv.Creates, pv.Updates, pv.Deleting)) > 0",
                          " INNER JOIN `view` v ON v.RowID=pv.ViewID",
                          " INNER JOIN listofval l ON l.DisplayValue=v.ViewName AND FIND_IN_SET(l.DisplayValue, ?reportNames) > 0",
                          " WHERE u.RowID = ", user_row_id, ";")
        Dim dataTable =
                New SQL(str_quer, New Object() {_reportNames}).GetFoundRows.Tables(0)

        Dim dRows = dataTable.Rows.OfType(Of DataRow)
        For Each drow In dRows
            Dim repName = Convert.ToString(drow(0))
            Dim reportProvidr = providers.Where(Function(rp) Equals(rp.GotescoReportName, repName))

            If reportProvidr.Any Then
                Dim provider = reportProvidr.FirstOrDefault
                Dim newListItem = New ListViewItem(provider.Name)
                newListItem.Tag = provider

                lvMainMenu.Items.Add(newListItem)
            Else
                Continue For
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
            MsgBox(getErrExcptn(ex, Name))
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

    Private Sub ReportsList_FormClosed(sender As Object, e As FormClosedEventArgs) Handles MyBase.FormClosed

    End Sub

    Private Sub ReportsList_FormClosing(sender As Object, e As FormClosingEventArgs) Handles MyBase.FormClosing
        FormReports.listReportsForm.Remove(Name)
    End Sub

    Private Sub tsbtnClose_Click(sender As Object, e As EventArgs) Handles tsbtnClose.Click
        Close()
    End Sub

End Class