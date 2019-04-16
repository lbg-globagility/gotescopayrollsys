Imports System.Text

Public Class SBConcat

    Public Shared Function ConcatResult(ParamArray array_of_objects() As Object) As Object

        Dim sb As New StringBuilder

        For Each str_val As String In array_of_objects
            sb.Append(str_val)
        Next

        Return Convert.ToString(sb)

    End Function

End Class