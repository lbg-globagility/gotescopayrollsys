
Public Class LeaveLedgerReportProvider
    Implements IReportProvider

    Public Property Name As String = "Leave Ledger" Implements IReportProvider.Name

    Public Property GotescoReportName As String = "Employee Leave Ledger" Implements IReportProvider.GotescoReportName

    Public Sub Run() Implements IReportProvider.Run
        Throw New NotImplementedException()
    End Sub

End Class