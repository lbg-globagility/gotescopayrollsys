Interface ILoanSchedule
    Property RowID As Integer
    Property OrganizationID As Integer
    Property Created As DateTime
    Property CreatedBy As Integer?
    Property LastUpd As DateTime?
    Property LastUpdBy As Integer?
    Property EmployeeID As Integer?
    Property LoanNo As String
    Property StartDate As Date?
    Property EndDate As Date?
    Property TotalLoanAmount As Decimal?
    Property DeductionSchedule As String
    Property TotalBalanceLeft As Decimal?
    Property DeductionAmount As Decimal?
    Property Status As String
    Property LoanTypeID As Integer?
    Property DeductionPercentage As Decimal?
    Property NoOfPayPeriod As Decimal?
    Property LoanPayPeriodLeft As Decimal?
    Property Comments As String
    Property Nondeductible As Char?
    Property ReferenceLoanID As Integer?
    Property SubstituteEndDate As Date?
    Property PayStubID As Integer?
End Interface