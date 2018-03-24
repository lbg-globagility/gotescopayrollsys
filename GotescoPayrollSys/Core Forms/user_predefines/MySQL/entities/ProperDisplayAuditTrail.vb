Option Strict On

Imports System.ComponentModel.DataAnnotations.Schema
Imports System.ComponentModel.DataAnnotations

<Table("properdisplayaudittrail")>
Public Class ProperDisplayAuditTrail

    Public Property Created As DateTime

    <Column("Created By")>
    Public Property CreatedBy As String

    <Column("Module")>
    Public Property ModuleName As String

    <Column("Module")>
    Public Property FieldChanged As String

    ''Created	Created By	Module	Field Changed	Previous Value	New Value	ActionPerformed	ViewID	OrganizationID

    <Column("Previous Value")>
    Public Property PreviouisValue As String

    <Column("New Value")>
    Public Property NewValue As String

    Public Property ActionPerformed As String

    <Column("ViewID")>
    Public Property ViewId As Integer

    <Column("OrganizationID")>
    Public Property OrganizationId As Integer

End Class
