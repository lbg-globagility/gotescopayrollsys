Imports System.Data.Entity

Public Class PhilHealthPolicy
    Public Const PHILHEALTH_POLICY_TYPE As String = "PhilHealth"

    Private ReadOnly _settings As ListOfValueCollection

    Public Sub New(settings As ListOfValueCollection)
        _settings = settings
        'Load()
    End Sub

    Private Async Sub Load()
        Using context = New DatabaseContext
            Dim philHealthCollection = Await context.ListOfValues.
                Where(Function(l) l.Type = PHILHEALTH_POLICY_TYPE).
                ToListAsync()
            Dim settings = New ListOfValueCollection(philHealthCollection)

            '_settings = settings
        End Using
    End Sub

    Public Function DeductionType() As PhilHealthDeductionType
        Dim deductType = _settings.GetString("DeductionType", "Formula")
        Dim resultType As PhilHealthDeductionType =
            [Enum].Parse(GetType(PhilHealthDeductionType), deductType)

        Return resultType
    End Function

    Public Function IsFormulaBased()
        Return DeductionType() = PhilHealthDeductionType.Formula
    End Function

    Public Function IsBracketBased()
        Return DeductionType() = PhilHealthDeductionType.Bracket
    End Function

    Public Function Rate() As Decimal
        Return _settings.GetDecimal("Rate")
    End Function

    Public Function MinimumContribution() As Decimal
        Return _settings.GetDecimal("MinimumContribution")
    End Function

    Public Function MaximumContribution() As Decimal
        Return _settings.GetDecimal("MaximumContribution")
    End Function

    Public Function YearStarted() As Integer
        Return _settings.GetDecimal("YearOfEffect", 2018)
    End Function

End Class

Public Enum PhilHealthDeductionType
    Formula
    Bracket
End Enum