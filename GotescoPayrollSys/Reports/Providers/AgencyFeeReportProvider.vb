Public Class AgencyFeeReportProvider
    Implements IReportProvider
    Private Const LocalReportName As String = "Agency Fee"

    Public Property Name As String = LocalReportName Implements IReportProvider.Name

    Public Property GotescoReportName As String = LocalReportName Implements IReportProvider.GotescoReportName

    Public Sub Run() Implements IReportProvider.Run
        Throw New NotImplementedException()
    End Sub

    Public Property IsFreeRangeOfDate As Boolean Implements IReportProvider.IsFreeRangeOfDate
End Class