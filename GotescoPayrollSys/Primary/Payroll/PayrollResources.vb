Option Strict On
Imports System.Data.Entity
Imports System.Threading.Tasks
Imports AccuPay.Entity
Imports GotescoPayrollSys
Imports MySql.Data.MySqlClient

Public Class PayrollResources
    Private _payPeriodID As Integer
    Private _payDateFrom As Date
    Private _payDateTo As Date
    Private _payPeriod As PayPeriod
    Private _loansWithPayPeriod As IList(Of LoanScheduleWithPayPeriod)
    Private _salaries As List(Of Salary)
    Private _employees As List(Of Employee)
    Private _products As List(Of Product)
    Private _philHealthBrackets As List(Of PhilHealth)
    Private _socialSecurityBrackets As List(Of SocialSecurity)
    Private _salariesWithSss As List(Of SalariesWithSSS)

    Public Sub New(payPeriodID As Integer, payDateFrom As Date, payDateTo As Date)
        _payPeriodID = payPeriodID
        _payDateFrom = payDateFrom
        _payDateTo = payDateTo
    End Sub

#Region "Propeties"

    Public ReadOnly Property PayPeriod As PayPeriod
        Get
            Return _payPeriod
        End Get
    End Property

    Public ReadOnly Property LoansWithPayPeriod As IList(Of LoanScheduleWithPayPeriod)
        Get
            Return _loansWithPayPeriod
        End Get
    End Property

    Public ReadOnly Property Employees As IList(Of Employee)
        Get
            Return _employees
        End Get
    End Property

    Public ReadOnly Property Salaries As IList(Of Salary)
        Get
            Return _salaries
        End Get
    End Property

    Public ReadOnly Property Products As IList(Of Product)
        Get
            Return _products
        End Get
    End Property

    Public ReadOnly Property PhilHealthBrackets As IList(Of PhilHealth)
        Get
            Return _philHealthBrackets
        End Get
    End Property

#End Region

