Imports System.Text.RegularExpressions

Public Class OutputText

    Shared Function Display(content_string As String,
                            ParamArray param_values() As Object) As String

        Dim r As Regex = New Regex("\{\w*?\}")

        Dim input As String = content_string.Trim

        Dim mc As MatchCollection =
            Regex.Matches(input, r.ToString)

        Dim i = 0

        Dim result As String = content_string

        For Each m As Match In mc

            Dim indx_tobe_replace =
                mc.Item(i).ToString

            Dim _indx = indx_tobe_replace.Replace("{", "").Replace("}", "")

            Dim indx = CInt(_indx)

            result =
                Replace(result,
                        indx_tobe_replace,
                        param_values(indx))

            'Console.WriteLine(result)

            i += 1

        Next

        Return result

    End Function

End Class