
Imports MySql.Data.MySqlClient

Public Class LoanBackground
    Private _list As List(Of LoanPrediction)

    Private _loanID As Integer
    Public Property LoanID() As Integer
        Get
            Return _loanID
        End Get
        Set(ByVal value As Integer)
            _loanID = value
        End Set
    End Property

    Private _predictedLoan As LoanPrediction
    Public ReadOnly Property LoanPrediction() As LoanPrediction
        Get
            Return _predictedLoan
        End Get
    End Property

    Public Sub New()

        ' This call is required by the designer.
        InitializeComponent()

        ' Add any initialization after the InitializeComponent() call.

        _list = New List(Of LoanPrediction)
    End Sub

    Public Sub New(LoanRowID As Integer)

        ' This call is required by the designer.
        InitializeComponent()

        ' Add any initialization after the InitializeComponent() call.

        _list = New List(Of LoanPrediction)
        _loanID = LoanRowID
    End Sub

    Private Sub LoanBackground_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        dataGrid.AutoGenerateColumns = False

        LoadLoanPredictionsAsync()
    End Sub

    Private Async Sub LoadLoanPredictionsAsync()
        Dim query = $"CALL `LoanPrediction`({org_rowid});
                    SELECT i.*
                    , psi.PayStubID IS NOT NULL `HasPayStub`
                    , psi.PayStubID
                    , psi.PayAmount
                    FROM loanpredict i
                    LEFT JOIN paystub ps ON ps.OrganizationID=i.OrganizationID AND ps.PayPeriodID=i.PayperiodID AND ps.EmployeeID=i.EmployeeID
                    LEFT JOIN paystubitem psi ON psi.PayStubID=ps.RowID AND psi.ProductID=i.LoanTypeID
                    WHERE i.RowID={_loanID};"

        Using connection As New MySqlConnection(connectionString),
            command As New MySqlCommand(query, connection)

            Await connection.OpenAsync()

            Dim reader = Await command.ExecuteReaderAsync()

            While reader.Read
                _list.Add(CreateLoanPrediction(reader))
            End While

            dataGrid.DataSource = _list
        End Using
    End Sub

    Private Shared Function CreateLoanPrediction(reader As Common.DbDataReader) As LoanPrediction
        Return New LoanPrediction With {
            .AssignAnotherID = reader.GetValue(Of Integer)("AssignAnotherID"),
            .Comments = reader.GetValue(Of String)("Comments"),
            .DedEffectiveDateFrom = reader.GetValue(Of Date)("DedEffectiveDateFrom"),
            .DedEffectiveDateTo = reader.GetValue(Of Date)("DedEffectiveDateTo"),
            .DeductionAmount = reader.GetValue(Of Decimal)("DeductionAmount"),
            .DeductionPercentage = reader.GetValue(Of Decimal)("DeductionPercentage"),
            .DeductionSchedule = reader.GetValue(Of String)("DeductionSchedule"),
            .DiscontinuedDate = reader.GetValue(Of Date)("DiscontinuedDate"),
            .EmployeeID = reader.GetValue(Of Integer)("EmployeeID"),
            .EmployeeUniqueID = reader.GetValue(Of String)("EmployeeUniqueID"),
            .FullName = reader.GetValue(Of String)("FullName"),
            .HasPayStub = reader.GetValue(Of Boolean)("HasPayStub"),
            .IsAnother = reader.GetValue(Of Boolean)("IsAnother"),
            .IsLast = reader.GetValue(Of Boolean)("IsLast"),
            .LoanBalance = reader.GetValue(Of Decimal)("LoanBalance"),
            .LoanNumber = reader.GetValue(Of String)("LoanNumber"),
            .LoanPayPeriodLeft = reader.GetValue(Of Integer)("LoanPayPeriodLeft"),
            .LoanTypeID = reader.GetValue(Of Integer)("LoanTypeID"),
            .Nondeductible = reader.GetValue(Of String)("Nondeductible"),
            .NoOfPayPeriod = reader.GetValue(Of Integer)("NoOfPayPeriod"),
            .OrdinalIndex = reader.GetValue(Of Integer)("OrdinalIndex"),
            .PayAmount = reader.GetValue(Of Decimal?)("PayAmount"),
            .PayFromDate = reader.GetValue(Of Date)("PayFromDate"),
            .PayperiodID = reader.GetValue(Of Integer)("PayperiodID"),
            .PayStubID = reader.GetValue(Of Integer?)("PayStubID"),
            .PayToDate = reader.GetValue(Of Date?)("PayToDate"),
            .ReferenceLoanID = reader.GetValue(Of Integer)("ReferenceLoanID"),
            .RowID = reader.GetValue(Of Integer)("RowID"),
            .Status = reader.GetValue(Of String)("Status"),
            .SubstituteEndDate = reader.GetValue(Of Date?)("SubstituteEndDate"),
            .TotalBalanceLeft = reader.GetValue(Of Decimal)("TotalBalanceLeft"),
            .TotalLoanAmount = reader.GetValue(Of Decimal)("TotalLoanAmount")
        }
    End Function

    Private Sub Button1_Click(sender As Object, e As EventArgs) Handles Button1.Click
        DialogResult = DialogResult.OK
    End Sub

    Private Sub Button2_Click(sender As Object, e As EventArgs) Handles Button2.Click
        DialogResult = DialogResult.Cancel
    End Sub

    Private Sub dataGrid_CellContentClick(sender As Object, e As DataGridViewCellEventArgs) Handles dataGrid.CellContentClick
        If e.ColumnIndex = Column35.Index Then
            Dim sdfsd = dataGrid.Rows.OfType(Of DataGridViewRow).
                Where(Function(row) Not row.Index = e.RowIndex).
                ToList()

            For Each row In sdfsd
                row.Cells(Column35.Name).Value = False
            Next

            dataGrid.Item(e.ColumnIndex, e.RowIndex).Value = True
        End If
    End Sub

    Private Sub dataGrid_SelectionChanged(sender As Object, e As EventArgs) Handles dataGrid.SelectionChanged
        _predictedLoan = DirectCast(dataGrid.CurrentRow.DataBoundItem, LoanPrediction)

    End Sub

    Private Sub dataGrid_DataSourceChanged(sender As Object, e As EventArgs) Handles dataGrid.DataSourceChanged
        Dim fsdfsd = _list.Where(Function(l) l.DiscontinuedDate.HasValue).ToList()
        If fsdfsd.Any() Then
            For Each row In dataGrid.Rows.OfType(Of DataGridViewRow)
                Dim l = DirectCast(row.DataBoundItem, LoanPrediction)

                If l.PayFromDate <= l.DiscontinuedDate AndAlso l.PayToDate >= l.DiscontinuedDate Then
                    dataGrid.CurrentCell = row.Cells(Column35.Name)
                    dataGrid.CurrentCell.Value = True
                    Exit For
                End If
            Next
        End If
    End Sub
