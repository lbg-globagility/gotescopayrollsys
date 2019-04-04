Option Strict On

Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel.DataAnnotations.Schema

<Table("timeentrylogspercutoff")>
Public Class TimeEntryLogsPerCutOff

    <Key>
    Public Property RowID As Integer

    Public Property OrganizationId As Integer

    Public Property Created As DateTime

    Public Property CreatedBy As Integer

    Public Property LastUpd As DateTime?

    Public Property LastUpdBy As Integer?

    Public Property EmployeeID As Integer

    Public Property TimeIn As TimeSpan?

    Public Property TimeOut As TimeSpan?

    <Column("Date")>
    Public Property DateValue As Date?

    Public Property TimeScheduleType As String

    Public Property TimeEntryStatus As String

    Public Property TimeentrylogsImportID As String

    Public Property PayPeriodID As Integer?

    Public Property PayFromDate As DateTime

    Public Property PayToDate As DateTime

    <Column("Month")>
    Public Property MonthValue As Integer

    <Column("Year")>
    Public Property YearValue As Integer

    Public Property OrdinalValue As Integer

    Public Property EmployeePrimaKey As Integer

    Public Property EmployeeUniqueKey As String

    Public Property FullName As String

    Public Property TimeInText As String

    Public Property TimeOutText As String

End Class