Option Strict On

Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel.DataAnnotations.Schema

<Table("view")>
Public Class PrivilegeType

    <Key>
    <DatabaseGenerated(DatabaseGeneratedOption.Identity)>
    Public Property RowID As Integer

    Public Property ViewName As String
    Public Property OrganizationID As Integer

End Class