End Class

Public Class LoanPrediction
    Public Property RowID As Integer
    Public Property EmployeeID As Integer
    Public Property LoanNumber As String
    Public Property DedEffectiveDateFrom As Date
    Public Property DedEffectiveDateTo As Date
    Public Property TotalLoanAmount As Decimal
    Public Property DeductionSchedule As String
    Public Property TotalBalanceLeft As Decimal
    Public Property DeductionAmount As Decimal
    Public Property Status As String
    Public Property LoanTypeID As Integer
    Public Property DeductionPercentage As Decimal
    Public Property NoOfPayPeriod As Integer
    Public Property LoanPayPeriodLeft As Integer
    Public Property Comments As String
    Public Property Nondeductible As String
    Public Property ReferenceLoanID As Integer
    Public Property SubstituteEndDate As Date?
    Public Property DiscontinuedDate As Date?
    Public Property PayperiodID As Integer
    Public Property PayFromDate As Date?
    Public Property PayToDate As Date?
    Public Property EmployeeUniqueID As String
    Public Property FullName As String
    Public Property IsAnother As Boolean
    Public Property AssignAnotherID As Integer
    Public Property LoanBalance As Decimal
    Public Property OrdinalIndex As Integer
    Public Property IsLast As Boolean

    Public Property HasPayStub As Boolean
    Public Property PayStubID As Integer?
    Public Property PayAmount As Decimal?

    Private UNPAID_TEXT As String = "Unpaid"
    Public ReadOnly Property PaidStatus As String
        Get

            If Not HasPayStub And Not PayAmount.HasValue Then Return UNPAID_TEXT

            If PayAmount > 0 Then Return "Paid"
            Return UNPAID_TEXT
        End Get
    End Property
End Class
