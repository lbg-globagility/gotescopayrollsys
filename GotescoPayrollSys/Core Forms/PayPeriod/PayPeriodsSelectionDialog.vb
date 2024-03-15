Imports System.Data.Entity
Imports System.Threading.Tasks

Public Class PayPeriodsSelectionDialog
    Private ReadOnly _organizationId As Integer
    Private ReadOnly _withLoanTypes As Boolean
    Public ReadOnly Property StartDate As Date?
    Public ReadOnly Property EndDate As Date?
    Private ReadOnly Property selectedYear As Integer
    Public ReadOnly Property SelectedLoanTypeIds As List(Of Integer)
    Public ReadOnly Property SelectedPayPeriodIds As List(Of Integer)

    Public Sub New(organizationId As Integer,
        Optional withLoanTypes As Boolean = False)
        _organizationId = organizationId
        _withLoanTypes = withLoanTypes

        ' This call is required by the designer.
        InitializeComponent()

        ' Add any initialization after the InitializeComponent() call.

        _selectedYear = Date.Now.Date.Year
    End Sub

    Private Async Sub PayPeriodsSelectionDialog_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        PanelLoanTypes.Visible = _withLoanTypes

        If _withLoanTypes Then Await LoadLoanTypesAsync()

        Await LoadPayPeriodsAsync(selectedYear)

        ChangeYearDisplayText()
    End Sub

    Private Sub ChangeYearDisplayText()
        LinkLabelPrev.Text = $"←{selectedYear - 1}"
        LinkLabelNext.Text = $"{selectedYear + 1}→"
    End Sub

    Private Async Function LoadPayPeriodsAsync(getYear As Integer) As Task
        Using context = New DatabaseContext
            Dim payPeriods = Await context.PayPeriods.
                AsNoTracking().
                Where(Function(p) p.OrganizationID = _organizationId).
                Where(Function(p) p.PayFrequencyID = 1).
                Where(Function(p) p.Year = getYear).
                OrderBy(Function(p) p.PayFromDate).
                ThenBy(Function(p) p.PayToDate).
                ToListAsync()

            'DataGridViewXPeriods.DataSource = payPeriods
            DataGridViewXPeriods.Rows.Clear()
            For Each payPeriod In payPeriods
                Dim rowIndex = DataGridViewXPeriods.Rows.Add(payPeriod.RowID,
                    False,
                    payPeriod.PayFromDate.Value.Date.ToShortDateString(),
                    payPeriod.PayToDate.Value.Date.ToShortDateString())

                DataGridViewXPeriods.Item(columnIndex:=Column2.Index, rowIndex:=rowIndex).ReadOnly = False
            Next
        End Using
    End Function

    Private Async Function LoadLoanTypesAsync() As Task
        Using context = New DatabaseContext
            Dim products = Await context.Products.
                AsNoTracking().
                Include(Function(p) p.Category).
                Where(Function(p) p.OrganizationID = _organizationId).
                Where(Function(p) p.CategoryText = ProductConstant.LOAN_TYPE_CATEGORY).
                OrderBy(Function(p) p.PartNo).
                ToListAsync()

            For Each p In products
                Dim checkBoxControl = New CheckBox() With {.Name = $"CheckBoxLoanType{p.PartNo.Replace(" ", String.Empty)}",
                    .Text = p.PartNo,
                    .Checked = True,
                    .Tag = p.RowID.Value,
                    .Margin = New Padding(0, 0, 0, 0)}

                Dim textSize = TextRenderer.MeasureText(checkBoxControl.Text, checkBoxControl.Font)

                Dim width = checkBoxControl.Size.Width
                checkBoxControl.AutoSize = False
                checkBoxControl.AutoEllipsis = False
                checkBoxControl.Width = textSize.Width + (width * 0.5)

                FlowLayoutPanelLoanTypes.Controls.Add(checkBoxControl)

                AddHandler checkBoxControl.CheckedChanged, AddressOf checkBoxControl_CheckedChanged
            Next

            LabelSelectedLoanTypes.Text = $"Select Loan Type({If(products?.Count(), 0)}):"

            checkBoxControl_CheckedChanged(sender:=0, e:=New EventArgs())
        End Using
    End Function

    Private Sub checkBoxControl_CheckedChanged(sender As Object, e As EventArgs)
        Dim loanTypes = FlowLayoutPanelLoanTypes.Controls.
            OfType(Of CheckBox).
            Where(Function(t) t.Checked).
            ToList()

        LabelSelectedLoanTypes.Text = $"Select Loan Type({If(loanTypes?.Count(), 0)})"

        _SelectedLoanTypeIds = loanTypes.
            Select(Function(t) CInt(t.Tag)).
            ToList()
    End Sub

    Private Sub LinkLabelUnSelectAll_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles LinkLabelUnSelectAll.LinkClicked
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

        checkBoxControl_CheckedChanged(sender, e)
    End Sub

    Private Sub DataGridViewXPeriods_CellContentClick(sender As Object, e As DataGridViewCellEventArgs) Handles DataGridViewXPeriods.CellContentClick

    End Sub

    Private Sub DataGridViewXPeriods_CellContentClick1(sender As Object, e As DataGridViewCellEventArgs) Handles DataGridViewXPeriods.CellContentClick
        If Not e.RowIndex > -1 Then Return

        If e.ColumnIndex = Column2.Index Then
            DataGridViewXPeriods.EndEdit()
            DataGridViewXPeriods.CurrentCell = DataGridViewXPeriods.Item(columnIndex:=Column3.Index, rowIndex:=e.RowIndex)
            DataGridViewXPeriods.EndEdit()
            Button1.Focus()
            DataGridViewXPeriods.CurrentCell = DataGridViewXPeriods.Item(columnIndex:=Column2.Index, rowIndex:=e.RowIndex)

            Dim rows = DataGridViewXPeriods.Rows.
                OfType(Of DataGridViewRow).
                Where(Function(t) CBool(t.Cells(Column2.Index).Value)).
                ToList()

            Dim start As Date? = If(String.IsNullOrEmpty(If(rows.FirstOrDefault()?.Cells(Column3.Index).Value, String.Empty)),
                Nothing,
                CDate(rows.FirstOrDefault()?.Cells(Column3.Index).Value))
            _StartDate = start

            Dim [end] As Date? = If(String.IsNullOrEmpty(If(rows.LastOrDefault()?.Cells(Column4.Index).Value, String.Empty)),
                Nothing,
                CDate(rows.LastOrDefault()?.Cells(Column4.Index).Value))
            _EndDate = [end]

            Dim twoSelectedPeriods = (
                CInt(If(rows.FirstOrDefault()?.Cells(Column1.Index).Value, 0)),
                CInt(If(rows.LastOrDefault()?.Cells(Column1.Index).Value, 0))
                )

            Dim fsdfsd = If(twoSelectedPeriods.Item1 = twoSelectedPeriods.Item2,
                New List(Of Integer) From {twoSelectedPeriods.Item1},
                New List(Of Integer) From {twoSelectedPeriods.Item1, twoSelectedPeriods.Item2})
            _SelectedPayPeriodIds = fsdfsd.Where(Function(i) i > 0).ToList()

            LabelPeriodDisplayText.Text = $"From: {start:MMM dd, yyyy}{Environment.NewLine}To: {[end]:MMM dd, yyyy}"

        Else
            _SelectedPayPeriodIds = Enumerable.Empty(Of Integer).ToList()
            _StartDate = Nothing
            _EndDate = Nothing
        End If
    End Sub

    Private Sub ButtonOK_Click(sender As Object, e As EventArgs) Handles ButtonOK.Click
        DialogResult = DialogResult.OK
    End Sub

    Private Sub ButtonClose_Click(sender As Object, e As EventArgs) Handles ButtonClose.Click
        DialogResult = DialogResult.Cancel
    End Sub

    Private Async Sub LinkLabelPrev_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles LinkLabelPrev.LinkClicked
        Panel4.Enabled = False
        _selectedYear -= 1

        Await LoadPayPeriodsAsync(selectedYear)

        ChangeYearDisplayText()
        Panel4.Enabled = True
    End Sub

    Private Async Sub LinkLabelNext_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles LinkLabelNext.LinkClicked
        Panel4.Enabled = False
        _selectedYear += 1

        Await LoadPayPeriodsAsync(selectedYear)

        ChangeYearDisplayText()
        Panel4.Enabled = True
    End Sub

    Private Sub DataGridViewXPeriods_CellValueChanged(sender As Object, e As DataGridViewCellEventArgs) Handles DataGridViewXPeriods.CellValueChanged
        If Not e.RowIndex > -1 Then Return

        If e.ColumnIndex = Column2.Index Then DataGridViewXPeriods.EndEdit()
    End Sub

End Class