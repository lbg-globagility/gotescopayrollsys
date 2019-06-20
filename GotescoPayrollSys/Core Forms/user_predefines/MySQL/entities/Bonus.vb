Option Strict On

Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel.DataAnnotations.Schema

<Table("employeebonus")>
Public Class Bonus

    <Key>
    <DatabaseGenerated(DatabaseGeneratedOption.Identity)>
    Public Property RowID As Integer

    Public Property OrganizationID As Integer

    <DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    Public Property Created As DateTime

    Public Property CreatedBy As Integer?

    <DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    Public Property LastUpd As DateTime?

    Public Property LastUpdBy As Integer?
    Public Property EmployeeID As Integer?
    Public Property ProductID As Integer?
    Public Property EffectiveStartDate As Date?
    Public Property AllowanceFrequency As String
    Public Property EffectiveEndDate As Date?
    Public Property TaxableFlag As String
    Public Property BonusAmount As Decimal?
End Class