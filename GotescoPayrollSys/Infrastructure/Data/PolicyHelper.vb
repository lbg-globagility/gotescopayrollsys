Imports System.Data.Entity

Public Class PolicyHelper
    Implements IPolicyHelper

    Public ReadOnly Property PhilHealthPolicy As PhilHealthPolicy Implements IPolicyHelper.PhilHealthPolicy

    Public ReadOnly Property SocialSecurityPolicy As SocialSecurityPolicy Implements IPolicyHelper.SocialSecurityPolicy

    Public Sub New()
        Using context = New DatabaseContext
            Dim types = {
                PhilHealthPolicy.PHILHEALTH_POLICY_TYPE,
                SocialSecurityPolicy.SOCIAL_SECURITY_POLICY_TYPE}

            Dim listOfValues = context.ListOfValues.
                Where(Function(l) types.Contains(l.Type)).
                AsNoTracking().
                ToList()

            Dim philHealthSettings = listOfValues.
                Where(Function(l) l.Type = PhilHealthPolicy.PHILHEALTH_POLICY_TYPE).
                ToList()
            PhilHealthPolicy = New PhilHealthPolicy(
                settings:=New ListOfValueCollection(philHealthSettings))

            Dim socialSecuritySettings = listOfValues.
                Where(Function(l) l.Type = SocialSecurityPolicy.SOCIAL_SECURITY_POLICY_TYPE).
                ToList()
            SocialSecurityPolicy = New SocialSecurityPolicy(
                settings:=New ListOfValueCollection(socialSecuritySettings))
        End Using
    End Sub

    Private Async Sub Load()
        Using context = New DatabaseContext
            Dim listOfValues = Await context.ListOfValues.
                AsNoTracking().
                ToListAsync()

            Dim settings = New ListOfValueCollection(listOfValues)

        End Using
    End Sub

End Class