Option Strict On

Imports System.ComponentModel.DataAnnotations.Schema
Imports System.ComponentModel.DataAnnotations

<Table("employeesimpleview")>
Public Class EmployeeEntity

    <Key>
    <System.ComponentModel.Browsable(False)>
    Public Property RowID As Integer

    Public Property EmployeeID As String

    Public Property LastName As String

    Public Property FirstName As String

    Public Property MiddleName As String

    Public Property OrganizationID As Integer

    Public Property FullName As String

End Class
