Imports MySql.Data.MySqlClient

Public Class SQLQueryToDatatable

    Private priv_conn As New MySqlConnection

    Private priv_da As New MySqlDataAdapter

    Private priv_cmd As New MySqlCommand

    Sub New(SQLProcedureName As String,
            Optional command_time_out As Integer = 0)

        priv_conn.ConnectionString = mysql_conn_text

        SQLProcedureName = SQLProcedureName.Trim

        Try

            If priv_conn.State = ConnectionState.Open Then
                priv_conn.Close()

            End If

            priv_conn.Open()

            priv_cmd = New MySqlCommand

            With priv_cmd

                If command_time_out > 0 Then
                    .CommandTimeout = command_time_out

                End If

                .Parameters.Clear()

                .Connection = priv_conn

                .CommandText = SQLProcedureName

                .CommandType = CommandType.Text

                priv_da.SelectCommand = priv_cmd

                priv_da.Fill(n_ResultTable)

            End With
        Catch ex As Exception
            MsgBox(getErrExcptn(ex, MyBase.ToString), , SQLProcedureName)
        Finally
            priv_cmd.Connection.Close()

            priv_da.Dispose()

            priv_conn.Close()

            priv_conn.Dispose()

            priv_cmd.Dispose()

        End Try

    End Sub

    Dim n_ResultTable As New DataTable

    Property ResultTable As DataTable

        Get
            Return n_ResultTable

        End Get

        Set(value As DataTable)

            n_ResultTable = value

        End Set

    End Property

End Class