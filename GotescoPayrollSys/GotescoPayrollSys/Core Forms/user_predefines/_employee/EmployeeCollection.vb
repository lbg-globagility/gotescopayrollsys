Imports System.Collections.ObjectModel
Imports System.ComponentModel
Imports System.Threading.Tasks

Public Class EmployeeCollection
    Implements IEmployee

    Public Property AdditionalVLAllowance As Decimal Implements IEmployee.AdditionalVLAllowance

    Public Property AdditionalVLBalance As Decimal Implements IEmployee.AdditionalVLBalance

    Public Property AdditionalVLPerPayPeriod As Decimal Implements IEmployee.AdditionalVLPerPayPeriod

    Public Property AgencyID As Integer? Implements IEmployee.AgencyID

    Public Property AlphaListExempted As Char Implements IEmployee.AlphaListExempted

    Public Property ATMNo As String Implements IEmployee.ATMNo

    Public Property BankName As String Implements IEmployee.BankName

    Public Property Birthdate As Date Implements IEmployee.Birthdate

    Public Property CalcHoliday As Char Implements IEmployee.CalcHoliday

    Public Property CalcNightDiff As Char Implements IEmployee.CalcNightDiff

    Public Property CalcNightDiffOT As Char Implements IEmployee.CalcNightDiffOT

    Public Property CalcRestDay As Char Implements IEmployee.CalcRestDay

    Public Property CalcRestDayOT As Char Implements IEmployee.CalcRestDayOT

    Public Property CalcSpecialHoliday As Char Implements IEmployee.CalcSpecialHoliday

    Public Property Created As Date Implements IEmployee.Created

    Public Property CreatedBy As Integer? Implements IEmployee.CreatedBy

    Public Property DateEvaluated As Date Implements IEmployee.DateEvaluated

    Public Property DateR1A As Date Implements IEmployee.DateR1A

    Public Property DateRegularized As Date Implements IEmployee.DateRegularized

    Public Property DayOfRest As Char Implements IEmployee.DayOfRest

    Public Property DeptManager As Integer? Implements IEmployee.DeptManager

    Public Property EmailAddress As String Implements IEmployee.EmailAddress

    Public Property EmployeeID As String Implements IEmployee.EmployeeID

    Public Property EmployeeType As String Implements IEmployee.EmployeeType

    Public Property EmploymentStatus As String Implements IEmployee.EmploymentStatus

    Public Property FirstName As String Implements IEmployee.FirstName

    Public Property Gender As String Implements IEmployee.Gender

    Public Property HDMFNo As String Implements IEmployee.HDMFNo

    Public Property HomeAddress As String Implements IEmployee.HomeAddress

    Public Property HomePhone As String Implements IEmployee.HomePhone

    Public Property JobTitle As String Implements IEmployee.JobTitle

    Public Property LastName As String Implements IEmployee.LastName

    Public Property LastUpd As Date Implements IEmployee.LastUpd

    Public Property LastUpdBy As Integer? Implements IEmployee.LastUpdBy

    Public Property LateGracePeriod As Decimal Implements IEmployee.LateGracePeriod

    Public Property LeaveAboveFifteenthYearService As Decimal Implements IEmployee.LeaveAboveFifteenthYearService

    Public Property LeaveAllowance As Decimal Implements IEmployee.LeaveAllowance

    Public Property LeaveBalance As Decimal Implements IEmployee.LeaveBalance

    Public Property LeaveFifteenthYearService As Decimal Implements IEmployee.LeaveFifteenthYearService

    Public Property LeavePerPayPeriod As Decimal Implements IEmployee.LeavePerPayPeriod

    Public Property LeaveTenthYearService As Decimal Implements IEmployee.LeaveTenthYearService

    Public Property MaritalStatus As String Implements IEmployee.MaritalStatus

    Public Property MaternityLeaveAllowance As Decimal Implements IEmployee.MaternityLeaveAllowance

    Public Property MaternityLeaveBalance As Decimal Implements IEmployee.MaternityLeaveBalance

    Public Property MaternityLeavePerPayPeriod As Decimal Implements IEmployee.MaternityLeavePerPayPeriod

    Public Property MiddleName As String Implements IEmployee.MiddleName

    Public Property MobilePhone As String Implements IEmployee.MobilePhone

    Public Property NewEmployeeFlag As String Implements IEmployee.NewEmployeeFlag

    Public Property Nickname As String Implements IEmployee.Nickname

    Public Property NoOfDependents As Integer? Implements IEmployee.NoOfDependents

    Public Property OffsetBalance As Decimal Implements IEmployee.OffsetBalance

    Public Property OrganizationID As Integer? Implements IEmployee.OrganizationID

    Public Property OtherLeaveAllowance As Decimal Implements IEmployee.OtherLeaveAllowance

    Public Property OtherLeaveBalance As Decimal Implements IEmployee.OtherLeaveBalance

    Public Property OtherLeavePerPayPeriod As Decimal Implements IEmployee.OtherLeavePerPayPeriod

    Public Property OvertimeOverride As String Implements IEmployee.OvertimeOverride

    Public Property PayFrequencyID As Integer? Implements IEmployee.PayFrequencyID

    Public Property PhilHealthNo As String Implements IEmployee.PhilHealthNo

    Public Property PositionID As Integer? Implements IEmployee.PositionID

    Public Property RevealInPayroll As Char Implements IEmployee.RevealInPayroll

    Public Property RowID As Integer? Implements IEmployee.RowID

    Public Property Salutation As String Implements IEmployee.Salutation

    Public Property SickLeaveAllowance As Decimal Implements IEmployee.SickLeaveAllowance

    Public Property SickLeaveBalance As Decimal Implements IEmployee.SickLeaveBalance

    Public Property SickLeavePerPayPeriod As Decimal Implements IEmployee.SickLeavePerPayPeriod

    Public Property SSSNo As String Implements IEmployee.SSSNo

    Public Property StartDate As Date Implements IEmployee.StartDate

    Public Property Surname As String Implements IEmployee.Surname

    Public Property TerminationDate As Date Implements IEmployee.TerminationDate

    Public Property TINNo As String Implements IEmployee.TINNo

    Public Property UndertimeOverride As String Implements IEmployee.UndertimeOverride

    Public Property WorkDaysPerYear As Integer? Implements IEmployee.WorkDaysPerYear

    Public Property WorkPhone As String Implements IEmployee.WorkPhone

    Const str_quer_employees As String = "SELECT * FROM employee WHERE OrganizationID = "

    Public Shared ReadOnly Property Lists As ICollection(Of EmployeeCollection)
        Get
            Static propert_value As New Collection(Of EmployeeCollection)

            Static strquer_employees = String.Concat(str_quer_employees, orgztnID)

            Static sql As New SQL(strquer_employees)

            sql.ExecuteQuery()

            If sql.HasError Then

            Else
                Static dt As New DataTable
                dt = sql.GetFoundRows.Tables(0)
                For Each drow As DataRow In dt.Rows

                    'Dim new_ee As IEmployee
                    'new_ee.RowID = drow("RowID")
                    'new_ee.EmployeeID = drow("EmployeeID")
                    'new_ee.LastName = drow("LastName")
                    'new_ee.FirstName = drow("FirstName")
                    'new_ee.MiddleName = drow("MiddleName")
                    'new_ee.PositionID = drow("PositionID")
                    'new_ee.EmailAddress = drow("EmailAddress")

                    Dim is_positID_null = IsDBNull(drow("PositionID"))

                    Dim position_row_id As Integer = 0

                    If is_positID_null = False Then
                        position_row_id = drow("PositionID")
                    End If

                    Dim new_ee As New EmployeeCollection _
                        With {.RowID = drow("RowID"),
                              .EmployeeID = drow("EmployeeID"),
                              .LastName = drow("LastName"),
                              .FirstName = drow("FirstName"),
                              .MiddleName = drow("MiddleName"),
                              .PositionID = position_row_id,
                              .EmailAddress = drow("EmailAddress")}

                    propert_value.Add(new_ee)

                Next
            End If

            Return propert_value
        End Get
    End Property

    'Private Async Function LoadList() As Task(Of ICollection(Of EmployeeCollection))

    '    Dim propert_value As New Collection(Of EmployeeCollection)

    '    Dim strquer_employees = String.Concat(str_quer_employees, orgztnID)

    '    Dim sql As New SQL(strquer_employees)

    '    sql.ExecuteQuery()

    '    If sql.HasError Then

    '    Else
    '        Dim dt As New DataTable
    '        dt = sql.GetFoundRows.Tables(0)
    '        For Each drow As DataRow In dt.Rows

    '            'Dim new_ee As IEmployee
    '            'new_ee.RowID = drow("RowID")
    '            'new_ee.EmployeeID = drow("EmployeeID")
    '            'new_ee.LastName = drow("LastName")
    '            'new_ee.FirstName = drow("FirstName")
    '            'new_ee.MiddleName = drow("MiddleName")
    '            'new_ee.PositionID = drow("PositionID")
    '            'new_ee.EmailAddress = drow("EmailAddress")

    '            Dim new_ee As New EmployeeCollection _
    '                With {.RowID = drow("RowID"),
    '                      .EmployeeID = drow("EmployeeID"),
    '                      .LastName = drow("LastName"),
    '                      .FirstName = drow("FirstName"),
    '                      .MiddleName = drow("MiddleName"),
    '                      .PositionID = drow("PositionID"),
    '                      .EmailAddress = drow("EmailAddress")}

    '            propert_value.Add(new_ee)

    '        Next
    '    End If

    '    Return propert_value

    'End Function

End Class