Option Strict On

Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel.DataAnnotations.Schema
Imports GotescoPayrollSys

Namespace Global.AccuPay.Entity

    <Table("paystub")>
    Public Class Paystub

        <Key>
        <DatabaseGenerated(DatabaseGeneratedOption.Identity)>
        Public Property RowID As Integer?

        Public Property PayPeriodID As Integer?

        Public Property EmployeeID As Integer?

        <ForeignKey("PayPeriodID")>
        Public Overridable Property PayPeriod As PayPeriod
    End Class

End Namespace

