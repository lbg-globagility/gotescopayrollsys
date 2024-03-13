
Imports System.Data.Entity
Imports System.Threading.Tasks

Partial Public Class EmployeeForm

    Private Async Function LoadFilterLeaveTypesAsync() As Task
        '"SELECT CONCAT(COALESCE(PartNo,''),'@',RowID) FROM product WHERE CategoryID='" & categleavID & "' AND OrganizationID=" & org_rowid & ";"
        Using context = New DatabaseContext
            Dim products = Await context.Products.
                AsNoTracking().
                Include(Function(p) p.Category).
                Where(Function(p) p.OrganizationID = z_OrganizationID).
                Where(Function(p) p.CategoryText = ProductConstant.LEAVE_TYPE_CATEGORY).
                OrderBy(Function(p) p.PartNo).
                ToListAsync()

            For Each p In products
                FlowLayoutPanelLeaveType.Controls.Add(New CheckBox() With {.Name = $"CheckBoxLeaveType{p.PartNo.Replace(" ", String.Empty)}",
                    .Text = p.PartNo,
                    .Checked = True,
                    .Tag = p.RowID.Value})
            Next
        End Using
    End Function

    Private Async Function LoadFilterLeaveStatusAsync() As Task
        '"SELECT DisplayValue FROM listofval WHERE `Type`='Employee Leave Status' AND Active='Yes' ORDER BY OrderBy;"
        Using context = New DatabaseContext
            Dim listOfValues = Await context.ListOfValues.
                AsNoTracking().
                Where(Function(p) p.Type = "Employee Leave Status").
                Where(Function(p) p.Active = "Yes").
                ToListAsync()

            For Each l In listOfValues
                FlowLayoutPanelLeaveStatus.Controls.Add(New CheckBox() With {.Name = $"CheckBoxLeaveStatus{l.DisplayValue.Replace(" ", String.Empty)}",
                    .Text = l.DisplayValue,
                    .Checked = True,
                    .Tag = l.RowID.Value})
            Next
        End Using
    End Function

    Private Sub ButtonFilterLeave_Click(sender As Object, e As EventArgs) Handles ButtonFilterLeave.Click

        Dim start = DateTimePickerLeaveStart.Value.Date
        Dim [end] = DateTimePickerLeaveEnd.Value.Date

        Dim leaveTypes = FlowLayoutPanelLeaveType.Controls.
            OfType(Of CheckBox).
            Where(Function(t) t.Checked).
            Select(Function(t) t.Text).
            ToList()

        Dim leaveStatuses = FlowLayoutPanelLeaveStatus.Controls.
            OfType(Of CheckBox).
            Where(Function(t) t.Checked).
            Select(Function(t) t.Text).
            ToList()

        Dim query = _employeeLeaveGridRows.
            Where(Function(t) True)

        If If(leaveTypes?.Any(), False) Then query = query.
            Where(Function(t)
                      If String.IsNullOrEmpty(If(t.Cells(elv_Type.Index)?.Value, String.Empty)) Then
                          Return False
                      Else
                          Return leaveTypes.Any(Function(s) CStr(t.Cells(elv_Type.Index).Value).SimilarTo(s))
                      End If
                  End Function)

        If If(leaveStatuses?.Any(), False) Then query = query.
            Where(Function(t)
                      If String.IsNullOrEmpty(If(t.Cells(elv_Status.Index)?.Value, String.Empty)) Then
                          Return False
                      Else
                          Return leaveStatuses.Any(Function(s) CStr(t.Cells(elv_Status.Index).Value).SimilarTo(s))
                      End If
                  End Function)

        If DateTimePickerLeaveStart.Checked Then query = query.
            Where(Function(t) CDate(t.Cells(elv_StartDate.Index)?.Value) >= start)

        If DateTimePickerLeaveEnd.Checked Then query = query.
            Where(Function(t) CDate(t.Cells(elv_EndDate.Index)?.Value) <= [end])

        Dim rows = query.ToList()

        dgvempleave.Rows.Clear()
        dgvempleave.Rows.AddRange(rows.ToArray())
    End Sub

    Private Sub ButtonResetFilterLeave_Click(sender As Object, e As EventArgs) Handles ButtonResetFilterLeave.Click
        dgvempleave.Rows.Clear()
        dgvempleave.Rows.AddRange(_employeeLeaveGridRows.ToArray())
    End Sub

    Private Sub ButtonLoanFilter_Click(sender As Object, e As EventArgs) Handles ButtonLoanFilter.Click

        Dim start = DateTimePickerLoanStart.Value.Date
        Dim [end] = DateTimePickerLoanEnd.Value.Date

        Dim loanTypes = FlowLayoutPanelLoanTypes.Controls.
            OfType(Of CheckBox).
            Where(Function(t) t.Checked).
            Select(Function(t) t.Text).
            ToList()

        Dim loanStatuses = FlowLayoutPanelLoanStatuses.Controls.
            OfType(Of CheckBox).
            Where(Function(t) t.Checked).
            Select(Function(t) t.Text).
            ToList()

        Dim query = _employeeLoanGridRows.Where(Function(t) True)

        If Not String.IsNullOrEmpty(TextBoxFilterLoanNum.Text) Then query = query.
            Where(Function(t)
                      If String.IsNullOrEmpty(If(t.Cells(c_loanno.Index)?.Value, String.Empty)) Then
                          Return False
                      Else
                          Return CStr(t.Cells(c_loanno.Index).Value).SimilarTo(TextBoxFilterLoanNum.Text)
                      End If
                  End Function)

        If If(loanTypes?.Any(), False) Then query = query.
            Where(Function(t)

                      If String.IsNullOrEmpty(If(t.Cells(c_loantype.Index)?.Value, String.Empty)) Then
                          Return False
                      Else
                          Return loanTypes.Any(Function(s) CStr(t.Cells(c_loantype.Index).Value).SimilarTo(s))
                      End If
                  End Function)

        If If(loanStatuses?.Any(), False) Then query = query.
            Where(Function(t)

                      If String.IsNullOrEmpty(If(t.Cells(c_status.Index)?.Value, String.Empty)) Then
                          Return False
                      Else
                          Return loanStatuses.Any(Function(s) CStr(t.Cells(c_status.Index).Value).SimilarTo(s))
                      End If
                  End Function)

        If DateTimePickerLoanStart.Checked Then query = query.
            Where(Function(t) CDate(t.Cells(c_dedeffectivedatefrom.Index)?.Value) >= start)

        If DateTimePickerLoanEnd.Checked Then query = query.
            Where(Function(t) CDate(t.Cells(c_dedeffectivedatefrom.Index)?.Value) <= [end])

        Dim rows = query.ToList()

        dgvLoanList.Rows.Clear()
        dgvLoanList.Rows.AddRange(rows.ToArray())
    End Sub

    Private Sub ButtonLoanFilterReset_Click(sender As Object, e As EventArgs) Handles ButtonLoanFilterReset.Click
        dgvLoanList.Rows.Clear()
        dgvLoanList.Rows.AddRange(_employeeLoanGridRows.ToArray())
    End Sub

    Private Async Function LoadFilterLoanTypesAsync() As Task
        Using context = New DatabaseContext
            Dim products = Await context.Products.
                AsNoTracking().
                Include(Function(p) p.Category).
                Where(Function(p) p.OrganizationID = z_OrganizationID).
                Where(Function(p) p.CategoryText = ProductConstant.LOAN_TYPE_CATEGORY).
                OrderBy(Function(p) p.PartNo).
                ToListAsync()

            For Each p In products
                Dim checkBoxControl = New CheckBox() With {.Name = $"CheckBoxLoanType{p.PartNo.Replace(" ", String.Empty)}",
                    .Text = p.PartNo,
                    .Checked = True,
                    .Tag = p.RowID.Value,
                    .AutoSize = False,
                    .AutoEllipsis = False,
                    .Width = 256}

                AddHandler checkBoxControl.CheckedChanged, AddressOf checkBoxControl_CheckedChanged

                FlowLayoutPanelLoanTypes.Controls.Add(checkBoxControl)
            Next

            LabelLoanFilterLoanTypes.Text = $"Loan Type({If(products?.Count(), 0)})"
        End Using
    End Function

    Private Async Function LoadFilterLoanStatusesAsync() As Task
        Dim fsdfsdf As New List(Of String) From {"Complete", "Cancelled"}
        fsdfsdf.AddRange(cmbStatus.Items.OfType(Of Object).Select(Function(t) CStr(t)).ToList())

        For Each status In fsdfsdf
            FlowLayoutPanelLoanStatuses.Controls.Add(New CheckBox() With {.Name = $"CheckBoxLoanStatus{status.Replace(" ", String.Empty)}",
                .Text = status,
                .Checked = True,
                .Tag = Nothing})
        Next
    End Function

    Private Sub LinkLabelUnSelectLoanTypes_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles LinkLabelUnSelectLoanTypes.LinkClicked
        Dim checkedList = FlowLayoutPanelLoanTypes.Controls.
            OfType(Of CheckBox).
            Where(Function(t) t.Checked).
            Select(Function(t) t.Text).
            ToList()

        Dim uncheckedList = FlowLayoutPanelLoanTypes.Controls.
            OfType(Of CheckBox).
            Where(Function(t) Not t.Checked).
            Select(Function(t) t.Text).
            ToList()

        Dim isChecked = If(checkedList?.Count(), 0) > If(uncheckedList?.Count(), 0)

        For Each chk In FlowLayoutPanelLoanTypes.Controls.OfType(Of CheckBox)
            chk.Checked = Not isChecked
        Next
    End Sub

    Private Sub checkBoxControl_CheckedChanged(sender As Object, e As EventArgs)
        Dim loanTypes = FlowLayoutPanelLoanTypes.Controls.
            OfType(Of CheckBox).
            Where(Function(t) t.Checked).
            Select(Function(t) t.Text).
            ToList()

        LabelLoanFilterLoanTypes.Text = $"Loan Type({If(loanTypes?.Count(), 0)})"
    End Sub

    Private Async Function LoadFilterOvertimeStatusAsync() As Task
        Using context = New DatabaseContext
            Dim listOfValues = Await context.ListOfValues.
                AsNoTracking().
                Where(Function(p) p.Type = "Employee Overtime Status").
                Where(Function(p) p.Active = "Yes").
                ToListAsync()

            For Each l In listOfValues
                FlowLayoutPanelFilterOvertimeStatus.Controls.Add(New CheckBox() With {.Name = $"CheckBoxOvertimeStatus{l.DisplayValue.Replace(" ", String.Empty)}",
                    .Text = l.DisplayValue,
                    .Checked = True,
                    .Tag = l.RowID.Value})
            Next
        End Using
    End Function

    Private Sub ButtonFilterOvertime_Click(sender As Object, e As EventArgs) Handles ButtonFilterOvertime.Click

        Dim start = DateTimePickerFilterOvertimeStart.Value.Date
        Dim [end] = DateTimePickerFilterOvertimeEnd.Value.Date

        Dim overtimeStatuses = FlowLayoutPanelFilterOvertimeStatus.Controls.
            OfType(Of CheckBox).
            Where(Function(t) t.Checked).
            Select(Function(t) t.Text).
            ToList()

        Dim query = _employeeOvertimeGridRows.Where(Function(t) True)

        If Not String.IsNullOrEmpty(TextBoxFilterOvertimeReasonComment.Text) Then query = query.
            Where(Function(t)
                      Dim thisString = String.Concat(If(t.Cells(eot_Reason.Index)?.Value, String.Empty),
                        If(t.Cells(eot_Comment.Index)?.Value, String.Empty))
                      If String.IsNullOrEmpty(thisString) Then
                          Return False
                      Else
                          Return thisString.SimilarTo(TextBoxFilterOvertimeReasonComment.Text)
                      End If
                  End Function)

        If If(overtimeStatuses?.Any(), False) Then query = query.
            Where(Function(t)

                      If String.IsNullOrEmpty(If(t.Cells(eot_Status.Index)?.Value, String.Empty)) Then
                          Return False
                      Else
                          Return overtimeStatuses.Any(Function(s) CStr(t.Cells(eot_Status.Index).Value).SimilarTo(s))
                      End If
                  End Function)

        If DateTimePickerFilterOvertimeStart.Checked Then query = query.
            Where(Function(t) CDate(t.Cells(eot_StartDate.Index)?.Value) >= start)

        If DateTimePickerFilterOvertimeEnd.Checked Then query = query.
            Where(Function(t) CDate(t.Cells(eot_EndDate.Index)?.Value) <= [end])

        Dim rows = query.ToList()

        dgvempOT.Rows.Clear()
        dgvempOT.Rows.AddRange(rows.ToArray())
    End Sub

    Private Sub ButtonFilterOvertimeReset_Click(sender As Object, e As EventArgs) Handles ButtonFilterOvertimeReset.Click
        dgvempOT.Rows.Clear()
        dgvempOT.Rows.AddRange(_employeeOvertimeGridRows.ToArray())
    End Sub

End Class