#Region "Methods"

    Public Async Function Load() As Task
        'LoadPayPeriod() should be executed before LoadSocialSecurityBrackets()

        Await LoadPayPeriodAsync()

        Await Task.
            WhenAll({
                    LoadEmployeesAync(),
                    LoadLoanSchedulesWithPayPeriodAsync(),
                    LoadSalariesAsync(),
                    LoadProductsAsync(),
                    LoadSalariesWithSSSAsync()
                    })
    End Function

    Public Async Function LoadPayPeriodAsync() As Task
        Try
            Using context = New DatabaseContext
                Dim seek = Await context.PayPeriods.
                    Where(Function(pp) pp.RowID = _payPeriodID).
                    ToListAsync()

                If seek.Any() Then _payPeriod = seek.FirstOrDefault

            End Using
        Catch ex As Exception
            Throw New ResourceLoadingException("PayPeriods", ex)
        End Try
    End Function

    Public Async Function LoadLoanSchedulesWithPayPeriodAsync() As Task
        _loansWithPayPeriod = New List(Of LoanScheduleWithPayPeriod)

        Dim sql = <![CDATA[CALL `LoanPrediction`(@organizationID);]]>.Value

        Using connection As New MySqlConnection(connectionString),
            command As New MySqlCommand(sql, connection)

            With command.Parameters
                .AddWithValue("@organizationID", z_OrganizationID)
            End With

            Await connection.OpenAsync()
            Try
                Dim reader = Await command.ExecuteReaderAsync()

                Dim models = New List(Of LoanScheduleWithPayPeriod)
                While Await reader.ReadAsync()
                    Dim loanSchedWithPayPeriod = GetLoanSchedWithPayPeriod(reader)
                    models.Add(loanSchedWithPayPeriod)
                End While

                If models.Any() Then
                    _loansWithPayPeriod = models.Where(Function(els) els.PayPeriodID = _payPeriodID).ToList()
                End If
            Catch ex As Exception
                Throw New ResourceLoadingException("LoanSchedulesWithPayPeriod", ex)
            End Try
        End Using
    End Function

    Public Async Function LoadEmployeesAync() As Task
        Try
            'Dim dateWithinOfService =
            '    Function(e As Employee) As Date
            '        If Not e.TerminationDate.HasValue Then Return _payDateTo
            '        Return e.TerminationDate.Value
            '    End Function

            Using context = New DatabaseContext
                Dim seek = Await context.Employees.
                    Where(Function(e) z_OrganizationID = e.OrganizationID.Value).
                    Where(Function(e) _payDateFrom.Date >= e.StartDate.Value AndAlso _payDateTo >= If(e.TerminationDate, _payDateTo)).
                    ToListAsync()

                If seek.Any() Then _employees = seek
            End Using
        Catch ex As Exception
            Throw New ResourceLoadingException("Employees", ex)
        End Try
    End Function

    Public Async Function LoadSalariesAsync() As Task
        Try
            Using context = New DatabaseContext
                Dim seek = Await context.Salaries.
                    Include(Function(s) s.Employee).
                    Include(Function(s) s.SociaSecurityService).
                    Include(Function(s) s.PhilHealth).
                    Where(Function(s) z_OrganizationID = s.OrganizationID.Value).
                    ToListAsync()

                _salaries = seek
            End Using
        Catch ex As Exception
            Throw New ResourceLoadingException("Salaries", ex)
        End Try
    End Function

    Public Async Function LoadSalariesWithSSSAsync() As Task

        Dim sql = <![CDATA[CALL `SalariesWithSSSContrib`(@organizationID);
SELECT i.* FROM salarieswithsssamount i WHERE i.PayPeriodID=@payPeriodID;]]>.Value

        Using connection As New MySqlConnection(connectionString),
            command As New MySqlCommand(sql, connection)

            With command.Parameters
                .AddWithValue("@organizationID", 18) 'z_OrganizationID
                .AddWithValue("@payPeriodID", _payPeriodID)
            End With

            Await connection.OpenAsync()
            Try
                Dim reader = Await command.ExecuteReaderAsync()

                Dim list As New List(Of SalariesWithSSS)
                While Await reader.ReadAsync()
                    list.Add(CreateSalaryWithSSS(reader))
                End While

                _salariesWithSss = list
            Catch ex As Exception
                Throw New ResourceLoadingException("SalariesWithSSS", ex)
            End Try
        End Using
    End Function

    Private Shared Function CreateSalaryWithSSS(reader As Common.DbDataReader) As SalariesWithSSS
        Return New SalariesWithSSS With {
            .RowID = reader.GetValue(Of Integer)("RowID"),
            .EmployeeID = reader.GetValue(Of Integer)("EmployeeID"),
            .Created = reader.GetValue(Of Date)("Created"),
            .CreatedBy = reader.GetValue(Of Integer)("CreatedBy"),
            .LastUpd = reader.GetValue(Of Date?)("LastUpd"),
            .LastUpdBy = reader.GetValue(Of Integer?)("LastUpdBy"),
            .OrganizationID = reader.GetValue(Of Integer?)("OrganizationID"),
            .FilingStatusID = reader.GetValue(Of Integer?)("FilingStatusID"),
            .PaySocialSecurityID = reader.GetValue(Of Integer?)("PaySocialSecurityID"),
            .PayPhilhealthID = reader.GetValue(Of Integer?)("PayPhilhealthID"),
            .PhilHealthDeduction = reader.GetValue(Of Decimal?)("PhilHealthDeduction"),
            .HDMFAmount = reader.GetValue(Of Decimal?)("HDMFAmount"),
            .TrueSalary = reader.GetValue(Of Decimal?)("TrueSalary"),
            .BasicPay = reader.GetValue(Of Decimal?)("BasicPay"),
            .SalaryAmount = reader.GetValue(Of Decimal?)("Salary"),
            .UndeclaredSalary = reader.GetValue(Of Decimal?)("UndeclaredSalary"),
            .BasicDailyPay = reader.GetValue(Of Decimal?)("BasicDailyPay"),
            .BasicHourlyPay = reader.GetValue(Of Decimal?)("BasicHourlyPay"),
            .NoofDependents = reader.GetValue(Of Integer?)("NoofDependents"),
            .MaritalStatus = reader.GetValue(Of String)("MaritalStatus"),
            .PositionID = reader.GetValue(Of Integer?)("PositionID"),
            .EffectiveDateFrom = reader.GetValue(Of Date?)("EffectiveDateFrom"),
            .EffectiveDateTo = reader.GetValue(Of Date?)("EffectiveDateTo"),
            .ContributeToGovt = reader.GetValue(Of Char?)("ContributeToGovt"),
            .OverrideDiscardSSSContrib = reader.GetValue(Of Boolean)("OverrideDiscardSSSContrib"),
            .OverrideDiscardPhilHealthContrib = reader.GetValue(Of Boolean)("OverrideDiscardPhilHealthContrib"),
            .PayPeriodID = reader.GetValue(Of Integer)("PayPeriodID"),
            .NewSSSContribution = reader.GetValue(Of Decimal)("Result")
        }
    End Function

    Public Async Function LoadSocialSecurityTableAsync() As Task

        Dim sql = <![CDATA[SELECT sss.* FROM paysocialsecurity sss WHERE sss.EffectiveDateFrom <= @dateFrom AND sss.EffectiveDateTo >= @dateTo;]]>.Value

        Using connection As New MySqlConnection(connectionString),
            command As New MySqlCommand(sql, connection)

            With command.Parameters
                .AddWithValue("@dateFrom", _payDateFrom)
                .AddWithValue("@dateTo", _payDateTo)
            End With

            Await connection.OpenAsync()
            Try
                Dim reader = Await command.ExecuteReaderAsync()

                Dim list As New List(Of SocialSecurity)
                While Await reader.ReadAsync()
                    list.Add(CreateSocialSecurity(reader))
                End While

                _socialSecurityBrackets = list
            Catch ex As Exception
                Throw New ResourceLoadingException("SocialSecurityTable", ex)
            End Try
        End Using
    End Function

    Private Shared Function CreateSocialSecurity(reader As Common.DbDataReader) As SocialSecurity
        Return New SocialSecurity With {
            .RowID = reader.GetValue(Of Integer)("RowID"),
            .Created = reader.GetValue(Of DateTime)("Created"),
            .CreatedBy = reader.GetValue(Of Integer)("CreatedBy"),
            .LastUpd = reader.GetValue(Of DateTime)("LastUpd"),
            .LastUpdBy = reader.GetValue(Of Integer)("LastUpdBy"),
            .RangeFromAmount = reader.GetValue(Of Decimal)("RangeFromAmount"),
            .RangeToAmount = reader.GetValue(Of Decimal)("RangeToAmount"),
            .MonthlySalaryCredit = reader.GetValue(Of Decimal)("MonthlySalaryCredit"),
            .EmployeeContributionAmount = reader.GetValue(Of Decimal)("EmployeeContributionAmount"),
            .EmployerContributionAmount = reader.GetValue(Of Decimal)("EmployerContributionAmount"),
            .EmployeeECAmount = reader.GetValue(Of Decimal)("EmployeeECAmount"),
            .HiddenData = reader.GetValue(Of Char)("HiddenData"),
            .EffectiveDateFrom = reader.GetValue(Of Date)("EffectiveDateFrom"),
            .EffectiveDateTo = reader.GetValue(Of Date)("EffectiveDateTo")
        }
    End Function

    Public Async Function LoadProductsAsync() As Task
        Try
            Using context = New DatabaseContext
                Dim seek = Await context.Products.
                    Include(Function(p) p.Category).
                    Where(Function(p) z_OrganizationID = p.OrganizationID.Value).
                    ToListAsync()

                If seek.Any() Then _products = seek
            End Using
        Catch ex As Exception
            Throw New ResourceLoadingException("Products", ex)
        End Try
    End Function

    Public Async Function LoadPhilHealthBracketsAsync() As Task
        Try
            Using context = New DatabaseContext
                Dim seek = Await context.PhilHealthBrackets.
                    Where(Function(phh) phh.IsNotHidden).
                    ToListAsync()

                If seek.Any() Then _philHealthBrackets = seek
            End Using
        Catch ex As Exception
            Throw New ResourceLoadingException("PhilHealthBrackets", ex)
        End Try
    End Function

