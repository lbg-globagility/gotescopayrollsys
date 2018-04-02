<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class TimeEntryLogs
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Dim DataGridViewCellStyle4 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()
        Dim DataGridViewCellStyle5 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()
        Dim DataGridViewCellStyle6 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()
        Me.DataGridViewX1 = New DevComponents.DotNetBar.Controls.DataGridViewX()
        Me.Panel1 = New System.Windows.Forms.Panel()
        Me.Panel6 = New System.Windows.Forms.Panel()
        Me.lblYear = New System.Windows.Forms.Label()
        Me.NxtYear = New System.Windows.Forms.LinkLabel()
        Me.PrevYear = New System.Windows.Forms.LinkLabel()
        Me.Panel2 = New System.Windows.Forms.Panel()
        Me.Panel3 = New System.Windows.Forms.Panel()
        Me.DataGridViewX2 = New DevComponents.DotNetBar.Controls.DataGridViewX()
        Me.EId = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.EFullName = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.E_RowId = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Panel8 = New System.Windows.Forms.Panel()
        Me.Button1 = New System.Windows.Forms.Button()
        Me.TextBox1 = New System.Windows.Forms.TextBox()
        Me.Panel7 = New System.Windows.Forms.Panel()
        Me.Nxt = New System.Windows.Forms.LinkLabel()
        Me.Prev = New System.Windows.Forms.LinkLabel()
        Me.Last = New System.Windows.Forms.LinkLabel()
        Me.First = New System.Windows.Forms.LinkLabel()
        Me.Panel4 = New System.Windows.Forms.Panel()
        Me.Panel5 = New System.Windows.Forms.Panel()
        Me.DataGridViewX3 = New DevComponents.DotNetBar.Controls.DataGridViewX()
        Me.colTimeIn = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.colTimeOut = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.colDateValue = New DevComponents.DotNetBar.Controls.DataGridViewDateTimeInputColumn()
        Me.WasEdited = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.ToolStrip1 = New System.Windows.Forms.ToolStrip()
        Me.tsbtnNew = New System.Windows.Forms.ToolStripButton()
        Me.tsbtnSave = New System.Windows.Forms.ToolStripButton()
        Me.tsbtndel = New System.Windows.Forms.ToolStripButton()
        Me.tsbtnCancel = New System.Windows.Forms.ToolStripButton()
        Me.ToolStripLabel1 = New System.Windows.Forms.ToolStripLabel()
        Me.tsbtnImport = New System.Windows.Forms.ToolStripButton()
        Me.tsbtnClose = New System.Windows.Forms.ToolStripButton()
        Me.tsbtnAudittrail = New System.Windows.Forms.ToolStripButton()
        Me.ToolStripProgressBar1 = New System.Windows.Forms.ToolStripProgressBar()
        Me.Label2 = New System.Windows.Forms.Label()
        Me.Label3 = New System.Windows.Forms.Label()
        Me.Label1 = New System.Windows.Forms.Label()
        Me.bgworkTypicalImport = New System.ComponentModel.BackgroundWorker()
        Me.DataGridViewTextBoxColumn1 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.DataGridViewTextBoxColumn2 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.DataGridViewTextBoxColumn3 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.DataGridViewTextBoxColumn4 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.DataGridViewTextBoxColumn5 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.DataGridViewTextBoxColumn6 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        CType(Me.DataGridViewX1, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.Panel1.SuspendLayout()
        Me.Panel6.SuspendLayout()
        Me.Panel3.SuspendLayout()
        CType(Me.DataGridViewX2, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.Panel8.SuspendLayout()
        Me.Panel7.SuspendLayout()
        Me.Panel5.SuspendLayout()
        CType(Me.DataGridViewX3, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.ToolStrip1.SuspendLayout()
        Me.SuspendLayout()
        '
        'DataGridViewX1
        '
        Me.DataGridViewX1.AllowUserToAddRows = False
        Me.DataGridViewX1.AllowUserToDeleteRows = False
        Me.DataGridViewX1.AllowUserToResizeColumns = False
        Me.DataGridViewX1.AllowUserToResizeRows = False
        Me.DataGridViewX1.BackgroundColor = System.Drawing.Color.White
        Me.DataGridViewX1.ColumnHeadersHeight = 35
        Me.DataGridViewX1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing
        DataGridViewCellStyle4.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle4.BackColor = System.Drawing.SystemColors.Window
        DataGridViewCellStyle4.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        DataGridViewCellStyle4.ForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle4.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle4.SelectionForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle4.WrapMode = System.Windows.Forms.DataGridViewTriState.[False]
        Me.DataGridViewX1.DefaultCellStyle = DataGridViewCellStyle4
        Me.DataGridViewX1.Dock = System.Windows.Forms.DockStyle.Fill
        Me.DataGridViewX1.GridColor = System.Drawing.Color.FromArgb(CType(CType(208, Byte), Integer), CType(CType(215, Byte), Integer), CType(CType(229, Byte), Integer))
        Me.DataGridViewX1.Location = New System.Drawing.Point(0, 0)
        Me.DataGridViewX1.MultiSelect = False
        Me.DataGridViewX1.Name = "DataGridViewX1"
        Me.DataGridViewX1.ReadOnly = True
        Me.DataGridViewX1.RowHeadersWidthSizeMode = System.Windows.Forms.DataGridViewRowHeadersWidthSizeMode.DisableResizing
        Me.DataGridViewX1.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect
        Me.DataGridViewX1.Size = New System.Drawing.Size(255, 551)
        Me.DataGridViewX1.TabIndex = 157
        '
        'Panel1
        '
        Me.Panel1.Controls.Add(Me.DataGridViewX1)
        Me.Panel1.Controls.Add(Me.Panel6)
        Me.Panel1.Dock = System.Windows.Forms.DockStyle.Left
        Me.Panel1.Location = New System.Drawing.Point(0, 0)
        Me.Panel1.Name = "Panel1"
        Me.Panel1.Size = New System.Drawing.Size(255, 566)
        Me.Panel1.TabIndex = 158
        '
        'Panel6
        '
        Me.Panel6.Controls.Add(Me.lblYear)
        Me.Panel6.Controls.Add(Me.NxtYear)
        Me.Panel6.Controls.Add(Me.PrevYear)
        Me.Panel6.Dock = System.Windows.Forms.DockStyle.Bottom
        Me.Panel6.Location = New System.Drawing.Point(0, 551)
        Me.Panel6.Name = "Panel6"
        Me.Panel6.Size = New System.Drawing.Size(255, 15)
        Me.Panel6.TabIndex = 158
        '
        'lblYear
        '
        Me.lblYear.Dock = System.Windows.Forms.DockStyle.Fill
        Me.lblYear.Location = New System.Drawing.Point(28, 0)
        Me.lblYear.Name = "lblYear"
        Me.lblYear.Size = New System.Drawing.Size(199, 15)
        Me.lblYear.TabIndex = 0
        Me.lblYear.Text = "Label1"
        Me.lblYear.Visible = False
        '
        'NxtYear
        '
        Me.NxtYear.AccessibleDescription = "+1"
        Me.NxtYear.AutoSize = True
        Me.NxtYear.Dock = System.Windows.Forms.DockStyle.Right
        Me.NxtYear.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.NxtYear.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.NxtYear.Location = New System.Drawing.Point(227, 0)
        Me.NxtYear.Name = "NxtYear"
        Me.NxtYear.Size = New System.Drawing.Size(28, 15)
        Me.NxtYear.TabIndex = 154
        Me.NxtYear.TabStop = True
        Me.NxtYear.Text = ">>>"
        '
        'PrevYear
        '
        Me.PrevYear.AccessibleDescription = "-1"
        Me.PrevYear.AutoSize = True
        Me.PrevYear.Dock = System.Windows.Forms.DockStyle.Left
        Me.PrevYear.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.PrevYear.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.PrevYear.Location = New System.Drawing.Point(0, 0)
        Me.PrevYear.Name = "PrevYear"
        Me.PrevYear.Size = New System.Drawing.Size(28, 15)
        Me.PrevYear.TabIndex = 152
        Me.PrevYear.TabStop = True
        Me.PrevYear.Text = "<<<"
        '
        'Panel2
        '
        Me.Panel2.Dock = System.Windows.Forms.DockStyle.Left
        Me.Panel2.Location = New System.Drawing.Point(255, 0)
        Me.Panel2.Name = "Panel2"
        Me.Panel2.Size = New System.Drawing.Size(10, 566)
        Me.Panel2.TabIndex = 159
        '
        'Panel3
        '
        Me.Panel3.Controls.Add(Me.DataGridViewX2)
        Me.Panel3.Controls.Add(Me.Panel8)
        Me.Panel3.Controls.Add(Me.Panel7)
        Me.Panel3.Dock = System.Windows.Forms.DockStyle.Left
        Me.Panel3.Location = New System.Drawing.Point(265, 0)
        Me.Panel3.Name = "Panel3"
        Me.Panel3.Size = New System.Drawing.Size(341, 566)
        Me.Panel3.TabIndex = 160
        '
        'DataGridViewX2
        '
        Me.DataGridViewX2.AllowUserToAddRows = False
        Me.DataGridViewX2.AllowUserToDeleteRows = False
        Me.DataGridViewX2.AllowUserToResizeColumns = False
        Me.DataGridViewX2.AllowUserToResizeRows = False
        Me.DataGridViewX2.BackgroundColor = System.Drawing.Color.White
        Me.DataGridViewX2.ColumnHeadersHeight = 35
        Me.DataGridViewX2.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing
        Me.DataGridViewX2.Columns.AddRange(New System.Windows.Forms.DataGridViewColumn() {Me.EId, Me.EFullName, Me.E_RowId})
        DataGridViewCellStyle5.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle5.BackColor = System.Drawing.SystemColors.Window
        DataGridViewCellStyle5.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        DataGridViewCellStyle5.ForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle5.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle5.SelectionForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle5.WrapMode = System.Windows.Forms.DataGridViewTriState.[False]
        Me.DataGridViewX2.DefaultCellStyle = DataGridViewCellStyle5
        Me.DataGridViewX2.Dock = System.Windows.Forms.DockStyle.Fill
        Me.DataGridViewX2.GridColor = System.Drawing.Color.FromArgb(CType(CType(208, Byte), Integer), CType(CType(215, Byte), Integer), CType(CType(229, Byte), Integer))
        Me.DataGridViewX2.Location = New System.Drawing.Point(0, 41)
        Me.DataGridViewX2.MultiSelect = False
        Me.DataGridViewX2.Name = "DataGridViewX2"
        Me.DataGridViewX2.ReadOnly = True
        Me.DataGridViewX2.RowHeadersWidthSizeMode = System.Windows.Forms.DataGridViewRowHeadersWidthSizeMode.DisableResizing
        Me.DataGridViewX2.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect
        Me.DataGridViewX2.Size = New System.Drawing.Size(341, 510)
        Me.DataGridViewX2.TabIndex = 159
        '
        'EId
        '
        Me.EId.HeaderText = "Employee ID"
        Me.EId.Name = "EId"
        Me.EId.ReadOnly = True
        Me.EId.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.EId.Width = 149
        '
        'EFullName
        '
        Me.EFullName.HeaderText = "Full Name"
        Me.EFullName.Name = "EFullName"
        Me.EFullName.ReadOnly = True
        Me.EFullName.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.EFullName.Width = 149
        '
        'E_RowId
        '
        Me.E_RowId.HeaderText = "RowID"
        Me.E_RowId.Name = "E_RowId"
        Me.E_RowId.ReadOnly = True
        Me.E_RowId.Visible = False
        '
        'Panel8
        '
        Me.Panel8.Controls.Add(Me.Button1)
        Me.Panel8.Controls.Add(Me.TextBox1)
        Me.Panel8.Dock = System.Windows.Forms.DockStyle.Top
        Me.Panel8.Location = New System.Drawing.Point(0, 0)
        Me.Panel8.Name = "Panel8"
        Me.Panel8.Size = New System.Drawing.Size(341, 41)
        Me.Panel8.TabIndex = 161
        '
        'Button1
        '
        Me.Button1.Location = New System.Drawing.Point(266, 13)
        Me.Button1.Name = "Button1"
        Me.Button1.Size = New System.Drawing.Size(75, 20)
        Me.Button1.TabIndex = 1
        Me.Button1.Text = "&Refresh"
        Me.Button1.UseVisualStyleBackColor = True
        '
        'TextBox1
        '
        Me.TextBox1.Location = New System.Drawing.Point(0, 12)
        Me.TextBox1.Name = "TextBox1"
        Me.TextBox1.Size = New System.Drawing.Size(260, 20)
        Me.TextBox1.TabIndex = 0
        '
        'Panel7
        '
        Me.Panel7.Controls.Add(Me.Nxt)
        Me.Panel7.Controls.Add(Me.Prev)
        Me.Panel7.Controls.Add(Me.Last)
        Me.Panel7.Controls.Add(Me.First)
        Me.Panel7.Dock = System.Windows.Forms.DockStyle.Bottom
        Me.Panel7.Location = New System.Drawing.Point(0, 551)
        Me.Panel7.Name = "Panel7"
        Me.Panel7.Size = New System.Drawing.Size(341, 15)
        Me.Panel7.TabIndex = 160
        '
        'Nxt
        '
        Me.Nxt.AccessibleDescription = "1"
        Me.Nxt.AutoSize = True
        Me.Nxt.Dock = System.Windows.Forms.DockStyle.Right
        Me.Nxt.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Nxt.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.Nxt.Location = New System.Drawing.Point(258, 0)
        Me.Nxt.Name = "Nxt"
        Me.Nxt.Size = New System.Drawing.Size(39, 15)
        Me.Nxt.TabIndex = 156
        Me.Nxt.TabStop = True
        Me.Nxt.Text = "Next>"
        '
        'Prev
        '
        Me.Prev.AccessibleDescription = "-1"
        Me.Prev.AutoSize = True
        Me.Prev.Dock = System.Windows.Forms.DockStyle.Left
        Me.Prev.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Prev.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.Prev.Location = New System.Drawing.Point(44, 0)
        Me.Prev.Name = "Prev"
        Me.Prev.Size = New System.Drawing.Size(38, 15)
        Me.Prev.TabIndex = 155
        Me.Prev.TabStop = True
        Me.Prev.Text = "<Prev"
        '
        'Last
        '
        Me.Last.AutoSize = True
        Me.Last.Dock = System.Windows.Forms.DockStyle.Right
        Me.Last.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Last.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.Last.Location = New System.Drawing.Point(297, 0)
        Me.Last.Name = "Last"
        Me.Last.Size = New System.Drawing.Size(44, 15)
        Me.Last.TabIndex = 154
        Me.Last.TabStop = True
        Me.Last.Text = "Last>>"
        '
        'First
        '
        Me.First.AccessibleDescription = "0"
        Me.First.AutoSize = True
        Me.First.Dock = System.Windows.Forms.DockStyle.Left
        Me.First.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.First.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.First.Location = New System.Drawing.Point(0, 0)
        Me.First.Name = "First"
        Me.First.Size = New System.Drawing.Size(44, 15)
        Me.First.TabIndex = 152
        Me.First.TabStop = True
        Me.First.Text = "<<First"
        '
        'Panel4
        '
        Me.Panel4.Dock = System.Windows.Forms.DockStyle.Left
        Me.Panel4.Location = New System.Drawing.Point(606, 0)
        Me.Panel4.Name = "Panel4"
        Me.Panel4.Size = New System.Drawing.Size(10, 566)
        Me.Panel4.TabIndex = 161
        '
        'Panel5
        '
        Me.Panel5.Controls.Add(Me.DataGridViewX3)
        Me.Panel5.Controls.Add(Me.ToolStrip1)
        Me.Panel5.Controls.Add(Me.Label2)
        Me.Panel5.Controls.Add(Me.Label3)
        Me.Panel5.Controls.Add(Me.Label1)
        Me.Panel5.Dock = System.Windows.Forms.DockStyle.Fill
        Me.Panel5.Location = New System.Drawing.Point(616, 0)
        Me.Panel5.Name = "Panel5"
        Me.Panel5.Size = New System.Drawing.Size(653, 566)
        Me.Panel5.TabIndex = 162
        '
        'DataGridViewX3
        '
        Me.DataGridViewX3.AllowUserToDeleteRows = False
        Me.DataGridViewX3.AllowUserToResizeColumns = False
        Me.DataGridViewX3.AllowUserToResizeRows = False
        Me.DataGridViewX3.BackgroundColor = System.Drawing.Color.White
        Me.DataGridViewX3.ColumnHeadersHeight = 35
        Me.DataGridViewX3.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing
        Me.DataGridViewX3.Columns.AddRange(New System.Windows.Forms.DataGridViewColumn() {Me.colTimeIn, Me.colTimeOut, Me.colDateValue, Me.WasEdited})
        DataGridViewCellStyle6.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle6.BackColor = System.Drawing.SystemColors.Window
        DataGridViewCellStyle6.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        DataGridViewCellStyle6.ForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle6.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle6.SelectionForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle6.WrapMode = System.Windows.Forms.DataGridViewTriState.[False]
        Me.DataGridViewX3.DefaultCellStyle = DataGridViewCellStyle6
        Me.DataGridViewX3.Dock = System.Windows.Forms.DockStyle.Fill
        Me.DataGridViewX3.GridColor = System.Drawing.Color.FromArgb(CType(CType(208, Byte), Integer), CType(CType(215, Byte), Integer), CType(CType(229, Byte), Integer))
        Me.DataGridViewX3.Location = New System.Drawing.Point(0, 25)
        Me.DataGridViewX3.Name = "DataGridViewX3"
        Me.DataGridViewX3.RowHeadersWidthSizeMode = System.Windows.Forms.DataGridViewRowHeadersWidthSizeMode.DisableResizing
        Me.DataGridViewX3.Size = New System.Drawing.Size(653, 541)
        Me.DataGridViewX3.TabIndex = 160
        '
        'colTimeIn
        '
        Me.colTimeIn.HeaderText = "Time In"
        Me.colTimeIn.Name = "colTimeIn"
        Me.colTimeIn.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.colTimeIn.Width = 203
        '
        'colTimeOut
        '
        Me.colTimeOut.HeaderText = "Time Out"
        Me.colTimeOut.Name = "colTimeOut"
        Me.colTimeOut.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.colTimeOut.Width = 204
        '
        'colDateValue
        '
        '
        '
        '
        Me.colDateValue.BackgroundStyle.BackColor = System.Drawing.SystemColors.Window
        Me.colDateValue.BackgroundStyle.Class = "DataGridViewDateTimeBorder"
        Me.colDateValue.BackgroundStyle.CornerType = DevComponents.DotNetBar.eCornerType.Square
        Me.colDateValue.BackgroundStyle.TextColor = System.Drawing.SystemColors.ControlText
        Me.colDateValue.HeaderText = "Date Attended"
        Me.colDateValue.InputHorizontalAlignment = DevComponents.Editors.eHorizontalAlignment.Left
        '
        '
        '
        Me.colDateValue.MonthCalendar.AnnuallyMarkedDates = New Date(-1) {}
        '
        '
        '
        Me.colDateValue.MonthCalendar.BackgroundStyle.Class = ""
        Me.colDateValue.MonthCalendar.BackgroundStyle.CornerType = DevComponents.DotNetBar.eCornerType.Square
        '
        '
        '
        Me.colDateValue.MonthCalendar.CommandsBackgroundStyle.Class = ""
        Me.colDateValue.MonthCalendar.CommandsBackgroundStyle.CornerType = DevComponents.DotNetBar.eCornerType.Square
        Me.colDateValue.MonthCalendar.DisplayMonth = New Date(2018, 3, 1, 0, 0, 0, 0)
        Me.colDateValue.MonthCalendar.MarkedDates = New Date(-1) {}
        Me.colDateValue.MonthCalendar.MonthlyMarkedDates = New Date(-1) {}
        '
        '
        '
        Me.colDateValue.MonthCalendar.NavigationBackgroundStyle.Class = ""
        Me.colDateValue.MonthCalendar.NavigationBackgroundStyle.CornerType = DevComponents.DotNetBar.eCornerType.Square
        Me.colDateValue.MonthCalendar.WeeklyMarkedDays = New System.DayOfWeek(-1) {}
        Me.colDateValue.Name = "colDateValue"
        Me.colDateValue.Resizable = System.Windows.Forms.DataGridViewTriState.[True]
        Me.colDateValue.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.colDateValue.Width = 203
        '
        'WasEdited
        '
        Me.WasEdited.HeaderText = "WasEdited"
        Me.WasEdited.Name = "WasEdited"
        Me.WasEdited.Visible = False
        '
        'ToolStrip1
        '
        Me.ToolStrip1.BackColor = System.Drawing.Color.White
        Me.ToolStrip1.GripStyle = System.Windows.Forms.ToolStripGripStyle.Hidden
        Me.ToolStrip1.Items.AddRange(New System.Windows.Forms.ToolStripItem() {Me.tsbtnNew, Me.tsbtnSave, Me.tsbtndel, Me.tsbtnCancel, Me.ToolStripLabel1, Me.tsbtnImport, Me.tsbtnClose, Me.tsbtnAudittrail, Me.ToolStripProgressBar1})
        Me.ToolStrip1.Location = New System.Drawing.Point(0, 0)
        Me.ToolStrip1.Name = "ToolStrip1"
        Me.ToolStrip1.Size = New System.Drawing.Size(653, 25)
        Me.ToolStrip1.TabIndex = 161
        Me.ToolStrip1.Text = "ToolStrip1"
        '
        'tsbtnNew
        '
        Me.tsbtnNew.Image = Global.GotescoPayrollSys.My.Resources.Resources.Add
        Me.tsbtnNew.ImageTransparentColor = System.Drawing.Color.Magenta
        Me.tsbtnNew.Name = "tsbtnNew"
        Me.tsbtnNew.Size = New System.Drawing.Size(108, 22)
        Me.tsbtnNew.Text = "&New time entry"
        '
        'tsbtnSave
        '
        Me.tsbtnSave.Image = Global.GotescoPayrollSys.My.Resources.Resources.Save
        Me.tsbtnSave.ImageTransparentColor = System.Drawing.Color.Magenta
        Me.tsbtnSave.Name = "tsbtnSave"
        Me.tsbtnSave.Size = New System.Drawing.Size(108, 22)
        Me.tsbtnSave.Text = "&Save time entry"
        '
        'tsbtndel
        '
        Me.tsbtndel.Image = Global.GotescoPayrollSys.My.Resources.Resources.CLOSE_00
        Me.tsbtndel.ImageTransparentColor = System.Drawing.Color.Magenta
        Me.tsbtndel.Name = "tsbtndel"
        Me.tsbtndel.Size = New System.Drawing.Size(117, 22)
        Me.tsbtndel.Text = "&Delete time entry"
        '
        'tsbtnCancel
        '
        Me.tsbtnCancel.Image = Global.GotescoPayrollSys.My.Resources.Resources.cancel1
        Me.tsbtnCancel.ImageTransparentColor = System.Drawing.Color.Magenta
        Me.tsbtnCancel.Name = "tsbtnCancel"
        Me.tsbtnCancel.Size = New System.Drawing.Size(63, 22)
        Me.tsbtnCancel.Text = "Cancel"
        '
        'ToolStripLabel1
        '
        Me.ToolStripLabel1.Name = "ToolStripLabel1"
        Me.ToolStripLabel1.Size = New System.Drawing.Size(52, 22)
        Me.ToolStripLabel1.Text = "               "
        '
        'tsbtnImport
        '
        Me.tsbtnImport.Image = Global.GotescoPayrollSys.My.Resources.Resources._new
        Me.tsbtnImport.ImageTransparentColor = System.Drawing.Color.Magenta
        Me.tsbtnImport.Name = "tsbtnImport"
        Me.tsbtnImport.Size = New System.Drawing.Size(63, 22)
        Me.tsbtnImport.Text = "Import"
        '
        'tsbtnClose
        '
        Me.tsbtnClose.Alignment = System.Windows.Forms.ToolStripItemAlignment.Right
        Me.tsbtnClose.Image = Global.GotescoPayrollSys.My.Resources.Resources.Button_Delete_icon
        Me.tsbtnClose.ImageTransparentColor = System.Drawing.Color.Magenta
        Me.tsbtnClose.Name = "tsbtnClose"
        Me.tsbtnClose.Size = New System.Drawing.Size(56, 22)
        Me.tsbtnClose.Text = "Close"
        '
        'tsbtnAudittrail
        '
        Me.tsbtnAudittrail.Alignment = System.Windows.Forms.ToolStripItemAlignment.Right
        Me.tsbtnAudittrail.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image
        Me.tsbtnAudittrail.Image = Global.GotescoPayrollSys.My.Resources.Resources.audit_trail_icon
        Me.tsbtnAudittrail.ImageTransparentColor = System.Drawing.Color.Magenta
        Me.tsbtnAudittrail.Name = "tsbtnAudittrail"
        Me.tsbtnAudittrail.Size = New System.Drawing.Size(23, 22)
        Me.tsbtnAudittrail.Text = "ToolStripButton1"
        Me.tsbtnAudittrail.ToolTipText = "Show audit trails"
        '
        'ToolStripProgressBar1
        '
        Me.ToolStripProgressBar1.Alignment = System.Windows.Forms.ToolStripItemAlignment.Right
        Me.ToolStripProgressBar1.Name = "ToolStripProgressBar1"
        Me.ToolStripProgressBar1.Size = New System.Drawing.Size(100, 22)
        Me.ToolStripProgressBar1.Visible = False
        '
        'Label2
        '
        Me.Label2.Font = New System.Drawing.Font("Segoe UI", 9.0!)
        Me.Label2.Location = New System.Drawing.Point(466, 0)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(108, 22)
        Me.Label2.TabIndex = 162
        Me.Label2.Text = "Import"
        '
        'Label3
        '
        Me.Label3.Font = New System.Drawing.Font("Segoe UI", 9.0!)
        Me.Label3.Location = New System.Drawing.Point(233, 0)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(108, 22)
        Me.Label3.TabIndex = 162
        Me.Label3.Text = "Delete time entry"
        '
        'Label1
        '
        Me.Label1.Font = New System.Drawing.Font("Segoe UI", 9.0!)
        Me.Label1.Location = New System.Drawing.Point(125, 0)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(108, 22)
        Me.Label1.TabIndex = 162
        Me.Label1.Text = "Save time entry"
        '
        'bgworkTypicalImport
        '
        Me.bgworkTypicalImport.WorkerReportsProgress = True
        Me.bgworkTypicalImport.WorkerSupportsCancellation = True
        '
        'DataGridViewTextBoxColumn1
        '
        Me.DataGridViewTextBoxColumn1.HeaderText = "Time In"
        Me.DataGridViewTextBoxColumn1.Name = "DataGridViewTextBoxColumn1"
        Me.DataGridViewTextBoxColumn1.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.DataGridViewTextBoxColumn1.Width = 139
        '
        'DataGridViewTextBoxColumn2
        '
        Me.DataGridViewTextBoxColumn2.HeaderText = "Time Out"
        Me.DataGridViewTextBoxColumn2.Name = "DataGridViewTextBoxColumn2"
        Me.DataGridViewTextBoxColumn2.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.DataGridViewTextBoxColumn2.Width = 140
        '
        'DataGridViewTextBoxColumn3
        '
        Me.DataGridViewTextBoxColumn3.HeaderText = "Date Attended"
        Me.DataGridViewTextBoxColumn3.Name = "DataGridViewTextBoxColumn3"
        Me.DataGridViewTextBoxColumn3.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.DataGridViewTextBoxColumn3.Visible = False
        Me.DataGridViewTextBoxColumn3.Width = 139
        '
        'DataGridViewTextBoxColumn4
        '
        Me.DataGridViewTextBoxColumn4.HeaderText = "WasEdited"
        Me.DataGridViewTextBoxColumn4.Name = "DataGridViewTextBoxColumn4"
        Me.DataGridViewTextBoxColumn4.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.DataGridViewTextBoxColumn4.Visible = False
        Me.DataGridViewTextBoxColumn4.Width = 203
        '
        'DataGridViewTextBoxColumn5
        '
        Me.DataGridViewTextBoxColumn5.HeaderText = "Time Out"
        Me.DataGridViewTextBoxColumn5.Name = "DataGridViewTextBoxColumn5"
        Me.DataGridViewTextBoxColumn5.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.DataGridViewTextBoxColumn5.Width = 204
        '
        'DataGridViewTextBoxColumn6
        '
        Me.DataGridViewTextBoxColumn6.HeaderText = "WasEdited"
        Me.DataGridViewTextBoxColumn6.Name = "DataGridViewTextBoxColumn6"
        Me.DataGridViewTextBoxColumn6.Visible = False
        '
        'TimeEntryLogs
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.BackColor = System.Drawing.Color.White
        Me.ClientSize = New System.Drawing.Size(1269, 566)
        Me.ControlBox = False
        Me.Controls.Add(Me.Panel5)
        Me.Controls.Add(Me.Panel4)
        Me.Controls.Add(Me.Panel3)
        Me.Controls.Add(Me.Panel2)
        Me.Controls.Add(Me.Panel1)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None
        Me.KeyPreview = True
        Me.MaximizeBox = False
        Me.MinimizeBox = False
        Me.Name = "TimeEntryLogs"
        CType(Me.DataGridViewX1, System.ComponentModel.ISupportInitialize).EndInit()
        Me.Panel1.ResumeLayout(False)
        Me.Panel6.ResumeLayout(False)
        Me.Panel6.PerformLayout()
        Me.Panel3.ResumeLayout(False)
        CType(Me.DataGridViewX2, System.ComponentModel.ISupportInitialize).EndInit()
        Me.Panel8.ResumeLayout(False)
        Me.Panel8.PerformLayout()
        Me.Panel7.ResumeLayout(False)
        Me.Panel7.PerformLayout()
        Me.Panel5.ResumeLayout(False)
        Me.Panel5.PerformLayout()
        CType(Me.DataGridViewX3, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ToolStrip1.ResumeLayout(False)
        Me.ToolStrip1.PerformLayout()
        Me.ResumeLayout(False)

    End Sub
    Friend WithEvents DataGridViewX1 As DevComponents.DotNetBar.Controls.DataGridViewX
    Friend WithEvents Panel1 As System.Windows.Forms.Panel
    Friend WithEvents Panel2 As System.Windows.Forms.Panel
    Friend WithEvents Panel3 As System.Windows.Forms.Panel
    Friend WithEvents Panel4 As System.Windows.Forms.Panel
    Friend WithEvents Panel5 As System.Windows.Forms.Panel
    Friend WithEvents Panel6 As System.Windows.Forms.Panel
    Friend WithEvents PrevYear As System.Windows.Forms.LinkLabel
    Friend WithEvents NxtYear As System.Windows.Forms.LinkLabel
    Friend WithEvents DataGridViewX2 As DevComponents.DotNetBar.Controls.DataGridViewX
    Friend WithEvents Panel7 As System.Windows.Forms.Panel
    Friend WithEvents Nxt As System.Windows.Forms.LinkLabel
    Friend WithEvents Prev As System.Windows.Forms.LinkLabel
    Friend WithEvents Last As System.Windows.Forms.LinkLabel
    Friend WithEvents First As System.Windows.Forms.LinkLabel
    Friend WithEvents Panel8 As System.Windows.Forms.Panel
    Friend WithEvents Button1 As System.Windows.Forms.Button
    Friend WithEvents TextBox1 As System.Windows.Forms.TextBox
    Friend WithEvents lblYear As System.Windows.Forms.Label
    Friend WithEvents DataGridViewX3 As DevComponents.DotNetBar.Controls.DataGridViewX
    Friend WithEvents ToolStrip1 As System.Windows.Forms.ToolStrip
    Friend WithEvents tsbtnImport As System.Windows.Forms.ToolStripButton
    Friend WithEvents tsbtnSave As System.Windows.Forms.ToolStripButton
    Friend WithEvents tsbtndel As System.Windows.Forms.ToolStripButton
    Friend WithEvents tsbtnCancel As System.Windows.Forms.ToolStripButton
    Friend WithEvents tsbtnClose As System.Windows.Forms.ToolStripButton
    Friend WithEvents tsbtnAudittrail As System.Windows.Forms.ToolStripButton
    Friend WithEvents ToolStripProgressBar1 As System.Windows.Forms.ToolStripProgressBar
    Friend WithEvents ToolStripLabel1 As System.Windows.Forms.ToolStripLabel
    Friend WithEvents tsbtnNew As System.Windows.Forms.ToolStripButton
    Friend WithEvents DataGridViewTextBoxColumn1 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents DataGridViewTextBoxColumn2 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents DataGridViewTextBoxColumn3 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents bgworkTypicalImport As System.ComponentModel.BackgroundWorker
    Friend WithEvents DataGridViewTextBoxColumn4 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents colTimeIn As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents colTimeOut As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents colDateValue As DevComponents.DotNetBar.Controls.DataGridViewDateTimeInputColumn
    Friend WithEvents WasEdited As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents EId As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents EFullName As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents E_RowId As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents DataGridViewTextBoxColumn5 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents DataGridViewTextBoxColumn6 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Label3 As System.Windows.Forms.Label
End Class
