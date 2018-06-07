Public Class AgencyFeeReportProvider
    Implements IReportProvider

    Public Property Name As String = "Agency Fee" Implements IReportProvider.Name

    Public Property GotescoReportName As String = String.Empty Implements IReportProvider.GotescoReportName

    Public Sub Run() Implements IReportProvider.Run
        Throw New NotImplementedException()
    End Sub

    Public Property IsFreeRangeOfDate As Boolean Implements IReportProvider.IsFreeRangeOfDate
End Class