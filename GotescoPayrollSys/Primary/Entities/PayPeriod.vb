Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel.DataAnnotations.Schema

<Table("payperiod")>
Public Class PayPeriod

    <Key>
    <DatabaseGenerated(DatabaseGeneratedOption.Identity)>
    Public Property RowID As Integer

    Public Property OrganizationID As Integer?

    <DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    Public Property Created As DateTime
    Public Property CreatedBy As Integer?

    <DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    Public Property LastUpd As DateTime?
    Public Property LastUpdBy As Integer?
    Public Property PayFromDate As Date?
    Public Property PayToDate As Date?

    <Column("TotalGrossSalary")>
    Public Property PayFrequencyID As Integer?

    Public Property TotalNetSalary As Decimal?
    Public Property TotalEmpSSS As Decimal?
    Public Property TotalEmpWithholdingTax As Decimal?
    Public Property TotalCompSSS As Decimal?
    Public Property TotalEmpPhilhealth As Decimal?
    Public Property TotalCompPhilhealth As Decimal?
    Public Property TotalEmpHDMF As Decimal?
    Public Property TotalCompHDMF As Decimal?
    Public Property Month As Integer?
    Public Property Year As Integer?
    Public Property Half As String
    Public Property SSSContribSched As String
    Public Property PhHContribSched As String
    Public Property HDMFContribSched As String
    Public Property OrdinalValue As Integer?
    Public Property MinimumWageValue As Decimal?

    Public ReadOnly Property IsMonthly As Boolean
        Get
            Return PayFrequencyID.Value = 1
        End Get
    End Property

    Public ReadOnly Property IsWeekly As Boolean
        Get
            Return PayFrequencyID.Value = 4
        End Get
    End Property

    Public ReadOnly Property IsFirstHalf As Boolean
        Get
            Return Half = 1
        End Get
    End Property

    Public ReadOnly Property IsEndOfTheMonth As Boolean
        Get
            Return Half = 0
        End Get
    End Property

End Class