
Public Class PostEmploymentClearanceReportProvider
    Implements IReportProvider

    Public Property Name As String = "Post Employment Clearance" Implements IReportProvider.Name

    Public Property GotescoReportName As String = String.Empty Implements IReportProvider.GotescoReportName

    Public Sub Run() Implements IReportProvider.Run
        Throw New NotImplementedException("No decision yet what employment clearance would look like.")
    End Sub

End Class