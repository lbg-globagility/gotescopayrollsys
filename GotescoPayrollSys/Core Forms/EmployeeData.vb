Public Class EmployeeData

#Region "Properties"

    Property RowID As String

    Property EmployeeId As String

    Property LastName As String

    Property FirstName As String

    Property MiddleName As String

    Property EmployeeType As String

    Property EmploymentStatus As String

    Property PositionName As String

    Property PositionID As String

    Property PayFrequencyType As String

    Property PayFrequencyId As String

    Property FullName As String

    Property ExceptRowIds() As Object()

#End Region

    Private str_view_employee_paystub As String =
        "CALL view_employee_paystub(?og_id, ?string_search, ?page_num, ?max_displaycount, ?is_display_thelast, ?payfreq_rowid);"

    Private char_enter_key = ChrW(13)

    Private has_pre_selected_emp As Boolean = False

    Private pre_selected_emprowid As String = ""

    Protected Overrides Sub OnLoad(e As EventArgs)
        Try
            has_pre_selected_emp = (RowID.Length > 0)
        Catch ex As Exception
            has_pre_selected_emp = False
        End Try

        If has_pre_selected_emp Then
            pre_selected_emprowid = RowID
        End If

        MyBase.OnLoad(e)

    End Sub

    Private Sub EmployeeData_Load(sender As Object, e As EventArgs) Handles MyBase.Load

        tsSearch_KeyPress(tsSearch, New KeyPressEventArgs(char_enter_key))

        If has_pre_selected_emp Then

            Dim dgv_rows =
                dgvEmployee.Rows.Cast(Of DataGridViewRow).Where(Function(dgv) dgv.Cells("e_rowid").Value = pre_selected_emprowid)

            dgvEmployee.ClearSelection()

            For Each dgv In dgv_rows

                'dgvEmployee.Item("e_id", dgv.Index).Selected = True
                dgvEmployee.CurrentCell = dgv.Cells("e_id")

            Next

        End If

        AddHandler dgvEmployee.SelectionChanged, AddressOf dgvEmployee_SelectionChanged1

        dgvEmployee_SelectionChanged1(dgvEmployee, New EventArgs)

    End Sub

    Private Sub tsSearch_Click(sender As Object, e As EventArgs) Handles tsSearch.Click

    End Sub

    Private Sub tsbtnSearch_Click(sender As Object, e As EventArgs) Handles tsbtnSearch.Click

        tsSearch_KeyPress(tsSearch, New KeyPressEventArgs(char_enter_key))

    End Sub

    Private Sub tsSearch_KeyPress(sender As Object, e As KeyPressEventArgs) Handles tsSearch.KeyPress

        Dim e_asc = Asc(e.KeyChar)

        If e_asc = 13 Then

            LoadEmployees()

            e.Handled = True

        End If

    End Sub

    Private Sub LoadEmployees()

        Dim str_searching As Object = tsSearch.Text.Trim

        Dim param_vals() =
            New Object() {org_rowid,
                          str_searching,
                          0,
                          Integer.MaxValue,
                          False,
                          DBNull.Value}

        Dim sql As New SQL(str_view_employee_paystub,
                           param_vals)

        Try

            dgvEmployee.Rows.Clear()

            Dim caught_datset As New DataSet
            caught_datset = sql.GetFoundRows

            If sql.HasError Then

                Throw sql.ErrorException
            Else

                Dim catch_table As New DataTable
                catch_table = caught_datset.Tables(0)

                For Each drow As DataRow In catch_table.Rows
                    Dim row_array = drow.ItemArray
                    dgvEmployee.Rows.Add(row_array)
                Next

            End If
        Catch ex As Exception
            MsgBox(getErrExcptn(ex, Name))
        Finally

        End Try

    End Sub

    Private Sub dgvEmployee_CellContentClick(sender As Object, e As DataGridViewCellEventArgs) Handles dgvEmployee.CellContentClick

    End Sub

    Private Sub dgvEmployee_SelectionChanged(sender As Object, e As EventArgs) Handles dgvEmployee.SelectionChanged

    End Sub

    Private Sub dgvEmployee_SelectionChanged1(sender As Object, e As EventArgs)

        If dgvEmployee.RowCount > 0 Then

            Dim has_validcurr_row As Boolean = False

            Try
                has_validcurr_row = (dgvEmployee.CurrentRow IsNot Nothing)
            Catch ex As Exception
                has_validcurr_row = False

            End Try

            If has_validcurr_row Then

                With dgvEmployee.CurrentRow

                    RowID = .Cells("e_rowid").Value

                    EmployeeId = .Cells("e_id").Value

                    LastName = .Cells("e_lname").Value

                    FirstName = .Cells("e_fname").Value

                    MiddleName = .Cells("e_midname").Value

                    EmployeeType = .Cells("e_type").Value

                    EmploymentStatus = .Cells("e_status").Value

                    PositionName = .Cells("e_posname").Value

                    'Me.PositionID = .Cells("").Value

                    PayFrequencyType = .Cells("e_payfreqtype").Value

                    'Me.PayFrequencyId = .Cells("").Value

                    Dim display_infos() As String = Split(Convert.ToString(.Cells("e_dispinfo").Value), "?", )

                    FullName = display_infos(0)

                End With
            Else
                ClearProperties()
            End If
        Else
            ClearProperties()
        End If

    End Sub

    Private Sub ClearProperties()

        RowID = ""

        EmployeeId = ""

        LastName = ""

        FirstName = ""

        MiddleName = ""

        EmployeeType = ""

        EmploymentStatus = ""

        PositionName = ""

        PositionID = ""

        PayFrequencyType = ""

        PayFrequencyId = ""

        FullName = ""

    End Sub

    Private Sub Button1_Click(sender As Object, e As EventArgs) Handles Button1.Click

        Dim is_not_empty_rowid As Boolean = False

        Try
            is_not_empty_rowid = (RowID IsNot Nothing)
        Catch ex As Exception
            is_not_empty_rowid = False
        End Try

        If dgvEmployee.Rows.Count > 0 _
            And is_not_empty_rowid Then
            DialogResult = Windows.Forms.DialogResult.OK

        End If

    End Sub

    Private Sub Button2_Click(sender As Object, e As EventArgs) Handles Button2.Click
        Close()
    End Sub

    Private Sub dgvEmployee_CellMouseDoubleClick(sender As Object, e As DataGridViewCellMouseEventArgs) Handles dgvEmployee.CellMouseDoubleClick
        Button1_Click(Button1, New EventArgs)
    End Sub

End Class