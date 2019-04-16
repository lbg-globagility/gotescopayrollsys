Public Class LoanType

    Protected Overrides Sub OnLoad(e As EventArgs)
        Size = New Size(346, 175)
        MyBase.OnLoad(e)
    End Sub

    Private Sub LoanType_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        'dbconn()

        TextBox1.ContextMenu = New ContextMenu
        'Gotesco
    End Sub

    Private Sub Button1_Click(sender As Object, e As EventArgs) Handles Button1.Click
        dgvproduct.EndEdit()
        If Trim(TextBox1.Text) <> "" Then
            'TextBox1.Text = StrConv(TextBox1.Text, VbStrConv.ProperCase)
            Dim new_ID = EmployeeForm.INS_product(Trim(TextBox1.Text), _
                             Trim(TextBox1.Text), _
                             "Loan Type", ,
                             chknondeductible.Tag)

            EmployeeForm.cboloantype.Items.Add(Trim(TextBox1.Text))

            EmployeeForm.loan_type.Add(Trim(TextBox1.Text) & "@" & new_ID)

            If lnklblleave.Text.Length = 5 Then

                LoadLoanNames()

            End If

        End If

        Close()
    End Sub

    Private Sub Button2_Click(sender As Object, e As EventArgs) Handles Button2.Click
        Close()
    End Sub

    Private Sub chknondeductible_CheckedChanged(sender As Object, e As EventArgs) Handles chknondeductible.CheckedChanged
        chknondeductible.Tag = Convert.ToInt32(chknondeductible.Checked).ToString

    End Sub

    Private Sub lnklblleave_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles lnklblleave.LinkClicked

        Static once As SByte = 2

        If once Mod 2 = 0 Then
            once = 1
            lnklblleave.Text = "Hid&e"
            '5
            Size = New Size(346, 435)

            LoadLoanNames()

        Else
            once = 2
            lnklblleave.Text = "Vi&ew others"
            '12
            Size = New Size(346, 175)
        End If

        ResumeLayout()

    End Sub

    Dim loanprod As New DataTable

    Private Sub LoadLoanNames()

        loanprod.Dispose()

        loanprod = New SQLQueryToDatatable("SELECT p.RowID" &
                                           ",p.PartNo" &
                                           ",IF(p.Strength='1',TRUE,FALSE) AS Strength" &
                                           " FROM product p" &
                                           " INNER JOIN category cg ON cg.OrganizationID='" & org_rowid & "' AND p.CategoryID=cg.RowID AND cg.CategoryName='Loan Type'" &
                                           " WHERE p.OrganizationID='" & org_rowid & "';").ResultTable

        dgvproduct.Rows.Clear()

        For Each drow As DataRow In loanprod.Rows

            Dim rowarray = drow.ItemArray()

            dgvproduct.Rows.Add(rowarray)

        Next

    End Sub


    Private Sub dgvproduct_CellBeginEdit(sender As Object, e As DataGridViewCellCancelEventArgs) Handles dgvproduct.CellBeginEdit

    End Sub

    Private Sub dgvproduct_CellContentClick(sender As Object, e As DataGridViewCellEventArgs) Handles dgvproduct.CellContentClick

    End Sub

    Private Sub dgvproduct_CellEndEdit(sender As Object, e As DataGridViewCellEventArgs) Handles dgvproduct.CellEndEdit

        Dim hasNoError = 0

        Dim dgcolname As String = String.Empty

        Try

            If TypeOf dgvproduct.Item(e.ColumnIndex, e.RowIndex).Value Is Boolean Then
                dgvproduct.Item(e.ColumnIndex, e.RowIndex).Tag = Convert.ToInt32(dgvproduct.Item(e.ColumnIndex, e.RowIndex).Value)

            Else
                dgvproduct.Item(e.ColumnIndex, e.RowIndex).Tag = dgvproduct.Item(e.ColumnIndex, e.RowIndex).Value.ToString.Trim

            End If

            dgcolname = dgvproduct.Columns(e.ColumnIndex).Name

        Catch ex As Exception
            hasNoError = 1

            MsgBox(getErrExcptn(ex, Name))

        Finally

            If hasNoError = 0 Then

                Dim sel_loanprod = loanprod.Select("RowID=" & dgvproduct.Item("RowID", e.RowIndex).Value)

                Dim hasChanges As SByte = 0

                For Each prow In sel_loanprod

                    If prow(dgcolname).ToString <> dgvproduct.Item(dgcolname, e.RowIndex).Value.ToString Then
                        hasChanges = 1
                    End If

                Next

                If hasChanges = 1 Then

                    Dim n_ReadSQLFunction As _
                        New ReadSQLFunction("INSUPD_product",
                                            "prod_RowID",
                                            dgvproduct.Item("RowID", e.RowIndex).Value,
                                            dgvproduct.Item("PartNo", e.RowIndex).Value,
                                            org_rowid,
                                            dgvproduct.Item("PartNo", e.RowIndex).Value,
                                            user_row_id,
                                            user_row_id,
                                            0,
                                            0,
                                            0,
                                            0,
                                            0,
                                            dgvproduct.Item(e.ColumnIndex, e.RowIndex).Tag)

                End If

            End If

        End Try

    End Sub

    Private Sub dgvproduct_CellMouseDown(sender As Object, e As DataGridViewCellMouseEventArgs) Handles dgvproduct.CellMouseDown

    End Sub

    Private Sub dgvproduct_SelectionChanged(sender As Object, e As EventArgs) Handles dgvproduct.SelectionChanged

    End Sub

End Class