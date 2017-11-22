<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class TrialForm
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
        Me.components = New System.ComponentModel.Container()
        Dim DataGridViewCellStyle1 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()
        Dim DataGridViewCellStyle2 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()
        Dim DataGridViewCellStyle4 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()
        Dim DataGridViewCellStyle3 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()
        Me.SplitContainer1 = New System.Windows.Forms.SplitContainer()
        Me.SplitContainer2 = New System.Windows.Forms.SplitContainer()
        Me.DataGridViewX1 = New DevComponents.DotNetBar.Controls.DataGridViewX()
        Me.FileSystemWatcher1 = New System.IO.FileSystemWatcher()
        Me.TextBox1 = New CustomObject.TextBox()
        Me.Timer1 = New System.Windows.Forms.Timer(Me.components)
        Me.Button1 = New System.Windows.Forms.Button()
        Me.Button2 = New System.Windows.Forms.Button()
        Me.CollapsibleGroupBox6 = New Indigo.CollapsibleGroupBox()
        Me.Panel7 = New System.Windows.Forms.Panel()
        Me.dgvEvaluationRegular = New DevComponents.DotNetBar.Controls.DataGridViewX()
        Me.Panel1 = New System.Windows.Forms.Panel()
        Me.NumericUpDown1 = New System.Windows.Forms.NumericUpDown()
        Me.Label1 = New System.Windows.Forms.Label()
        Me.BackgroundWorker1 = New System.ComponentModel.BackgroundWorker()
        Me.Timer2 = New System.Windows.Forms.Timer(Me.components)
        Me.ErrorProvider1 = New System.Windows.Forms.ErrorProvider(Me.components)
        Me.ToolTip1 = New System.Windows.Forms.ToolTip(Me.components)
        Me.Button3 = New System.Windows.Forms.Button()
        Me.CustomDateTextBox1 = New GotescoPayrollSys.CustomDateTextBox()
        Me.CustomDatePicker1 = New GotescoPayrollSys.CustomDatePicker()
        Me.DataGridViewX2 = New DevComponents.DotNetBar.Controls.DataGridViewX()
        Me.Column1 = New GotescoPayrollSys.DataGridViewNumberColumn()
        Me.Column2 = New GotescoPayrollSys.DataGridViewDateColumn()
        Me.PictureBox1 = New GotescoPayrollSys.CustomPictureBox()
        Me.DataGridViewMySQLTable1 = New GotescoPayrollSys.DataGridViewMySQLTable()
        Me.ComboBox1 = New System.Windows.Forms.ComboBox()
        Me.Button4 = New System.Windows.Forms.Button()
        CType(Me.SplitContainer1, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SplitContainer1.Panel2.SuspendLayout()
        Me.SplitContainer1.SuspendLayout()
        CType(Me.SplitContainer2, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SplitContainer2.SuspendLayout()
        CType(Me.DataGridViewX1, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.FileSystemWatcher1, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.CollapsibleGroupBox6.SuspendLayout()
        Me.Panel7.SuspendLayout()
        CType(Me.dgvEvaluationRegular, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.NumericUpDown1, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.ErrorProvider1, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.DataGridViewX2, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.PictureBox1, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'SplitContainer1
        '
        Me.SplitContainer1.Location = New System.Drawing.Point(194, 482)
        Me.SplitContainer1.Name = "SplitContainer1"
        '
        'SplitContainer1.Panel2
        '
        Me.SplitContainer1.Panel2.Controls.Add(Me.SplitContainer2)
        Me.SplitContainer1.Size = New System.Drawing.Size(534, 159)
        Me.SplitContainer1.SplitterDistance = 177
        Me.SplitContainer1.TabIndex = 0
        '
        'SplitContainer2
        '
        Me.SplitContainer2.Dock = System.Windows.Forms.DockStyle.Fill
        Me.SplitContainer2.Location = New System.Drawing.Point(0, 0)
        Me.SplitContainer2.Name = "SplitContainer2"
        Me.SplitContainer2.Size = New System.Drawing.Size(353, 159)
        Me.SplitContainer2.SplitterDistance = 174
        Me.SplitContainer2.TabIndex = 0
        '
        'DataGridViewX1
        '
        Me.DataGridViewX1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize
        DataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle1.BackColor = System.Drawing.SystemColors.Window
        DataGridViewCellStyle1.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        DataGridViewCellStyle1.ForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle1.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle1.SelectionForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.[False]
        Me.DataGridViewX1.DefaultCellStyle = DataGridViewCellStyle1
        Me.DataGridViewX1.GridColor = System.Drawing.Color.FromArgb(CType(CType(208, Byte), Integer), CType(CType(215, Byte), Integer), CType(CType(229, Byte), Integer))
        Me.DataGridViewX1.Location = New System.Drawing.Point(12, 647)
        Me.DataGridViewX1.Name = "DataGridViewX1"
        Me.DataGridViewX1.Size = New System.Drawing.Size(240, 150)
        Me.DataGridViewX1.TabIndex = 1
        '
        'FileSystemWatcher1
        '
        Me.FileSystemWatcher1.EnableRaisingEvents = True
        Me.FileSystemWatcher1.SynchronizingObject = Me
        '
        'TextBox1
        '
        Me.TextBox1.Location = New System.Drawing.Point(194, 456)
        Me.TextBox1.Name = "TextBox1"
        Me.TextBox1.Size = New System.Drawing.Size(100, 20)
        Me.TextBox1.TabIndex = 2
        '
        'Timer1
        '
        Me.Timer1.Enabled = True
        Me.Timer1.Interval = 1000
        '
        'Button1
        '
        Me.Button1.Location = New System.Drawing.Point(575, 787)
        Me.Button1.Name = "Button1"
        Me.Button1.Size = New System.Drawing.Size(75, 23)
        Me.Button1.TabIndex = 4
        Me.Button1.Text = "Button1"
        Me.Button1.UseVisualStyleBackColor = True
        '
        'Button2
        '
        Me.Button2.Location = New System.Drawing.Point(575, 816)
        Me.Button2.Name = "Button2"
        Me.Button2.Size = New System.Drawing.Size(75, 23)
        Me.Button2.TabIndex = 5
        Me.Button2.Text = "Button2"
        Me.Button2.UseVisualStyleBackColor = True
        '
        'CollapsibleGroupBox6
        '
        Me.CollapsibleGroupBox6.Controls.Add(Me.Panel7)
        Me.CollapsibleGroupBox6.Font = New System.Drawing.Font("Segoe UI Semibold", 11.25!, System.Drawing.FontStyle.Bold)
        Me.CollapsibleGroupBox6.Location = New System.Drawing.Point(175, 816)
        Me.CollapsibleGroupBox6.Name = "CollapsibleGroupBox6"
        Me.CollapsibleGroupBox6.Size = New System.Drawing.Size(296, 246)
        Me.CollapsibleGroupBox6.TabIndex = 138
        Me.CollapsibleGroupBox6.TabStop = False
        Me.CollapsibleGroupBox6.Text = "EMP. LACKING REQUIREMENTS"
        '
        'Panel7
        '
        Me.Panel7.Controls.Add(Me.dgvEvaluationRegular)
        Me.Panel7.Dock = System.Windows.Forms.DockStyle.Fill
        Me.Panel7.Location = New System.Drawing.Point(3, 23)
        Me.Panel7.Name = "Panel7"
        Me.Panel7.Size = New System.Drawing.Size(290, 220)
        Me.Panel7.TabIndex = 0
        '
        'dgvEvaluationRegular
        '
        Me.dgvEvaluationRegular.AllowUserToAddRows = False
        Me.dgvEvaluationRegular.AllowUserToDeleteRows = False
        Me.dgvEvaluationRegular.AllowUserToOrderColumns = True
        Me.dgvEvaluationRegular.BackgroundColor = System.Drawing.Color.White
        Me.dgvEvaluationRegular.ColumnHeadersHeight = 34
        DataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle2.BackColor = System.Drawing.SystemColors.Window
        DataGridViewCellStyle2.Font = New System.Drawing.Font("Segoe UI Semibold", 11.25!, System.Drawing.FontStyle.Bold)
        DataGridViewCellStyle2.ForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle2.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle2.SelectionForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.[False]
        Me.dgvEvaluationRegular.DefaultCellStyle = DataGridViewCellStyle2
        Me.dgvEvaluationRegular.Dock = System.Windows.Forms.DockStyle.Fill
        Me.dgvEvaluationRegular.Enabled = False
        Me.dgvEvaluationRegular.GridColor = System.Drawing.Color.FromArgb(CType(CType(208, Byte), Integer), CType(CType(215, Byte), Integer), CType(CType(229, Byte), Integer))
        Me.dgvEvaluationRegular.Location = New System.Drawing.Point(0, 0)
        Me.dgvEvaluationRegular.MultiSelect = False
        Me.dgvEvaluationRegular.Name = "dgvEvaluationRegular"
        Me.dgvEvaluationRegular.ReadOnly = True
        Me.dgvEvaluationRegular.RowHeadersWidth = 30
        Me.dgvEvaluationRegular.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect
        Me.dgvEvaluationRegular.Size = New System.Drawing.Size(290, 220)
        Me.dgvEvaluationRegular.TabIndex = 124
        '
        'Panel1
        '
        Me.Panel1.Location = New System.Drawing.Point(29, 474)
        Me.Panel1.Name = "Panel1"
        Me.Panel1.Size = New System.Drawing.Size(64, 100)
        Me.Panel1.TabIndex = 139
        '
        'NumericUpDown1
        '
        Me.NumericUpDown1.Location = New System.Drawing.Point(29, 580)
        Me.NumericUpDown1.Maximum = New Decimal(New Integer() {255, 0, 0, 0})
        Me.NumericUpDown1.Name = "NumericUpDown1"
        Me.NumericUpDown1.Size = New System.Drawing.Size(120, 20)
        Me.NumericUpDown1.TabIndex = 0
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.Location = New System.Drawing.Point(12, 862)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(39, 13)
        Me.Label1.TabIndex = 141
        Me.Label1.Text = "Label1"
        '
        'BackgroundWorker1
        '
        '
        'Timer2
        '
        Me.Timer2.Enabled = True
        Me.Timer2.Interval = 800
        '
        'ErrorProvider1
        '
        Me.ErrorProvider1.ContainerControl = Me
        '
        'ToolTip1
        '
        Me.ToolTip1.ToolTipIcon = System.Windows.Forms.ToolTipIcon.[Error]
        '
        'Button3
        '
        Me.Button3.Location = New System.Drawing.Point(534, 660)
        Me.Button3.Name = "Button3"
        Me.Button3.Size = New System.Drawing.Size(75, 23)
        Me.Button3.TabIndex = 143
        Me.Button3.Text = "SEND SMS"
        Me.Button3.UseVisualStyleBackColor = True
        '
        'CustomDateTextBox1
        '
        Me.CustomDateTextBox1.ErrorContent = "Input was unrecognized as date"
        Me.CustomDateTextBox1.ErrorTitle = "Invalid date value"
        Me.CustomDateTextBox1.Location = New System.Drawing.Point(534, 882)
        Me.CustomDateTextBox1.Name = "CustomDateTextBox1"
        Me.CustomDateTextBox1.Size = New System.Drawing.Size(100, 20)
        Me.CustomDateTextBox1.TabIndex = 142
        '
        'CustomDatePicker1
        '
        Me.CustomDatePicker1.Format = System.Windows.Forms.DateTimePickerFormat.Custom
        Me.CustomDatePicker1.Location = New System.Drawing.Point(12, 839)
        Me.CustomDatePicker1.Name = "CustomDatePicker1"
        Me.CustomDatePicker1.Size = New System.Drawing.Size(113, 20)
        Me.CustomDatePicker1.TabIndex = 140
        Me.CustomDatePicker1.Tag = "2016-08-11"
        Me.CustomDatePicker1.Value = New Date(2016, 8, 11, 0, 0, 0, 0)
        '
        'DataGridViewX2
        '
        Me.DataGridViewX2.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize
        Me.DataGridViewX2.Columns.AddRange(New System.Windows.Forms.DataGridViewColumn() {Me.Column1, Me.Column2})
        DataGridViewCellStyle4.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle4.BackColor = System.Drawing.SystemColors.Window
        DataGridViewCellStyle4.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        DataGridViewCellStyle4.ForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle4.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle4.SelectionForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle4.WrapMode = System.Windows.Forms.DataGridViewTriState.[False]
        Me.DataGridViewX2.DefaultCellStyle = DataGridViewCellStyle4
        Me.DataGridViewX2.GridColor = System.Drawing.Color.FromArgb(CType(CType(208, Byte), Integer), CType(CType(215, Byte), Integer), CType(CType(229, Byte), Integer))
        Me.DataGridViewX2.Location = New System.Drawing.Point(258, 647)
        Me.DataGridViewX2.Name = "DataGridViewX2"
        Me.DataGridViewX2.Size = New System.Drawing.Size(240, 150)
        Me.DataGridViewX2.TabIndex = 7
        '
        'Column1
        '
        Me.Column1.HeaderText = "Column1"
        Me.Column1.MaxInputLength = 11
        Me.Column1.Name = "Column1"
        '
        'Column2
        '
        DataGridViewCellStyle3.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle3.BackColor = System.Drawing.SystemColors.Window
        DataGridViewCellStyle3.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        DataGridViewCellStyle3.ForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle3.Format = "M/d/yyyy"
        DataGridViewCellStyle3.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle3.SelectionForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle3.WrapMode = System.Windows.Forms.DataGridViewTriState.[False]
        Me.Column2.DefaultCellStyle = DataGridViewCellStyle3
        Me.Column2.HeaderText = "Column2"
        Me.Column2.MaxInputLength = 11
        Me.Column2.Name = "Column2"
        '
        'PictureBox1
        '
        Me.PictureBox1.Image = Nothing
        Me.PictureBox1.Location = New System.Drawing.Point(656, 647)
        Me.PictureBox1.Name = "PictureBox1"
        Me.PictureBox1.Size = New System.Drawing.Size(192, 192)
        Me.PictureBox1.TabIndex = 6
        Me.PictureBox1.TabStop = False
        '
        'DataGridViewMySQLTable1
        '
        Me.DataGridViewMySQLTable1.AllowPagination = True
        Me.DataGridViewMySQLTable1.DisplayedRecordPerPage = 0
        Me.DataGridViewMySQLTable1.Location = New System.Drawing.Point(665, 882)
        Me.DataGridViewMySQLTable1.MySQLTableSource = ""
        Me.DataGridViewMySQLTable1.Name = "DataGridViewMySQLTable1"
        Me.DataGridViewMySQLTable1.Size = New System.Drawing.Size(150, 117)
        Me.DataGridViewMySQLTable1.TabIndex = 144
        Me.DataGridViewMySQLTable1.ViewProcedureName = ""
        Me.DataGridViewMySQLTable1.ViewProcedureParameterValues = Nothing
        '
        'ComboBox1
        '
        Me.ComboBox1.FormattingEnabled = True
        Me.ComboBox1.Location = New System.Drawing.Point(297, 165)
        Me.ComboBox1.Name = "ComboBox1"
        Me.ComboBox1.Size = New System.Drawing.Size(121, 21)
        Me.ComboBox1.TabIndex = 145
        '
        'Button4
        '
        Me.Button4.Location = New System.Drawing.Point(375, 98)
        Me.Button4.Name = "Button4"
        Me.Button4.Size = New System.Drawing.Size(75, 23)
        Me.Button4.TabIndex = 146
        Me.Button4.Text = "ShiftTemplater"
        Me.Button4.UseVisualStyleBackColor = True
        '
        'TrialForm
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.AutoScroll = True
        Me.ClientSize = New System.Drawing.Size(860, 487)
        Me.Controls.Add(Me.Button4)
        Me.Controls.Add(Me.ComboBox1)
        Me.Controls.Add(Me.DataGridViewMySQLTable1)
        Me.Controls.Add(Me.Button3)
        Me.Controls.Add(Me.CustomDateTextBox1)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.CustomDatePicker1)
        Me.Controls.Add(Me.NumericUpDown1)
        Me.Controls.Add(Me.Panel1)
        Me.Controls.Add(Me.CollapsibleGroupBox6)
        Me.Controls.Add(Me.DataGridViewX2)
        Me.Controls.Add(Me.PictureBox1)
        Me.Controls.Add(Me.Button2)
        Me.Controls.Add(Me.Button1)
        Me.Controls.Add(Me.TextBox1)
        Me.Controls.Add(Me.DataGridViewX1)
        Me.Controls.Add(Me.SplitContainer1)
        Me.Name = "TrialForm"
        Me.Text = "TrialForm"
        Me.SplitContainer1.Panel2.ResumeLayout(False)
        CType(Me.SplitContainer1, System.ComponentModel.ISupportInitialize).EndInit()
        Me.SplitContainer1.ResumeLayout(False)
        CType(Me.SplitContainer2, System.ComponentModel.ISupportInitialize).EndInit()
        Me.SplitContainer2.ResumeLayout(False)
        CType(Me.DataGridViewX1, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.FileSystemWatcher1, System.ComponentModel.ISupportInitialize).EndInit()
        Me.CollapsibleGroupBox6.ResumeLayout(False)
        Me.Panel7.ResumeLayout(False)
        CType(Me.dgvEvaluationRegular, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.NumericUpDown1, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.ErrorProvider1, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.DataGridViewX2, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.PictureBox1, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents SplitContainer1 As System.Windows.Forms.SplitContainer
    Friend WithEvents SplitContainer2 As System.Windows.Forms.SplitContainer
    Friend WithEvents DataGridViewX1 As DevComponents.DotNetBar.Controls.DataGridViewX
    Friend WithEvents FileSystemWatcher1 As System.IO.FileSystemWatcher
    Friend WithEvents TextBox1 As CustomObject.TextBox
    Friend WithEvents Timer1 As System.Windows.Forms.Timer
    Friend WithEvents Button1 As System.Windows.Forms.Button
    Friend WithEvents Button2 As System.Windows.Forms.Button
    Friend WithEvents PictureBox1 As GotescoPayrollSys.CustomPictureBox
    Friend WithEvents DataGridViewX2 As DevComponents.DotNetBar.Controls.DataGridViewX
    Friend WithEvents Column1 As GotescoPayrollSys.DataGridViewNumberColumn
    Friend WithEvents Column2 As GotescoPayrollSys.DataGridViewDateColumn
    Friend WithEvents CollapsibleGroupBox6 As Indigo.CollapsibleGroupBox
    Friend WithEvents Panel7 As System.Windows.Forms.Panel
    Friend WithEvents dgvEvaluationRegular As DevComponents.DotNetBar.Controls.DataGridViewX
    Friend WithEvents NumericUpDown1 As System.Windows.Forms.NumericUpDown
    Friend WithEvents Panel1 As System.Windows.Forms.Panel
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents CustomDatePicker1 As GotescoPayrollSys.CustomDatePicker
    Friend WithEvents BackgroundWorker1 As System.ComponentModel.BackgroundWorker
    Friend WithEvents CustomDateTextBox1 As GotescoPayrollSys.CustomDateTextBox
    Friend WithEvents Timer2 As System.Windows.Forms.Timer
    Friend WithEvents ErrorProvider1 As System.Windows.Forms.ErrorProvider
    Friend WithEvents ToolTip1 As System.Windows.Forms.ToolTip
    Friend WithEvents Button3 As System.Windows.Forms.Button
    Friend WithEvents DataGridViewMySQLTable1 As GotescoPayrollSys.DataGridViewMySQLTable
    Friend WithEvents ComboBox1 As System.Windows.Forms.ComboBox
    Friend WithEvents Button4 As System.Windows.Forms.Button

End Class
