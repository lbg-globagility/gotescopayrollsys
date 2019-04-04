Option Strict On

Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel.DataAnnotations.Schema

<Table("employeetimeentrydetails")>
Public Class EmployeeTimeEntryDetails

    <Key>
    Public Property RowID As Integer

    <Column("OrganizationID")>
    Public Property OrganizationId As Integer

    Public Property Created As DateTime

    Public Property CreatedBy As Integer

    Public Property LastUpd As DateTime?

    Public Property LastUpdBy As Integer?

    <Column("EmployeeID")>
    Public Property EmployeeId As Integer

    Public Property TimeIn As TimeSpan?

    Public Property TimeOut As TimeSpan?

    <Column("Date")>
    Public Property DateValue As Date

End Class