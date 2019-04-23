Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel.DataAnnotations.Schema

<Table("employeeloanschedule")>
Public Class LoanSchedule
    Implements ILoanSchedule

    <Key>
    <DatabaseGenerated(DatabaseGeneratedOption.Identity)>
    Public Property RowID As Integer Implements ILoanSchedule.RowID

    Public Property OrganizationID As Integer Implements ILoanSchedule.OrganizationID

    <DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    Public Property Created As Date Implements ILoanSchedule.Created

    Public Property CreatedBy As Integer? Implements ILoanSchedule.CreatedBy

    <DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    Public Property LastUpd As Date? Implements ILoanSchedule.LastUpd

    Public Property LastUpdBy As Integer? Implements ILoanSchedule.LastUpdBy

    Public Property EmployeeID As Integer? Implements ILoanSchedule.EmployeeID

    <Column("LoanNumber")>
    Public Property LoanNo As String Implements ILoanSchedule.LoanNo

    <Column("DedEffectiveDateFrom")>
    Public Property StartDate As Date? Implements ILoanSchedule.StartDate

    <Column("DedEffectiveDateTo")>
    Public Property EndDate As Date? Implements ILoanSchedule.EndDate

    Public Property TotalLoanAmount As Decimal? Implements ILoanSchedule.TotalLoanAmount

    Public Property DeductionSchedule As String Implements ILoanSchedule.DeductionSchedule

    Public Property TotalBalanceLeft As Decimal? Implements ILoanSchedule.TotalBalanceLeft

    Public Property DeductionAmount As Decimal? Implements ILoanSchedule.DeductionAmount

    Public Property Status As String Implements ILoanSchedule.Status

    Public Property LoanTypeID As Integer? Implements ILoanSchedule.LoanTypeID

    Public Property DeductionPercentage As Decimal? Implements ILoanSchedule.DeductionPercentage

    Public Property NoOfPayPeriod As Decimal? Implements ILoanSchedule.NoOfPayPeriod

    Public Property LoanPayPeriodLeft As Decimal? Implements ILoanSchedule.LoanPayPeriodLeft

    Public Property Comments As String Implements ILoanSchedule.Comments

    Public Property Nondeductible As Char? Implements ILoanSchedule.Nondeductible

    Public Property ReferenceLoanID As Integer? Implements ILoanSchedule.ReferenceLoanID

    Public Property SubstituteEndDate As Date? Implements ILoanSchedule.SubstituteEndDate

    Public Property PayStubID As Integer? Implements ILoanSchedule.PayStubID

End Class