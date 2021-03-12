Imports System.Data.Entity

Public Class SocialSecurityPolicy
    Public Const SOCIAL_SECURITY_POLICY_TYPE As String = "SocialSecuritySystem"

    Private ReadOnly _settings As ListOfValueCollection

    Public Sub New(settings As ListOfValueCollection)
        _settings = settings
        'Load()
    End Sub

    Private Async Sub Load()
        Using context = New DatabaseContext
            Dim philHealthCollection = Await context.ListOfValues.
                Where(Function(l) l.Type = SOCIAL_SECURITY_POLICY_TYPE).
                ToListAsync()
            Dim settings = New ListOfValueCollection(philHealthCollection)

            '_settings = settings
        End Using
    End Sub

    Public ReadOnly Property IncludeOvertime() As Boolean
        Get
            Return _settings.GetBoolean($"{SOCIAL_SECURITY_POLICY_TYPE}.IncludeOvertime")
        End Get
    End Property

End Class