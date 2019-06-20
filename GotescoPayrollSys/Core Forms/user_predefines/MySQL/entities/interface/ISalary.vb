Public Interface ISalary
    Property RowID As Integer
    Property EmployeeID As Integer
    Property Created As DateTime
    Property CreatedBy As Integer
    Property LastUpd As DateTime?
    Property LastUpdBy As Integer?
    Property OrganizationID As Integer?
    Property FilingStatusID As Integer?
    Property PaySocialSecurityID As Integer?
    Property PayPhilhealthID As Integer?
    Property PhilHealthDeduction As Decimal?
    Property HDMFAmount As Decimal?
    Property TrueSalary As Decimal?
    Property BasicPay As Decimal?
    Property SalaryAmount As Decimal?
    Property UndeclaredSalary As Decimal?
    Property BasicDailyPay As Decimal?
    Property BasicHourlyPay As Decimal?
    Property NoofDependents As Integer?
    Property MaritalStatus As String
    Property PositionID As Integer?
    Property EffectiveDateFrom As Date?
    Property EffectiveDateTo As Date?
    Property ContributeToGovt As Char?
    Property OverrideDiscardSSSContrib As Boolean
    Property OverrideDiscardPhilHealthContrib As Boolean
End Interface