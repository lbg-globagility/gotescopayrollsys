Public Class MetroLogin

    'Public n_FileObserver As New FileObserver(sys_apppath)

    Protected Overrides Sub OnLoad(e As EventArgs)
        'GWSI
        'gw0001

        'FINANCE1
        '9988

        Console.WriteLine(DecrypedData("ÌÔÚÑÉººº¶"))
        Console.WriteLine(DecrypedData("¶·¸¹"))

        'A01274
        '1234

        'dbconn()

        ReloadOrganization()

        'Dim thisfilepath = "D:\Visual Studio 2013 project\GotescoPayrollSys\GotescoPayrollSys\bin\Debug"

        'Dim files() = Directory.GetFiles(thisfilepath, "*.*")

        'For Each strval In files
        '    File.AppendAllText("C:\Users\GLOBAL-D-PC\Desktop\gotescobindebug.txt", strval & Environment.NewLine)
        'Next

        MyBase.OnLoad(e)

    End Sub

    Protected Overrides Function ProcessCmdKey(ByRef msg As Message, keyData As Keys) As Boolean

        If keyData = Keys.Escape Then

            Close()

            Return True

            'ElseIf keyData = Keys.Oem5 Then

            '    Static thrice As Integer = -1

            '    thrice += 1

            '    If thrice = 5 Then

            '        thrice = 0

            '        'Dim n_ShiftTemplater As _
            '        '    New ShiftTemplater

            '        'n_ShiftTemplater.Show()
            '        Dim n_TrialForm As _
            '            New TrialForm

            '        n_TrialForm.Show()

            '    End If

            '    Return False
        Else

            Return MyBase.ProcessCmdKey(msg, keyData)

        End If

    End Function

    Private Sub MetroLogin_FormClosing(sender As Object, e As FormClosingEventArgs) Handles Me.FormClosing

        'n_FileObserver.Undetect()

        Application.Exit()

    End Sub

    Private Sub MetroLogin_Load(sender As Object, e As EventArgs) Handles Me.Load
        'Dim datenow = CDate(New ExecuteQuery(CURDATE_MDY).Result)

        'CustomDatePicker1.Value = datenow

    End Sub

    Private Sub Login_KeyPress(sender As Object, e As KeyPressEventArgs) Handles txtbxPword.KeyPress,
                                                                                    txtbxUserID.KeyPress,
                                                                                    cbxorganiz.KeyPress

        Dim e_asc = Asc(e.KeyChar)

        If e_asc = 13 Then

            btnlogin_Click(btnlogin, New EventArgs)

        End If

    End Sub

    Private Const err_log_limit As SByte = 3

    Private Sub btnlogin_Click(sender As Object, e As EventArgs) Handles btnlogin.Click

        user_row_id = UserAuthentication()

        Static err_count As SByte = 0

        If user_row_id > 0 Then

            If cbxorganiz.SelectedIndex = -1 Then

                WarnBalloon("Please select a company.", "Invalid company", btnlogin, btnlogin.Width - 18, -69)

                cbxorganiz.Focus()

                Exit Sub

            End If

            err_count = 0

            Dim userFNameLName = EXECQUER("SELECT CONCAT(COALESCE(FirstName,'.'),',',COALESCE(LastName,'.')) FROM user WHERE RowID='" & user_row_id & "';")

            Dim splitFNameLName = Split(userFNameLName, ",")

            userFirstName = splitFNameLName(0).ToString.Replace(".", "")

            If userFirstName = "" Then
            Else
                userFirstName = StrConv(userFirstName, VbStrConv.ProperCase)

            End If

            userLastName = splitFNameLName(1).ToString.Replace(".", "")

            If userLastName = "" Then
            Else
                userLastName = StrConv(userLastName, VbStrConv.ProperCase)

            End If

            If dbnow = Nothing Then

                dbnow = EXECQUER(CURDATE_MDY)

            End If

            Static freq As Integer = -1

            If cbxorganiz.SelectedIndex <> -1 Then

                numofdaysthisyear = EXECQUER("SELECT DAYOFYEAR(LAST_DAY(CONCAT(YEAR(CURRENT_DATE()),'-12-01')));")

                If freq <> org_rowid Then
                    freq = org_rowid

                End If

                position_view_table =
                    New SQLQueryToDatatable("SELECT *" &
                                            " FROM position_view" &
                                            " WHERE PositionID=(SELECT PositionID FROM user WHERE RowID=" & user_row_id & ")" &
                                            " AND OrganizationID='" & org_rowid & "';").ResultTable

                Dim i = position_view_table.Rows.Count

            End If

            z_postName = EXECQUER("SELECT p.PositionName FROM user u INNER JOIN position p ON p.RowID=u.PositionID WHERE u.RowID='" & user_row_id & "';")

            If org_rowid <> Nothing Then

                MDIPrimaryForm.Show()

            End If
        Else
            'WarnBalloon("Please input your correct credentials.", "Invalid credentials", btnlogin, btnlogin.Width - 18, -69)

            Dim n_BalloonToolTipShower As _
              New BalloonToolTipShower(BalloonToolTip,
                                       "Please input your correct credentials.",
                                       "Invalid credentials",
                                       btnlogin,
                                       btnlogin.Width - 18,
                                       -69)

            txtbxUserID.Focus()

            err_count += 1

            If (err_log_limit > err_count) = False Then

                Close()

            End If

        End If

    End Sub

    Function UserAuthentication() As Integer

        Dim returnvalue As Integer = 0

        'Dim params(1, 2) As Object

        'params(0, 0) = "user_name"
        'params(1, 0) = "pass_word"

        'Dim n_EncryptData As New EncryptData(txtbxUserID.Text)

        'params(0, 1) = n_EncryptData.ResultValue

        'n_EncryptData = New EncryptData(txtbxPword.Text)

        'params(1, 1) = n_EncryptData.ResultValue

        Dim returnobj = Nothing
        'EXEC_INSUPD_PROCEDURE(params,
        '                      "UserAuthentication",
        '                      "returnvaue")

        Dim n_ReadSQLFunction As New ReadSQLFunction("UserAuthentication",
                                                     "returnvaue",
                                                     New EncryptData(txtbxUserID.Text).ResultValue,
                                                     New EncryptData(txtbxPword.Text).ResultValue)

        returnobj = n_ReadSQLFunction.ReturnValue

        returnvalue = ValNoComma(returnobj)

        Return returnvalue

    End Function

    Private Sub cbxorganiz_SelectedIndexChanged(sender As Object, e As EventArgs) Handles cbxorganiz.SelectedIndexChanged

        PhotoImages.Image = Nothing

        orgNam = cbxorganiz.Text

        z_CompanyName = orgNam

        ''orgztnID = EXECQUER("SELECT RowID FROM organization WHERE Name='" & orgNam & "' LIMIT 1;")

        org_rowid = cbxorganiz.SelectedValue

        z_OrganizationID = ValNoComma(org_rowid)

        Dim org_emblem As New DataTable

        Dim n_SQLQueryToDatatable As New SQLQueryToDatatable("SELECT Image FROM organization WHERE RowID='" & org_rowid & "' AND Image IS NOT NULL;")

        org_emblem = n_SQLQueryToDatatable.ResultTable

        If org_emblem.Rows.Count <> 0 Then

            PhotoImages.Image = ConvertByteToImage(org_emblem.Rows(0)("Image"))

        End If

    End Sub

    Private Sub cbxorganiz_SelectedValueChanged(sender As Object, e As EventArgs) Handles cbxorganiz.SelectedValueChanged

    End Sub

    Private Sub MetroLink1_Click(sender As Object, e As EventArgs) Handles MetroLink1.Click

        Dim n_ForgotPasswordForm As New ForgotPasswordForm

        n_ForgotPasswordForm.ShowDialog()

        'ForgotPasswordForm.Show()

        'MsgBox(Convert.ToBoolean("1"))

        'cbxorganiz.Enabled = Convert.ToBoolean("1")

        ''MsgBox(Convert.ToBoolean("0").ToString)

        'cbxorganiz.Enabled = Convert.ToBoolean("0")

        'Dim dialog_box = MessageBox.Show("Come on", "", MessageBoxButtons.YesNoCancel)

        'If dialog_box = Windows.Forms.DialogResult.Yes Then
        '    cbxorganiz.Enabled = Convert.ToBoolean(1)
        'Else
        '    cbxorganiz.Enabled = Convert.ToBoolean(0)
        'End If

    End Sub

    Private Sub MetroLogin_Resize(sender As Object, e As EventArgs) Handles Me.Resize

    End Sub

    Sub ReloadOrganization()

        Dim strQuery As String = "SELECT RowID,Name FROM organization WHERE NoPurpose='0' ORDER BY Name;"

        Static once As SByte = 0

        If once = 0 Then

            once = 1

            Dim n_SQLQueryToDatatable As New SQLQueryToDatatable(strQuery)

            cbxorganiz.ValueMember = n_SQLQueryToDatatable.ResultTable.Columns(0).ColumnName

            cbxorganiz.DisplayMember = n_SQLQueryToDatatable.ResultTable.Columns(1).ColumnName

            cbxorganiz.DataSource = n_SQLQueryToDatatable.ResultTable
        Else

            Dim isThereSomeNewToOrganization =
                EXECQUER("SELECT EXISTS(SELECT RowID FROM organization WHERE DATE_FORMAT(Created,'%Y-%m-%d')=CURDATE() OR DATE_FORMAT(LastUpd,'%Y-%m-%d')=CURDATE() LIMIT 1);")

            If isThereSomeNewToOrganization = "1" Then

                Dim n_SQLQueryToDatatable As New SQLQueryToDatatable(strQuery)

                cbxorganiz.ValueMember = n_SQLQueryToDatatable.ResultTable.Columns(0).ColumnName

                cbxorganiz.DisplayMember = n_SQLQueryToDatatable.ResultTable.Columns(1).ColumnName

                cbxorganiz.DataSource = n_SQLQueryToDatatable.ResultTable
            Else

            End If

        End If

    End Sub

    Private Sub lnklblleave_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles lnklblleave.LinkClicked

        Dim n_LeaveForm As New LeaveForm

        With n_LeaveForm

            .CboListOfValue1.Visible = False

            .Label3.Visible = False

            .Label4.Visible = False

            .Show()

        End With

    End Sub

    Private Sub lnklblovertime_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles lnklblovertime.LinkClicked

        Dim n_OverTimeForm As New OverTimeForm

        With n_OverTimeForm

            .cboOTStatus.Visible = False

            .Label186.Visible = False

            .Label4.Visible = False

            .Show()

        End With

    End Sub

    Private Sub lnklblobf_LinkClicked(sender As Object, e As LinkLabelLinkClickedEventArgs) Handles lnklblobf.LinkClicked

        Dim n_OBFForm As New OBFForm

        With n_OBFForm

            .cboOBFStatus.Visible = False

            .Label186.Visible = False

            .Label4.Visible = False

            .Show()

        End With

    End Sub

    Private Function CustomDatePicker1() As Object
        Throw New NotImplementedException
    End Function

    Private Sub PhotoImages_Click(sender As Object, e As EventArgs) Handles PhotoImages.Click
        txtbxUserID.Focus()
    End Sub

    Private Sub txtbxUserID_Click(sender As Object, e As EventArgs) Handles txtbxUserID.Click

    End Sub

End Class

Friend Class EncryptData

    Dim n_ResultValue = Nothing

    Property ResultValue As Object

        Get
            Return n_ResultValue

        End Get

        Set(value As Object)
            n_ResultValue = value

        End Set

    End Property

    Sub New(StringToEncrypt As String)

        n_ResultValue = EncrypedData(StringToEncrypt)

    End Sub

    Private Function EncrypedData(ByVal a As String)

        Dim Encryped = Nothing

        If Not a Is Nothing Then

            For Each x As Char In a

                Dim ToCOn As Integer = Convert.ToInt64(x) + 133

                Encryped &= Convert.ToChar(Convert.ToInt64(ToCOn))

            Next

        End If

        Return Encryped

    End Function

End Class