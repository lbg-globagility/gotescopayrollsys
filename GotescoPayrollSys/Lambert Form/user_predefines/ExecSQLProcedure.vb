Imports MySql.Data.MySqlClient

Public Class ExecSQLProcedure

    Dim n_ReturnValue = Nothing

    Private priv_conn As New MySqlConnection

    Private priv_da As New MySqlDataAdapter

    Private priv_cmd As New MySqlCommand

    Dim mysqltransac As MySqlTransaction

    Sub New(SQLProcedureName As String,
            n_CommandTimeOut As Integer,
            ParamArray ParameterInput() As Object)

        If n_CommandTimeOut > 0 Then

            priv_conn.ConnectionString =
                String.Concat(mysql_conn_text,
                              "default command timeout=", n_CommandTimeOut, ";")

        Else

            priv_conn.ConnectionString = mysql_conn_text

        End If

        SQLProcedureName = SQLProcedureName.Trim

        'Dim n_SQLQueryToDatatable = _
        '    New SQLQueryToDatatable("SELECT GROUP_CONCAT(ii.PARAMETER_NAME) `Result`" &
        '                            " FROM information_schema.PARAMETERS ii" &
        '                            " WHERE ii.SPECIFIC_NAME = '" & SQLProcedureName & "'" &
        '                            " AND ii.`SPECIFIC_SCHEMA` = '" & sys_db & "'" &
        '                            " AND ii.PARAMETER_NAME IS NOT NULL;")

        Dim n_SQLQueryToDatatable =
            New SQLQueryToDatatable(String.Concat("CALL GET_parameter_collection('", sys_db, "'",
                                                  ", '", SQLProcedureName, "');"),
                                    1024)

        Dim catchdt As New DataTable
        catchdt = n_SQLQueryToDatatable.ResultTable

        Dim paramName As String = String.Empty

        Dim list_params As New List(Of String)

        For Each drow As DataRow In catchdt.Rows
            paramName = Convert.ToString(drow(0))
            list_params.Add(paramName)
        Next

        'Dim paramNames = Split(paramName, ",")
        Dim paramNames = list_params.ToArray

        Try

            If priv_conn.State = ConnectionState.Open Then : priv_conn.Close() : End If

            priv_cmd = New MySqlCommand(SQLProcedureName, priv_conn, mysqltransac)

            priv_conn.Open()

            With priv_cmd

                mysqltransac = priv_conn.BeginTransaction()

                .Parameters.Clear()

                .CommandType = CommandType.StoredProcedure

                For e = 0 To paramNames.GetUpperBound(0)

                    Dim param_Name = paramNames(e)

                    Dim paramVal = ParameterInput(e)

                    .Parameters.AddWithValue(param_Name, paramVal)

                Next

                .ExecuteNonQuery()

                mysqltransac.Commit()

            End With

            _error_message = String.Empty

        Catch ex As Exception
            _hasError = True

            mysqltransac.Rollback()

            _error_message = getErrExcptn(ex, MyBase.ToString)

            MsgBox(_error_message, , SQLProcedureName)

        Finally

            priv_cmd.Connection.Close()

            priv_da.Dispose()
            
            priv_conn.Close()

            priv_conn.Dispose()

            priv_cmd.Dispose()

        End Try

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