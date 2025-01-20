Option Strict On

Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel.DataAnnotations.Schema

<Table("payrate")>
Partial Public Class PayRateEntity
    <Key>
    <DatabaseGenerated(DatabaseGeneratedOption.Identity)>
    Public Property RowID As Integer

    Public Property OrganizationID As Integer

    <DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    Public Property Created As Date

    Public Property CreatedBy As Integer?

    <DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    Public Property LastUpd As Date?

    Public Property LastUpdBy As Integer?
    Public Property DayBefore As Date?
    Public Property [Date] As Date?

    <Column("PayType")>
    Public Property Type As String
    Public Property Description As String

    <Column("PayRate")>
    Public Property DefaultRate As Decimal?
    Public Property OvertimeRate As Decimal?
    Public Property NightDifferentialRate As Decimal?
    Public Property NightDifferentialOTRate As Decimal?
    Public Property RestDayRate As Decimal?
    Public Property RestDayOvertimeRate As Decimal?
    Public Property TomorrowDate As Date?
End Class

Partial Public Class PayRateEntity

    Public Const TYPE_DEFAULT_TEXT As String = "Regular Day"
    Public Const TYPE_LEGAL_TEXT As String = "Regular Holiday"
    Public Const TYPE_SPECIAL_TEXT As String = "Special Non-Working Holiday"

    Private Sub New()

    End Sub

    Public Sub New(userId As Integer,
        organizationID As Integer,
        [date] As Date,
        Optional type As String = "")

        Me.OrganizationID = organizationID
        CreatedBy = userId
        Me.[Date] = [date]

        Dim _type = If(String.IsNullOrEmpty(type), TYPE_DEFAULT_TEXT, type)
        Me.Type = _type

        SetRates(type:=_type)

    End Sub

    Private Sub SetRates(type As String)
        DefaultRate = 0
        OvertimeRate = 0
        NightDifferentialRate = 0
        NightDifferentialOTRate = 0
        RestDayRate = 0
        RestDayOvertimeRate = 0

        If type = TYPE_DEFAULT_TEXT Then
            DefaultRate = 1
            OvertimeRate = 1.25D
            NightDifferentialRate = 1.1D
            NightDifferentialOTRate = 1.375D
            RestDayRate = 1.3D
            RestDayOvertimeRate = 1.69D

        ElseIf type = TYPE_SPECIAL_TEXT Then
            DefaultRate = 1.3D
            OvertimeRate = 1.69D
            NightDifferentialRate = 1.43D
            NightDifferentialOTRate = 1.859D
            RestDayRate = 1.5D
            RestDayOvertimeRate = 1.95D

        ElseIf type = TYPE_LEGAL_TEXT Then
            DefaultRate = 2D
            OvertimeRate = 2.6D
            NightDifferentialRate = 2.2D
            NightDifferentialOTRate = 2.86D
            RestDayRate = 2.6D
            RestDayOvertimeRate = 3.38D

        End If
    End Sub

    Public Shared Function NewPayrate(userId As Integer,
        organizationId As Integer,
        [date] As Date,
        Optional type As String = "") As PayRateEntity

        Return New PayRateEntity(userId:=userId,
            organizationID:=organizationId,
            [date]:=[date],
            type:=type)
    End Function

End Class
