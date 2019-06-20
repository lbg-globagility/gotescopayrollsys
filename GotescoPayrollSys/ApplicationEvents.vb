Imports System.Threading
Imports MySql.Data.MySqlClient

Namespace My

    ' The following events are available for MyApplication:
    '
    ' Startup: Raised when the application starts, before the startup form is created.
    ' Shutdown: Raised after all application forms are closed.  This event is not raised if the application terminates abnormally.
    ' UnhandledException: Raised if the application encounters an unhandled exception.
    ' StartupNextInstance: Raised when launching a single-instance application and the application is already active.
    ' NetworkAvailabilityChanged: Raised when the network connection is connected or disconnected.

    Partial Friend Class MyApplication

        Protected Overrides Sub Finalize()
            MyBase.Finalize()
        End Sub

        Private Sub MyApplication_NetworkAvailabilityChanged(sender As Object, e As Devices.NetworkAvailableEventArgs) Handles Me.NetworkAvailabilityChanged

        End Sub

        Private Sub MyApplication_Shutdown(sender As Object, e As EventArgs) Handles Me.Shutdown

            Thread.Sleep(1000)

            Dim n_ExecuteQuery As _
                New ExecuteQuery("UPDATE user" &
                                 " SET InSession='0'" &
                                 ",LastUpd=CURRENT_TIMESTAMP()" &
                                 ",LastUpdBy='" & user_row_id & "'" &
                                 " WHERE RowID='" & user_row_id & "';")

            If MachineLocalization IsNot Nothing Then

                Thread.Sleep(1000)

                Try

                    For Each drow As DataRow In MachineLocalization.Rows

                        For Each dcol As DataColumn In MachineLocalization.Columns

                            'rKey.SetValue(dcol.ColumnName, drow(dcol.ColumnName).ToString)

                        Next

                        Thread.Sleep(100)

                    Next
                Catch ex As Exception
                    MsgBox(ex, MyBase.ToString)
                Finally
                    MachineLocalization.Dispose()

                End Try

            End If

        End Sub

        'Dim rKey As RegistryKey = Registry.CurrentUser.OpenSubKey("Control Panel\International", True)

        Public MachineLocalization As New DataTable

        Private Sub MyApplication_Startup(sender As Object, e As ApplicationServices.StartupEventArgs) Handles Me.Startup

            Try
                conn = New MySqlConnection

                conn.ConnectionString = n_DataBaseConnection.GetStringMySQLConnectionString

                hasERR = 0
            Catch ex As Exception

                hasERR = 1

                MsgBox(getErrExcptn(ex, "Namespace_My") & vbNewLine & " MyApplication_Startup", MsgBoxStyle.Information, "Server Connection")
            Finally

                If hasERR = 0 Then
                    EXECQUER("CALL SET_group_concat_max_len();")

                End If

                Dim str_fill_datadictionary_query As String =
                    String.Concat("INSERT INTO `", sys_db, "`.`datadictionary`",
                                  "(`SPECIFIC_NAME`",
                                  ", `ORDINAL_POSITION`",
                                  ", `PARAMETER_MODE`",
                                  ", `PARAMETER_NAME`",
                                  ", `DATA_TYPE`",
                                  ", `CHARACTER_MAXIMUM_LENGTH`",
                                  ", `CHARACTER_OCTET_LENGTH`",
                                  ", `NUMERIC_PRECISION`",
                                  ", `NUMERIC_SCALE`",
                                  ", `DATETIME_PRECISION`",
                                  ", `CHARACTER_SET_NAME`",
                                  ", `COLLATION_NAME`",
                                  ", `DTD_IDENTIFIER`",
                                  ", `ROUTINE_TYPE`)",
                                  " SELECT ii.`SPECIFIC_NAME`",
                                  ", ii.`ORDINAL_POSITION`",
                                  ", ii.`PARAMETER_MODE`",
                                  ", ii.`PARAMETER_NAME`",
                                  ", ii.`DATA_TYPE`",
                                  ", ii.`CHARACTER_MAXIMUM_LENGTH`",
                                  ", ii.`CHARACTER_OCTET_LENGTH`",
                                  ", ii.`NUMERIC_PRECISION`",
                                  ", ii.`NUMERIC_SCALE`",
                                  ", ii.`DATETIME_PRECISION`",
                                  ", ii.`CHARACTER_SET_NAME`",
                                  ", ii.`COLLATION_NAME`",
                                  ", ii.`DTD_IDENTIFIER`",
                                  ", ii.`ROUTINE_TYPE`",
                                  " FROM information_schema.PARAMETERS ii",
                                  " WHERE ii.`SPECIFIC_SCHEMA`='", sys_db, "'",
                                  " AND ii.PARAMETER_NAME IS NOT NULL",
                                  " ON DUPLICATE KEY UPDATE `ORDINAL_POSITION`=ii.`ORDINAL_POSITION`;")

                Dim n_ExecuteQuery As New ExecuteQuery(str_fill_datadictionary_query, 1024)

            End Try

            '    With MachineLocalization.Columns
            '        .Add("Locale")
            '        .Add("LocaleName")
            '        .Add("s1159")
            '        .Add("s2359")
            '        .Add("sCountry")
            '        .Add("sCurrency")
            '        .Add("sDate")
            '        .Add("sDecimal")
            '        .Add("sGrouping")
            '        .Add("sLanguage")
            '        .Add("sList")
            '        .Add("sLongDate")
            '        .Add("sMonDecimalSep")
            '        .Add("sMonGrouping")
            '        .Add("sMonThousandSep")
            '        .Add("sNativeDigits")
            '        .Add("sNegativeSign")
            '        .Add("sPositiveSign")
            '        .Add("sShortDate")
            '        .Add("sThousand")
            '        .Add("sTime")
            '        .Add("sTimeFormat")
            '        .Add("sShortTime")
            '        .Add("sYearMonth")
            '        .Add("iCalendarType")
            '        .Add("iCountry")
            '        .Add("iCurrDigits")
            '        .Add("iCurrency")
            '        .Add("iDate")
            '        .Add("iDigits")
            '        .Add("NumShape")
            '        .Add("iFirstDayOfWeek")
            '        .Add("iFirstWeekOfYear")
            '        .Add("iLZero")
            '        .Add("iMeasure")
            '        .Add("iNegCurr")
            '        .Add("iNegNumber")
            '        .Add("iPaperSize")
            '        .Add("iTime")
            '        .Add("iTimePrefix")
            '        .Add("iTLZero")

            '    End With

            '    Try

            '        Dim theValue As New List(Of String)

            '        For Each rk In rKey.GetValueNames

            '            Dim r_Key = rKey

            '            theValue.Add(r_Key.GetValue(rk.ToString))

            '        Next

            '        MachineLocalization.Rows.Add(theValue.ToArray())

            '    Catch ex As Exception
            '        MsgBox(ex, MyBase.ToString)

            '    End Try

            '    Try

            '        With rKey
            '            .SetValue("Locale", "00000409")
            '            .SetValue("LocaleName", "en-US")
            '            .SetValue("s1159", "AM")
            '            .SetValue("s2359", "PM")
            '            .SetValue("sCountry", "United States")
            '            .SetValue("sCurrency", "$")
            '            .SetValue("sDate", "/")
            '            .SetValue("sDecimal", ".")
            '            .SetValue("sGrouping", "3;0")
            '            .SetValue("sLanguage", "ENU")
            '            .SetValue("sList", ",")
            '            .SetValue("sLongDate", "dddd, MMMM dd, yyyy")
            '            .SetValue("sMonDecimalSep", ".")
            '            .SetValue("sMonGrouping", "3;0")
            '            .SetValue("sMonThousandSep", ",")
            '            .SetValue("sNativeDigits", "123456789")
            '            .SetValue("sNegativeSign", "-")
            '            .SetValue("sPositiveSign", "")
            '            .SetValue("sShortDate", machineShortDateFormat)
            '            .SetValue("sThousand", ",")
            '            .SetValue("sTime", ":")
            '            .SetValue("sTimeFormat", "h:mm:ss tt")
            '            .SetValue("sShortTime", "h:mm tt")
            '            .SetValue("sYearMonth", "MMMM, yyyy")
            '            .SetValue("iCalendarType", "1")
            '            .SetValue("iCountry", "1")
            '            .SetValue("iCurrDigits", "2")
            '            .SetValue("iCurrency", "0")
            '            .SetValue("iDate", "0")
            '            .SetValue("iDigits", "2")
            '            .SetValue("NumShape", "1")
            '            .SetValue("iFirstDayOfWeek", "6")
            '            .SetValue("iFirstWeekOfYear", "0")
            '            .SetValue("iLZero", "1")
            '            .SetValue("iMeasure", "1")
            '            .SetValue("iNegCurr", "0")
            '            .SetValue("iNegNumber", "1")
            '            .SetValue("iPaperSize", "1")
            '            .SetValue("iTime", "0")
            '            .SetValue("iTimePrefix", "0")
            '            .SetValue("iTLZero", "0")

            '        End With

            '    Catch ex As Exception
            '        MsgBox(ex, MyBase.ToString)

            '    Finally

            custom_mysqldateformat = "%" & machineShortDateFormat.Replace("/", "/%")

            custom_mysqldateformat = custom_mysqldateformat.ToLower

            If custom_mysqldateformat.Contains("yyyy") Then
                custom_mysqldateformat = custom_mysqldateformat.Replace("yyyy", "Y")
            ElseIf custom_mysqldateformat.Contains("yy") Then
                custom_mysqldateformat = custom_mysqldateformat.Replace("yy", "Y")
            End If

            If custom_mysqldateformat.Contains("mm") Then
                custom_mysqldateformat = custom_mysqldateformat.Replace("mm", "c")

            ElseIf custom_mysqldateformat.Contains("m") Then
                custom_mysqldateformat = custom_mysqldateformat.Replace("m", "c")

            End If

            If custom_mysqldateformat.Contains("dd") Then
                custom_mysqldateformat = custom_mysqldateformat.Replace("dd", "e")

            ElseIf custom_mysqldateformat.Contains("d") Then
                custom_mysqldateformat = custom_mysqldateformat.Replace("d", "e")

            End If

            'CURDATE_MDY = "SELECT DATE_FORMAT(CURDATE(),'" & custom_mysqldateformat & "');"
            'CURDATE_MDY = "SELECT CURDATE();"

            '    End Try

            'End Try

        End Sub

        Private Sub MyApplication_StartupNextInstance(sender As Object, e As ApplicationServices.StartupNextInstanceEventArgs) Handles Me.StartupNextInstance

            'With rKey

            '    Dim machineLocal = .GetValue("Locale")

            '    If machineLocal = "00000409" Then

            '        If MachineLocalization IsNot Nothing Then

            '            MachineLocalization.Rows.Clear()

            '        End If

            '    End If

            'End With

        End Sub

        Private Sub MyApplication_UnhandledException(sender As Object, e As ApplicationServices.UnhandledExceptionEventArgs) Handles Me.UnhandledException

            _logger.Error("MyApplication_UnhandledException", e.Exception)

        End Sub

    End Class

End Namespace