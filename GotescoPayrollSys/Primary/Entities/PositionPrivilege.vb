Option Strict On

Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel.DataAnnotations.Schema

<Table("position_view")>
Public Class PositionPrivilege

    <Key>
    <DatabaseGenerated(DatabaseGeneratedOption.Identity)>
    Public Property RowID As Integer

    <ForeignKey("Position")>
    Public Property PositionID As Integer?

    <ForeignKey("PrivilegeType")>
    Public Property ViewID As Integer?

    Public Property Creates As String

    <ForeignKey("Organization")>
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

    Public Overridable Property Position As Position

    Public Overridable Property PrivilegeType As PrivilegeType

    Public Overridable Property Organization As Organization

End Class