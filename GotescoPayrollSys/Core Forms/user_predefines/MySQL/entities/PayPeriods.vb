Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel.DataAnnotations.Schema

<Table("payperiod")>
Public Class PayPeriods

    <Key>
    Public Property RowID As Integer

    Public Property OrganizationID As Integer?
    Public Property Created As DateTime
    Public Property CreatedBy As Integer?
    Public Property LastUpd As DateTime?
    Public Property LastUpdBy As Integer?
    Public Property PayFromDate As Date?
    Public Property PayToDate As Date?
    Public Property TotalGrossSalary As Decimal?
    Public Property TotalNetSalary As Decimal?
    Public Property TotalEmpSSS As Decimal?
    Public Property TotalEmpWithholdingTax As Decimal?
    Public Property TotalCompSSS As Decimal?
    Public Property TotalEmpPhilhealth As Decimal?
    Public Property TotalCompPhilhealth As Decimal?
    Public Property TotalEmpHDMF As Decimal?
    Public Property TotalCompHDMF As Decimal?
    Public Property Month As Integer?
    Public Property Year As String
    Public Property Half As String
    Public Property SSSContribSched As String
    Public Property PhHContribSched As String
    Public Property HDMFContribSched As String
    Public Property OrdinalValue As Integer?
    Public Property MinimumWageValue As Decimal?

End Class