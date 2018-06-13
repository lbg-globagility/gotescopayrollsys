Public Class LoanSummaryGroupByTypeReportProvider
    Implements IReportProvider

    Public Property Name As String = "Loan Summary Report" Implements IReportProvider.Name

    Public Property GotescoReportName As String = "Employee Loan Summary Report" Implements IReportProvider.GotescoReportName

    Public Property IsFreeRangeOfDate As Boolean Implements IReportProvider.IsFreeRangeOfDate

    Public Sub Run() Implements IReportProvider.Run

    End Sub

End Class