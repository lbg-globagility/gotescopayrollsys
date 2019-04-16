Option Strict On

Imports CrystalDecisions.CrystalReports.Engine

Public Class AttendanceSheetReportProvider
    Implements IReportProvider

    Public Property Name As String = "Attendance Sheet" Implements IReportProvider.Name

    Public Property GotescoReportName As String = "Attendance sheet" Implements IReportProvider.GotescoReportName

    Public Sub Run() Implements IReportProvider.Run
        Dim n_PayrollSummaDateSelection As New PayrollSummaDateSelection

        If Not n_PayrollSummaDateSelection.ShowDialog = Windows.Forms.DialogResult.OK Then
            Return
        End If

        Dim d_from = If(n_PayrollSummaDateSelection.DateFrom Is Nothing, Nothing,
                        Format(CDate(n_PayrollSummaDateSelection.DateFrom), "yyyy-MM-dd"))

        Dim d_to = If(n_PayrollSummaDateSelection.DateTo Is Nothing, Nothing,
                        Format(CDate(n_PayrollSummaDateSelection.DateTo), "yyyy-MM-dd"))

        Dim params(2, 2) As Object

        params(0, 0) = "OrganizationID"
        params(1, 0) = "FromDate"
        params(2, 0) = "ToDate"

        params(0, 1) = org_rowid
        params(1, 1) = d_from
        params(2, 1) = d_to

        Dim data = callProcAsDatTab(params, "RPT_attendance_sheet")

        Dim report = New Attendance_Sheet

        Dim objText As TextObject = DirectCast(report.ReportDefinition.Sections(2).ReportObjects("Text14"), TextObject)
        objText.Text = String.Concat("for the period of ", d_from, " to ", d_to)

        objText = DirectCast(report.ReportDefinition.Sections(2).ReportObjects("txtorgname"), TextObject)
        objText.Text = orgNam

        objText = DirectCast(report.ReportDefinition.Sections(2).ReportObjects("txtorgaddress"), TextObject)

        Dim org_address As String =
            New SQL(String.Concat("SELECT CONCAT_WS(', '",
                                  ", IF(LENGTH(TRIM(a.StreetAddress1)) = 0, NULL, a.StreetAddress1)",
                                  ", IF(LENGTH(TRIM(a.StreetAddress2)) = 0, NULL, a.StreetAddress2)",
                                  ", IF(LENGTH(TRIM(a.Barangay)) = 0, NULL, a.Barangay)",
                                  ", IF(LENGTH(TRIM(a.CityTown)) = 0, NULL, a.CityTown)",
                                  ", IF(LENGTH(TRIM(a.Country)) = 0, NULL, a.Country)",
                                  ", IF(LENGTH(TRIM(a.State)) = 0, NULL, a.State)",
                                  ") `Result`",
                                  " FROM address a",
                                  " LEFT JOIN organization o ON o.PrimaryAddressID=a.RowID",
                                  " WHERE o.RowID=", org_rowid,
                                  " AND o.PrimaryAddressID IS NOT NULL LIMIT 1;")).GetFoundRow.ToString

        objText.Text = org_address

        Dim contactdetails = CStr(EXECQUER("SELECT GROUP_CONCAT(COALESCE(MainPhone,'')" &
                                ",',',COALESCE(FaxNumber,'')" &
                                ",',',COALESCE(EmailAddress,'')" &
                                ",',',COALESCE(TINNo,''))" &
                                " FROM organization WHERE RowID=" & org_rowid & ";"))
        Dim contactdet = Split(contactdetails, ",")

        objText = DirectCast(report.ReportDefinition.Sections(2).ReportObjects("txtorgcontactno"), TextObject)

        If Not Trim(contactdet(0).ToString) = "" Then
            objText.Text = "Contact No. " & contactdet(0).ToString
        End If

        report.SetDataSource(data)

        Dim crvwr As New CrysRepForm
        crvwr.crysrepvwr.ReportSource = report
        crvwr.Show()
    End Sub

    Public Property IsFreeRangeOfDate As Boolean Implements IReportProvider.IsFreeRangeOfDate
End Class