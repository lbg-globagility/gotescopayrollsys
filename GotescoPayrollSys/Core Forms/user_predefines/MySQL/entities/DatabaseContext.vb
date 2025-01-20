Imports System.Data.Common
Imports System.Data.Entity
Imports AccuPay.Entity

Public Class DatabaseContext
    Inherits DbContext

    ' Your context has been configured to use a 'Model1' connection string from your application's
    ' configuration file (App.config or Web.config). By default, this connection string targets the
    ' 'GotescoPayrollSys.Model1' database on your LocalDb instance.
    '
    ' If you wish to target a different database and/or database provider, modify the 'Model1'
    ' connection string in the application configuration file.

    'Public Sub New()
    '    Dim newConn = New DataBaseConnection
    '    MyBase.New(newConn.GetStringMySQLConnectionString, True)
    '    'MyBase.New("name=Model1")
    '    'MyBase.New("name=TestModel1")
    'End Sub

    Private Shared Function GetConnection() As DbConnection
        Dim connection = DbProviderFactories.GetFactory("MySql.Data.MySqlClient").CreateConnection()
        Dim newConn = New DataBaseConnection
        connection.ConnectionString = newConn.GetStringMySQLConnectionString
        Return connection
    End Function

    Public Sub New()
        MyBase.New(GetConnection(), True)
    End Sub

    Public Sub New(connection As DbConnection)
        MyBase.New(connection, True)
    End Sub

    ' Add a DbSet for each entity type that you want to include in your model. For more information
    ' on configuring and using a Code First model, see http:'go.microsoft.com/fwlink/?LinkId=390109.
    ' Public Overridable Property MyEntities() As DbSet(Of MyEntity)
    Public Overridable Property NewPhilHealth() As DbSet(Of newphilhealthimplement)

    Public Overridable Property NewWithholdingTax() As DbSet(Of WithholdingTaxBracket)

    Public Overridable Property Adjustments() As DbSet(Of Adjustment)

    Public Overridable Property ActualAdjustments As DbSet(Of ActualAdjustment)

    Public Overridable Property AuditTrail() As DbSet(Of AuditTrail)

    Public Overridable Property Categories() As DbSet(Of Category)

    Public Overridable Property ProperDisplayAuditTrail() As DbSet(Of ProperDisplayAuditTrail)

    Public Overridable Property TimeEntryLogsPerCutOff() As DbSet(Of TimeEntryLogsPerCutOff)

    Public Overridable Property Employees() As DbSet(Of Employee)

    Public Overridable Property EmployeeEntity() As DbSet(Of EmployeeEntity)

    Public Overridable Property EmployeeTimeEntryDetails() As DbSet(Of EmployeeTimeEntryDetails)

    Public Overridable Property Organizations() As DbSet(Of Organization)

    Public Overridable Property PayPeriods() As DbSet(Of PayPeriod)

    Public Overridable Property PayRates() As DbSet(Of PayRateEntity)

    Public Overridable Property PayStubItems() As DbSet(Of PaystubItem)

    Public Overridable Property Products() As DbSet(Of Product)

    Public Overridable Property PositionPrivileges() As DbSet(Of PositionPrivilege)

    Public Overridable Property Salaries As DbSet(Of Salary)

    Public Overridable Property SssBrackets() As DbSet(Of SssBracket)

    Public Overridable Property PhilHealthBrackets() As DbSet(Of PhilHealth)

    Public Overridable Property Bonuses() As DbSet(Of Bonus)

    Public Overridable Property ListOfValues As DbSet(Of ListOfValue)

End Class