Option Strict On

Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel.DataAnnotations.Schema

<Table("employeesalary")>
Public Class Salary
    <Key>
    <DatabaseGenerated(DatabaseGeneratedOption.Identity)>
    Public Property RowID As Integer

    <ForeignKey("Employee")>
    Public Property EmployeeID As Integer

    <DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    Public Property Created As DateTime

    Public Property CreatedBy As Integer

    <DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    Public Property LastUpd As DateTime?

    Public Property LastUpdBy As Integer?
    Public Property OrganizationID As Integer?
    Public Property FilingStatusID As Integer?

    <ForeignKey("SociaSecurityService")>
    Public Property PaySocialSecurityID As Integer?

    <ForeignKey("PhilHealth")>
    Public Property PayPhilhealthID As Integer?

    Public Property PhilHealthDeduction As Decimal?
    Public Property HDMFAmount As Decimal?
    Public Property TrueSalary As Decimal?
    Public Property BasicPay As Decimal?

    <Column("Salary")>
    Public Property SalaryAmount As Decimal?

    Public Property UndeclaredSalary As Decimal?
    Public Property BasicDailyPay As Decimal?
    Public Property BasicHourlyPay As Decimal?
    Public Property NoofDependents As Integer?
    Public Property MaritalStatus As String
    Public Property PositionID As Integer?
    Public Property EffectiveDateFrom As Date?
    Public Property EffectiveDateTo As Date?
    Public Property ContributeToGovt As Char?
    Public Property OverrideDiscardSSSContrib As Boolean
    Public Property OverrideDiscardPhilHealthContrib As Boolean

    Public Overridable Property Employee As Employee

    Public Overridable Property SociaSecurityService As SociaSecurityService

    Public Overridable Property PhilHealth As PhilHealth

End Class
