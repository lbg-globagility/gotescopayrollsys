Public Class SalariesWithSSS
    Implements ISalary

    Public Property RowID As Integer Implements ISalary.RowID

    Public Property EmployeeID As Integer Implements ISalary.EmployeeID

    Public Property Created As Date Implements ISalary.Created

    Public Property CreatedBy As Integer Implements ISalary.CreatedBy

    Public Property LastUpd As Date? Implements ISalary.LastUpd

    Public Property LastUpdBy As Integer? Implements ISalary.LastUpdBy

    Public Property OrganizationID As Integer? Implements ISalary.OrganizationID

    Public Property FilingStatusID As Integer? Implements ISalary.FilingStatusID

    Public Property PaySocialSecurityID As Integer? Implements ISalary.PaySocialSecurityID

    Public Property PayPhilhealthID As Integer? Implements ISalary.PayPhilhealthID

    Public Property PhilHealthDeduction As Decimal? Implements ISalary.PhilHealthDeduction

    Public Property HDMFAmount As Decimal? Implements ISalary.HDMFAmount

    Public Property TrueSalary As Decimal? Implements ISalary.TrueSalary

    Public Property BasicPay As Decimal? Implements ISalary.BasicPay

    Public Property SalaryAmount As Decimal? Implements ISalary.SalaryAmount

    Public Property UndeclaredSalary As Decimal? Implements ISalary.UndeclaredSalary

    Public Property BasicDailyPay As Decimal? Implements ISalary.BasicDailyPay

    Public Property BasicHourlyPay As Decimal? Implements ISalary.BasicHourlyPay

    Public Property NoofDependents As Integer? Implements ISalary.NoofDependents

    Public Property MaritalStatus As String Implements ISalary.MaritalStatus

    Public Property PositionID As Integer? Implements ISalary.PositionID

    Public Property EffectiveDateFrom As Date? Implements ISalary.EffectiveDateFrom

    Public Property EffectiveDateTo As Date? Implements ISalary.EffectiveDateTo

    Public Property ContributeToGovt As Char? Implements ISalary.ContributeToGovt

    Public Property OverrideDiscardSSSContrib As Boolean Implements ISalary.OverrideDiscardSSSContrib

    Public Property OverrideDiscardPhilHealthContrib As Boolean Implements ISalary.OverrideDiscardPhilHealthContrib

    Public Property PayPeriodID As Integer

    Public Property NewSSSContribution As Decimal

End Class