#End Region

#Region "Functions"

    Private Shared Function GetLoanSchedWithPayPeriod(reader As Common.DbDataReader) As LoanScheduleWithPayPeriod
        Return New LoanScheduleWithPayPeriod() With {
                                .RowID = reader.GetValue(Of Integer)("RowID"),
                                .OrganizationID = reader.GetValue(Of Integer)("OrganizationID"),
                                .Created = reader.GetValue(Of DateTime)("Created"),
                                .CreatedBy = reader.GetValue(Of Integer?)("CreatedBy"),
                                .LastUpd = reader.GetValue(Of DateTime?)("LastUpd"),
                                .LastUpdBy = reader.GetValue(Of Integer?)("LastUpdBy"),
                                .EmployeeID = reader.GetValue(Of Integer?)("EmployeeID"),
                                .LoanNo = reader.GetValue(Of String)("LoanNumber"),
                                .StartDate = reader.GetValue(Of Date?)("DedEffectiveDateFrom"),
                                .EndDate = reader.GetValue(Of Date?)("DedEffectiveDateTo"),
                                .TotalLoanAmount = reader.GetValue(Of Decimal?)("TotalLoanAmount"),
                                .DeductionSchedule = reader.GetValue(Of String)("DeductionSchedule"),
                                .TotalBalanceLeft = reader.GetValue(Of Decimal?)("TotalBalanceLeft"),
                                .DeductionAmount = reader.GetValue(Of Decimal?)("DeductionAmount"),
                                .Status = reader.GetValue(Of String)("Status"),
                                .LoanTypeID = reader.GetValue(Of Integer?)("LoanTypeID"),
                                .DeductionPercentage = reader.GetValue(Of Decimal?)("DeductionPercentage"),
                                .NoOfPayPeriod = reader.GetValue(Of Decimal?)("NoOfPayPeriod"),
                                .LoanPayPeriodLeft = reader.GetValue(Of Decimal?)("LoanPayPeriodLeft"),
                                .Comments = reader.GetValue(Of String)("Comments"),
                                .Nondeductible = reader.GetValue(Of Char?)("Nondeductible"),
                                .ReferenceLoanID = reader.GetValue(Of Integer?)("ReferenceLoanID"),
                                .SubstituteEndDate = reader.GetValue(Of Date?)("SubstituteEndDate"),
                                .PayStubID = reader.GetValue(Of Integer?)("PayStubID"),
                                .LoanBalance = reader.GetValue(Of Decimal)("LoanBalance"),
                                .PayFromDate = reader.GetValue(Of Date)("PayFromDate"),
                                .PayToDate = reader.GetValue(Of Date)("PayToDate"),
                                .PayPeriodID = reader.GetValue(Of Integer)("PayPeriodID")
                            }
    End Function

#End Region
End Class

Public Class ResourceLoadingException
    Inherits Exception

    Public Sub New(resource As String, ex As Exception)
        MyBase.New($"Failure to load resource `{resource}`", ex)
    End Sub

End Class
