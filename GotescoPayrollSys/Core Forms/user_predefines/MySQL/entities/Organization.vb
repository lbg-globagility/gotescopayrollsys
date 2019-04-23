Option Strict On

Imports System.ComponentModel.DataAnnotations.Schema
Imports System.ComponentModel.DataAnnotations

<Table("organization")>
Public Class Organization
    <Key>
    <DatabaseGenerated(DatabaseGeneratedOption.Identity)>
    Public Property RowID As Integer

    'Public Property Name As String
    'Public Property TradeName As String
    'Public Property PrimaryAddressID As Integer?
    'Public Property PrimaryContactID As Integer?
    'Public Property PremiseAddressID As Integer?
    'Public Property MainPhone As String
    'Public Property FaxNumber As String
    'Public Property EmailAddress As String
    'Public Property AltEmailAddress As String
    'Public Property AltPhone As String
    'Public Property URL As String
    'Public Property TINNo As String
    'Public Property BankAccountNo As String
    'Public Property BankName As String

    '<DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    'Public Property Created As DateTime?

    'Public Property CreatedBy As Integer?

    '<DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    'Public Property LastUpd As DateTime?

    'Public Property LastUpdBy As Integer?
    ''Public Property Image As mediumblob?
    'Public Property OrganizationType As String
    'Public Property TotalFloorArea As Decimal?
    'Public Property MinimumWater As Decimal?
    'Public Property MinimumElectricity As Decimal?
    'Public Property VacationLeaveDays As Decimal?
    'Public Property SickLeaveDays As Decimal?
    'Public Property MaternityLeaveDays As Decimal?
    'Public Property OthersLeaveDays As Decimal?
    'Public Property STPFlag As String
    'Public Property PayFrequencyID As Integer?
    'Public Property PhilhealthDeductionSchedule As String
    'Public Property SSSDeductionSchedule As String
    'Public Property PagIbigDeductionSchedule As String
    'Public Property WithholdingDeductionSchedule As String
    'Public Property LoanDeductionSchedule As String
    'Public Property ReportText As String
    'Public Property NightDifferentialTimeFrom As DateTime?
    'Public Property NightDifferentialTimeTo As DateTime?
    'Public Property NightShiftTimeFrom As DateTime?
    'Public Property NightShiftTimeTo As DateTime?
    'Public Property AllowNegativeLeaves As String
    'Public Property LimitedAccess As String
    'Public Property WorkDaysPerYear As Decimal?
    'Public Property GracePeriod As Decimal?
    'Public Property RDOCode As String
    'Public Property ZIPCode As String
    'Public Property MinWageEmpSSSContrib As Decimal?
    'Public Property MinWageEmpPhHContrib As Decimal?
    'Public Property MinWageEmpHDMFContrib As Decimal?
    Public Property NoPurpose As Boolean
End Class
