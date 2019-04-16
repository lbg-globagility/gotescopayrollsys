Imports Microsoft.Win32

Public Class DataBaseConnection

    Dim regKey As RegistryKey

    Dim n_NameOfServer As String = String.Empty

    Property NameOfServer As String

        Get
            Return n_NameOfServer

        End Get

        Set(value As String)
            n_NameOfServer = value

        End Set

    End Property

    Dim n_IDOfUser As String = String.Empty

    Property IDOfUser As String
        Get
            Return n_IDOfUser

        End Get

        Set(value As String)
            n_IDOfUser = value

        End Set

    End Property

    Dim n_PasswordOfDatabase As String = String.Empty

    Property PasswordOfDatabase As String
        Get
            Return n_PasswordOfDatabase

        End Get

        Set(value As String)
            n_PasswordOfDatabase = value

        End Set

    End Property

    Dim n_NameOfDatabase As String = String.Empty

    Property NameOfDatabase As String
        Get
            Return n_NameOfDatabase

        End Get

        Set(value As String)
            n_NameOfDatabase = value

        End Set

    End Property

    Function GetStringMySQLConnectionString() As String

        Dim ver As String = String.Empty

        Dim connstringresult As String = String.Empty

        Try

            regKey = Registry.LocalMachine.OpenSubKey("Software\Globagility\DBConn\Gotesco", True)

            If regKey Is Nothing Then

                regKey = Registry.LocalMachine.OpenSubKey("SOFTWARE", True)

                regKey.CreateSubKey("Globagility\DBConn\Gotesco")

                regKey = Registry.LocalMachine.OpenSubKey("Software\Globagility\DBConn\Gotesco", True)

                regKey.SetValue("server", "localhost")

                regKey.SetValue("user id", "root")

                regKey.SetValue("password", "globagility")

                regKey.SetValue("database", "gotescopayrolldb")

            End If

            Dim fields = {Convert.ToString(regKey.GetValue("server")),
                Convert.ToString(regKey.GetValue("user id")),
                Convert.ToString(regKey.GetValue("password")),
                Convert.ToString(regKey.GetValue("database"))}

            sys_servername = fields.FirstOrDefault

            sys_userid = fields(1)

            sys_password = fields(2)

            sys_db = fields.LastOrDefault

            installerpath = sys_apppath

            n_NameOfServer = sys_servername
            n_IDOfUser = sys_userid
            n_PasswordOfDatabase = sys_password
            n_NameOfDatabase = sys_db

            connstringresult =
                String.Join(";", {$"server={sys_servername}", $"user id={sys_userid}", $"password={sys_password}", $"database={sys_db}", String.Empty})

            db_connectinstring = connstringresult

        Catch ex As Exception
            MsgBox(getErrExcptn(ex, "DataBaseConnection"))

        Finally
            regKey.Close()

        End Try

        Return connstringresult

    End Function

End Class