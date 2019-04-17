Public Class SocialSecurity
    Public Property RowID As Integer
    Public Property Created As DateTime?
    Public Property CreatedBy As Integer
    Public Property LastUpd As DateTime?
    Public Property LastUpdBy As Integer?
    Public Property RangeFromAmount As Decimal
    Public Property RangeToAmount As Decimal
    Public Property MonthlySalaryCredit As Decimal
    Public Property EmployeeContributionAmount As Decimal
    Public Property EmployerContributionAmount As Decimal
    Public Property EmployeeECAmount As Decimal
    Public Property HiddenData As Char
    Public Property EffectiveDateFrom As Date
    Public Property EffectiveDateTo As Date
End Class
