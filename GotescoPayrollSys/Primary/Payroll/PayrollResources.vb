Option Strict On

Public Class PayrollResources
    Private _payPeriodID As Integer
    Private _payDateFrom As Date
    Private _payDateTo As Date

    Public Sub New(payPeriodID As Integer, payDateFrom As Date, payDateTo As Date)
        _payPeriodID = payPeriodID
        _payDateFrom = payDateFrom
        _payDateTo = payDateTo
    End Sub

End Class
