Imports System.Data.Entity
Imports AccuPay.Entity
Imports log4net
Imports Microsoft.EntityFrameworkCore
Imports MySql.Data.MySqlClient

Public Class PreviewLeaveBalanceForm
    Public _logger As ILog = LogManager.GetLogger("LoggerWork")

    Private payPeriodId As Integer

    Private periodDateFrom, periodDateTo As Date

    Private _employees As IList(Of Employee)

    Private _employeeModels As IList(Of EmployeeModel)

    Private policy As New RenewLeaveBalancePolicy

    Dim organizationId As Integer = 0

    Private Async Sub PreviewLeaveBalanceForm_LoadAsync(sender As Object, e As EventArgs) Handles MyBase.Load
        organizationId = Convert.ToInt32(org_rowid)

        Await LoadEmployees()
    End Sub

    Private Sub btnClose_Click(sender As Object, e As EventArgs) Handles btnClose.Click
        Close()
    End Sub

    Private Async Sub btnReset_ClickAsync(sender As Object, e As EventArgs) Handles btnReset.Click
        Dim result As DialogResult
        Dim isOk As Boolean = False

        Using dialog = New DateRangePickerDialog()
            result = dialog.ShowDialog()

            If result = DialogResult.OK Then
                payPeriodId = dialog.Id
                periodDateFrom = dialog.Start
                periodDateTo = dialog.End
                isOk = True
            End If
        End Using

        If isOk Then

            If policy.ProrateOnFirstAnniversary = False Then

                If policy.LeaveAllowanceAmount = RenewLeaveBalancePolicy.LeaveAllowanceAmountBasis.Default Then

                    Await RenewLeaveBalances()
                End If

            Else

            End If

            Await LoadEmployees()
        End If

    End Sub

    Private Async Function RenewLeaveBalances() As Threading.Tasks.Task
        Using command = New MySqlCommand("CALL LEAVE_gainingbalance(@orgId, NULL, @userId, @dateFrom, @dateTo);",
                                         New MySqlConnection(mysql_conn_text))
            With command.Parameters
                .AddWithValue("@orgId", organizationId)
                .AddWithValue("@userId", user_row_id)
                .AddWithValue("@dateFrom", periodDateFrom)
                .AddWithValue("@dateTo", periodDateTo)

            End With

            Await command.Connection.OpenAsync

            Dim transaction = Await command.Connection.BeginTransactionAsync

            Try
                Await command.ExecuteNonQueryAsync()
                transaction.Commit()
            Catch ex As Exception
                _logger.Error("RenewLeaveBalances", ex)
                transaction.Rollback()
            End Try

        End Using
    End Function

    Private Function CreateCreditLeaveTransaction(context As DatabaseContext, employee As EmployeeModel, employeeId As Integer, leaveLedgerId As Integer, leaveType As LeaveType) As LeaveTransaction
        Dim lt As New LeaveTransaction With {
        .OrganizationID = organizationId,
        .Created = Date.Now,
        .CreatedBy = user_row_id,
        .LastUpd = Date.Now,
        .LastUpdBy = user_row_id,
        .EmployeeID = employeeId,
        .LeaveLedgerID = leaveLedgerId,
        .PayPeriodID = payPeriodId,
        .ReferenceID = Nothing,
        .TransactionDate = periodDateFrom,
        .Type = "Credit"
        }

        Dim _amount As Decimal
        If leaveType = LeaveType.VacationLeave Then
            _amount = employee.VacationLeaveAllowance
        ElseIf leaveType = LeaveType.SickLeave Then
            _amount = employee.SickLeaveAllowance
        End If

        lt.Balance = _amount
        lt.Amount = _amount

        'context.LeaveTransactions.Add(lt)

        Return lt
    End Function

    Private Function GetLeaveLedger(leaveLedgers As List(Of LeaveLedger), leaveTypeId As Integer, employeeId As Integer) As LeaveLedger
        Dim leaveLedger = leaveLedgers.
                            Where(Function(ll) Nullable.Equals(ll.EmployeeID, employeeId)).
                            Where(Function(ll) Nullable.Equals(ll.ProductID, leaveTypeId)).FirstOrDefault

        If leaveLedger Is Nothing Then
            Using context = New DatabaseContext()
                Dim lLedger As New LeaveLedger With {
                    .Created = Date.Now,
                    .CreatedBy = user_row_id,
                    .EmployeeID = employeeId,
                    .LastUpd = Date.Now,
                    .LastUpdBy = user_row_id,
                    .OrganizationID = organizationId,
                    .ProductID = leaveTypeId
                }

                'context.LeaveLedgers.Add(lLedger)

                context.SaveChanges()

                leaveLedger = lLedger
            End Using

            Return leaveLedger
        End If

        Return leaveLedger
    End Function

    Private Async Function LoadEmployees() As Threading.Tasks.Task
        Dim unemployedStatuses = New String() {"Resigned", "Terminated"}

        Using context = New DatabaseContext()
            'Where(Function(e) Not unemployedStatuses.Any(Function(strValue) Nullable.Equals(strValue, e.EmploymentStatus))).
            _employees = Await context.Employees.
                Where(Function(e) Nullable.Equals(e.OrganizationID.Value, organizationId)).
                Where(Function(e) Not unemployedStatuses.Contains(e.EmploymentStatus)).
                OrderBy(Function(e) String.Concat(e.LastName, e.FirstName, e.MiddleName)).
                ToListAsync()
        End Using

        _employeeModels = _employees.Select(Function(e) New EmployeeModel(e)).ToList()

        dgvEmployees.DataSource = _employeeModels
    End Function

    Private Enum LeaveType
        VacationLeave
        SickLeave
    End Enum

    Private Class EmployeeModel

        Private _employee As Employee

        Sub New(employee As Employee)
            _employee = employee
        End Sub

        Public ReadOnly Property RowID As Integer
            Get
                Return _employee.RowID
            End Get
        End Property

        Public ReadOnly Property EmployeeNo As String
            Get
                Return _employee.EmployeeNo
            End Get
        End Property

        Public ReadOnly Property LastName As String
            Get
                Return _employee.LastName
            End Get
        End Property

        Public ReadOnly Property FirstName As String
            Get
                Return _employee.FirstName
            End Get
        End Property

        Public ReadOnly Property VacationLeaveAllowance As Decimal
            Get
                Return _employee.LeaveAllowance
            End Get
        End Property

        Public ReadOnly Property VacationLeaveBalance As Decimal
            Get
                Return _employee.LeaveBalance
            End Get
        End Property

        Public ReadOnly Property SickLeaveAllowance As Decimal
            Get
                Return _employee.SickLeaveAllowance
            End Get
        End Property

        Public ReadOnly Property SickLeaveBalance As Decimal
            Get
                Return _employee.SickLeaveBalance
            End Get
        End Property

        Public ReadOnly Property AdditionalVLAllowance As Decimal
            Get
                Return _employee.AdditionalVLAllowance
            End Get
        End Property

        Public ReadOnly Property AdditionalVLBalance As Decimal
            Get
                Return _employee.AdditionalVLBalance
            End Get
        End Property

    End Class

    Private Class LeaveTypeModel

        Private _product As Product

        Sub New(product As Product)
            _product = product
        End Sub

        Public ReadOnly Property RowID As Integer
            Get
                Return _product.RowID.Value
            End Get
        End Property

        Public ReadOnly Property PartNo As String
            Get
                Return _product.PartNo
            End Get
        End Property

    End Class

End Class