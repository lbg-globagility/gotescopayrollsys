<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class EmployeeData
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
        Dim resources As System.ComponentModel.ComponentResourceManager = New System.ComponentModel.ComponentResourceManager(GetType(EmployeeData))
        Me.dgvEmployee = New DevComponents.DotNetBar.Controls.DataGridViewX()
        Me.e_rowid = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.e_id = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.e_lname = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.e_fname = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.e_midname = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.e_type = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.e_status = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.e_posname = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.e_payfreqtype = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.e_dispinfo = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.ToolStrip1 = New System.Windows.Forms.ToolStrip()
        Me.ToolStripLabel1 = New System.Windows.Forms.ToolStripLabel()
        Me.tsSearch = New System.Windows.Forms.ToolStripTextBox()
        Me.tsbtnSearch = New System.Windows.Forms.ToolStripButton()
        Me.DeclaredToolStripMenuItem2 = New System.Windows.Forms.ToolStripMenuItem()
        Me.ActualToolStripMenuItem2 = New System.Windows.Forms.ToolStripMenuItem()
        Me.DeclaredToolStripMenuItem1 = New System.Windows.Forms.ToolStripMenuItem()
        Me.ActualToolStripMenuItem1 = New System.Windows.Forms.ToolStripMenuItem()
        Me.DeclaredToolStripMenuItem = New System.Windows.Forms.ToolStripMenuItem()
        Me.ActualToolStripMenuItem = New System.Windows.Forms.ToolStripMenuItem()
        Me.Panel1 = New System.Windows.Forms.Panel()
        Me.Button2 = New System.Windows.Forms.Button()
        Me.Button1 = New System.Windows.Forms.Button()
        CType(Me.dgvEmployee, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.ToolStrip1.SuspendLayout()
        Me.Panel1.SuspendLayout()
        Me.SuspendLayout()
        '
        'dgvEmployee
        '
        Me.dgvEmployee.AllowUserToAddRows = False
        Me.dgvEmployee.AllowUserToDeleteRows = False
        Me.dgvEmployee.AllowUserToResizeRows = False
        Me.dgvEmployee.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing
        Me.dgvEmployee.Columns.AddRange(New System.Windows.Forms.DataGridViewColumn() {Me.e_rowid, Me.e_id, Me.e_lname, Me.e_fname, Me.e_midname, Me.e_type, Me.e_status, Me.e_posname, Me.e_payfreqtype, Me.e_dispinfo})
        DataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle1.BackColor = System.Drawing.SystemColors.Window
        DataGridViewCellStyle1.Font = New System.Drawing.Font("Segoe UI", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        DataGridViewCellStyle1.ForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle1.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle1.SelectionForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.[False]
        Me.dgvEmployee.DefaultCellStyle = DataGridViewCellStyle1
        Me.dgvEmployee.Dock = System.Windows.Forms.DockStyle.Fill
        Me.dgvEmployee.GridColor = System.Drawing.Color.FromArgb(CType(CType(208, Byte), Integer), CType(CType(215, Byte), Integer), CType(CType(229, Byte), Integer))
        Me.dgvEmployee.Location = New System.Drawing.Point(0, 25)
        Me.dgvEmployee.MultiSelect = False
        Me.dgvEmployee.Name = "dgvEmployee"
        Me.dgvEmployee.ReadOnly = True
        Me.dgvEmployee.RowHeadersWidthSizeMode = System.Windows.Forms.DataGridViewRowHeadersWidthSizeMode.DisableResizing
        Me.dgvEmployee.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect
        Me.dgvEmployee.Size = New System.Drawing.Size(756, 326)
        Me.dgvEmployee.TabIndex = 2
        '
        'e_rowid
        '
        Me.e_rowid.HeaderText = "RowID"
        Me.e_rowid.Name = "e_rowid"
        Me.e_rowid.ReadOnly = True
        Me.e_rowid.Visible = False
        '
        'e_id
        '
        Me.e_id.HeaderText = "ID"
        Me.e_id.Name = "e_id"
        Me.e_id.ReadOnly = True
        '
        'e_lname
        '
        Me.e_lname.HeaderText = "Last Name"
        Me.e_lname.Name = "e_lname"
        Me.e_lname.ReadOnly = True
        '
        'e_fname
        '
        Me.e_fname.HeaderText = "First Name"
        Me.e_fname.Name = "e_fname"
        Me.e_fname.ReadOnly = True
        '
        'e_midname
        '
        Me.e_midname.HeaderText = "Middle Name"
        Me.e_midname.Name = "e_midname"
        Me.e_midname.ReadOnly = True
        '
        'e_type
        '
        Me.e_type.HeaderText = "Type"
        Me.e_type.Name = "e_type"
        Me.e_type.ReadOnly = True
        '
        'e_status
        '
        Me.e_status.HeaderText = "Employment status"
        Me.e_status.Name = "e_status"
        Me.e_status.ReadOnly = True
        '
        'e_posname
        '
        Me.e_posname.HeaderText = "Position"
        Me.e_posname.Name = "e_posname"
        Me.e_posname.ReadOnly = True
        '
        'e_payfreqtype
        '
        Me.e_payfreqtype.HeaderText = "Pay frequency"
        Me.e_payfreqtype.Name = "e_payfreqtype"
        Me.e_payfreqtype.ReadOnly = True
        Me.e_payfreqtype.Visible = False
        '
        'e_dispinfo
        '
        Me.e_dispinfo.HeaderText = "DisplayInfo"
        Me.e_dispinfo.Name = "e_dispinfo"
        Me.e_dispinfo.ReadOnly = True
        Me.e_dispinfo.Visible = False
        '
        'ToolStrip1
        '
        Me.ToolStrip1.GripStyle = System.Windows.Forms.ToolStripGripStyle.Hidden
        Me.ToolStrip1.Items.AddRange(New System.Windows.Forms.ToolStripItem() {Me.ToolStripLabel1, Me.tsSearch, Me.tsbtnSearch})
        Me.ToolStrip1.Location = New System.Drawing.Point(0, 0)
        Me.ToolStrip1.Name = "ToolStrip1"
        Me.ToolStrip1.Size = New System.Drawing.Size(756, 25)
        Me.ToolStrip1.TabIndex = 287
        Me.ToolStrip1.Text = "ToolStrip1"
        '
        'ToolStripLabel1
        '
        Me.ToolStripLabel1.Name = "ToolStripLabel1"
        Me.ToolStripLabel1.Size = New System.Drawing.Size(42, 22)
        Me.ToolStripLabel1.Text = "Search"
        '
        'tsSearch
        '
        Me.tsSearch.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.tsSearch.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!)
        Me.tsSearch.Name = "tsSearch"
        Me.tsSearch.Size = New System.Drawing.Size(250, 25)
        '
        'tsbtnSearch
        '
        Me.tsbtnSearch.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image
        Me.tsbtnSearch.Image = CType(resources.GetObject("tsbtnSearch.Image"), System.Drawing.Image)
        Me.tsbtnSearch.ImageTransparentColor = System.Drawing.Color.Magenta
        Me.tsbtnSearch.Name = "tsbtnSearch"
        Me.tsbtnSearch.Size = New System.Drawing.Size(23, 22)
        Me.tsbtnSearch.Text = "Search Employee"
        '
        'DeclaredToolStripMenuItem2
        '
        Me.DeclaredToolStripMenuItem2.Name = "DeclaredToolStripMenuItem2"
        Me.DeclaredToolStripMenuItem2.Size = New System.Drawing.Size(120, 22)
        Me.DeclaredToolStripMenuItem2.Tag = "0"
        Me.DeclaredToolStripMenuItem2.Text = "Declared"
        '
        'ActualToolStripMenuItem2
        '
        Me.ActualToolStripMenuItem2.Name = "ActualToolStripMenuItem2"
        Me.ActualToolStripMenuItem2.Size = New System.Drawing.Size(120, 22)
        Me.ActualToolStripMenuItem2.Tag = "1"
        Me.ActualToolStripMenuItem2.Text = "Actual"
        '
        'DeclaredToolStripMenuItem1
        '
        Me.DeclaredToolStripMenuItem1.Name = "DeclaredToolStripMenuItem1"
        Me.DeclaredToolStripMenuItem1.Size = New System.Drawing.Size(120, 22)
        Me.DeclaredToolStripMenuItem1.Tag = "0"
        Me.DeclaredToolStripMenuItem1.Text = "Declared"
        '
        'ActualToolStripMenuItem1
        '
        Me.ActualToolStripMenuItem1.Name = "ActualToolStripMenuItem1"
        Me.ActualToolStripMenuItem1.Size = New System.Drawing.Size(120, 22)
        Me.ActualToolStripMenuItem1.Tag = "1"
        Me.ActualToolStripMenuItem1.Text = "Actual"
        '
        'DeclaredToolStripMenuItem
        '
        Me.DeclaredToolStripMenuItem.Name = "DeclaredToolStripMenuItem"
        Me.DeclaredToolStripMenuItem.Size = New System.Drawing.Size(120, 22)
        Me.DeclaredToolStripMenuItem.Tag = "0"
        Me.DeclaredToolStripMenuItem.Text = "Declared"
        '
        'ActualToolStripMenuItem
        '
        Me.ActualToolStripMenuItem.Name = "ActualToolStripMenuItem"
        Me.ActualToolStripMenuItem.Size = New System.Drawing.Size(120, 22)
        Me.ActualToolStripMenuItem.Tag = "1"
        Me.ActualToolStripMenuItem.Text = "Actual"
        '
        'Panel1
        '
        Me.Panel1.Controls.Add(Me.Button2)
        Me.Panel1.Controls.Add(Me.Button1)
        Me.Panel1.Dock = System.Windows.Forms.DockStyle.Bottom
        Me.Panel1.Location = New System.Drawing.Point(0, 351)
        Me.Panel1.Name = "Panel1"
        Me.Panel1.Size = New System.Drawing.Size(756, 35)
        Me.Panel1.TabIndex = 288
        '
        'Button2
        '
        Me.Button2.Location = New System.Drawing.Point(669, 6)
        Me.Button2.Name = "Button2"
        Me.Button2.Size = New System.Drawing.Size(75, 23)
        Me.Button2.TabIndex = 0
        Me.Button2.Text = "Cancel"
        Me.Button2.UseVisualStyleBackColor = True
        '
        'Button1
        '
        Me.Button1.Location = New System.Drawing.Point(588, 6)
        Me.Button1.Name = "Button1"
        Me.Button1.Size = New System.Drawing.Size(75, 23)
        Me.Button1.TabIndex = 0
        Me.Button1.Text = "OK"
        Me.Button1.UseVisualStyleBackColor = True
        '
        'EmployeeData
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(756, 386)
        Me.Controls.Add(Me.dgvEmployee)
        Me.Controls.Add(Me.Panel1)
        Me.Controls.Add(Me.ToolStrip1)
        Me.Font = New System.Drawing.Font("Segoe UI", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
        Me.KeyPreview = True
        Me.MaximizeBox = False
        Me.MinimizeBox = False
        Me.Name = "EmployeeData"
        CType(Me.dgvEmployee, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ToolStrip1.ResumeLayout(False)
        Me.ToolStrip1.PerformLayout()
        Me.Panel1.ResumeLayout(False)
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents dgvEmployee As DevComponents.DotNetBar.Controls.DataGridViewX
    Friend WithEvents e_rowid As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents e_id As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents e_lname As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents e_fname As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents e_midname As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents e_type As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents e_status As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents e_posname As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents e_payfreqtype As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents e_dispinfo As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents ToolStrip1 As System.Windows.Forms.ToolStrip
    Friend WithEvents tsSearch As System.Windows.Forms.ToolStripTextBox
    Friend WithEvents tsbtnSearch As System.Windows.Forms.ToolStripButton
    Friend WithEvents DeclaredToolStripMenuItem2 As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents ActualToolStripMenuItem2 As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents DeclaredToolStripMenuItem1 As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents ActualToolStripMenuItem1 As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents DeclaredToolStripMenuItem As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents ActualToolStripMenuItem As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents ToolStripLabel1 As System.Windows.Forms.ToolStripLabel
    Friend WithEvents Panel1 As System.Windows.Forms.Panel
    Friend WithEvents Button2 As System.Windows.Forms.Button
    Friend WithEvents Button1 As System.Windows.Forms.Button
End Class
