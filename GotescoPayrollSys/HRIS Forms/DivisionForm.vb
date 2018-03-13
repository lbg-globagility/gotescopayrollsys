Public Class DivisionForm

    Protected Overrides Sub OnLoad(e As EventArgs)

        OjbAssignNoContextMenu(txtgraceperiod)

        OjbAssignNoContextMenu(txtmindayperyear)

        OjbAssignNoContextMenu(txtslallow)
        OjbAssignNoContextMenu(txtvlallow)
        OjbAssignNoContextMenu(txtmlallow)
        OjbAssignNoContextMenu(txtpatlallow)

        Dim payfrequencytable As New DataTable

        Dim n_SQLQueryToDatatable As New SQLQueryToDatatable("SELECT RowID,PayFrequencyType FROM payfrequency;")

        payfrequencytable = n_SQLQueryToDatatable.ResultTable

        cbopayfrequency.ValueMember = payfrequencytable.Columns(0).ColumnName

        cbopayfrequency.DisplayMember = payfrequencytable.Columns(1).ColumnName

        cbopayfrequency.DataSource = payfrequencytable

        'enlistTheLists("SELECT DisplayValue FROM listofval WHERE `Type`='Government deduction schedule' AND Active='Yes' ORDER BY OrderBy;", govdeducsched)

        MyBase.OnLoad(e)

    End Sub

    Dim IsNew As Integer = 0
    'Private Sub AddNode(parentNode As String, nodeText As String)
    '    Dim node As New List(Of TreeNode)
    '    node.AddRange(TreeView1.Nodes.Find(parentNode, True))
    '    If Not node.Any Then
    '        node.Add(TreeView1.Nodes.Add(parentNode, parentNode))
    '    End If
    '    node(0).Nodes.Add(nodeText, nodeText)
    'End Sub

    'Private Sub filltreeview()
    '    Dim dt As New DataTable()
    '    dt = getDataTableForSQL("Select * from division where DivisionType = 'Department' And OrganizationID = '" & z_OrganizationID & "'")
    '    TreeView1.Nodes.Clear()
    '    For Each dr As DataRow In dt.Rows

    '        Dim dvID As String = dr("RowID").ToString
    '        Dim dv As New DataTable
    '        dv = getDataTableForSQL("Select * from division Where ParentDivisionID = '" & Val(dvID) & "' And OrganizationID = '" & z_OrganizationID & "' And DivisionType = 'Branch'")

    '        For Each drow As DataRow In dv.Rows
    '            AddNode(dr("Name").ToString, drow("Name").ToString)
    '            Dim dvID2 As String = drow("RowID").ToString
    '            Dim dv2 As New DataTable
    '            dv2 = getDataTableForSQL("Select * from division Where ParentDivisionID = '" & Val(dvID2) & "' And OrganizationID = '" & z_OrganizationID & "' And DivisionType = 'Sub branch'")

    '            For Each drow2 As DataRow In dv2.Rows
    '                AddNode(drow("Name").ToString, drow2("Name").ToString)
    '            Next

    '        Next

    '    Next
    '    TreeView1.ExpandAll()
    'End Sub

    Sub fillDivisionCMB(Optional ExceptDivision As String = Nothing)

        Dim additionalQuery As String = Nothing

        If ExceptDivision = Nothing Then
            additionalQuery = ";"
        Else
            additionalQuery = " AND Name != '" & ExceptDivision & "';"
        End If

        Dim strQuery As String = "select Name from Division Where OrganizationID = '" & z_OrganizationID & "'" & additionalQuery

        cmbDivision.Items.Clear()
        cmbDivision.Items.Add("")
        cmbDivision.Items.AddRange(CType(SQL_ArrayList(strQuery).ToArray(GetType(String)), String()))
        cmbDivision.SelectedIndex = 0

    End Sub

    Private Sub fillDivision()
        Dim dt As New DataTable
        dt = getDataTableForSQL("SELECT d.*" & _
                                ",IFNULL(pf.PayFrequencyType,'') AS PayFrequencyType" & _
                                ",IFNULL(pf.RowID,'') AS pfRowID" & _
                                " FROM `division` d" & _
                                " LEFT JOIN payfrequency pf ON pf.RowID=d.PayFrequencyID" & _
                                " WHERE d.OrganizationID = '" & z_OrganizationID & "'" & _
                                " LIMIT " & pagination & ", 20;")

        dgvDivisionList.Rows.Clear()
        For Each row As DataRow In dt.Rows
            Dim n As Integer = dgvDivisionList.Rows.Add()
            With row
                Dim dvID As String = .Item("ParentDivisionID").ToString
                Dim dv As String = getStringItem("Select Name from division Where RowID = '" & Val(dvID) & "' And OrganizationID = '" & z_OrganizationID & "'")
                Dim getdv As String = dv

                dgvDivisionList.Rows.Item(n).Cells(c_divisionName.Index).Value = .Item("DivisionType").ToString
                dgvDivisionList.Rows.Item(n).Cells(c_division.Index).Value = getdv
                dgvDivisionList.Rows.Item(n).Cells(c_name.Index).Value = .Item("Name").ToString
                dgvDivisionList.Rows.Item(n).Cells(c_TradeName.Index).Value = .Item("TradeName").ToString
                dgvDivisionList.Rows.Item(n).Cells(c_MainPhone.Index).Value = .Item("MainPhone").ToString
                dgvDivisionList.Rows.Item(n).Cells(c_AltMainPhone.Index).Value = .Item("AltPhone").ToString
                dgvDivisionList.Rows.Item(n).Cells(c_emailaddr.Index).Value = .Item("EmailAddress").ToString
                dgvDivisionList.Rows.Item(n).Cells(c_altemailaddr.Index).Value = .Item("AltEmailAddress").ToString
                dgvDivisionList.Rows.Item(n).Cells(c_FaxNo.Index).Value = .Item("FaxNumber").ToString
                dgvDivisionList.Rows.Item(n).Cells(c_tinno.Index).Value = .Item("TinNo").ToString
                dgvDivisionList.Rows.Item(n).Cells(c_url.Index).Value = .Item("URL").ToString
                dgvDivisionList.Rows.Item(n).Cells(c_contactName.Index).Value = .Item("ContactName").ToString
                dgvDivisionList.Rows.Item(n).Cells(c_businessaddr.Index).Value = .Item("BusinessAddress").ToString
                dgvDivisionList.Rows.Item(n).Cells(c_rowID.Index).Value = .Item("RowID").ToString

                dgvDivisionList.Rows.Item(n).Cells(GracePeriod.Index).Value = .Item("GracePeriod").ToString

                dgvDivisionList.Rows.Item(n).Cells(WorkDaysPerYear.Index).Value = .Item("WorkDaysPerYear").ToString

                dgvDivisionList.Rows.Item(n).Cells(PhHealthDeductSched.Index).Value = .Item("PhHealthDeductSched").ToString

                dgvDivisionList.Rows.Item(n).Cells(HDMFDeductSched.Index).Value = .Item("HDMFDeductSched").ToString

                dgvDivisionList.Rows.Item(n).Cells(SSSDeductSched.Index).Value = .Item("SSSDeductSched").ToString

                dgvDivisionList.Rows.Item(n).Cells(WTaxDeductSched.Index).Value = .Item("WTaxDeductSched").ToString

                dgvDivisionList.Rows.Item(n).Cells(DefaultVacationLeave.Index).Value = .Item("DefaultVacationLeave").ToString

                dgvDivisionList.Rows.Item(n).Cells(DefaultSickLeave.Index).Value = .Item("DefaultSickLeave").ToString

                dgvDivisionList.Rows.Item(n).Cells(DefaultMaternityLeave.Index).Value = .Item("DefaultMaternityLeave").ToString

                dgvDivisionList.Rows.Item(n).Cells(DefaultPaternityLeave.Index).Value = .Item("DefaultPaternityLeave").ToString

                dgvDivisionList.Rows.Item(n).Cells(DefaultOtherLeave.Index).Value = .Item("DefaultOtherLeave").ToString

                dgvDivisionList.Rows.Item(n).Cells(PayFrequencyType.Index).Value = .Item("PayFrequencyType").ToString

                dgvDivisionList.Rows.Item(n).Cells(PayFrequencyID.Index).Value = .Item("pfRowID").ToString

                dgvDivisionList.Rows.Item(n).Cells(PayFrequencyID.Index).Value = .Item("PhHealthDeductSchedAgency").ToString

                dgvDivisionList.Rows.Item(n).Cells(PayFrequencyID.Index).Value = .Item("HDMFDeductSchedAgency").ToString

                dgvDivisionList.Rows.Item(n).Cells(PayFrequencyID.Index).Value = .Item("SSSDeductSchedAgency").ToString

                dgvDivisionList.Rows.Item(n).Cells(PayFrequencyID.Index).Value = .Item("WTaxDeductSchedAgency").ToString

            End With

        Next

    End Sub

    Private Sub fillSelectedDivision()
        If dgvDivisionList.Rows.Count = 0 Then
        Else
            Dim dt As New DataTable
            'dt = getDataTableForSQL("Select * From Division Where OrganizationID = '" & z_OrganizationID & "' And RowID = '" & dgvDivisionList.CurrentRow.Cells(c_rowID.Index).Value & "'")

            dt = getDataTableForSQL("SELECT d.*" & _
                                    ",IFNULL(pf.PayFrequencyType,'') AS PayFrequencyType" & _
                                    ",IFNULL(pf.RowID,'') AS pfRowID" & _
                                    " FROM `division` d" & _
                                    " LEFT JOIN payfrequency pf ON pf.RowID=d.PayFrequencyID" & _
                                    " WHERE d.OrganizationID = '" & z_OrganizationID & "'" & _
                                    " AND d.RowID = '" & dgvDivisionList.CurrentRow.Cells(c_rowID.Index).Value & "'" & _
                                    " LIMIT " & pagination & ", 20;")

            For Each row As DataRow In dt.Rows

                With row
                    Dim dvID As String = .Item("ParentDivisionID").ToString
                    Dim dv As String = getStringItem("Select Name from division Where RowID = '" & Val(dvID) & "' And OrganizationID = '" & z_OrganizationID & "'")
                    Dim getdv As String = dv

                    cmbDivision.Text = dv
                    cmbDivisionType.Text = .Item("DivisionType").ToString
                    txtname.Text = .Item("Name").ToString
                    txttradename.Text = .Item("TradeName").ToString
                    txtmainphone.Text = .Item("MainPhone").ToString
                    txtaltphone.Text = .Item("AltPhone").ToString
                    txtaltemailaddr.Text = .Item("EmailAddress").ToString
                    txtaltemailaddr.Text = .Item("AltEmailAddress").ToString
                    txtfaxno.Text = .Item("FaxNumber").ToString
                    txttinno.Text = .Item("TinNo").ToString
                    txturl.Text = .Item("URL").ToString
                    txtcontantname.Text = .Item("ContactName").ToString
                    txtbusinessaddr.Text = .Item("BusinessAddress").ToString

                    txtgraceperiod.Text = .Item("GracePeriod").ToString

                    txtmindayperyear.Text = .Item("WorkDaysPerYear").ToString

                    cbophhdeductsched.Text = .Item("PhHealthDeductSched").ToString

                    cbohdmfdeductsched.Text = .Item("HDMFDeductSched").ToString

                    cbosssdeductsched.Text = .Item("SSSDeductSched").ToString

                    cboTaxDeductSched.Text = .Item("WTaxDeductSched").ToString

                    txtvlallow.Text = .Item("DefaultVacationLeave").ToString

                    txtslallow.Text = .Item("DefaultSickLeave").ToString

                    txtmlallow.Text = .Item("DefaultMaternityLeave").ToString

                    txtpatlallow.Text = .Item("DefaultPaternityLeave").ToString

                    txtotherallow.Text = .Item("DefaultOtherLeave").ToString

                    cbopayfrequency.Text = .Item("PayFrequencyType").ToString

                    cbophhdeductsched2.Text = .Item("PhHealthDeductSchedAgency").ToString

                    cbohdmfdeductsched2.Text = .Item("HDMFDeductSchedAgency").ToString

                    cbosssdeductsched2.Text = .Item("SSSDeductSchedAgency").ToString

                    cboTaxDeductSched2.Text = .Item("WTaxDeductSchedAgency").ToString

                    txtminwage.Text = .Item("MinimumWageAmount")

                    If IsDBNull(.Item("AutomaticOvertimeFiling")) Then
                        chkbxAutoOT.Checked = False
                    Else
                        chkbxAutoOT.Checked = Convert.ToInt16(.Item("AutomaticOvertimeFiling"))
                    End If

                End With

            Next

        End If

    End Sub

    Private Sub cleartext()
        txtaltemailaddr.Clear()
        txtaltphone.Clear()
        txtbusinessaddr.Clear()
        txtcontantname.Clear()
        cmbDivisionType.SelectedIndex = -1
        txtemailaddr.Clear()
        txtfaxno.Clear()
        txtmainphone.Clear()
        txtname.Clear()
        txttradename.Clear()
        txttinno.Clear()
        txturl.Clear()

        txtgraceperiod.Clear()

        txtmindayperyear.Clear()

        cbophhdeductsched.Text = String.Empty

        cbohdmfdeductsched.Text = String.Empty

        cbosssdeductsched.Text = String.Empty

        cboTaxDeductSched.Text = String.Empty

        txtvlallow.Clear()

        txtslallow.Clear()

        txtmlallow.Clear()

        txtpatlallow.Clear()

        txtotherallow.Clear()

    End Sub

    Private Sub btnClose_Click(sender As Object, e As EventArgs) Handles btnClose.Click
        Me.Close()

    End Sub

    Dim divisiontbl As New DataTable

    Private Sub btnNew_Click(sender As Object, e As EventArgs) Handles btnNew.Click
        cleartext()

        IsNew = 1

        btnNew.Enabled = False

        cmbDivisionType.Focus()

        divisiontbl = retAsDatTbl("SELECT RowID,Name FROM division WHERE OrganizationID=" & org_rowid & ";")

        cmbDivision.Items.Clear()

        For Each drow As DataRow In divisiontbl.Rows
            cmbDivision.Items.Add(Trim(drow("Name")))
        Next

    End Sub

    Dim dontUpdate As SByte = 0

    Private Sub btnSave_Click(sender As Object, e As EventArgs) Handles btnSave.Click

        btnSave.Enabled = False

        If cbopayfrequency.SelectedValue = Nothing Then
            cbopayfrequency.Focus()

            IsNew = 2

        End If

        If IsNew = 1 Then

            SP_Division(Trim(txtname.Text), Trim(txtmainphone.Text), Trim(txtfaxno.Text), Trim(txtemailaddr.Text), Trim(txtaltemailaddr.Text), _
                        Trim(txtaltphone.Text), Trim(txturl.Text), z_datetime, user_row_id, z_datetime, user_row_id, Trim(txttinno.Text), _
                        Trim(txttradename.Text), Trim(cmbDivisionType.Text), Trim(txtbusinessaddr.Text), Trim(txtcontantname.Text),
                        z_OrganizationID,
                        FormatNumber(ValNoComma(txtgraceperiod.Text), 2).Replace(",", ""),
                        ValNoComma(txtmindayperyear.Text),
                        cbophhdeductsched.Text,
                        cbohdmfdeductsched.Text,
                        cbosssdeductsched.Text,
                        cboTaxDeductSched.Text,
                        FormatNumber(ValNoComma(txtvlallow.Text), 2).Replace(",", ""),
                        FormatNumber(ValNoComma(txtslallow.Text), 2).Replace(",", ""),
                        FormatNumber(ValNoComma(txtmlallow.Text), 2).Replace(",", ""),
                        FormatNumber(ValNoComma(txtpatlallow.Text), 2).Replace(",", ""),
                        FormatNumber(ValNoComma(txtotherallow.Text), 2).Replace(",", ""),
                        cbopayfrequency.SelectedValue,
                        cbophhdeductsched2.Text,
                        cbohdmfdeductsched2.Text,
                        cbosssdeductsched2.Text,
                        cboTaxDeductSched2.Text,
                        ValNoComma(txtminwage.Text),
                        chkbxAutoOT.Tag)

            If cmbDivision.Text IsNot Nothing Then
                Dim dvID As String = getStringItem("Select RowID from division Where Name = '" & txtname.Text & "' And OrganizationID = '" & z_OrganizationID & "'")
                Dim getdvID As Integer = Val(dvID)
                Dim dv As String = getStringItem("Select RowID from division Where Name = '" & cmbDivision.Text & "' And OrganizationID = '" & z_OrganizationID & "'")
                Dim getdv As Integer = Val(dv)
                DirectCommand("UPDATE division SET ParentDivisionID = '" & getdv & "' Where RowID = '" & getdvID & "'")
            End If
            fillDivision()
            'filltreeview()

        ElseIf IsNew = 0 Then

            If dontUpdate = 1 Then
                Exit Sub
            ElseIf dgvDivisionList.RowCount = 0 Then
                Exit Sub
            End If

            SP_DivisionUpdate(txtname.Text, txtmainphone.Text, txtfaxno.Text, txtemailaddr.Text, txtaltemailaddr.Text, _
                       txtaltphone.Text, txturl.Text, z_datetime, user_row_id, txttinno.Text, _
                       txttradename.Text, cmbDivisionType.Text, txtbusinessaddr.Text, txtcontantname.Text, dgvDivisionList.CurrentRow.Cells(c_rowID.Index).Value,
                        FormatNumber(ValNoComma(txtgraceperiod.Text), 2).Replace(",", ""),
                        ValNoComma(txtmindayperyear.Text),
                        cbophhdeductsched.Text,
                        cbohdmfdeductsched.Text,
                        cbosssdeductsched.Text,
                        cboTaxDeductSched.Text,
                        FormatNumber(ValNoComma(txtvlallow.Text), 2).Replace(",", ""),
                        FormatNumber(ValNoComma(txtslallow.Text), 2).Replace(",", ""),
                        FormatNumber(ValNoComma(txtmlallow.Text), 2).Replace(",", ""),
                        FormatNumber(ValNoComma(txtpatlallow.Text), 2).Replace(",", ""),
                        FormatNumber(ValNoComma(txtotherallow.Text), 2).Replace(",", ""),
                        cbopayfrequency.SelectedValue,
                        cbophhdeductsched2.Text,
                        cbohdmfdeductsched2.Text,
                        cbosssdeductsched2.Text,
                        cboTaxDeductSched2.Text,
                        ValNoComma(txtminwage.Text),
                        chkbxAutoOT.Tag)

            If cmbDivision.Text IsNot Nothing Then
                Dim dvID As String = getStringItem("Select RowID from division Where Name = '" & txtname.Text & "' And OrganizationID = '" & z_OrganizationID & "'")
                Dim getdvID As Integer = Val(dvID)
                Dim dv As String = getStringItem("Select RowID from division Where Name = '" & cmbDivision.Text & "' And OrganizationID = '" & z_OrganizationID & "'")
                Dim getdv As Integer = Val(dv)
                DirectCommand("UPDATE division SET ParentDivisionID = '" & getdv & "' Where RowID = '" & getdvID & "'")
            End If

            fillDivision()
            'filltreeview()

        End If

        IsNew = 0

        btnSave.Enabled = True

    End Sub

    Private Sub DivisionForm_FormClosing(sender As Object, e As FormClosingEventArgs) Handles Me.FormClosing

        If previousForm IsNot Nothing Then
            If previousForm.Name = Me.Name Then
                previousForm = Nothing
            End If
        End If

        HRISForm.listHRISForm.Remove(Me.Name)

    End Sub

    Dim view_ID As Integer = Nothing

    Private Sub DivisionForm_Load(sender As Object, e As EventArgs) Handles Me.Load

        fillDivision()

        fillSelectedDivision()
        'filltreeview()

        'divisiontable = retAsDatTbl("SELECT * FROM division WHERE OrganizationID=" & orgztnID & ";")

        'alphadivision = retAsDatTbl("SELECT * FROM division WHERE OrganizationID=" & orgztnID & " AND ParentDivisionID IS NULL;")

        'For Each drow As DataRow In alphadivision.Rows

        '    Divisiontreeviewfiller(drow("RowID"), drow("Name"), )

        'Next

        'TreeView1.ExpandAll()

        view_ID = VIEW_privilege("Division", org_rowid)

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

        If dgvDivisionList.RowCount <> 0 Then
            fillDivisionCMB(dgvDivisionList.Item("c_name", 0).Value)
        Else

        End If

    End Sub

    Dim divisiontable As New DataTable

    Dim alphadivision As New DataTable

    Sub Divisiontreeviewfiller(Optional primkey As Object = Nothing, _
                       Optional strval As Object = Nothing, _
                       Optional trnod As TreeNode = Nothing)

        Dim n_nod As TreeNode = Nothing

        strval = strval & "[Department]"

        If trnod Is Nothing Then
            'n_nod = TreeView1.Nodes.Add(primkey, strval)
        Else
            n_nod = trnod.Nodes.Add(primkey, strval)
        End If

        Dim selchild = divisiontable.Select("ParentDivisionID=" & primkey)

        For Each drow In selchild

            Divisiontreeviewfiller(drow("RowID"), drow("Name"), n_nod)

        Next

    End Sub

    Private Sub dgvDivisionList_CellClick(sender As Object, e As DataGridViewCellEventArgs) Handles dgvDivisionList.CellClick

        chkbxAutoOT.Checked = False

        fillSelectedDivision()

        If dgvDivisionList.RowCount <> 0 Then

            fillDivisionCMB(dgvDivisionList.CurrentRow.Cells("c_name").Value)
        Else

        End If

    End Sub

    Private Sub tsAudittrail_Click(sender As Object, e As EventArgs) Handles tsAudittrail.Click
        showAuditTrail.Show()

        showAuditTrail.loadAudTrail(view_ID)

        showAuditTrail.BringToFront()

    End Sub

    Private Sub cmbDivisionType_SelectedIndexChanged(sender As Object, e As EventArgs) Handles cmbDivisionType.SelectedIndexChanged

    End Sub

    Private Sub cmbDivision_SelectedIndexChanged(sender As Object, e As EventArgs) Handles cmbDivision.SelectedIndexChanged

    End Sub

    Private Sub dgvDivisionList_CellContentClick(sender As Object, e As DataGridViewCellEventArgs) Handles dgvDivisionList.CellContentClick

    End Sub

    Private Sub btnCancel_Click(sender As Object, e As EventArgs) Handles btnCancel.Click
        btnNew.Enabled = True

        If dgvDivisionList.RowCount <> 0 Then
            dgvDivisionList_CellClick(sender, New DataGridViewCellEventArgs(c_divisionName.Index, 0))

        End If

    End Sub

    Private Sub txtgraceperiod_KeyPress(sender As Object, e As KeyPressEventArgs) Handles txtgraceperiod.KeyPress

        Dim e_KAsc As String = Asc(e.KeyChar)

        Static onedot As SByte = 0

        If (e_KAsc >= 48 And e_KAsc <= 57) Or e_KAsc = 8 Or e_KAsc = 46 Then

            If e_KAsc = 46 Then

                onedot += 1

                If onedot >= 2 Then

                    If txtgraceperiod.Text.Contains(".") Then
                        e.Handled = True

                        onedot = 2
                    Else
                        e.Handled = False

                        onedot = 0

                    End If
                Else
                    If txtgraceperiod.Text.Contains(".") Then
                        e.Handled = True
                    Else
                        e.Handled = False

                    End If

                End If
            Else
                e.Handled = False

            End If
        Else
            e.Handled = True

        End If

    End Sub

    Private Sub txtgraceperiod_TextChanged(sender As Object, e As EventArgs) Handles txtgraceperiod.TextChanged

    End Sub

    Private Sub dgvDivisionList_SelectionChanged(sender As Object, e As EventArgs) Handles dgvDivisionList.SelectionChanged

    End Sub

    Private Sub txtmindayperyear_KeyPress(sender As Object, e As KeyPressEventArgs) Handles txtmindayperyear.KeyPress

        Dim e_asc = Asc(e.KeyChar)

        Dim n_TrapDecimalKey As New TrapDecimalKey(e_asc, txtmindayperyear.Text)

        e.Handled = n_TrapDecimalKey.ResultTrap

    End Sub

    Private Sub txtmindayperyear_TextChanged(sender As Object, e As EventArgs) Handles txtmindayperyear.TextChanged

    End Sub

    Private Sub Leaves_KeyPress(sender As Object, e As KeyPressEventArgs) Handles txtslallow.KeyPress, _
                                                                                    txtvlallow.KeyPress, _
                                                                                    txtmlallow.KeyPress, _
                                                                                    txtpatlallow.KeyPress

        Dim e_asc = Asc(e.KeyChar)

        Dim obj_sndr = DirectCast(sender, TextBox)

        Dim n_TrapDecimalKey As New TrapDecimalKey(e_asc, obj_sndr.Text)

        e.Handled = n_TrapDecimalKey.ResultTrap

    End Sub

    Dim pagination As Integer = 0

    Private Sub Pagination_Link(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles First.LinkClicked,
                                                                                                Prev.LinkClicked,
                                                                                                Nxt.LinkClicked,
                                                                                                Last.LinkClicked

        'RemoveHandler dgvemployees.SelectionChanged, AddressOf dgvemployees_SelectionChanged

        Dim sendrname As String = DirectCast(sender, LinkLabel).Name

        If sendrname = "First" Then
            pagination = 0
        ElseIf sendrname = "Prev" Then

            Dim modcent = pagination Mod 20

            If modcent = 0 Then

                pagination -= 20
            Else

                pagination -= modcent

            End If

            If pagination < 0 Then

                pagination = 0

            End If

        ElseIf sendrname = "Nxt" Then

            Dim modcent = pagination Mod 20

            If modcent = 0 Then
                pagination += 20
            Else
                pagination -= modcent

                pagination += 20

            End If
        ElseIf sendrname = "Last" Then
            Dim lastpage = Val(EXECQUER("SELECT COUNT(RowID) FROM employee WHERE OrganizationID=" & org_rowid & ";"))

            Dim remender = lastpage Mod 20

            pagination = lastpage - remender

            If pagination - 20 < 20 Then
                pagination = 0

            End If

            'pagination = If(lastpage - 20 >= 20, _
            '                lastpage - 20, _
            '                lastpage)

        End If

        btnRefresh_Click(sender, e)

        'dgvemployees_SelectionChanged(sender, e)

        'AddHandler dgvemployees.SelectionChanged, AddressOf dgvemployees_SelectionChanged

    End Sub

    Dim VIEW_division As New DataTable

    Private Sub btnRefresh_Click(sender As Object, e As EventArgs) Handles btnRefresh.Click

        VIEW_division = New DataTable

        Dim n_ReadSQLProcedureToDatatable As New ReadSQLProcedureToDatatable("VIEW_division",
                                                                             org_rowid,
                                                                             autcomptxtdivision.Text.Trim)

        VIEW_division = n_ReadSQLProcedureToDatatable.ResultTable

        dgvDivisionList.Rows.Clear()

        For Each drow As DataRow In VIEW_division.Rows

            Dim rowarray = drow.ItemArray

            dgvDivisionList.Rows.Add(rowarray)

        Next

    End Sub

    Private Sub btnDelete_Click(sender As Object, e As EventArgs) Handles btnDelete.Click

    End Sub

    Private Sub cbopayfrequency_SelectedIndexChanged(sender As Object, e As EventArgs) Handles cbopayfrequency.SelectedIndexChanged

        'MsgBox(cbopayfrequency.SelectedValue)

    End Sub

    Private Sub txtminwage_KeyPress(sender As Object, e As KeyPressEventArgs) Handles txtminwage.KeyPress

        Dim e_asc = Asc(e.KeyChar)

        Dim n_TrapDecimalKey As New TrapDecimalKey(e_asc, txtminwage.Text)

        e.Handled = n_TrapDecimalKey.ResultTrap

    End Sub

    Private Sub txtminwage_TextChanged(sender As Object, e As EventArgs) Handles txtminwage.TextChanged

    End Sub

    Private Sub chkbxAutoOT_CheckedChanged(sender As Object, e As EventArgs) Handles chkbxAutoOT.CheckedChanged

        Dim bool_result = chkbxAutoOT.Checked

        chkbxAutoOT.Tag = Convert.ToInt16(bool_result)

        If bool_result Then
        Else

        End If

    End Sub

    Protected Overrides Sub OnActivated(e As EventArgs)
        Me.KeyPreview = True
        MyBase.OnActivated(e)
    End Sub

    Protected Overrides Sub OnDeactivate(e As EventArgs)
        Me.KeyPreview = False
        MyBase.OnDeactivate(e)
    End Sub

End Class