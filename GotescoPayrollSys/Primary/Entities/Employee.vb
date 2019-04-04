Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel.DataAnnotations.Schema

<Table("employee")>
Public Class Employee

    <Key>
    Public Property RowID As Integer

    Public Property CreatedBy As Integer?
    Public Property Created As DateTime?
    Public Property LastUpdBy As Integer?
    Public Property LastUpd As DateTime?
    Public Property OrganizationID As Integer?
    Public Property Salutation As String
    Public Property FirstName As String
    Public Property MiddleName As String
    Public Property LastName As String
    Public Property Surname As String

    <Column("EmployeeID")>
    Public Property EmployeeNo As String

    Public Property TINNo As String
    Public Property SSSNo As String
    Public Property HDMFNo As String
    Public Property PhilHealthNo As String
    Public Property EmploymentStatus As String
    Public Property EmailAddress As String
    Public Property WorkPhone As String
    Public Property HomePhone As String
    Public Property MobilePhone As String
    Public Property HomeAddress As String
    Public Property Nickname As String
    Public Property JobTitle As String
    Public Property Gender As String
    Public Property EmployeeType As String
    Public Property MaritalStatus As String
    Public Property Birthdate As Date?
    Public Property StartDate As Date?
    Public Property TerminationDate As Date?
    Public Property PositionID As Integer?
    Public Property PayFrequencyID As Integer?
    Public Property NoOfDependents As Integer?
    Public Property UndertimeOverride As String
    Public Property OvertimeOverride As String
    Public Property NewEmployeeFlag As String
    Public Property LeaveBalance As Decimal?
    Public Property SickLeaveBalance As Decimal?
    Public Property MaternityLeaveBalance As Decimal?
    Public Property OtherLeaveBalance As Decimal?
    Public Property LeaveAllowance As Decimal?
    Public Property SickLeaveAllowance As Decimal?
    Public Property MaternityLeaveAllowance As Decimal?
    Public Property OtherLeaveAllowance As Decimal?

    'Public Property Image As mediumblob?
    Public Property LeavePerPayPeriod As Decimal?

    Public Property SickLeavePerPayPeriod As Decimal?
    Public Property MaternityLeavePerPayPeriod As Decimal?
    Public Property OtherLeavePerPayPeriod As Decimal?
    Public Property AlphaListExempted As Char?
    Public Property WorkDaysPerYear As Integer?
    Public Property DayOfRest As Char?
    Public Property ATMNo As String
    Public Property BankName As String
    Public Property CalcHoliday As Char?
    Public Property CalcSpecialHoliday As Char?
    Public Property CalcNightDiff As Char?
    Public Property CalcNightDiffOT As Char?
    Public Property CalcRestDay As Char?
    Public Property CalcRestDayOT As Char?
    Public Property DateRegularized As Date?
    Public Property DateEvaluated As Date?
    Public Property RevealInPayroll As Char?
    Public Property LateGracePeriod As Decimal?
    Public Property AgencyID As Integer?
    Public Property OffsetBalance As Decimal?
    Public Property DateR1A As Date?
    Public Property AdditionalVLAllowance As Decimal?
    Public Property AdditionalVLBalance As Decimal?
    Public Property AdditionalVLPerPayPeriod As Decimal?
    Public Property LeaveTenthYearService As Decimal?
    Public Property LeaveFifteenthYearService As Decimal?
    Public Property LeaveAboveFifteenthYearService As Decimal?
    Public Property DeptManager As Integer?

End Class