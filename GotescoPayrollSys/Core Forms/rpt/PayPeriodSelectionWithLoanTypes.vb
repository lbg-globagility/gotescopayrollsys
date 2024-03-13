Public Class PayPeriodSelectionWithLoanTypes
    Inherits PayrollSummaDateSelection

    Private _loanTypeId As Object

    Public ReadOnly Property LoanTypeId As Object

        Get
            Return _loanTypeId
        End Get

    End Property

    Private Sub PayPeriodSelectionWithLoanTypes_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        LoadLoanTypes()
    End Sub

    Private Sub LoadLoanTypes()
        Dim params = New Object() {org_rowid}
        Dim strQuery =
            String.Concat("SELECT NULL `RowID`, 'ALL' `PartNo`",
                          " UNION SELECT p.RowID, p.PartNo FROM category c INNER JOIN product p ON p.CategoryID=c.RowID WHERE c.OrganizationID=?og_rowid AND c.CategoryName='Loan Type' AND p.ActiveData=TRUE")
        Dim query = $"SELECT i.* FROM ({strQuery}) i ORDER BY FIELD(ISNULL(i.`RowID`), TRUE, FALSE), i.PartNo;"
        Dim sql As New SQL(query, params)

        Dim dt As New DataTable
        dt = sql.GetFoundRows.Tables.OfType(Of DataTable).First

        cboxLoanTypes.ValueMember = "RowID"
        cboxLoanTypes.DisplayMember = "PartNo"
        cboxLoanTypes.DataSource = dt
    End Sub

    Private Sub cboxLoanTypes_SelectedIndexChanged(sender As Object, e As EventArgs) Handles cboxLoanTypes.SelectedIndexChanged
        _loanTypeId = cboxLoanTypes.SelectedValue

        Console.WriteLine(IsDBNull(_loanTypeId))
    End Sub

    Private Sub cboxLoanTypes_DropDown(sender As Object, e As EventArgs) Handles cboxLoanTypes.DropDown

        Static once As Boolean = False

        If once = False Then
            once = True
        Else
            Exit Sub
        End If

        Static cb_font As Font = cboxLoanTypes.Font

        'Dim cb_width As Integer = cboxLoanTypes.DropDownWidth

        Dim grp As Graphics = cboxLoanTypes.CreateGraphics()

        Dim vertScrollBarWidth As Integer = If(cboxLoanTypes.Items.Count > cboxLoanTypes.MaxDropDownItems, SystemInformation.VerticalScrollBarWidth, 0)

        Dim wiidth As Integer = 0

        Dim data_source As New DataTable

        data_source = cboxLoanTypes.DataSource

        Dim i = 0

        Dim drp_downwidhths As Integer()

        'Try

        '    ReDim drp_downwidhths(cboxLoanTypes.Items.Count - 1)

        'Catch ex As Exception

        'ReDim drp_downwidhths(data_source.Rows.Count - 1)
        ReDim drp_downwidhths(data_source.Rows.Count)

        'End Try

        For Each strRow As DataRow In data_source.Rows

            wiidth = CInt(grp.MeasureString(CStr(strRow(1)), cb_font).Width) + vertScrollBarWidth

            drp_downwidhths(i) = wiidth

            'If cb_width < wiidth Then
            '    wiidth = wiidth
            'End If

            i += 1

        Next

        Dim max_drp_downwidhth As Integer = 0

        Try
            max_drp_downwidhth = drp_downwidhths.Max
        Catch ex As Exception
            max_drp_downwidhth = cboxLoanTypes.Width
        Finally
            cboxLoanTypes.DropDownWidth = max_drp_downwidhth 'wiidth, cb_width

        End Try

    End Sub

End Class