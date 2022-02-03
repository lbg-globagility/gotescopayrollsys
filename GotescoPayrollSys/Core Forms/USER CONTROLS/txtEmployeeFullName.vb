Public Class txtEmployeeFullName

    'Inherits TextBox
    Inherits Femiani.Forms.UI.Input.CoolTextBox

    Private organization_RowID As String = String.Empty

    Sub New()
        organization_RowID = org_rowid
    End Sub

    Dim dbcol_employee As String = String.Empty

    Public Property EmployeeTableColumnName As String

        Get
            Return dbcol_employee

        End Get

        Set(value As String)
            dbcol_employee = value

        End Set

    End Property

    Dim n_Exists As Boolean = False

    Public ReadOnly Property Exists As Boolean

        Get

            Return n_Exists

        End Get

    End Property

    Dim n_RowIDValue As String = String.Empty

    Public ReadOnly Property RowIDValue As String

        Get

            Return n_RowIDValue

        End Get

    End Property

    'Protected Overrides Sub OnTextChanged(e As EventArgs)
    '    MyBase.OnTextChanged(e)
    'End Sub

    Protected Overrides Sub OnLeave(e As EventArgs)
        If DesignMode Then Return

        Dim strQuery = $"SELECT COUNT(e.RowID)
FROM employee e
INNER JOIN organization og ON og.RowID=e.OrganizationID AND og.NoPurpose=FALSE
WHERE {dbcol_employee}='{Text}'
AND e.EmploymentStatus NOT IN ('Resigned','Terminated');"

        Dim isExistCount =
            EXECQUER(strQuery)

        Static once As String = String.Empty

        If once <> MyBase.Text Then
            once = MyBase.Text
        Else
        End If

        If ValNoComma(isExistCount) > 1 Then

            Dim n_OrganizationPrompt As New OrganizationPrompt

            n_OrganizationPrompt.EmployeeRowIDValue = MyBase.Text
            'n_OrganizationPrompt.OrganizationTableColumnName = "CONCAT(e.LastName,', ',e.FirstName,IF(e.MiddleName = '', '', CONCAT(', ',e.MiddleName)))"
            n_OrganizationPrompt.OrganizationTableColumnName = "CONCAT_WS(', ', e.LastName, e.FirstName, IF(LENGTH(TRIM(e.MiddleName)) = 0, NULL, e.MiddleName))"

            Dim confirmOk = n_OrganizationPrompt.ShowDialog = DialogResult.OK

            If confirmOk Then

                organization_RowID = n_OrganizationPrompt.RowIDValue

                If organization_RowID = String.Empty Then

                    Me.Focus()

                End If
            Else
                Me.Focus()
                Return
            End If
        Else

            Dim str_quer As String =
                    SBConcat.ConcatResult("SELECT e.OrganizationID",
                                          " FROM employee e",
                                          " INNER JOIN organization og ON og.RowID=e.OrganizationID AND og.NoPurpose='0'",
                                          " WHERE ", dbcol_employee,
                                          " = ?search_text",
                                          " AND e.EmploymentStatus NOT IN ('Resigned','Terminated')",
                                          " GROUP BY e.OrganizationID, CONCAT(e.LastName, e.FirstName, e.MiddleName)",
                                          " HAVING MAX(e.Created) IS NOT NULL",
                                          " ORDER BY CONCAT(e.LastName, e.FirstName, e.MiddleName);")

            Dim sql As New SQL(str_quer,
                                   New Object() {MyBase.Text})

            organization_RowID = Convert.ToString(sql.GetFoundRow)

        End If

        Dim employeeQuery = "SELECT" &
                            " RowID" &
                            " FROM employee" &
                            " WHERE " & dbcol_employee & "='" & MyBase.Text & "'" &
                            " AND OrganizationID='" & organization_RowID & "'" &
                            " AND EmploymentStatus NOT IN ('Resigned','Terminated')"

        Dim isExists =
                EXECQUER("SELECT EXISTS(" & employeeQuery & ");")

        n_Exists = CBool(isExists)

        If n_Exists Then
            Dim str_quer As String =
                SBConcat.ConcatResult("SELECT e.RowID",
                                      " FROM employee e",
                                      " INNER JOIN organization og ON og.RowID=e.OrganizationID AND og.NoPurpose='0'",
                                      " WHERE ", dbcol_employee,
                                      " = ?search_text",
                                      " AND e.OrganizationID = ?og_rowid",
                                      " AND FIND_IN_SET(e.EmploymentStatus, UNEMPLOYEMENT_STATUSES()) = 0",
                                      " ORDER BY e.Created DESC, CONCAT(e.LastName, e.FirstName, e.MiddleName)",
                                      " LIMIT 1;")

            Dim sql As New SQL(str_quer,
                               New Object() {MyBase.Text,
                                             organization_RowID})

            n_RowIDValue = Convert.ToString(sql.GetFoundRow)
        Else
            n_RowIDValue = String.Empty

        End If

        MyBase.OnLeave(e)

    End Sub

End Class