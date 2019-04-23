Public Interface IAuditTrail

    Property RowID As Integer

    Property Created As DateTime

    Property CreatedBy As Integer

    Property LastUpd As DateTime?

    Property LastUpdBy As Integer?

    Property OrganizationID As Integer

    Property ViewID As Integer

    Property FieldChanged As String

    Property ChangedRowID As Integer

    Property OldValue As String

    Property NewValue As String

    Property ActionPerformed As String

End Interface