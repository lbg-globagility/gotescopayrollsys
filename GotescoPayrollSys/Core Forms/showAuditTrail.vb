Public Class showAuditTrail

    Private mod1 As New DatabaseContext

    Private _audittrails As IQueryable(Of ProperDisplayAuditTrail) = mod1.ProperDisplayAuditTrail.OfType(Of ProperDisplayAuditTrail)()
    'Private _audittrails As IQueryable(Of AuditTrail) = mod1.AuditTrail.OfType(Of AuditTrail)()

    Const twenty = 20

    Private Sub showAuditTrail_FormClosing(sender As Object, e As FormClosingEventArgs) Handles Me.FormClosing

        MDIPrimaryForm.Enabled = True

        MDIPrimaryForm.BringToFront()

    End Sub

    Private Sub showAuditTrail_Load(sender As Object, e As EventArgs) Handles MyBase.Load

        MDIPrimaryForm.Enabled = False

    End Sub

    Dim n_ViewRowID = Nothing

    Sub loadAudTrail(Optional ViewRowID As String = Nothing)
        n_ViewRowID = ViewRowID
        'dgvRowAdder("SELECT aut.RowID" & _
        '            ",aut.ViewID" & _
        '            ",aut.ChangedRowID" & _
        '            ",DATE_FORMAT(aut.Created,'%m/%d/%Y %h:%i %p') 'Created'" & _
        '            ",PROPERCASE(CONCAT(COALESCE(u.FirstName,''),' ',COALESCE(u.LastName,''))) 'CreatedBy'" & _
        '            ",v.ViewName" & _
        '            ",aut.FieldChanged" & _
        '            ",COALESCE(aut.OldValue,'') 'OldValue'" & _
        '            ",COALESCE(aut.NewValue,'') 'NewValue'" & _
        '            ",aut.ActionPerformed" & _
        '            " FROM audittrail aut" & _
        '            " LEFT JOIN user u ON u.RowID=aut.CreatedBy" & _
        '            " LEFT JOIN `view` v ON v.RowID = aut.ViewID" & _
        '            " WHERE aut.OrganizationID=" & orgztnID & _
        '            " AND aut.ViewID=" & ViewRowID & _
        '            " AND aut.CreatedBy=" & z_User & _
        '            " ORDER BY aut.Created DESC;", _
        '             dgvaudit)

        Dim params(3, 1) As Object

        params(0, 0) = "OrganizID"
        params(1, 0) = "View_ID"
        params(2, 0) = "UserID"
        params(3, 0) = "pagenumber"

        params(0, 1) = org_rowid
        params(1, 1) = ViewRowID
        params(2, 1) = user_row_id
        params(3, 1) = pagination

        Dim dt_audit As New DataTable

        'dt_audit = callProcAsDatTab(params, _
        '                            "VIEW_audittrail")

        'dt_audit =
        '    New SQL("CALL VIEW_audittrail(?OrganizID, ?View_ID, ?UserID, ?pagenumber);",
        '            New Object() {org_rowid, ViewRowID, user_row_id, pagination}).GetFoundRows.Tables(0)

        'dt_audit = retAsDatTbl("CALL VIEW_audittrail('" & orgztnID & "','" & ViewRowID & "','" & z_User & "','" & pagination & "')")
        Try

            Dim audit_trails =
                _audittrails.
                Where(Function(_at) _at.ViewId = ViewRowID And _at.OrganizationId = org_rowid).
                OrderByDescending(Function(_at) _at.Created)

            audit_trails = audit_trails.Skip(pagination).Take(twenty)

            Dim data_source =
                From au In audit_trails
                Where au.RowID > 0
                Select au.Created, au.CreatedBy, au.ModuleName, au.FieldChanged, au.PreviouisValue, au.NewValue, au.ActionPerformed

            dgvaudit.Rows.Clear()

            DataGridViewX1.DataSource = data_source.ToList

        Catch ex As Exception
            MsgBox("Something went wrong, see log file.", MsgBoxStyle.Critical)
            _logger.Error(String.Concat("loadAudTrail", " - (view_id=", ViewRowID, ", page=", pagination, ")"), ex)
        End Try
        'If dt_audit IsNot Nothing Then

        '    Dim drowColCount = dt_audit.Columns.Count - 1

        '    For Each drow As DataRow In dt_audit.Rows

        '        Dim row_array = drow.ItemArray

        '        dgvaudit.Rows.Add(row_array)

        '    Next

        'End If

    End Sub

    Private Sub dgvaudit_CellContentClick(sender As Object, e As DataGridViewCellEventArgs) Handles dgvaudit.CellContentClick

    End Sub

    Protected Overrides Function ProcessCmdKey(ByRef msg As Message, keyData As Keys) As Boolean

        If keyData = Keys.Escape Then

            Close()

            Return True

        Else

            Return MyBase.ProcessCmdKey(msg, keyData)

        End If

    End Function

    Dim pagination = 0

    Private Sub PaginationEmployee(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles Prev.LinkClicked, Nxt.LinkClicked, _
                                                                                                 First.LinkClicked, Last.LinkClicked

        Panel1.Enabled = False

        Dim sender_linklabel = DirectCast(sender, LinkLabel)

        If sender_linklabel.Name = "Prev" Then
            'If pagination - twenty < 0 Then
            '    pagination = 0
            'Else
            '    pagination -= twenty
            'End If

            Dim modcent = pagination Mod twenty

            If modcent = 0 Then

                pagination -= twenty

            Else

                pagination -= modcent

            End If

            If pagination < 0 Then

                pagination = 0

            End If

        ElseIf sender_linklabel.Name = "Nxt" Then

            Dim modcent = pagination Mod twenty

            If modcent = 0 Then
                pagination += twenty

            Else
                pagination -= modcent

                pagination += twenty

            End If

        ElseIf sender_linklabel.Name = "First" Then
            pagination = 0

        ElseIf sender_linklabel.Name = "Last" Then
            Dim lastpage = Val(EXECQUER(String.Concat("SELECT COUNT(RowID) / ", twenty, " FROM audittrail WHERE OrganizationID=", org_rowid, " AND ViewID='", n_ViewRowID, "';")))

            Dim remender = lastpage Mod 1

            pagination = (lastpage - remender) * twenty

            If pagination - twenty < twenty Then
                'pagination = 0

            End If

            'pagination = If(lastpage - twenty >= twenty, _
            '                lastpage - twenty, _
            '                lastpage)
        End If

        loadAudTrail(n_ViewRowID)

        Panel1.Enabled = True

    End Sub

End Class