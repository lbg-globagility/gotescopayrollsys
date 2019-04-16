
Public Class DataGridViewMySQLTable

    'Inherits DevComponents.DotNetBar.Controls.DataGridViewX

    'Dim DataGridViewCellStyle1 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()

    Sub New()

        ' This call is required by the designer.
        InitializeComponent()

        ' Add any initialization after the InitializeComponent() call.

        'With DataGridViewCellStyle1

        '    .Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        '    .BackColor = System.Drawing.SystemColors.Window
        '    .Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        '    .ForeColor = System.Drawing.SystemColors.ControlText
        '    .SelectionBackColor = System.Drawing.SystemColors.Highlight
        '    .SelectionForeColor = System.Drawing.SystemColors.ControlText
        '    .WrapMode = System.Windows.Forms.DataGridViewTriState.[False]

        'End With

        'dgv.DefaultCellStyle = DataGridViewCellStyle1

    End Sub

    Dim n_MySQLTableSource As String = String.Empty

    Property MySQLTableSource As String
        Get
            Return n_MySQLTableSource
        End Get
        Set(value As String)
            n_MySQLTableSource = value
        End Set
    End Property

    Dim n_AllowPagination As Boolean = False

    Property AllowPagination As Boolean
        Get
            Return n_AllowPagination
        End Get
        Set(value As Boolean)
            n_AllowPagination = value
            
            Panel1.Visible = n_AllowPagination

        End Set
    End Property

    Dim n_ViewProcedureName As String = String.Empty

    Property ViewProcedureName As String
        Get
            Return n_ViewProcedureName
        End Get
        Set(value As String)
            n_ViewProcedureName = value
        End Set
    End Property

    Dim n_ViewProcedureParameterValues As ArrayList

    Property ViewProcedureParameterValues As IEnumerable(Of String)
        Get
            Return n_ViewProcedureParameterValues
        End Get
        Set(value As IEnumerable(Of String))
            n_ViewProcedureParameterValues = value
        End Set
    End Property

    Dim pagination_GIVEN_PARAMETER_NAMES() As String = {"pagination", "pagenumber", "page", "page_number", "page_num"}

    Private Sub Pagination_HandlerControl(ByVal AddTheHandler As Boolean)

        Static once As SByte = 0

        If once = 0 And n_ViewProcedureName <> String.Empty Then

            'once = 1

            Dim mysqlTableColumnHeaders As _
                New SQLQueryToDatatable("SELECT ii.PARAMETER_NAME" &
                                        " FROM information_schema.PARAMETERS ii" &
                                        " WHERE ii.SPECIFIC_NAME = '" & n_ViewProcedureName & "'" &
                                        " AND ii.`SPECIFIC_SCHEMA`='" & "test" & "'" &
                                        " AND ii.PARAMETER_NAME IS NOT NULL;")

            Dim catchdt As New DataTable

            catchdt = mysqlTableColumnHeaders.ResultTable

            For Each drow As DataRow In catchdt.Rows
                If pagination_GIVEN_PARAMETER_NAMES.Contains(CStr(drow("PARAMETER_NAME"))) Then
                    AddTheHandler = True
                Else
                    AddTheHandler = False
                End If
            Next

        End If

        If AddTheHandler _
            And n_DisplayedRecordPerPage > -1 Then
            AddHandler lnkFirst.LinkClicked, AddressOf Pagination_Event
            AddHandler lnkPrev.LinkClicked, AddressOf Pagination_Event
            AddHandler lnkNext.LinkClicked, AddressOf Pagination_Event
            AddHandler lnkLast.LinkClicked, AddressOf Pagination_Event
        Else
            RemoveHandler lnkFirst.LinkClicked, AddressOf Pagination_Event
            RemoveHandler lnkPrev.LinkClicked, AddressOf Pagination_Event
            RemoveHandler lnkNext.LinkClicked, AddressOf Pagination_Event
            RemoveHandler lnkLast.LinkClicked, AddressOf Pagination_Event
        End If
    End Sub

    Dim n_DisplayedRecordPerPage As Integer = -1

    Property DisplayedRecordPerPage As Integer
        Get
            Return n_DisplayedRecordPerPage
        End Get
        Set(value As Integer)
            n_DisplayedRecordPerPage = value
        End Set
    End Property

    Dim mysqlTableColumnHeaders As _
        New SQLQueryToDatatable("SELECT ii.COLUMN_NAME,ii.COLUMN_COMMENT" &
                                " FROM information_schema.`COLUMNS` ii" &
                                " WHERE ii.TABLE_SCHEMA='" & "test" & "'" &
                                " AND ii.TABLE_NAME='" & n_MySQLTableSource & "'" &
                                " ORDER BY ii.ORDINAL_POSITION;")

    Dim tableColHeadrs As DataTable = mysqlTableColumnHeaders.ResultTable

    Dim catchdt As New DataTable

    Dim IsWorkingInRunTime As Boolean = False

    Protected Overrides Sub OnLoad(e As EventArgs)

        IsWorkingInRunTime = True

        If n_ViewProcedureName <> String.Empty Then

            Dim n_SQLQueryToDatatable As _
                New SQLQueryToDatatable("CALL " & "test" & "." & n_ViewProcedureName & "();")

            catchdt = n_SQLQueryToDatatable.ResultTable

            Static once As SByte = 0

            'If once = 0 Then

            '    once = 1

            For Each dcol As DataColumn In catchdt.Columns

                Dim colName As String = dcol.ColumnName

                Dim dsfd = tableColHeadrs.Select("COLUMN_NAME = '" & colName & "'")

                If dsfd.Count > 0 Then

                    Dim n_dgvColumn As New DataGridViewColumn

                    n_dgvColumn.Name = colName

                    n_dgvColumn.HeaderText = CStr(dsfd(0)(1))

                    n_dgvColumn.CellTemplate = New DataGridViewDateCell

                    dgv.Columns.Add(n_dgvColumn)

                Else
                    Continue For

                End If

            Next

            'End If

            DATALOADER(n_DisplayedRecordPerPage)

            'Static onetime As SByte = 0

            'If onetime = 0 Then

            '    onetime = 1

            AddHandler dgv.CellContentClick, AddressOf dgv_CellContentClick

            'End If

        End If

        MyBase.OnLoad(e)

    End Sub

    Private Sub DATALOADER(ByVal pag_num As Integer)

        If pag_num < 0 Then
            pag_num = 0
        End If

        If n_ViewProcedureName <> String.Empty Then

            Dim n_SQLQueryToDatatable As _
                New SQLQueryToDatatable("CALL " & "test" & "." & n_ViewProcedureName & "();")

            catchdt = New DataTable

            catchdt = n_SQLQueryToDatatable.ResultTable

            dgv.Rows.Clear()

            Dim first_index As Short = 0

            For Each drow As DataRow In catchdt.Rows

                Dim row_array = drow.ItemArray

                If first_index = 0 Then
                    first_index = 1
                    dgv.Tag = drow(0)
                End If

                dgv.Rows.Add(row_array)

            Next

        End If

    End Sub

    Private Sub dgv_CellContentClick(sender As Object, e As DataGridViewCellEventArgs)

        dgv.Tag = Nothing

        If e.ColumnIndex > -1 _
            And e.RowIndex > -1 Then

            dgv.Tag = dgv.Item(0, e.RowIndex).Value

        End If

    End Sub

    Private Sub Pagination_Event(sender As Object, e As LinkLabelLinkClickedEventArgs) 'Handles lnkFirst.LinkClicked, lnkPrev.LinkClicked, lnkNext.LinkClicked, lnkLast.LinkClicked

        Static page_number As Integer = 0

        Dim n_linklabel As New LinkLabel

        n_linklabel = DirectCast(sender, LinkLabel)

        If n_DisplayedRecordPerPage > 0 Then

            Select Case CInt(n_linklabel.Tag)
                Case 0
                    page_number = 0
                Case 1
                    If (page_number - n_DisplayedRecordPerPage) < 0 Then
                        page_number = 0
                    Else
                        page_number -= n_DisplayedRecordPerPage
                    End If
                Case 2
                    page_number += n_DisplayedRecordPerPage
                Case 3
                    MsgBox(n_linklabel.Name)
            End Select

        End If

    End Sub

    Private Sub Panel1_VisibleChanged(sender As Object, e As EventArgs) Handles Panel1.VisibleChanged

        Dim n_linklabel As New Panel

        n_linklabel = DirectCast(sender, Panel)

        If IsWorkingInRunTime Then
            Pagination_HandlerControl(n_linklabel.Visible)
        End If
        
    End Sub

End Class