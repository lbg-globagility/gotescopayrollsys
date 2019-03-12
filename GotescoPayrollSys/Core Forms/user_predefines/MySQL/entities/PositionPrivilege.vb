Option Strict On

Imports System.ComponentModel.DataAnnotations.Schema
Imports System.ComponentModel.DataAnnotations

<Table("position_view")>
Public Class PositionPrivilege
    <Key>
    <DatabaseGenerated(DatabaseGeneratedOption.Identity)>
    Public Property RowID As Integer
    Public Property PositionID As Integer?
    Public Property ViewID As Integer?
    Public Property Creates As String
    Public Property OrganizationID As Integer
    Public Property [ReadOnly] As String
    Public Property Updates As String
    Public Property Deleting As String
    <DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    Public Property Created As DateTime
    Public Property CreatedBy As Integer
    <DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    Public Property LastUpd As DateTime?
    Public Property LastUpdBy As Integer
End Class
