Option Strict On

Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel.DataAnnotations.Schema

<Table("position")>
Public Class Position

    <Key>
    <DatabaseGenerated(DatabaseGeneratedOption.Identity)>
    Public Property RowID As Integer

    Public Property PositionName As String

    <DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    Public Property LastUpd As DateTime?

    <DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    Public Property Created As DateTime?

    Public Property CreatedBy As Integer?
    Public Property OrganizationID As Integer
    Public Property LastUpdBy As Integer?
    Public Property ParentPositionID As Integer?
    Public Property DivisionId As Integer?
End Class