Imports System.Runtime.CompilerServices

Module StringExtensions

    <Extension()>
    Public Function SimilarTo(ByVal source As String,
        toCheck As String,
        Optional comp As StringComparison = StringComparison.OrdinalIgnoreCase) As Boolean

        Return (If(source?.IndexOf(toCheck, comp), -1)) >= 0
    End Function
End Module
