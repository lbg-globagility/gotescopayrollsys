Public Class UsersForm
    Dim isNew As Integer = 0
    Dim rowid As Integer

    Protected Overrides Sub OnLoad(e As EventArgs)

        OjbAssignNoContextMenu(cmbPosition)

        MyBase.OnLoad(e)

    End Sub

    Private Sub fillUsers()

        Try
            Dim dt As New DataTable
            dt = getDataTableForSQL("Select u.RowID, u.UserID, p.PositionName, u.LastName, u.Firstname, u.MiddleName, u.RowID, u.EmailAddress, u.DeptMngrID from User u " & _
                                    " inner join Position p on u.PositionID = p.RowID AND u.RowID > 0 ORDER BY u.Rowid ASC;")

            'Where u.OrganizationID = '" & Z_OrganizationID & "' And Status = 'Active'

            dgvUserList.Rows.Clear()
            If dt.Rows.Count > 0 Then
                For Each drow As DataRow In dt.Rows
                    Dim n As Integer = dgvUserList.Rows.Add()
                    With drow
                        Try
                            dgvUserList.Rows.Item(n).Cells(c_userid.Index).Value = DecrypedData(.Item("UserID").ToString)
                            dgvUserList.Rows.Item(n).Cells(c_Position.Index).Value = .Item("PositionName").ToString
                            dgvUserList.Rows.Item(n).Cells(c_lname.Index).Value = .Item("LastName").ToString
                            dgvUserList.Rows.Item(n).Cells(c_fname.Index).Value = .Item("FirstName").ToString
                            dgvUserList.Rows.Item(n).Cells(c_Mname.Index).Value = .Item("MiddleName").ToString
                            dgvUserList.Rows.Item(n).Cells(c_rowid.Index).Value = .Item("RowID").ToString
                            dgvUserList.Rows.Item(n).Cells(c_emailadd.Index).Value = .Item("EmailAddress").ToString
                            'dgvUserList.Rows.Item(n).Cells(5).Value = .Item("PositionID").ToString
                            dgvUserList.Rows.Item(n).Cells(c_userid.Index).Tag = If(IsDBNull(.Item("DeptMngrID")), Nothing, .Item("DeptMngrID"))
                            'DeptMngrID
                        Catch ex As Exception

                        End Try

                    End With
                Next
            End If
        Catch ex As Exception
            MsgBox(ex.Message, MsgBoxStyle.Critical, "Error code fillUsers")
        End Try
    End Sub

    Private Function DisplayValue(ByVal UserID As Integer) As Boolean
        txtPassword.Clear()
        txtConfirmPassword.Clear()
        chkboxIsDeptMngr.Tag = Nothing
        Try

            If dgvUserList.Rows.Count = 0 Then
            Else
                Dim dt As New DataTable
                dt = getDataTableForSQL("select * from user where RowID = " & UserID & ";") ' And OrganizationID = " & z_OrganizationID & "
                For Each drow As DataRow In dt.Rows
                    With drow
                        Dim posID As Integer = .Item("PositionID").ToString

                        Dim postname As String = getStringItem("Select PositionName from position where rowID = '" & posID & "'")
                        Dim getpostname As String = postname
                        txtUserName.Text = DecrypedData(.Item("UserID"))
                        txtPassword.Text = DecrypedData(.Item("Password"))
                        txtConfirmPassword.Text = DecrypedData(.Item("Password"))

                        txtLastName.Text = .Item("LastName").ToString
                        txtFirstName.Text = .Item("FirstName").ToString
                        txtMiddleName.Text = .Item("Middlename").ToString
                        txtEmailAdd.Text = .Item("EmailAddress").ToString
                        cmbPosition.Text = getpostname

                        rowid = .Item("RowID")

                        Dim is_null_dptmngr As Boolean = IsDBNull(.Item("DeptMngrID"))

                        chkboxIsDeptMngr.Checked = (Not is_null_dptmngr)

                        If is_null_dptmngr = False Then
                            chkboxIsDeptMngr.Tag = .Item("DeptMngrID")
                        End If

                    End With

                Next

            End If

            Return True
        Catch ex As Exception
            MsgBox(ex.Message, MsgBoxStyle.Critical, "Error code DisplayValue")
        End Try
        Return True
    End Function

    Sub fillPosition()
        Dim strQuery As String = "select PositionName from Position Where OrganizationID = '" & z_OrganizationID & "'"

        '"SELECT PositionName" & _
        '" FROM position" & _
        '" WHERE OrganizationID='" & orgztnID & "'" & _
        '" UNION" & _
        '" SELECT pos.PositionName" & _
        '" FROM USER u INNER JOIN POSITION pos ON pos.RowID=u.PositionID" & _
        '" WHERE u.OrganizationID = '" & orgztnID & "'" & _
        '" AND u.PositionID IS NOT NULL;"

        '_

        '"' ORDER BY PositionName AND RowID NOT IN (SELECT DISTINCT(PositionID) FROM employee WHERE PositionID IS NOT NULL AND OrganizationID=" & z_OrganizationID & ");"

        cmbPosition.Items.Clear()

        cmbPosition.Items.AddRange(CType(SQL_ArrayList(strQuery).ToArray(GetType(String)), String()))

        cmbPosition.SelectedIndex = -1

    End Sub

    Private Sub cleartextbox()
        txtConfirmPassword.Clear()
        txtEmailAdd.Clear()
        txtFirstName.Clear()
        txtLastName.Clear()
        txtMiddleName.Clear()
        cmbPosition.SelectedIndex = -1
        txtUserName.Clear()

    End Sub

    Private Sub btnNew_Click(sender As Object, e As EventArgs) Handles btnNew.Click
        cleartextbox()
        btnNew.Enabled = False
        dgvUserList.Enabled = False
        isNew = 1

    End Sub

    Private Sub btnCancel_Click(sender As Object, e As EventArgs) Handles btnCancel.Click
        cleartextbox()
        btnNew.Enabled = True
        dgvUserList.Enabled = True
        Z_ErrorProvider.Dispose()
    End Sub

    Dim dontUpdate As SByte = 0

    Private Sub btnSave_Click(sender As Object, e As EventArgs) Handles btnSave.Click

        Dim isnot_dept_mngr As Boolean = (chkboxIsDeptMngr.Tag = Nothing)

        Dim dept_mngr_id = If(isnot_dept_mngr, DBNull.Value, chkboxIsDeptMngr.Tag)

        If isNew = 1 Then
            Z_ErrorProvider.Dispose()

            If txtLastName.Text = "" Or txtFirstName.Text = "" Or txtUserName.Text = "" Or txtPassword.Text = "" _
                Or txtConfirmPassword.Text = "" Or cmbPosition.Text = "" Then
                If Not SetWarningIfEmpty(txtLastName) And SetWarningIfEmpty(txtFirstName) And SetWarningIfEmpty(txtUserName) And _
                    SetWarningIfEmpty(txtPassword) And SetWarningIfEmpty(txtConfirmPassword) And SetWarningIfEmpty(cmbPosition) Then

                End If
            Else

                Dim position As String = getStringItem("Select RowID From Position Where PositionName = '" & cmbPosition.Text & "' And OrganizationID = " & z_OrganizationID & "")
                Dim getposition As Integer = Val(position)

                Dim status As String = "Active"
                Dim userid As String = getStringItem("Select UserID from user Where UserID = '" & EncrypedData(txtUserName.Text) & "' AND OrganizationID = '" & z_OrganizationID & "'")
                Dim getuserid As String = userid
                If getuserid = EncrypedData(txtUserName.Text) Then
                    myBalloonWarn("User ID Already exist.", "Duplicate", txtUserName, , -65)
                Else
                    If txtPassword.Text = txtConfirmPassword.Text Then
                        I_UsersProc(txtLastName.Text, _
                                    txtFirstName.Text, _
                                    txtMiddleName.Text, _
                               EncrypedData(txtUserName.Text), _
                                    EncrypedData(txtConfirmPassword.Text), _
                               z_OrganizationID, _
                                    getposition, _
                                    Date.Now.ToString("yyyy-MM-dd HH:mm:ss"), _
                               user_row_id, _
                                    user_row_id, _
                                    Date.Now.ToString("yyyy-MM-dd HH:mm:ss"), _
                                    status, _
                                    txtEmailAdd.Text,
                                    dept_mngr_id)

                        myBalloon("Successfully Save", "Saved", lblSaveMsg, , -100)
                        fillUsers()
                        btnNew.Enabled = True
                        dgvUserList.Enabled = True
                        isNew = 0
                    Else
                        myBalloonWarn("Password does not match", "Not Match", txtConfirmPassword, , -65)
                    End If

                End If

            End If
        Else

            If txtConfirmPassword.Tag = Nothing Then
            Else

                Dim enc_userid = New EncryptData(txtUserName.Text.Trim).ResultValue

                Dim enc_pword = New EncryptData(txtConfirmPassword.Tag).ResultValue

                If dontUpdate = 1 Then
                    Exit Sub
                End If

                Dim queryGetPositionID =
                    $"SELECT pos.RowID
                    FROM `position` pos
                    INNER JOIN `user` u ON u.RowID={user_row_id} AND u.OrganizationID=pos.OrganizationID
                    WHERE pos.PositionName='{cmbPosition.Text}'
                    LIMIT 1;"
                Dim position As String = getStringItem(queryGetPositionID)

                Dim getposition As Integer = Val(position)

                If getposition = 0 Then

                    Dim position_count As String = getStringItem("Select COUNT(RowID) From Position Where PositionName = '" & cmbPosition.Text & "';")

                    If position_count <> 0 Then

                        If position_count = 1 Then

                            getposition = getStringItem("Select RowID From Position Where PositionName = '" & cmbPosition.Text & "';")

                        ElseIf position_count > 1 Then

                            getposition = getStringItem(queryGetPositionID)

                        End If

                    End If

                End If

                Dim status As String = "Active"
                U_UsersProc(Val(dgvUserList.CurrentRow.Cells(c_rowid.Index).Value), _
                                        txtLastName.Text, _
                                        txtFirstName.Text, _
                                        txtMiddleName.Text, _
                                        getposition, _
                                        Today.Date, _
                                        user_row_id, _
                                        user_row_id, _
                                        Today.Date, _
                                        status, _
                                        txtEmailAdd.Text,
                                        enc_userid,
                                        enc_pword,
                                        dept_mngr_id)

                'SetBalloonTip("Updated", "Successfully Save.")
                myBalloon("Successfully Save", "Updated", lblSaveMsg, , -100)
                fillUsers()

            End If

        End If

    End Sub

    Private Sub UsersForm_FormClosing(sender As Object, e As FormClosingEventArgs) Handles Me.FormClosing
        Try
            hintInfo.Dispose()
        Catch ex As Exception

        End Try

        If previousForm IsNot Nothing Then
            If previousForm.Name = Name Then
                previousForm = Nothing
            End If
        End If

        'If FormLeft.Contains("Users") Then
        '    FormLeft.Remove("Users")
        'End If

        'If FormLeft.Count = 0 Then
        '    MDIPrimaryForm.Text = "Welcome"
        'Else
        '    MDIPrimaryForm.Text = "Welcome to " & FormLeft.Item(FormLeft.Count - 1)
        'End If
        GeneralForm.listGeneralForm.Remove(Name)

    End Sub

    Dim view_ID As Integer = Nothing

    Private Sub UsersForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        fillPosition()
        fillUsers()
        If dgvUserList.Rows.Count = 0 Then
        Else
            DisplayValue(dgvUserList.CurrentRow.Cells(c_rowid.Index).Value)

        End If

        view_ID = VIEW_privilege("Users", org_rowid)

        Dim formuserprivilege = position_view_table.Select("ViewID = " & view_ID)

        If formuserprivilege.Count = 0 Then

            btnNew.Visible = 0
            btnSave.Visible = 0
            btnDelete.Visible = 0
        Else
            For Each drow In formuserprivilege
                If drow("ReadOnly").ToString = "Y" Then
                    'ToolStripButton2.Visible = 0
                    btnNew.Visible = 0
                    btnSave.Visible = 0
                    btnDelete.Visible = 0
                    dontUpdate = 1
                    Exit For
                Else
                    If drow("Creates").ToString = "N" Then
                        btnNew.Visible = 0
                    Else
                        btnNew.Visible = 1
                    End If

                    If drow("Deleting").ToString = "N" Then
                        btnDelete.Visible = 0
                    Else
                        btnDelete.Visible = 1
                    End If

                    If drow("Updates").ToString = "N" Then
                        dontUpdate = 1
                    Else
                        dontUpdate = 0
                    End If

                End If

            Next

        End If

        Dim dgv_row_count = dgvUserList.DisplayedRowCount(False)

        If dgv_row_count > 0 Then
            'dgvUserList_CellClick(dgvUserList, New DataGridViewCellEventArgs(c_userid.Index, dgvUserList.CurrentRow.Index))
            dgvUserList_CellClick(dgvUserList, New DataGridViewCellEventArgs(c_userid.Index, 0))
        End If

    End Sub

    Private Sub ToolStripButton12_Click(sender As Object, e As EventArgs) Handles ToolStripButton12.Click
        Close()

    End Sub

    Private Sub dgvUserList_CellClick(sender As Object, e As DataGridViewCellEventArgs) Handles dgvUserList.CellClick

        RemoveHandler txtPassword.TextChanged, AddressOf txtConfirmPassword_TextChanged

        RemoveHandler txtConfirmPassword.TextChanged, AddressOf txtConfirmPassword_TextChanged

        RemoveHandler chkboxIsDeptMngr.CheckedChanged, AddressOf chkboxIsDeptMngr_CheckedChanged

        Try

            DisplayValue(dgvUserList.CurrentRow.Cells(c_rowid.Index).Value)
        Catch ex As Exception
        Finally

            txtConfirmPassword.Tag = Nothing

            AddHandler txtPassword.TextChanged, AddressOf txtConfirmPassword_TextChanged

            AddHandler txtConfirmPassword.TextChanged, AddressOf txtConfirmPassword_TextChanged

            AddHandler chkboxIsDeptMngr.CheckedChanged, AddressOf chkboxIsDeptMngr_CheckedChanged

            txtConfirmPassword_TextChanged(txtConfirmPassword, New EventArgs)

        End Try

    End Sub

    Private Sub lblAddPosition_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles lblAddPosition.LinkClicked

        Dim n_EmpPosition As New EmpPosition

        With n_EmpPosition

            .ShowMeAsDialog = True

            .Size = New Size(901, 477)

            .StartPosition = FormStartPosition.CenterScreen

            .WindowState = FormWindowState.Normal

            .MinimizeBox = False

            .MaximizeBox = False

            .FormBorderStyle = Windows.Forms.FormBorderStyle.FixedDialog

            .ShowDialog()

        End With

        'AddPostionForm.ShowDialog()

    End Sub

    Private Sub btnDelete_Click(sender As Object, e As EventArgs) Handles btnDelete.Click
        Try

            If MsgBox("Are you sure you want to remove this user?", MsgBoxStyle.YesNo, "Removing...") = MsgBoxResult.Yes Then

                DirectCommand("Update user Set Status = 'Inactive' Where RowID = '" & dgvUserList.CurrentRow.Cells(c_rowid.Index).Value & "'")
                fillUsers()
            End If
        Catch ex As Exception
            MsgBox(ex.Message, MsgBoxStyle.Critical, "Error code btnDelete_Click")
        End Try
    End Sub

    Private Sub tsAuditTrail_Click(sender As Object, e As EventArgs) Handles tsAuditTrail.Click
        showAuditTrail.Show()

        showAuditTrail.loadAudTrail(view_ID)

        showAuditTrail.BringToFront()

    End Sub

    Private Sub cmbPosition_KeyPress(sender As Object, e As KeyPressEventArgs) Handles cmbPosition.KeyPress

        e.Handled = True

    End Sub

    Private Sub cmbPosition_SelectedIndexChanged(sender As Object, e As EventArgs) Handles cmbPosition.SelectedIndexChanged

    End Sub

    Private Sub dgvUserList_CellContentClick(sender As Object, e As DataGridViewCellEventArgs) Handles dgvUserList.CellContentClick

    End Sub

    Private Sub txtConfirmPassword_TextChanged(sender As Object, e As EventArgs) 'Handles txtConfirmPassword.TextChanged

        If txtConfirmPassword.Text.Trim = txtPassword.Text.Trim Then
            txtConfirmPassword.Tag = txtConfirmPassword.Text.Trim
        Else
            txtConfirmPassword.Tag = Nothing
        End If

    End Sub

    Protected Overrides Sub OnActivated(e As EventArgs)
        KeyPreview = True
        MyBase.OnActivated(e)
    End Sub

    Protected Overrides Sub OnDeactivate(e As EventArgs)
        KeyPreview = False
        MyBase.OnDeactivate(e)
    End Sub

    Private Sub chkboxIsDeptMngr_CheckedChanged2(sender As Object, e As EventArgs) Handles chkboxIsDeptMngr.CheckedChanged

    End Sub

    Private Sub chkboxIsDeptMngr_CheckedChanged(sender As Object, e As EventArgs)

        If chkboxIsDeptMngr.Checked Then

            Dim emp_data As New EmployeeData

            Dim already_as_dptmngr As Boolean = ((dgvUserList.CurrentRow.Cells("c_userid").Tag = Nothing) = False)

            'If (chkboxIsDeptMngr.Tag = Nothing) = False Then
            If already_as_dptmngr Then
                'emp_data.RowID = chkboxIsDeptMngr.Tag
                emp_data.RowID = dgvUserList.CurrentRow.Cells("c_userid").Tag
            End If

            If emp_data.ShowDialog = Windows.Forms.DialogResult.OK Then

                chkboxIsDeptMngr.Tag = emp_data.RowID
            Else
                dgvUserList_CellClick(dgvUserList, New DataGridViewCellEventArgs(c_userid.Index, dgvUserList.CurrentRow.Index))
            End If
        Else
            chkboxIsDeptMngr.Tag = Nothing
        End If

    End Sub

End Class