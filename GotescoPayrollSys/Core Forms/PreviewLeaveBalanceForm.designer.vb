<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class PreviewLeaveBalanceForm
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
        Dim DataGridViewCellStyle1 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()
        Me.dgvEmployees = New DevComponents.DotNetBar.Controls.DataGridViewX()
        Me.eRowId = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.eId = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.eLastName = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.eFirstName = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.eVacationLeaveAllowance = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.eVacationLeaveBalance = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.eSickLeaveAllowance = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.eSickLeaveBalance = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.eAddtlLeaveAllowance = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.eAddtlLeaveBalance = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Panel1 = New System.Windows.Forms.Panel()
        Me.ProgressBar1 = New System.Windows.Forms.ProgressBar()
        Me.btnClose = New System.Windows.Forms.Button()
        Me.btnReset = New System.Windows.Forms.Button()
        Me.ToolStrip1 = New System.Windows.Forms.ToolStrip()
        Me.tsbtnSaveEmp = New System.Windows.Forms.ToolStripButton()
        Me.DataGridViewTextBoxColumn1 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.DataGridViewTextBoxColumn2 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.DataGridViewTextBoxColumn3 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.DataGridViewTextBoxColumn4 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.DataGridViewTextBoxColumn5 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.DataGridViewTextBoxColumn6 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.DataGridViewTextBoxColumn7 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.DataGridViewTextBoxColumn8 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.DataGridViewTextBoxColumn9 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.DataGridViewTextBoxColumn10 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        CType(Me.dgvEmployees, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.Panel1.SuspendLayout()
        Me.ToolStrip1.SuspendLayout()
        Me.SuspendLayout()
        '
        'dgvEmployees
        '
        Me.dgvEmployees.AllowUserToAddRows = False
        Me.dgvEmployees.AllowUserToDeleteRows = False
        Me.dgvEmployees.AllowUserToResizeColumns = False
        Me.dgvEmployees.AllowUserToResizeRows = False
        Me.dgvEmployees.BackgroundColor = System.Drawing.Color.White
        Me.dgvEmployees.ColumnHeadersHeight = 34
        Me.dgvEmployees.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing
        Me.dgvEmployees.Columns.AddRange(New System.Windows.Forms.DataGridViewColumn() {Me.eRowId, Me.eId, Me.eLastName, Me.eFirstName, Me.eVacationLeaveAllowance, Me.eVacationLeaveBalance, Me.eSickLeaveAllowance, Me.eSickLeaveBalance, Me.eAddtlLeaveAllowance, Me.eAddtlLeaveBalance})
        DataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle1.BackColor = System.Drawing.SystemColors.Window
        DataGridViewCellStyle1.Font = New System.Drawing.Font("Segoe UI", 8.25!)
        DataGridViewCellStyle1.ForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle1.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle1.SelectionForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.[False]
        Me.dgvEmployees.DefaultCellStyle = DataGridViewCellStyle1
        Me.dgvEmployees.Dock = System.Windows.Forms.DockStyle.Fill
        Me.dgvEmployees.GridColor = System.Drawing.Color.FromArgb(CType(CType(208, Byte), Integer), CType(CType(215, Byte), Integer), CType(CType(229, Byte), Integer))
        Me.dgvEmployees.Location = New System.Drawing.Point(0, 0)
        Me.dgvEmployees.MultiSelect = False
        Me.dgvEmployees.Name = "dgvEmployees"
        Me.dgvEmployees.ReadOnly = True
        Me.dgvEmployees.RowHeadersWidth = 32
        Me.dgvEmployees.RowHeadersWidthSizeMode = System.Windows.Forms.DataGridViewRowHeadersWidthSizeMode.DisableResizing
        Me.dgvEmployees.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect
        Me.dgvEmployees.Size = New System.Drawing.Size(960, 415)
        Me.dgvEmployees.TabIndex = 138
        '
        'eRowId
        '
        Me.eRowId.DataPropertyName = "RowID"
        Me.eRowId.HeaderText = "RowID"
        Me.eRowId.Name = "eRowId"
        Me.eRowId.ReadOnly = True
        Me.eRowId.Visible = False
        '
        'eId
        '
        Me.eId.DataPropertyName = "EmployeeNo"
        Me.eId.HeaderText = "Employee ID"
        Me.eId.Name = "eId"
        Me.eId.ReadOnly = True
        Me.eId.Width = 103
        '
        'eLastName
        '
        Me.eLastName.DataPropertyName = "LastName"
        Me.eLastName.HeaderText = "Last Name"
        Me.eLastName.Name = "eLastName"
        Me.eLastName.ReadOnly = True
        Me.eLastName.Width = 103
        '
        'eFirstName
        '
        Me.eFirstName.DataPropertyName = "FirstName"
        Me.eFirstName.HeaderText = "First Name"
        Me.eFirstName.Name = "eFirstName"
        Me.eFirstName.ReadOnly = True
        Me.eFirstName.Width = 103
        '
        'eVacationLeaveAllowance
        '
        Me.eVacationLeaveAllowance.DataPropertyName = "VacationLeaveAllowance"
        Me.eVacationLeaveAllowance.HeaderText = "Vacation Leave Allowance"
        Me.eVacationLeaveAllowance.Name = "eVacationLeaveAllowance"
        Me.eVacationLeaveAllowance.ReadOnly = True
        '
        'eVacationLeaveBalance
        '
        Me.eVacationLeaveBalance.DataPropertyName = "VacationLeaveBalance"
        Me.eVacationLeaveBalance.HeaderText = "Vacation Leave Balance"
        Me.eVacationLeaveBalance.Name = "eVacationLeaveBalance"
        Me.eVacationLeaveBalance.ReadOnly = True
        '
        'eSickLeaveAllowance
        '
        Me.eSickLeaveAllowance.DataPropertyName = "SickLeaveAllowance"
        Me.eSickLeaveAllowance.HeaderText = "Sick Leave Allowance"
        Me.eSickLeaveAllowance.Name = "eSickLeaveAllowance"
        Me.eSickLeaveAllowance.ReadOnly = True
        '
        'eSickLeaveBalance
        '
        Me.eSickLeaveBalance.DataPropertyName = "SickLeaveBalance"
        Me.eSickLeaveBalance.HeaderText = "Sick Leave Balance"
        Me.eSickLeaveBalance.Name = "eSickLeaveBalance"
        Me.eSickLeaveBalance.ReadOnly = True
        '
        'eAddtlLeaveAllowance
        '
        Me.eAddtlLeaveAllowance.DataPropertyName = "AdditionalVLAllowance"
        Me.eAddtlLeaveAllowance.HeaderText = "Additional Leave Allowance"
        Me.eAddtlLeaveAllowance.Name = "eAddtlLeaveAllowance"
        Me.eAddtlLeaveAllowance.ReadOnly = True
        '
        'eAddtlLeaveBalance
        '
        Me.eAddtlLeaveBalance.DataPropertyName = "AdditionalVLBalance"
        Me.eAddtlLeaveBalance.HeaderText = "Additional Leave Balance"
        Me.eAddtlLeaveBalance.Name = "eAddtlLeaveBalance"
        Me.eAddtlLeaveBalance.ReadOnly = True
        '
        'Panel1
        '
        Me.Panel1.Controls.Add(Me.ProgressBar1)
        Me.Panel1.Controls.Add(Me.btnClose)
        Me.Panel1.Controls.Add(Me.btnReset)
        Me.Panel1.Dock = System.Windows.Forms.DockStyle.Bottom
        Me.Panel1.Location = New System.Drawing.Point(0, 415)
        Me.Panel1.Name = "Panel1"
        Me.Panel1.Size = New System.Drawing.Size(960, 35)
        Me.Panel1.TabIndex = 139
        '
        'ProgressBar1
        '
        Me.ProgressBar1.Dock = System.Windows.Forms.DockStyle.Left
        Me.ProgressBar1.Location = New System.Drawing.Point(0, 0)
        Me.ProgressBar1.Name = "ProgressBar1"
        Me.ProgressBar1.Size = New System.Drawing.Size(100, 35)
        Me.ProgressBar1.TabIndex = 1
        Me.ProgressBar1.Visible = False
        '
        'btnClose
        '
        Me.btnClose.Location = New System.Drawing.Point(873, 6)
        Me.btnClose.Name = "btnClose"
        Me.btnClose.Size = New System.Drawing.Size(75, 23)
        Me.btnClose.TabIndex = 0
        Me.btnClose.Text = "Close"
        Me.btnClose.UseVisualStyleBackColor = True
        '
        'btnReset
        '
        Me.btnReset.Location = New System.Drawing.Point(652, 6)
        Me.btnReset.Name = "btnReset"
        Me.btnReset.Size = New System.Drawing.Size(215, 23)
        Me.btnReset.TabIndex = 0
        Me.btnReset.Text = "Reset from most current period"
        Me.btnReset.UseVisualStyleBackColor = True
        '
        'ToolStrip1
        '
        Me.ToolStrip1.BackColor = System.Drawing.Color.White
        Me.ToolStrip1.GripStyle = System.Windows.Forms.ToolStripGripStyle.Hidden
        Me.ToolStrip1.Items.AddRange(New System.Windows.Forms.ToolStripItem() {Me.tsbtnSaveEmp})
        Me.ToolStrip1.Location = New System.Drawing.Point(0, 0)
        Me.ToolStrip1.Name = "ToolStrip1"
        Me.ToolStrip1.Size = New System.Drawing.Size(960, 25)
        Me.ToolStrip1.TabIndex = 140
        Me.ToolStrip1.Text = "ToolStrip1"
        Me.ToolStrip1.Visible = False
        '
        'tsbtnSaveEmp
        '
        Me.tsbtnSaveEmp.ImageTransparentColor = System.Drawing.Color.Magenta
        Me.tsbtnSaveEmp.Name = "tsbtnSaveEmp"
        Me.tsbtnSaveEmp.Size = New System.Drawing.Size(90, 22)
        Me.tsbtnSaveEmp.Text = "&Save Employee"
        '
        'DataGridViewTextBoxColumn1
        '
        Me.DataGridViewTextBoxColumn1.DataPropertyName = "RowID"
        Me.DataGridViewTextBoxColumn1.HeaderText = "RowID"
        Me.DataGridViewTextBoxColumn1.Name = "DataGridViewTextBoxColumn1"
        Me.DataGridViewTextBoxColumn1.Visible = False
        '
        'DataGridViewTextBoxColumn2
        '
        Me.DataGridViewTextBoxColumn2.DataPropertyName = "EmployeeNo"
        Me.DataGridViewTextBoxColumn2.HeaderText = "Employee ID"
        Me.DataGridViewTextBoxColumn2.Name = "DataGridViewTextBoxColumn2"
        Me.DataGridViewTextBoxColumn2.Width = 103
        '
        'DataGridViewTextBoxColumn3
        '
        Me.DataGridViewTextBoxColumn3.DataPropertyName = "LastName"
        Me.DataGridViewTextBoxColumn3.HeaderText = "Last Name"
        Me.DataGridViewTextBoxColumn3.Name = "DataGridViewTextBoxColumn3"
        Me.DataGridViewTextBoxColumn3.Width = 103
        '
        'DataGridViewTextBoxColumn4
        '
        Me.DataGridViewTextBoxColumn4.DataPropertyName = "FirstName"
        Me.DataGridViewTextBoxColumn4.HeaderText = "First Name"
        Me.DataGridViewTextBoxColumn4.Name = "DataGridViewTextBoxColumn4"
        Me.DataGridViewTextBoxColumn4.Width = 103
        '
        'DataGridViewTextBoxColumn5
        '
        Me.DataGridViewTextBoxColumn5.DataPropertyName = "VacationLeaveAllowance"
        Me.DataGridViewTextBoxColumn5.HeaderText = "Vacation Leave Allowance"
        Me.DataGridViewTextBoxColumn5.Name = "DataGridViewTextBoxColumn5"
        '
        'DataGridViewTextBoxColumn6
        '
        Me.DataGridViewTextBoxColumn6.DataPropertyName = "VacationLeaveBalance"
        Me.DataGridViewTextBoxColumn6.HeaderText = "Vacation Leave Balance"
        Me.DataGridViewTextBoxColumn6.Name = "DataGridViewTextBoxColumn6"
        '
        'DataGridViewTextBoxColumn7
        '
        Me.DataGridViewTextBoxColumn7.DataPropertyName = "SickLeaveAllowance"
        Me.DataGridViewTextBoxColumn7.HeaderText = "Sick Leave Allowance"
        Me.DataGridViewTextBoxColumn7.Name = "DataGridViewTextBoxColumn7"
        '
        'DataGridViewTextBoxColumn8
        '
        Me.DataGridViewTextBoxColumn8.DataPropertyName = "SickLeaveBalance"
        Me.DataGridViewTextBoxColumn8.HeaderText = "Sick Leave Balance"
        Me.DataGridViewTextBoxColumn8.Name = "DataGridViewTextBoxColumn8"
        '
        'DataGridViewTextBoxColumn9
        '
        Me.DataGridViewTextBoxColumn9.DataPropertyName = "AdditionalVLAllowance"
        Me.DataGridViewTextBoxColumn9.HeaderText = "Additional Leave Allowance"
        Me.DataGridViewTextBoxColumn9.Name = "DataGridViewTextBoxColumn9"
        '
        'DataGridViewTextBoxColumn10
        '
        Me.DataGridViewTextBoxColumn10.DataPropertyName = "AdditionalVLBalance"
        Me.DataGridViewTextBoxColumn10.HeaderText = "Additional Leave Balance"
        Me.DataGridViewTextBoxColumn10.Name = "DataGridViewTextBoxColumn10"
        '
        'PreviewLeaveBalanceForm
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(960, 450)
        Me.Controls.Add(Me.dgvEmployees)
        Me.Controls.Add(Me.ToolStrip1)
        Me.Controls.Add(Me.Panel1)
        Me.Font = New System.Drawing.Font("Segoe UI", 8.25!)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
        Me.KeyPreview = True
        Me.MaximizeBox = False
        Me.MinimizeBox = False
        Me.Name = "PreviewLeaveBalanceForm"
        Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen
        Me.Text = "Preview leave allowance and balance"
        CType(Me.dgvEmployees, System.ComponentModel.ISupportInitialize).EndInit()
        Me.Panel1.ResumeLayout(False)
        Me.ToolStrip1.ResumeLayout(False)
        Me.ToolStrip1.PerformLayout()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub

    Friend WithEvents dgvEmployees As DevComponents.DotNetBar.Controls.DataGridViewX
    Friend WithEvents Panel1 As Panel
    Friend WithEvents btnClose As Button
    Friend WithEvents btnReset As Button
    Friend WithEvents ProgressBar1 As ProgressBar
    Friend WithEvents ToolStrip1 As ToolStrip
    Friend WithEvents tsbtnSaveEmp As ToolStripButton
    Friend WithEvents eRowId As DataGridViewTextBoxColumn
    Friend WithEvents eId As DataGridViewTextBoxColumn
    Friend WithEvents eLastName As DataGridViewTextBoxColumn
    Friend WithEvents eFirstName As DataGridViewTextBoxColumn
    Friend WithEvents eVacationLeaveAllowance As DataGridViewTextBoxColumn
    Friend WithEvents eVacationLeaveBalance As DataGridViewTextBoxColumn
    Friend WithEvents eSickLeaveAllowance As DataGridViewTextBoxColumn
    Friend WithEvents eSickLeaveBalance As DataGridViewTextBoxColumn
    Friend WithEvents eAddtlLeaveAllowance As DataGridViewTextBoxColumn
    Friend WithEvents eAddtlLeaveBalance As DataGridViewTextBoxColumn
    Friend WithEvents DataGridViewTextBoxColumn1 As DataGridViewTextBoxColumn
    Friend WithEvents DataGridViewTextBoxColumn2 As DataGridViewTextBoxColumn
    Friend WithEvents DataGridViewTextBoxColumn3 As DataGridViewTextBoxColumn
    Friend WithEvents DataGridViewTextBoxColumn4 As DataGridViewTextBoxColumn
    Friend WithEvents DataGridViewTextBoxColumn5 As DataGridViewTextBoxColumn
    Friend WithEvents DataGridViewTextBoxColumn6 As DataGridViewTextBoxColumn
    Friend WithEvents DataGridViewTextBoxColumn7 As DataGridViewTextBoxColumn
    Friend WithEvents DataGridViewTextBoxColumn8 As DataGridViewTextBoxColumn
    Friend WithEvents DataGridViewTextBoxColumn9 As DataGridViewTextBoxColumn
    Friend WithEvents DataGridViewTextBoxColumn10 As DataGridViewTextBoxColumn
End Class
