Option Strict On

Imports System.Data.Entity

Public Class DateRangePickerDialog

    Private _payFrequencyId As Integer = 1

    Private _currentPayperiod As PayPeriod

    Private _payperiodModels As IList(Of PayperiodModel)

    Private _payperiods As IList(Of PayPeriod)

    Public PeriodYear As Integer = Date.Today.Year

    Private _start As Date

    Private _end As Date

    Private _rowId, _year As Integer

    Public ReadOnly Property Start As Date
        Get
            Return _start
        End Get
    End Property

    Public ReadOnly Property [End] As Date
        Get
            Return _end
        End Get
    End Property

    Public ReadOnly Property Id As Integer
        Get
            Return _rowId
        End Get
    End Property

    Public ReadOnly Property Year As Integer
        Get
            Return _year
        End Get
    End Property

    Private Async Sub DateRangePickerDialog_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        PayperiodsDataGridView.AutoGenerateColumns = False

        Await LoadPayPeriods()

        lblYear.Text = Convert.ToString(PeriodYear)

        btnDecrementYear.Text = String.Concat("← ", (PeriodYear - 1))
        btnIncrementYear.Text = String.Concat((PeriodYear + 1), " →")
    End Sub

    Private Async Function LoadPayPeriods() As Threading.Tasks.Task
        Using context = New DatabaseContext()
            _payperiods = Await context.PayPeriods.
                Where(Function(p) Nullable.Equals(p.Year, PeriodYear)).
                Where(Function(p) Nullable.Equals(p.OrganizationID, z_OrganizationID)).
                Where(Function(p) Nullable.Equals(p.PayFrequencyID, _payFrequencyId)).
                ToListAsync()
        End Using

        _payperiodModels = _payperiods.Select(Function(p) New PayperiodModel(p)).ToList()

        PayperiodsDataGridView.DataSource = _payperiodModels
    End Function

    Private Sub PayperiodsDataGridView_SelectionChanged(sender As Object, e As EventArgs) Handles PayperiodsDataGridView.SelectionChanged
        Dim payperiod = DirectCast(PayperiodsDataGridView.CurrentRow.DataBoundItem, PayperiodModel)

        _currentPayperiod = payperiod.PayPeriod

        _rowId = payperiod.RowID

        _start = payperiod.PayFromDate.Value
        _end = payperiod.PayToDate.Value

        _year = payperiod.Year
    End Sub

    Public Async Sub UpdateWhenLeaveResetBegan(periodId As Integer)
        Using context = New DatabaseContext()
            Dim selectedPeriod = Await context.PayPeriods.FirstOrDefaultAsync(Function(pp) pp.RowID = periodId)
            If selectedPeriod Is Nothing Then Return

            Dim otherPeriods = Await context.PayPeriods.
                Where(Function(pp) pp.OrganizationID.Value = selectedPeriod.OrganizationID.Value).
                Where(Function(pp) pp.Year.Value = selectedPeriod.Year.Value).
                Where(Function(pp) pp.PayFrequencyID.Value = selectedPeriod.PayFrequencyID.Value).
                ToListAsync()

            otherPeriods.ForEach(Sub(pp)
                                     pp.BeginLeaveReset = False
                                 End Sub)

            selectedPeriod.BeginLeaveReset = True

            Await context.SaveChangesAsync()
        End Using
    End Sub

    Private Sub Button1_Click(sender As Object, e As EventArgs) Handles Button1.Click
        DialogResult = DialogResult.OK
    End Sub

    Private Sub Button2_Click(sender As Object, e As EventArgs) Handles Button2.Click
        DialogResult = DialogResult.Cancel
    End Sub

    Private Class PayperiodModel

        Public ReadOnly PayPeriod As PayPeriod

        Public Sub New(payperiod As PayPeriod)
            Me.PayPeriod = payperiod
        End Sub

        Public ReadOnly Property RowID As Integer
            Get
                Return PayPeriod.RowID
            End Get
        End Property

        Public ReadOnly Property PayFromDate As Date?
            Get
                Return PayPeriod.PayFromDate
            End Get
        End Property

        Public ReadOnly Property PayToDate As Date?
            Get
                Return PayPeriod.PayToDate
            End Get
        End Property

        Public ReadOnly Property Year As Integer
            Get
                Return PayPeriod.Year.Value
            End Get
        End Property

        Public ReadOnly Property Period As String
            Get
                If PayPeriod.IsMonthly Then
                    Dim month = New Date(PayPeriod.Year.Value, PayPeriod.Month.Value, 1)
                    Dim halfNo = String.Empty

                    If PayPeriod.IsFirstHalf Then
                        halfNo = "1st Half"
                    ElseIf PayPeriod.IsEndOfTheMonth Then
                        halfNo = "2nd Half"
                    End If

                    Return $"{month.ToString("MMM")} {halfNo}"
                ElseIf PayPeriod.IsWeekly Then
                    ' Not implemented yet
                    Return String.Empty
                Else
                    Return String.Empty
                End If
            End Get
        End Property

    End Class

    Private Async Sub lblDecrementIncrementYear_ClickedAsync(sender As Object, e As EventArgs) _
        Handles btnDecrementYear.Click, btnIncrementYear.Click

        Dim linkLabel = DirectCast(sender, Button)
        Dim factor = Convert.ToInt32(linkLabel.Tag)

        PeriodYear = PeriodYear + factor

        lblYear.Text = Convert.ToString(PeriodYear)

        Await LoadPayPeriods()

        btnDecrementYear.Text = String.Concat("← ", (PeriodYear - 1))
        btnIncrementYear.Text = String.Concat((PeriodYear + 1), " →")
    End Sub

End Class