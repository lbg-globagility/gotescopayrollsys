Option Strict On

Imports System.ComponentModel.DataAnnotations.Schema
Imports System.ComponentModel.DataAnnotations

<Table("audittrail")>
Public Class AuditTrail
    Implements IAuditTrail

    <Key>
    Public Property RowID As Integer Implements IAuditTrail.RowID

    Public Property ActionPerformed As String Implements IAuditTrail.ActionPerformed

    Public Property Created As Date Implements IAuditTrail.Created

    Public Property CreatedBy As Integer Implements IAuditTrail.CreatedBy

    Public Property FieldChanged As String Implements IAuditTrail.FieldChanged

    Public Property LastUpd As Date? Implements IAuditTrail.LastUpd

    Public Property LastUpdBy As Integer? Implements IAuditTrail.LastUpdBy

    Public Property NewValue As String Implements IAuditTrail.NewValue

    Public Property OldValue As String Implements IAuditTrail.OldValue

    Public Property OrganizationID As Integer Implements IAuditTrail.OrganizationID

    Public Property ViewID As Integer Implements IAuditTrail.ViewID

    Public Property ChangedRowID As Integer Implements IAuditTrail.ChangedRowID
End Class
