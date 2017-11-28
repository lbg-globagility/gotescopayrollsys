
Public Class EmployeeIdentificationNumberReportProvider
    Implements IReportProvider

    Public Property Name As String = "Employee's Identification Number" Implements IReportProvider.Name

    Public Property GotescoReportName As String = "Employee's Identification Number" Implements IReportProvider.GotescoReportName

    Public Sub Run() Implements IReportProvider.Run
        Throw New NotImplementedException()
    End Sub

End Class