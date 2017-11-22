Imports MySql.Data.MySqlClient

Public Class ExecuteQuery

    Private priv_conn As New MySqlConnection

    Private priv_da As New MySqlDataAdapter

    Private priv_cmd As New MySqlCommand

    Private getResult = Nothing

    Dim dr As MySqlDataReader

    Sub New(ByVal cmdsql As String,
            Optional cmd_time_out As Integer = 0)

        Static mysql_except_query() As String = {"CALL", "UPDATE", "DELETE"}

        'Dim n_DataBaseConnection As New DataBaseConnection

        If cmd_time_out > 0 Then

            priv_conn.ConnectionString = mysql_conn_text &
                "default command timeout=" & cmd_time_out & ";"

        Else

            priv_conn.ConnectionString = mysql_conn_text

        End If

        Try

            If priv_conn.State = ConnectionState.Open Then : priv_conn.Close() : End If

            priv_conn.Open()

            priv_cmd = New MySqlCommand

            With priv_cmd

                .CommandType = CommandType.Text

                .Connection = priv_conn

                .CommandText = cmdsql

                If cmd_time_out > 0 Then
                    .CommandTimeout = cmd_time_out
                End If

                If FindingWordsInString(cmdsql, mysql_except_query) Then

                    .ExecuteNonQuery()

                Else

                    dr = .ExecuteReader()

                End If

            End With
            
            If FindingWordsInString(cmdsql, mysql_except_query) Then
                getResult = Nothing
            Else

                If dr.Read = True Then

                    If IsDBNull(dr(0)) Then
                        getResult = String.Empty
                    Else
                        getResult = dr(0)

                    End If

                Else
                    getResult = Nothing

                End If

            End If

            _error_message = String.Empty

        Catch ex As Exception

            _hasError = True

            _error_message = getErrExcptn(ex, "ExecuteQuery")

            MsgBox(_error_message, , cmdsql)

        Finally

            priv_cmd.Connection.Close()

            If dr IsNot Nothing Then
                dr.Close()
                dr.Dispose()
            End If
            
            priv_conn.Close()

            priv_conn.Dispose()

            priv_cmd.Dispose()

        End Try

    End Sub

    Property Result As Object

        Get
            Return getResult

        End Get

        Set(value As Object)
            getResult = value

        End Set

    End Property

    Sub ExecuteQuery()

    End Sub

    Dim _hasError As Boolean = False

    Property HasError As Boolean

        Get
            Return _hasError

        End Get

        Set(value As Boolean)
            _hasError = value

        End Set

    End Property

    Dim _error_message As String = String.Empty

    Property ErrorMessage As String

        Get
            Return _error_message

        End Get

        Set(value As String)
            _error_message = value

        End Set

    End Property

End Class