Imports System.Configuration
Imports System.Data.Entity
Imports System.Threading.Tasks
Imports AccuPay.Entity
Imports log4net
Imports MySql.Data.MySqlClient

Public Class PreviewLeaveBalanceForm
    Public _logger As ILog = LogManager.GetLogger("LoggerWork")

    Private payPeriodId As Integer = 0
    Private periodYear As Integer = 0

    Private periodDateFrom, periodDateTo As Date

    Private _employees As IList(Of Employee)

    Private _employeeModels As IList(Of EmployeeModel)

    Private policy As New RenewLeaveBalancePolicy

    Dim organizationId As Integer = 0

    Private config As Specialized.NameValueCollection = ConfigurationManager.AppSettings

    Private configCommandTimeOut As Integer = 0

    Private Async Sub PreviewLeaveBalanceForm_LoadAsync(sender As Object, e As EventArgs) Handles MyBase.Load
        organizationId = Convert.ToInt32(org_rowid)

        configCommandTimeOut = Convert.ToInt32(config.GetValues("MySqlCommandTimeOut").FirstOrDefault)

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
                periodYear = dialog.Year
                isOk = True

                dialog.UpdateWhenLeaveResetBegan(payPeriodId)
            End If
        End Using

        If isOk Then

            If policy.ProrateOnFirstAnniversary = False Then

                If policy.LeaveAllowanceAmount = RenewLeaveBalancePolicy.LeaveAllowanceAmountBasis.Default Then

                    Await PerformGainLeaveBalanceAsync().
                       ContinueWith(Async Sub(antecedent1)
                                        If Not antecedent1.IsCompleted Then Return

                                        Await ResetAllLeaveAllowances()
                                    End Sub).
                                    ContinueWith(Async Sub(antecedent2)
                                                     If Not antecedent2.IsCompleted Then Return

                                                     Await Task.WhenAll(UpdateLeaveBalanceVacation(),
                                                        UpdateLeaveBalanceSick(),
                                                        UpdateLeaveBalanceAdditionalVL(),
                                                        UpdateLeaveBalanceOthers(),
                                                        UpdateLeaveBalanceParental()).
                                                     ContinueWith(Async Sub(antecedent3)
                                                                      If Not antecedent3.IsCompleted Then Return

                                                                      Await UpdateLeaveItemsAsync()
                                                                  End Sub)
                                                 End Sub)
                End If
            Else

            End If

            Await LoadEmployees()
        End If

    End Sub
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

    Private Async Function PerformGainLeaveBalanceAsync() As Task(Of Integer)
        Dim integerResult = New Integer

        Dim connectionText = String.Concat(mysql_conn_text, "default command timeout=", configCommandTimeOut, ";")

        Dim strQuery = "CALL `LEAVE_gainingbalance`(@orgId, NULL, @userId, @dateFrom, @dateTo);"

        Using command = New MySqlCommand(strQuery, New MySqlConnection(connectionText))

            With command.Parameters
                .AddWithValue("@orgId", organizationId)
                .AddWithValue("@userId", user_row_id)
                .AddWithValue("@dateFrom", periodDateFrom)
                .AddWithValue("@dateTo", periodDateTo)
                '.AddWithValue("@startingPeriodId", payPeriodId)
            End With

            Await command.Connection.OpenAsync

            Dim transaction = Await command.Connection.BeginTransactionAsync

            Try
                Dim result = Await command.ExecuteNonQueryAsync()

                transaction.Commit()

                integerResult = result
            Catch ex As Exception
                _logger.Error("PerformGainLeaveBalanceAsync", ex)
                transaction.Rollback()

                MessageBox.Show(String.Concat("Oops! something went wrong, please contact ", My.Resources.SystemDeveloper),
                    String.Empty,
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Exclamation)

            End Try

        End Using

        Return integerResult
    End Function

    Private Async Function ResetAllLeaveAllowances() As Task(Of Integer)
        Dim integerResult = New Integer

        Dim connectionText = String.Concat(mysql_conn_text, "default command timeout=", configCommandTimeOut, ";")

        Dim strQuery = "UPDATE employee e
                        SET e.LeaveBalance=e.LeaveAllowance,
                        e.LastUpdBy=@userId
                        WHERE e.OrganizationID=@orgId
                        AND e.LeaveAllowance=0
                        AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
                        ;

                        UPDATE employee e
                        SET e.SickLeaveBalance=e.SickLeaveAllowance,
                        e.LastUpdBy=@userId
                        WHERE e.OrganizationID=@orgId
                        AND e.SickLeaveAllowance=0
                        AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
                        ;

                        UPDATE employee e
                        SET e.AdditionalVLBalance=e.AdditionalVLAllowance,
                        e.LastUpdBy=@userId
                        WHERE e.OrganizationID=@orgId
                        AND e.AdditionalVLAllowance=0
                        AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
                        ;

                        UPDATE employee e
                        SET e.MaternityLeaveBalance=e.MaternityLeaveAllowance,
                        e.LastUpdBy=@userId
                        WHERE e.OrganizationID=@orgId
                        AND e.MaternityLeaveAllowance=0
                        AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
                        ;

                        UPDATE employee e
                        SET e.OtherLeaveBalance=e.OtherLeaveAllowance,
                        e.LastUpdBy=@userId
                        WHERE e.OrganizationID=@orgId
                        AND e.OtherLeaveAllowance=0
                        AND e.EmploymentStatus NOT IN ('Resigned', 'Terminated')
                        ;"

        Using command = New MySqlCommand(strQuery, New MySqlConnection(connectionText))

            With command.Parameters
                .AddWithValue("@orgId", organizationId)
                .AddWithValue("@userId", user_row_id)
            End With

            Await command.Connection.OpenAsync()

            Dim transaction = Await command.Connection.BeginTransactionAsync()

            Try
                Dim result = Await command.ExecuteNonQueryAsync()

                transaction.Commit()

                integerResult = result
            Catch ex As Exception
                _logger.Error("ResetLeaveAllowances", ex)
                transaction.Rollback()

                MessageBox.Show(String.Concat("Oops! something went wrong, please contact ", My.Resources.SystemDeveloper),
                    String.Empty,
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error)

            End Try

        End Using

        Return integerResult
    End Function

    Private Async Function UpdateLeaveBalanceVacation() As Task(Of Integer)
        Dim integerResult = New Integer

        Dim connectionText = String.Concat(mysql_conn_text, "default command timeout=", configCommandTimeOut, ";")

        Dim strQuery = "CALL `UpdateLeaveBalanceVacation`(@orgId, @userId, @periodId, (SELECT ppd.PayFromDate FROM payperiod pp INNER JOIN payperiod ppd ON ppd.`Year`=pp.`Year` And ppd.OrganizationID=pp.OrganizationID And ppd.TotalGrossSalary=pp.TotalGrossSalary And YEAR(ppd.PayFromDate)=pp.`Year` AND DATE_FORMAT(ppd.PayFromDate, '%m-%d')='01-01' WHERE pp.PayFromDate=@datefrom AND pp.OrganizationID=@orgId ORDER BY ppd.PayFromDate, ppd.PayToDate LIMIT 1));"

        Using command = New MySqlCommand(strQuery, New MySqlConnection(connectionText))

            With command.Parameters
                .AddWithValue("@orgId", organizationId)
                .AddWithValue("@userId", user_row_id)
                .AddWithValue("@dateFrom", periodDateFrom)
                .AddWithValue("@periodId", payPeriodId)
            End With

            Await command.Connection.OpenAsync()

            Dim transaction = Await command.Connection.BeginTransactionAsync()

            Try
                Dim result = Await command.ExecuteNonQueryAsync()

                transaction.Commit()

                integerResult = result
            Catch ex As Exception
                _logger.Error("UpdateLeaveBalanceVacation", ex)
                transaction.Rollback()

                MessageBox.Show(String.Concat("Oops! something went wrong, please contact ", My.Resources.SystemDeveloper),
                    String.Empty,
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Exclamation)

            End Try

        End Using

        Return integerResult
    End Function

    Private Async Function UpdateLeaveBalanceSick() As Task(Of Integer)
        Dim integerResult = New Integer

        Dim connectionText = String.Concat(mysql_conn_text, "default command timeout=", configCommandTimeOut, ";")

        Dim strQuery = "CALL `UpdateLeaveBalanceSick`(@orgId, @userId, @periodId, (SELECT ppd.PayFromDate FROM payperiod pp INNER JOIN payperiod ppd ON ppd.`Year`=pp.`Year` And ppd.OrganizationID=pp.OrganizationID And ppd.TotalGrossSalary=pp.TotalGrossSalary And YEAR(ppd.PayFromDate)=pp.`Year` AND DATE_FORMAT(ppd.PayFromDate, '%m-%d')='01-01' WHERE pp.PayFromDate=@datefrom AND pp.OrganizationID=@orgId ORDER BY ppd.PayFromDate, ppd.PayToDate LIMIT 1));"

        Using command = New MySqlCommand(strQuery, New MySqlConnection(connectionText))

            With command.Parameters
                .AddWithValue("@orgId", organizationId)
                .AddWithValue("@userId", user_row_id)
                .AddWithValue("@dateFrom", periodDateFrom)
                .AddWithValue("@periodId", payPeriodId)
            End With

            Await command.Connection.OpenAsync()

            Dim transaction = Await command.Connection.BeginTransactionAsync()

            Try
                Dim result = Await command.ExecuteNonQueryAsync()

                transaction.Commit()

                integerResult = result
            Catch ex As Exception
                _logger.Error("UpdateLeaveBalanceSick", ex)
                transaction.Rollback()

                MessageBox.Show(String.Concat("Oops! something went wrong, please contact ", My.Resources.SystemDeveloper),
                    String.Empty,
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Exclamation)

            End Try

        End Using

        Return integerResult
    End Function

    Private Async Function UpdateLeaveBalanceAdditionalVL() As Task(Of Integer)
        Dim integerResult = New Integer

        Dim connectionText = String.Concat(mysql_conn_text, "default command timeout=", configCommandTimeOut, ";")

        Dim strQuery = "CALL `UpdateLeaveBalanceAdditionalVL`(@orgId, @userId, @periodId, (SELECT ppd.PayFromDate FROM payperiod pp INNER JOIN payperiod ppd ON ppd.`Year`=pp.`Year` And ppd.OrganizationID=pp.OrganizationID And ppd.TotalGrossSalary=pp.TotalGrossSalary And YEAR(ppd.PayFromDate)=pp.`Year` AND DATE_FORMAT(ppd.PayFromDate, '%m-%d')='01-01' WHERE pp.PayFromDate=@datefrom AND pp.OrganizationID=@orgId ORDER BY ppd.PayFromDate, ppd.PayToDate LIMIT 1));"

        Using command = New MySqlCommand(strQuery, New MySqlConnection(connectionText))

            With command.Parameters
                .AddWithValue("@orgId", organizationId)
                .AddWithValue("@userId", user_row_id)
                .AddWithValue("@dateFrom", periodDateFrom)
                .AddWithValue("@periodId", payPeriodId)
            End With

            Await command.Connection.OpenAsync()

            Dim transaction = Await command.Connection.BeginTransactionAsync()

            Try
                Dim result = Await command.ExecuteNonQueryAsync()

                transaction.Commit()

                integerResult = result
            Catch ex As Exception
                _logger.Error("UpdateLeaveBalanceAdditionalVL", ex)
                transaction.Rollback()

                MessageBox.Show(String.Concat("Oops! something went wrong, please contact ", My.Resources.SystemDeveloper),
                    String.Empty,
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Exclamation)

            End Try

        End Using

        Return integerResult
    End Function

    Private Async Function UpdateLeaveBalanceOthers() As Task(Of Integer)
        Dim integerResult = New Integer

        Dim connectionText = String.Concat(mysql_conn_text, "default command timeout=", configCommandTimeOut, ";")

        Dim strQuery = "CALL `UpdateLeaveBalanceOthers`(@orgId, @userId, @periodId, (SELECT ppd.PayFromDate FROM payperiod pp INNER JOIN payperiod ppd ON ppd.`Year`=pp.`Year` And ppd.OrganizationID=pp.OrganizationID And ppd.TotalGrossSalary=pp.TotalGrossSalary And YEAR(ppd.PayFromDate)=pp.`Year` AND DATE_FORMAT(ppd.PayFromDate, '%m-%d')='01-01' WHERE pp.PayFromDate=@datefrom AND pp.OrganizationID=@orgId ORDER BY ppd.PayFromDate, ppd.PayToDate LIMIT 1));"

        Using command = New MySqlCommand(strQuery, New MySqlConnection(connectionText))

            With command.Parameters
                .AddWithValue("@orgId", organizationId)
                .AddWithValue("@userId", user_row_id)
                .AddWithValue("@dateFrom", periodDateFrom)
                .AddWithValue("@periodId", payPeriodId)
            End With

            Await command.Connection.OpenAsync()

            Dim transaction = Await command.Connection.BeginTransactionAsync()

            Try
                Dim result = Await command.ExecuteNonQueryAsync()

                transaction.Commit()

                integerResult = result
            Catch ex As Exception
                _logger.Error("UpdateLeaveBalanceOthers", ex)
                transaction.Rollback()

                MessageBox.Show(String.Concat("Oops! something went wrong, please contact ", My.Resources.SystemDeveloper),
                    String.Empty,
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Exclamation)

            End Try

        End Using

        Return integerResult
    End Function

    Private Async Function UpdateLeaveBalanceParental() As Task(Of Integer)
        Dim integerResult = New Integer

        Dim connectionText = String.Concat(mysql_conn_text, "default command timeout=", configCommandTimeOut, ";")

        Dim strQuery = "CALL `UpdateLeaveBalanceParental`(@orgId, @userId, @periodId, (SELECT ppd.PayFromDate FROM payperiod pp INNER JOIN payperiod ppd ON ppd.`Year`=pp.`Year` And ppd.OrganizationID=pp.OrganizationID And ppd.TotalGrossSalary=pp.TotalGrossSalary And YEAR(ppd.PayFromDate)=pp.`Year` AND DATE_FORMAT(ppd.PayFromDate, '%m-%d')='01-01' WHERE pp.PayFromDate=@datefrom AND pp.OrganizationID=@orgId ORDER BY ppd.PayFromDate, ppd.PayToDate LIMIT 1));"

        Using command = New MySqlCommand(strQuery, New MySqlConnection(connectionText))

            With command.Parameters
                .AddWithValue("@orgId", organizationId)
                .AddWithValue("@userId", user_row_id)
                .AddWithValue("@dateFrom", periodDateFrom)
                .AddWithValue("@periodId", payPeriodId)
            End With

            Await command.Connection.OpenAsync()

            Dim transaction = Await command.Connection.BeginTransactionAsync()

            Try
                Dim result = Await command.ExecuteNonQueryAsync()

                transaction.Commit()

                integerResult = result
            Catch ex As Exception
                _logger.Error("UpdateLeaveBalanceParental", ex)
                transaction.Rollback()

                MessageBox.Show(String.Concat("Oops! something went wrong, please contact ", My.Resources.SystemDeveloper),
                    String.Empty,
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Exclamation)

            End Try

        End Using

        Return integerResult
    End Function

    Private Async Function UpdateLeaveItemsAsync() As Task

        Dim connectionText = String.Concat(mysql_conn_text, "default command timeout=", configCommandTimeOut, ";")

        Dim getJanuaryOnePayPeriod =
            Function()
                Return $"SELECT ppd.RowID FROM payperiod pp INNER JOIN payperiod ppd ON ppd.`Year`=pp.`Year` And ppd.OrganizationID=pp.OrganizationID And ppd.TotalGrossSalary=pp.TotalGrossSalary And YEAR(ppd.PayFromDate)=pp.`Year` AND DATE_FORMAT(ppd.PayFromDate, '%m-%d')='01-01' WHERE pp.PayFromDate='{periodDateFrom:yyyy-MM-dd}' AND pp.PayToDate='{periodDateTo:yyyy-MM-dd}' AND pp.OrganizationID={organizationId} ORDER BY ppd.PayFromDate, ppd.PayToDate LIMIT 1"
            End Function

        Dim strQuery = $"CALL `UpdateLeaveItems`(@orgId, ({getJanuaryOnePayPeriod()}));"

        Using command = New MySqlCommand(strQuery, New MySqlConnection(connectionText))

            With command.Parameters
                .AddWithValue("@orgId", organizationId)
                '.AddWithValue("@userId", user_row_id)
                '.AddWithValue("@dateFrom", periodDateFrom)
                '.AddWithValue("@dateTo", periodDateTo)
                '.AddWithValue("@periodId", payPeriodId)

            End With

            Await command.Connection.OpenAsync

            Dim transaction = Await command.Connection.BeginTransactionAsync

            Try
                Await command.ExecuteNonQueryAsync()
                transaction.Commit()

                MessageBox.Show("Leave balance were reset successfully",
                    "Done reset leave balance",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information)
            Catch ex As Exception
                _logger.Error("UpdateLeaveItemsAsync", ex)
                transaction.Rollback()

                MessageBox.Show(String.Concat("Oops! something went wrong, please contact ", My.Resources.SystemDeveloper),
                    "Error reset leave balance",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Exclamation)
            End Try

        End Using
    End Function

End Class