Option Strict On

Imports System.Data.Entity
Imports System.Threading.Tasks

Public Class Form1
    Private ReadOnly _userId As Integer

    Public Sub New(userId As Integer)
        _userId = userId
        ' This call is required by the designer.
        InitializeComponent()

        ' Add any initialization after the InitializeComponent() call.

    End Sub

    Private Sub Form1_Load(sender As Object, e As EventArgs) Handles MyBase.Load

    End Sub

    Private Async Sub Button1_Click(sender As Object, e As EventArgs) Handles Button1.Click
        Using context = New DatabaseContext()

            Dim lastDateOfCurrentCalendar = New DateTime(2025, 12, 31)
            Dim numberOfDays = lastDateOfCurrentCalendar.DayOfYear
            Dim previousCalendarLastDate = New DateTime(lastDateOfCurrentCalendar.Year - 1, 12, 31)
            Dim currentCalendarDates = Enumerable.Range(1, numberOfDays).
                Select(Function(t) previousCalendarLastDate.AddDays(t)).
                ToList()

            Dim organizations = Await context.Organizations.
                AsNoTracking().
                Where(Function(t) t.NoPurpose = False).
                ToListAsync()
            Dim organizationIds = organizations.Select(Function(t) t.RowID).ToList()

            Dim query = context.PayRates.
                AsNoTracking().
                AsQueryable()

            Dim getPayrates =
                Function()
                    Return Task.FromResult(
                        query.
                        Where(Function(t) currentCalendarDates.Contains(t.Date.Value)).
                        Where(Function(t) organizationIds.Contains(t.OrganizationID)).
                        AsEnumerable().
                        ToList())
                End Function

            Dim payrates = Await getPayrates()

            Dim tasks = New List(Of Task)

            For Each [date] In currentCalendarDates

                For Each orgId In organizationIds
                    tasks.Add(SeedPayrateAsync(context, payrates, [date], orgId))
                Next

            Next

            Await Task.WhenAll(tasks)

        End Using

    End Sub

    Private Async Function SeedPayrateAsync(
            context As DatabaseContext,
            payrates As List(Of PayRateEntity),
            [date] As Date,
            orgId As Integer) As Task(Of String)

        Dim payrate = payrates.
            Where(Function(t) t.OrganizationID = orgId).
            Where(Function(t) [date] = t.Date.Value).
            FirstOrDefault()

        If payrate Is Nothing Then

            Dim newPayrate = PayRateEntity.NewPayrate(userId:=_userId,
                organizationId:=orgId,
                [date]:=[date])

            context.PayRates.Add(newPayrate)

            Await context.SaveChangesAsync()

            Dim result = $"Successfully added. {[date].Date.ToShortDateString()} for OrgId: {orgId}"
            Console.WriteLine(result)
            Return result

        Else

            Dim result = $"Already exists. {[date].Date.ToShortDateString()} for OrgId: {orgId}"
            Console.WriteLine(result)
            Return result

        End If

    End Function

    Private Function GetInnerException(ex As Exception) As Exception
        If ex?.InnerException IsNot Nothing Then Return GetInnerException(ex)

        Return ex
    End Function

End Class