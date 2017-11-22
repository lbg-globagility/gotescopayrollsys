<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class EmployeeShiftEntryForm
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
        Dim DataGridViewCellStyle3 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()
        Dim DataGridViewCellStyle4 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()
        Dim resources As System.ComponentModel.ComponentResourceManager = New System.ComponentModel.ComponentResourceManager(GetType(EmployeeShiftEntryForm))
        Me.Label16 = New System.Windows.Forms.Label()
        Me.Panel2 = New System.Windows.Forms.Panel()
        Me.SuperTabControl1 = New DevComponents.DotNetBar.SuperTabControl()
        Me.SuperTabControlPanel1 = New DevComponents.DotNetBar.SuperTabControlPanel()
        Me.TextBox4 = New System.Windows.Forms.TextBox()
        Me.TextBox2 = New System.Windows.Forms.TextBox()
        Me.Label4 = New System.Windows.Forms.Label()
        Me.cmbempname = New System.Windows.Forms.ComboBox()
        Me.Label7 = New System.Windows.Forms.Label()
        Me.SuperTabItem1 = New DevComponents.DotNetBar.SuperTabItem()
        Me.SuperTabControlPanel2 = New DevComponents.DotNetBar.SuperTabControlPanel()
        Me.Label10 = New System.Windows.Forms.Label()
        Me.Label13 = New System.Windows.Forms.Label()
        Me.TextBox5 = New System.Windows.Forms.TextBox()
        Me.TextBox3 = New System.Windows.Forms.TextBox()
        Me.SuperTabItem2 = New DevComponents.DotNetBar.SuperTabItem()
        Me.dgvEmpList = New DevComponents.DotNetBar.Controls.DataGridViewX()
        Me.c_EmployeeID = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.c_EmployeeName = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.c_ID = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Panel1 = New System.Windows.Forms.Panel()
        Me.Last = New System.Windows.Forms.LinkLabel()
        Me.Nxt = New System.Windows.Forms.LinkLabel()
        Me.Prev = New System.Windows.Forms.LinkLabel()
        Me.First = New System.Windows.Forms.LinkLabel()
        Me.cboshiftlist = New System.Windows.Forms.ComboBox()
        Me.chkrestday = New System.Windows.Forms.CheckBox()
        Me.chkNightShift = New System.Windows.Forms.CheckBox()
        Me.lblShiftEntry = New System.Windows.Forms.LinkLabel()
        Me.lblSaveMsg = New System.Windows.Forms.Label()
        Me.dgvEmpShiftList = New DevComponents.DotNetBar.Controls.DataGridViewX()
        Me.c_empIDShift = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.c_EmpnameShift = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.c_RowIDShift = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.c_DateFrom = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.c_DateTo = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.c_TimeFrom = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.c_TimeTo = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Label6 = New System.Windows.Forms.Label()
        Me.Label5 = New System.Windows.Forms.Label()
        Me.txtEmpID = New System.Windows.Forms.TextBox()
        Me.txtEmpName = New System.Windows.Forms.TextBox()
        Me.Label1 = New System.Windows.Forms.Label()
        Me.Label2 = New System.Windows.Forms.Label()
        Me.dtpDateTo = New System.Windows.Forms.DateTimePicker()
        Me.dtpDateFrom = New System.Windows.Forms.DateTimePicker()
        Me.ToolStrip1 = New System.Windows.Forms.ToolStrip()
        Me.btnNew = New System.Windows.Forms.ToolStripButton()
        Me.btnSave = New System.Windows.Forms.ToolStripButton()
        Me.ToolStripLabel1 = New System.Windows.Forms.ToolStripLabel()
        Me.ToolStripSeparator1 = New System.Windows.Forms.ToolStripSeparator()
        Me.btnDelete = New System.Windows.Forms.ToolStripButton()
        Me.ToolStripSeparator2 = New System.Windows.Forms.ToolStripSeparator()
        Me.btnCancel = New System.Windows.Forms.ToolStripButton()
        Me.btnClose = New System.Windows.Forms.ToolStripButton()
        Me.btnAudittrail = New System.Windows.Forms.ToolStripButton()
        Me.tsbtnImportEmpShift = New System.Windows.Forms.ToolStripButton()
        Me.ToolStripProgressBar1 = New System.Windows.Forms.ToolStripProgressBar()
        Me.lblShiftID = New System.Windows.Forms.Label()
        Me.Label8 = New System.Windows.Forms.Label()
        Me.Label3 = New System.Windows.Forms.Label()
        Me.dtpTimeTo = New System.Windows.Forms.DateTimePicker()
        Me.dtpTimeFrom = New System.Windows.Forms.DateTimePicker()
        Me.Label140 = New System.Windows.Forms.Label()
        Me.bgEmpShiftImport = New System.ComponentModel.BackgroundWorker()
        Me.Panel2.SuspendLayout()
        CType(Me.SuperTabControl1, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuperTabControl1.SuspendLayout()
        Me.SuperTabControlPanel1.SuspendLayout()
        Me.SuperTabControlPanel2.SuspendLayout()
        CType(Me.dgvEmpList, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.Panel1.SuspendLayout()
        CType(Me.dgvEmpShiftList, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.ToolStrip1.SuspendLayout()
        Me.SuspendLayout()
        '
        'Label16
        '
        Me.Label16.BackColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(220, Byte), Integer), CType(CType(190, Byte), Integer))
        Me.Label16.Dock = System.Windows.Forms.DockStyle.Top
        Me.Label16.Font = New System.Drawing.Font("Arial", 15.75!, System.Drawing.FontStyle.Bold)
        Me.Label16.ForeColor = System.Drawing.SystemColors.ActiveCaptionText
        Me.Label16.Location = New System.Drawing.Point(0, 0)
        Me.Label16.Name = "Label16"
        Me.Label16.Size = New System.Drawing.Size(1030, 24)
        Me.Label16.TabIndex = 313
        Me.Label16.Text = "EMPLOYEE SHIFT ENTRY"
        Me.Label16.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
        '
        'Panel2
        '
        Me.Panel2.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.Panel2.BackColor = System.Drawing.Color.White
        Me.Panel2.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.Panel2.Controls.Add(Me.SuperTabControl1)
        Me.Panel2.Controls.Add(Me.dgvEmpList)
        Me.Panel2.Location = New System.Drawing.Point(4, 27)
        Me.Panel2.Name = "Panel2"
        Me.Panel2.Size = New System.Drawing.Size(321, 437)
        Me.Panel2.TabIndex = 316
        '
        'SuperTabControl1
        '
        '
        '
        '
        '
        '
        '
        Me.SuperTabControl1.ControlBox.CloseBox.Name = ""
        '
        '
        '
        Me.SuperTabControl1.ControlBox.MenuBox.Name = ""
        Me.SuperTabControl1.ControlBox.Name = ""
        Me.SuperTabControl1.ControlBox.SubItems.AddRange(New DevComponents.DotNetBar.BaseItem() {Me.SuperTabControl1.ControlBox.MenuBox, Me.SuperTabControl1.ControlBox.CloseBox})
        Me.SuperTabControl1.Controls.Add(Me.SuperTabControlPanel1)
        Me.SuperTabControl1.Controls.Add(Me.SuperTabControlPanel2)
        Me.SuperTabControl1.Location = New System.Drawing.Point(7, 3)
        Me.SuperTabControl1.Name = "SuperTabControl1"
        Me.SuperTabControl1.ReorderTabsEnabled = True
        Me.SuperTabControl1.SelectedTabFont = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold)
        Me.SuperTabControl1.SelectedTabIndex = 0
        Me.SuperTabControl1.Size = New System.Drawing.Size(307, 113)
        Me.SuperTabControl1.TabFont = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.SuperTabControl1.TabIndex = 322
        Me.SuperTabControl1.Tabs.AddRange(New DevComponents.DotNetBar.BaseItem() {Me.SuperTabItem1, Me.SuperTabItem2})
        Me.SuperTabControl1.TabStyle = DevComponents.DotNetBar.eSuperTabStyle.WinMediaPlayer12
        Me.SuperTabControl1.Text = "SuperTabControl1"
        '
        'SuperTabControlPanel1
        '
        Me.SuperTabControlPanel1.Controls.Add(Me.TextBox4)
        Me.SuperTabControlPanel1.Controls.Add(Me.TextBox2)
        Me.SuperTabControlPanel1.Controls.Add(Me.Label4)
        Me.SuperTabControlPanel1.Controls.Add(Me.cmbempname)
        Me.SuperTabControlPanel1.Controls.Add(Me.Label7)
        Me.SuperTabControlPanel1.Dock = System.Windows.Forms.DockStyle.Fill
        Me.SuperTabControlPanel1.Location = New System.Drawing.Point(0, 23)
        Me.SuperTabControlPanel1.Name = "SuperTabControlPanel1"
        Me.SuperTabControlPanel1.Size = New System.Drawing.Size(307, 90)
        Me.SuperTabControlPanel1.TabIndex = 1
        Me.SuperTabControlPanel1.TabItem = Me.SuperTabItem1
        '
        'TextBox4
        '
        Me.TextBox4.Location = New System.Drawing.Point(90, 12)
        Me.TextBox4.Name = "TextBox4"
        Me.TextBox4.Size = New System.Drawing.Size(200, 20)
        Me.TextBox4.TabIndex = 149
        '
        'TextBox2
        '
        Me.TextBox2.Location = New System.Drawing.Point(90, 65)
        Me.TextBox2.Name = "TextBox2"
        Me.TextBox2.Size = New System.Drawing.Size(200, 20)
        Me.TextBox2.TabIndex = 148
        '
        'Label4
        '
        Me.Label4.AutoSize = True
        Me.Label4.BackColor = System.Drawing.Color.Transparent
        Me.Label4.Location = New System.Drawing.Point(3, 12)
        Me.Label4.Name = "Label4"
        Me.Label4.Size = New System.Drawing.Size(70, 13)
        Me.Label4.TabIndex = 147
        Me.Label4.Text = "Employee ID:"
        '
        'cmbempname
        '
        Me.cmbempname.FormattingEnabled = True
        Me.cmbempname.Items.AddRange(New Object() {"starts with", "contains like", "is exactly", "does not contain", "is empty null", "is not empty"})
        Me.cmbempname.Location = New System.Drawing.Point(90, 40)
        Me.cmbempname.Name = "cmbempname"
        Me.cmbempname.Size = New System.Drawing.Size(200, 21)
        Me.cmbempname.TabIndex = 146
        '
        'Label7
        '
        Me.Label7.AutoSize = True
        Me.Label7.BackColor = System.Drawing.Color.Transparent
        Me.Label7.Location = New System.Drawing.Point(3, 43)
        Me.Label7.Name = "Label7"
        Me.Label7.Size = New System.Drawing.Size(87, 13)
        Me.Label7.TabIndex = 144
        Me.Label7.Text = "Employee Name:"
        '
        'SuperTabItem1
        '
        Me.SuperTabItem1.AttachedControl = Me.SuperTabControlPanel1
        Me.SuperTabItem1.GlobalItem = False
        Me.SuperTabItem1.Name = "SuperTabItem1"
        Me.SuperTabItem1.Text = "Common Search"
        '
        'SuperTabControlPanel2
        '
        Me.SuperTabControlPanel2.Controls.Add(Me.Label10)
        Me.SuperTabControlPanel2.Controls.Add(Me.Label13)
        Me.SuperTabControlPanel2.Controls.Add(Me.TextBox5)
        Me.SuperTabControlPanel2.Controls.Add(Me.TextBox3)
        Me.SuperTabControlPanel2.Dock = System.Windows.Forms.DockStyle.Fill
        Me.SuperTabControlPanel2.Location = New System.Drawing.Point(0, 0)
        Me.SuperTabControlPanel2.Name = "SuperTabControlPanel2"
        Me.SuperTabControlPanel2.Size = New System.Drawing.Size(307, 113)
        Me.SuperTabControlPanel2.TabIndex = 0
        Me.SuperTabControlPanel2.TabItem = Me.SuperTabItem2
        '
        'Label10
        '
        Me.Label10.AutoSize = True
        Me.Label10.BackColor = System.Drawing.Color.Transparent
        Me.Label10.Location = New System.Drawing.Point(4, 12)
        Me.Label10.Name = "Label10"
        Me.Label10.Size = New System.Drawing.Size(70, 13)
        Me.Label10.TabIndex = 149
        Me.Label10.Text = "Employee ID:"
        '
        'Label13
        '
        Me.Label13.AutoSize = True
        Me.Label13.BackColor = System.Drawing.Color.Transparent
        Me.Label13.Location = New System.Drawing.Point(4, 43)
        Me.Label13.Name = "Label13"
        Me.Label13.Size = New System.Drawing.Size(87, 13)
        Me.Label13.TabIndex = 148
        Me.Label13.Text = "Employee Name:"
        '
        'TextBox5
        '
        Me.TextBox5.Location = New System.Drawing.Point(97, 40)
        Me.TextBox5.Multiline = True
        Me.TextBox5.Name = "TextBox5"
        Me.TextBox5.Size = New System.Drawing.Size(207, 21)
        Me.TextBox5.TabIndex = 146
        '
        'TextBox3
        '
        Me.TextBox3.Location = New System.Drawing.Point(97, 12)
        Me.TextBox3.Multiline = True
        Me.TextBox3.Name = "TextBox3"
        Me.TextBox3.Size = New System.Drawing.Size(207, 21)
        Me.TextBox3.TabIndex = 145
        '
        'SuperTabItem2
        '
        Me.SuperTabItem2.AttachedControl = Me.SuperTabControlPanel2
        Me.SuperTabItem2.GlobalItem = False
        Me.SuperTabItem2.Name = "SuperTabItem2"
        Me.SuperTabItem2.Text = "Simple Search"
        '
        'dgvEmpList
        '
        Me.dgvEmpList.AllowUserToAddRows = False
        Me.dgvEmpList.AllowUserToDeleteRows = False
        Me.dgvEmpList.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.dgvEmpList.BackgroundColor = System.Drawing.Color.White
        Me.dgvEmpList.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize
        Me.dgvEmpList.Columns.AddRange(New System.Windows.Forms.DataGridViewColumn() {Me.c_EmployeeID, Me.c_EmployeeName, Me.c_ID})
        DataGridViewCellStyle3.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle3.BackColor = System.Drawing.SystemColors.Window
        DataGridViewCellStyle3.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        DataGridViewCellStyle3.ForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle3.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle3.SelectionForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle3.WrapMode = System.Windows.Forms.DataGridViewTriState.[False]
        Me.dgvEmpList.DefaultCellStyle = DataGridViewCellStyle3
        Me.dgvEmpList.GridColor = System.Drawing.Color.FromArgb(CType(CType(208, Byte), Integer), CType(CType(215, Byte), Integer), CType(CType(229, Byte), Integer))
        Me.dgvEmpList.Location = New System.Drawing.Point(7, 118)
        Me.dgvEmpList.MultiSelect = False
        Me.dgvEmpList.Name = "dgvEmpList"
        Me.dgvEmpList.ReadOnly = True
        Me.dgvEmpList.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect
        Me.dgvEmpList.Size = New System.Drawing.Size(307, 314)
        Me.dgvEmpList.TabIndex = 321
        '
        'c_EmployeeID
        '
        Me.c_EmployeeID.HeaderText = "Employee ID"
        Me.c_EmployeeID.Name = "c_EmployeeID"
        Me.c_EmployeeID.ReadOnly = True
        '
        'c_EmployeeName
        '
        Me.c_EmployeeName.HeaderText = "Employee Name"
        Me.c_EmployeeName.Name = "c_EmployeeName"
        Me.c_EmployeeName.ReadOnly = True
        Me.c_EmployeeName.Width = 150
        '
        'c_ID
        '
        Me.c_ID.HeaderText = "RowID"
        Me.c_ID.Name = "c_ID"
        Me.c_ID.ReadOnly = True
        Me.c_ID.Visible = False
        '
        'Panel1
        '
        Me.Panel1.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Panel1.BackColor = System.Drawing.Color.White
        Me.Panel1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.Panel1.Controls.Add(Me.Last)
        Me.Panel1.Controls.Add(Me.Nxt)
        Me.Panel1.Controls.Add(Me.Prev)
        Me.Panel1.Controls.Add(Me.First)
        Me.Panel1.Controls.Add(Me.cboshiftlist)
        Me.Panel1.Controls.Add(Me.chkrestday)
        Me.Panel1.Controls.Add(Me.chkNightShift)
        Me.Panel1.Controls.Add(Me.lblShiftEntry)
        Me.Panel1.Controls.Add(Me.lblSaveMsg)
        Me.Panel1.Controls.Add(Me.dgvEmpShiftList)
        Me.Panel1.Controls.Add(Me.Label6)
        Me.Panel1.Controls.Add(Me.Label5)
        Me.Panel1.Controls.Add(Me.txtEmpID)
        Me.Panel1.Controls.Add(Me.txtEmpName)
        Me.Panel1.Controls.Add(Me.Label1)
        Me.Panel1.Controls.Add(Me.Label2)
        Me.Panel1.Controls.Add(Me.dtpDateTo)
        Me.Panel1.Controls.Add(Me.dtpDateFrom)
        Me.Panel1.Controls.Add(Me.ToolStrip1)
        Me.Panel1.Controls.Add(Me.lblShiftID)
        Me.Panel1.Controls.Add(Me.Label8)
        Me.Panel1.Controls.Add(Me.Label3)
        Me.Panel1.Controls.Add(Me.dtpTimeTo)
        Me.Panel1.Controls.Add(Me.dtpTimeFrom)
        Me.Panel1.Controls.Add(Me.Label140)
        Me.Panel1.Location = New System.Drawing.Point(331, 27)
        Me.Panel1.Name = "Panel1"
        Me.Panel1.Size = New System.Drawing.Size(695, 437)
        Me.Panel1.TabIndex = 317
        '
        'Last
        '
        Me.Last.AutoSize = True
        Me.Last.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Last.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.Last.Location = New System.Drawing.Point(145, 128)
        Me.Last.Name = "Last"
        Me.Last.Size = New System.Drawing.Size(44, 15)
        Me.Last.TabIndex = 347
        Me.Last.TabStop = True
        Me.Last.Text = "Last>>"
        '
        'Nxt
        '
        Me.Nxt.AutoSize = True
        Me.Nxt.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Nxt.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.Nxt.Location = New System.Drawing.Point(100, 128)
        Me.Nxt.Name = "Nxt"
        Me.Nxt.Size = New System.Drawing.Size(39, 15)
        Me.Nxt.TabIndex = 346
        Me.Nxt.TabStop = True
        Me.Nxt.Text = "Next>"
        '
        'Prev
        '
        Me.Prev.AutoSize = True
        Me.Prev.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Prev.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.Prev.Location = New System.Drawing.Point(56, 128)
        Me.Prev.Name = "Prev"
        Me.Prev.Size = New System.Drawing.Size(38, 15)
        Me.Prev.TabIndex = 345
        Me.Prev.TabStop = True
        Me.Prev.Text = "<Prev"
        '
        'First
        '
        Me.First.AutoSize = True
        Me.First.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.First.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.First.Location = New System.Drawing.Point(6, 128)
        Me.First.Name = "First"
        Me.First.Size = New System.Drawing.Size(44, 15)
        Me.First.TabIndex = 344
        Me.First.TabStop = True
        Me.First.Text = "<<First"
        '
        'cboshiftlist
        '
        Me.cboshiftlist.FormattingEnabled = True
        Me.cboshiftlist.Location = New System.Drawing.Point(238, 94)
        Me.cboshiftlist.Name = "cboshiftlist"
        Me.cboshiftlist.Size = New System.Drawing.Size(231, 21)
        Me.cboshiftlist.TabIndex = 332
        '
        'chkrestday
        '
        Me.chkrestday.AutoSize = True
        Me.chkrestday.Location = New System.Drawing.Point(556, 58)
        Me.chkrestday.Name = "chkrestday"
        Me.chkrestday.Size = New System.Drawing.Size(68, 17)
        Me.chkrestday.TabIndex = 331
        Me.chkrestday.Text = "Rest day"
        Me.chkrestday.UseVisualStyleBackColor = True
        '
        'chkNightShift
        '
        Me.chkNightShift.AutoSize = True
        Me.chkNightShift.Location = New System.Drawing.Point(475, 58)
        Me.chkNightShift.Name = "chkNightShift"
        Me.chkNightShift.Size = New System.Drawing.Size(75, 17)
        Me.chkNightShift.TabIndex = 330
        Me.chkNightShift.Text = "Night Shift"
        Me.chkNightShift.UseVisualStyleBackColor = True
        '
        'lblShiftEntry
        '
        Me.lblShiftEntry.AutoSize = True
        Me.lblShiftEntry.Location = New System.Drawing.Point(475, 102)
        Me.lblShiftEntry.Name = "lblShiftEntry"
        Me.lblShiftEntry.Size = New System.Drawing.Size(163, 13)
        Me.lblShiftEntry.TabIndex = 333
        Me.lblShiftEntry.TabStop = True
        Me.lblShiftEntry.Text = "Add Shift Entry/Select Shift Entry"
        '
        'lblSaveMsg
        '
        Me.lblSaveMsg.AutoSize = True
        Me.lblSaveMsg.BackColor = System.Drawing.Color.Transparent
        Me.lblSaveMsg.Location = New System.Drawing.Point(88, 26)
        Me.lblSaveMsg.Name = "lblSaveMsg"
        Me.lblSaveMsg.Size = New System.Drawing.Size(70, 13)
        Me.lblSaveMsg.TabIndex = 340
        Me.lblSaveMsg.Text = "Employee ID:"
        Me.lblSaveMsg.Visible = False
        '
        'dgvEmpShiftList
        '
        Me.dgvEmpShiftList.AllowUserToAddRows = False
        Me.dgvEmpShiftList.AllowUserToDeleteRows = False
        Me.dgvEmpShiftList.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.dgvEmpShiftList.BackgroundColor = System.Drawing.Color.White
        Me.dgvEmpShiftList.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize
        Me.dgvEmpShiftList.Columns.AddRange(New System.Windows.Forms.DataGridViewColumn() {Me.c_empIDShift, Me.c_EmpnameShift, Me.c_RowIDShift, Me.c_DateFrom, Me.c_DateTo, Me.c_TimeFrom, Me.c_TimeTo})
        DataGridViewCellStyle4.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle4.BackColor = System.Drawing.SystemColors.Window
        DataGridViewCellStyle4.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        DataGridViewCellStyle4.ForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle4.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle4.SelectionForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle4.WrapMode = System.Windows.Forms.DataGridViewTriState.[False]
        Me.dgvEmpShiftList.DefaultCellStyle = DataGridViewCellStyle4
        Me.dgvEmpShiftList.GridColor = System.Drawing.Color.FromArgb(CType(CType(208, Byte), Integer), CType(CType(215, Byte), Integer), CType(CType(229, Byte), Integer))
        Me.dgvEmpShiftList.Location = New System.Drawing.Point(6, 146)
        Me.dgvEmpShiftList.Name = "dgvEmpShiftList"
        Me.dgvEmpShiftList.ReadOnly = True
        Me.dgvEmpShiftList.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect
        Me.dgvEmpShiftList.Size = New System.Drawing.Size(684, 286)
        Me.dgvEmpShiftList.TabIndex = 334
        '
        'c_empIDShift
        '
        Me.c_empIDShift.HeaderText = "Employee ID"
        Me.c_empIDShift.Name = "c_empIDShift"
        Me.c_empIDShift.ReadOnly = True
        '
        'c_EmpnameShift
        '
        Me.c_EmpnameShift.HeaderText = "Employee Name"
        Me.c_EmpnameShift.Name = "c_EmpnameShift"
        Me.c_EmpnameShift.ReadOnly = True
        Me.c_EmpnameShift.Width = 150
        '
        'c_RowIDShift
        '
        Me.c_RowIDShift.HeaderText = "RowID"
        Me.c_RowIDShift.Name = "c_RowIDShift"
        Me.c_RowIDShift.ReadOnly = True
        Me.c_RowIDShift.Visible = False
        '
        'c_DateFrom
        '
        Me.c_DateFrom.HeaderText = "Effective Date From"
        Me.c_DateFrom.Name = "c_DateFrom"
        Me.c_DateFrom.ReadOnly = True
        '
        'c_DateTo
        '
        Me.c_DateTo.HeaderText = "Effective Date To"
        Me.c_DateTo.Name = "c_DateTo"
        Me.c_DateTo.ReadOnly = True
        '
        'c_TimeFrom
        '
        Me.c_TimeFrom.HeaderText = "Time From"
        Me.c_TimeFrom.Name = "c_TimeFrom"
        Me.c_TimeFrom.ReadOnly = True
        '
        'c_TimeTo
        '
        Me.c_TimeTo.HeaderText = "Time To"
        Me.c_TimeTo.Name = "c_TimeTo"
        Me.c_TimeTo.ReadOnly = True
        '
        'Label6
        '
        Me.Label6.AutoSize = True
        Me.Label6.BackColor = System.Drawing.Color.Transparent
        Me.Label6.Location = New System.Drawing.Point(361, 38)
        Me.Label6.Name = "Label6"
        Me.Label6.Size = New System.Drawing.Size(46, 13)
        Me.Label6.TabIndex = 338
        Me.Label6.Text = "Date To"
        '
        'Label5
        '
        Me.Label5.AutoSize = True
        Me.Label5.BackColor = System.Drawing.Color.Transparent
        Me.Label5.Location = New System.Drawing.Point(235, 38)
        Me.Label5.Name = "Label5"
        Me.Label5.Size = New System.Drawing.Size(56, 13)
        Me.Label5.TabIndex = 337
        Me.Label5.Text = "Date From"
        '
        'txtEmpID
        '
        Me.txtEmpID.Enabled = False
        Me.txtEmpID.Location = New System.Drawing.Point(6, 54)
        Me.txtEmpID.Multiline = True
        Me.txtEmpID.Name = "txtEmpID"
        Me.txtEmpID.Size = New System.Drawing.Size(209, 21)
        Me.txtEmpID.TabIndex = 335
        '
        'txtEmpName
        '
        Me.txtEmpName.Enabled = False
        Me.txtEmpName.Location = New System.Drawing.Point(6, 94)
        Me.txtEmpName.Multiline = True
        Me.txtEmpName.Name = "txtEmpName"
        Me.txtEmpName.Size = New System.Drawing.Size(209, 21)
        Me.txtEmpName.TabIndex = 334
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.BackColor = System.Drawing.Color.Transparent
        Me.Label1.Location = New System.Drawing.Point(3, 38)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(70, 13)
        Me.Label1.TabIndex = 333
        Me.Label1.Text = "Employee ID:"
        '
        'Label2
        '
        Me.Label2.AutoSize = True
        Me.Label2.BackColor = System.Drawing.Color.Transparent
        Me.Label2.Location = New System.Drawing.Point(3, 78)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(87, 13)
        Me.Label2.TabIndex = 332
        Me.Label2.Text = "Employee Name:"
        '
        'dtpDateTo
        '
        Me.dtpDateTo.Format = System.Windows.Forms.DateTimePickerFormat.[Short]
        Me.dtpDateTo.Location = New System.Drawing.Point(364, 54)
        Me.dtpDateTo.Name = "dtpDateTo"
        Me.dtpDateTo.Size = New System.Drawing.Size(105, 20)
        Me.dtpDateTo.TabIndex = 329
        '
        'dtpDateFrom
        '
        Me.dtpDateFrom.Format = System.Windows.Forms.DateTimePickerFormat.[Short]
        Me.dtpDateFrom.Location = New System.Drawing.Point(238, 54)
        Me.dtpDateFrom.Name = "dtpDateFrom"
        Me.dtpDateFrom.Size = New System.Drawing.Size(105, 20)
        Me.dtpDateFrom.TabIndex = 328
        '
        'ToolStrip1
        '
        Me.ToolStrip1.BackColor = System.Drawing.Color.White
        Me.ToolStrip1.Items.AddRange(New System.Windows.Forms.ToolStripItem() {Me.btnNew, Me.btnSave, Me.ToolStripLabel1, Me.ToolStripSeparator1, Me.btnDelete, Me.ToolStripSeparator2, Me.btnCancel, Me.btnClose, Me.btnAudittrail, Me.tsbtnImportEmpShift, Me.ToolStripProgressBar1})
        Me.ToolStrip1.Location = New System.Drawing.Point(0, 0)
        Me.ToolStrip1.Name = "ToolStrip1"
        Me.ToolStrip1.Size = New System.Drawing.Size(693, 25)
        Me.ToolStrip1.TabIndex = 327
        Me.ToolStrip1.Text = "ToolStrip1"
        '
        'btnNew
        '
        Me.btnNew.Image = Global.GotescoPayrollSys.My.Resources.Resources._new
        Me.btnNew.ImageTransparentColor = System.Drawing.Color.Magenta
        Me.btnNew.Name = "btnNew"
        Me.btnNew.Size = New System.Drawing.Size(78, 22)
        Me.btnNew.Text = "&New Shift"
        '
        'btnSave
        '
        Me.btnSave.Image = Global.GotescoPayrollSys.My.Resources.Resources.Save
        Me.btnSave.ImageTransparentColor = System.Drawing.Color.Magenta
        Me.btnSave.Name = "btnSave"
        Me.btnSave.Size = New System.Drawing.Size(78, 22)
        Me.btnSave.Text = "&Save Shift"
        '
        'ToolStripLabel1
        '
        Me.ToolStripLabel1.AutoSize = False
        Me.ToolStripLabel1.Name = "ToolStripLabel1"
        Me.ToolStripLabel1.Size = New System.Drawing.Size(50, 22)
        '
        'ToolStripSeparator1
        '
        Me.ToolStripSeparator1.Name = "ToolStripSeparator1"
        Me.ToolStripSeparator1.Size = New System.Drawing.Size(6, 25)
        '
        'btnDelete
        '
        Me.btnDelete.Enabled = False
        Me.btnDelete.Image = Global.GotescoPayrollSys.My.Resources.Resources.deleteuser
        Me.btnDelete.ImageTransparentColor = System.Drawing.Color.Magenta
        Me.btnDelete.Name = "btnDelete"
        Me.btnDelete.Size = New System.Drawing.Size(87, 22)
        Me.btnDelete.Text = "Delete Shift"
        '
        'ToolStripSeparator2
        '
        Me.ToolStripSeparator2.Name = "ToolStripSeparator2"
        Me.ToolStripSeparator2.Size = New System.Drawing.Size(6, 25)
        '
        'btnCancel
        '
        Me.btnCancel.Image = Global.GotescoPayrollSys.My.Resources.Resources.cancel1
        Me.btnCancel.ImageTransparentColor = System.Drawing.Color.Magenta
        Me.btnCancel.Name = "btnCancel"
        Me.btnCancel.Size = New System.Drawing.Size(63, 22)
        Me.btnCancel.Text = "&Cancel"
        '
        'btnClose
        '
        Me.btnClose.Alignment = System.Windows.Forms.ToolStripItemAlignment.Right
        Me.btnClose.Image = Global.GotescoPayrollSys.My.Resources.Resources.Button_Delete_icon
        Me.btnClose.ImageTransparentColor = System.Drawing.Color.Magenta
        Me.btnClose.Name = "btnClose"
        Me.btnClose.Size = New System.Drawing.Size(56, 22)
        Me.btnClose.Text = "&Close"
        '
        'btnAudittrail
        '
        Me.btnAudittrail.Alignment = System.Windows.Forms.ToolStripItemAlignment.Right
        Me.btnAudittrail.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image
        Me.btnAudittrail.Image = Global.GotescoPayrollSys.My.Resources.Resources.audit_trail_icon
        Me.btnAudittrail.ImageTransparentColor = System.Drawing.Color.Magenta
        Me.btnAudittrail.Name = "btnAudittrail"
        Me.btnAudittrail.Size = New System.Drawing.Size(23, 22)
        Me.btnAudittrail.Text = "ToolStripButton1"
        Me.btnAudittrail.ToolTipText = "Show audit trails"
        '
        'tsbtnImportEmpShift
        '
        Me.tsbtnImportEmpShift.Image = CType(resources.GetObject("tsbtnImportEmpShift.Image"), System.Drawing.Image)
        Me.tsbtnImportEmpShift.ImageTransparentColor = System.Drawing.Color.Magenta
        Me.tsbtnImportEmpShift.Name = "tsbtnImportEmpShift"
        Me.tsbtnImportEmpShift.Size = New System.Drawing.Size(145, 22)
        Me.tsbtnImportEmpShift.Text = "Import Employee Shift"
        '
        'ToolStripProgressBar1
        '
        Me.ToolStripProgressBar1.Alignment = System.Windows.Forms.ToolStripItemAlignment.Right
        Me.ToolStripProgressBar1.Name = "ToolStripProgressBar1"
        Me.ToolStripProgressBar1.Size = New System.Drawing.Size(100, 15)
        Me.ToolStripProgressBar1.Visible = False
        '
        'lblShiftID
        '
        Me.lblShiftID.AutoSize = True
        Me.lblShiftID.BackColor = System.Drawing.Color.Transparent
        Me.lblShiftID.Location = New System.Drawing.Point(679, 153)
        Me.lblShiftID.Name = "lblShiftID"
        Me.lblShiftID.Size = New System.Drawing.Size(13, 13)
        Me.lblShiftID.TabIndex = 342
        Me.lblShiftID.Text = "0"
        Me.lblShiftID.Visible = False
        '
        'Label8
        '
        Me.Label8.AutoSize = True
        Me.Label8.BackColor = System.Drawing.Color.Transparent
        Me.Label8.Location = New System.Drawing.Point(613, 153)
        Me.Label8.Name = "Label8"
        Me.Label8.Size = New System.Drawing.Size(46, 13)
        Me.Label8.TabIndex = 339
        Me.Label8.Text = "Time To"
        Me.Label8.Visible = False
        '
        'Label3
        '
        Me.Label3.AutoSize = True
        Me.Label3.BackColor = System.Drawing.Color.Transparent
        Me.Label3.Location = New System.Drawing.Point(487, 153)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(56, 13)
        Me.Label3.TabIndex = 336
        Me.Label3.Text = "Time From"
        Me.Label3.Visible = False
        '
        'dtpTimeTo
        '
        Me.dtpTimeTo.Enabled = False
        Me.dtpTimeTo.Format = System.Windows.Forms.DateTimePickerFormat.Time
        Me.dtpTimeTo.Location = New System.Drawing.Point(616, 169)
        Me.dtpTimeTo.Name = "dtpTimeTo"
        Me.dtpTimeTo.ShowUpDown = True
        Me.dtpTimeTo.Size = New System.Drawing.Size(105, 20)
        Me.dtpTimeTo.TabIndex = 333
        Me.dtpTimeTo.Visible = False
        '
        'dtpTimeFrom
        '
        Me.dtpTimeFrom.Enabled = False
        Me.dtpTimeFrom.Format = System.Windows.Forms.DateTimePickerFormat.Time
        Me.dtpTimeFrom.Location = New System.Drawing.Point(490, 169)
        Me.dtpTimeFrom.Name = "dtpTimeFrom"
        Me.dtpTimeFrom.ShowUpDown = True
        Me.dtpTimeFrom.Size = New System.Drawing.Size(105, 20)
        Me.dtpTimeFrom.TabIndex = 332
        Me.dtpTimeFrom.Visible = False
        '
        'Label140
        '
        Me.Label140.AutoSize = True
        Me.Label140.Font = New System.Drawing.Font("Gisha", 14.25!, System.Drawing.FontStyle.Bold)
        Me.Label140.ForeColor = System.Drawing.Color.FromArgb(CType(CType(255, Byte), Integer), CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer))
        Me.Label140.Location = New System.Drawing.Point(221, 92)
        Me.Label140.Name = "Label140"
        Me.Label140.Size = New System.Drawing.Size(19, 23)
        Me.Label140.TabIndex = 343
        Me.Label140.Text = "*"
        '
        'bgEmpShiftImport
        '
        Me.bgEmpShiftImport.WorkerReportsProgress = True
        Me.bgEmpShiftImport.WorkerSupportsCancellation = True
        '
        'EmployeeShiftEntryForm
        '
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Inherit
        Me.BackColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(200, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.ClientSize = New System.Drawing.Size(1030, 476)
        Me.Controls.Add(Me.Panel1)
        Me.Controls.Add(Me.Panel2)
        Me.Controls.Add(Me.Label16)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None
        Me.Name = "EmployeeShiftEntryForm"
        Me.Text = "ShiftEntryForm"
        Me.Panel2.ResumeLayout(False)
        CType(Me.SuperTabControl1, System.ComponentModel.ISupportInitialize).EndInit()
        Me.SuperTabControl1.ResumeLayout(False)
        Me.SuperTabControlPanel1.ResumeLayout(False)
        Me.SuperTabControlPanel1.PerformLayout()
        Me.SuperTabControlPanel2.ResumeLayout(False)
        Me.SuperTabControlPanel2.PerformLayout()
        CType(Me.dgvEmpList, System.ComponentModel.ISupportInitialize).EndInit()
        Me.Panel1.ResumeLayout(False)
        Me.Panel1.PerformLayout()
        CType(Me.dgvEmpShiftList, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ToolStrip1.ResumeLayout(False)
        Me.ToolStrip1.PerformLayout()
        Me.ResumeLayout(False)

    End Sub
    Friend WithEvents Label16 As System.Windows.Forms.Label
    Friend WithEvents Panel2 As System.Windows.Forms.Panel
    Friend WithEvents TextBox4 As System.Windows.Forms.TextBox
    Friend WithEvents TextBox2 As System.Windows.Forms.TextBox
    Friend WithEvents Label4 As System.Windows.Forms.Label
    Friend WithEvents cmbempname As System.Windows.Forms.ComboBox
    Friend WithEvents Label7 As System.Windows.Forms.Label
    Friend WithEvents Label10 As System.Windows.Forms.Label
    Friend WithEvents Label13 As System.Windows.Forms.Label
    Friend WithEvents TextBox5 As System.Windows.Forms.TextBox
    Friend WithEvents TextBox3 As System.Windows.Forms.TextBox
    Friend WithEvents dgvEmpList As DevComponents.DotNetBar.Controls.DataGridViewX
    Friend WithEvents c_EmployeeID As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents c_EmployeeName As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents c_ID As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Panel1 As System.Windows.Forms.Panel
    Friend WithEvents dgvEmpShiftList As DevComponents.DotNetBar.Controls.DataGridViewX
    Friend WithEvents Label8 As System.Windows.Forms.Label
    Friend WithEvents Label6 As System.Windows.Forms.Label
    Friend WithEvents Label5 As System.Windows.Forms.Label
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents txtEmpID As System.Windows.Forms.TextBox
    Friend WithEvents txtEmpName As System.Windows.Forms.TextBox
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents dtpDateTo As System.Windows.Forms.DateTimePicker
    Friend WithEvents dtpDateFrom As System.Windows.Forms.DateTimePicker
    Friend WithEvents dtpTimeTo As System.Windows.Forms.DateTimePicker
    Friend WithEvents dtpTimeFrom As System.Windows.Forms.DateTimePicker
    Friend WithEvents ToolStrip1 As System.Windows.Forms.ToolStrip
    Friend WithEvents btnNew As System.Windows.Forms.ToolStripButton
    Friend WithEvents btnSave As System.Windows.Forms.ToolStripButton
    Friend WithEvents ToolStripLabel1 As System.Windows.Forms.ToolStripLabel
    Friend WithEvents ToolStripSeparator1 As System.Windows.Forms.ToolStripSeparator
    Friend WithEvents btnDelete As System.Windows.Forms.ToolStripButton
    Friend WithEvents ToolStripSeparator2 As System.Windows.Forms.ToolStripSeparator
    Friend WithEvents btnCancel As System.Windows.Forms.ToolStripButton
    Friend WithEvents btnClose As System.Windows.Forms.ToolStripButton
    Friend WithEvents btnAudittrail As System.Windows.Forms.ToolStripButton
    Friend WithEvents lblSaveMsg As System.Windows.Forms.Label
    Friend WithEvents lblShiftEntry As System.Windows.Forms.LinkLabel
    Friend WithEvents lblShiftID As System.Windows.Forms.Label
    Friend WithEvents c_empIDShift As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents c_EmpnameShift As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents c_RowIDShift As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents c_DateFrom As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents c_DateTo As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents c_TimeFrom As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents c_TimeTo As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents chkNightShift As System.Windows.Forms.CheckBox
    Friend WithEvents chkrestday As System.Windows.Forms.CheckBox
    Private WithEvents SuperTabControl1 As DevComponents.DotNetBar.SuperTabControl
    Private WithEvents SuperTabControlPanel1 As DevComponents.DotNetBar.SuperTabControlPanel
    Private WithEvents SuperTabItem1 As DevComponents.DotNetBar.SuperTabItem
    Private WithEvents SuperTabControlPanel2 As DevComponents.DotNetBar.SuperTabControlPanel
    Private WithEvents SuperTabItem2 As DevComponents.DotNetBar.SuperTabItem
    Friend WithEvents cboshiftlist As System.Windows.Forms.ComboBox
    Friend WithEvents Label140 As System.Windows.Forms.Label
    Friend WithEvents tsbtnImportEmpShift As System.Windows.Forms.ToolStripButton
    Friend WithEvents ToolStripProgressBar1 As System.Windows.Forms.ToolStripProgressBar
    Friend WithEvents bgEmpShiftImport As System.ComponentModel.BackgroundWorker
    Friend WithEvents Last As System.Windows.Forms.LinkLabel
    Friend WithEvents Nxt As System.Windows.Forms.LinkLabel
    Friend WithEvents Prev As System.Windows.Forms.LinkLabel
    Friend WithEvents First As System.Windows.Forms.LinkLabel
End Class
