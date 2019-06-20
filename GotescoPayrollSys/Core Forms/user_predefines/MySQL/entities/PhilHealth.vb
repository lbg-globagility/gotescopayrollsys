Option Strict On

Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel.DataAnnotations.Schema

<Table("payphilhealth")>
Public Class PhilHealth

    <Key>
    <DatabaseGenerated(DatabaseGeneratedOption.Identity)>
    Public Property RowID As Integer

    <DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    Public Property Created As DateTime

    <DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    Public Property LastUpd As DateTime?

    Public Property CreatedBy As Integer
    Public Property LastUpdBy As Integer?
    Public Property SalaryBracket As Integer?
    Public Property SalaryRangeFrom As Decimal?
    Public Property SalaryRangeTo As Decimal?
    Public Property SalaryBase As Decimal?
    Public Property TotalMonthlyPremium As Decimal?
    Public Property EmployeeShare As Decimal?
    Public Property EmployerShare As Decimal?
    Public Property HiddenData As Char?

    Public Overridable ReadOnly Property IsNotHidden As Boolean
        Get
            If Not HiddenData.HasValue Then Return False
            Return HiddenData.Value = "0"
        End Get
    End Property

End Class