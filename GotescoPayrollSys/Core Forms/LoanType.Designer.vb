<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class LoanType
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
        Dim DataGridViewCellStyle3 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()
        Dim DataGridViewCellStyle4 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()
        Dim DataGridViewCellStyle2 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()
        Me.TextBox1 = New System.Windows.Forms.TextBox()
        Me.Button1 = New System.Windows.Forms.Button()
        Me.Button2 = New System.Windows.Forms.Button()
        Me.Label1 = New System.Windows.Forms.Label()
        Me.Label164 = New System.Windows.Forms.Label()
        Me.chknondeductible = New System.Windows.Forms.CheckBox()
        Me.lnklblleave = New System.Windows.Forms.LinkLabel()
        Me.dgvproduct = New DevComponents.DotNetBar.Controls.DataGridViewX()
        Me.RowID = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.PartNo = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Strength = New System.Windows.Forms.DataGridViewCheckBoxColumn()
        CType(Me.dgvproduct, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'TextBox1
        '
        Me.TextBox1.Location = New System.Drawing.Point(103, 12)
        Me.TextBox1.Multiline = True
        Me.TextBox1.Name = "TextBox1"
        Me.TextBox1.ScrollBars = System.Windows.Forms.ScrollBars.Vertical
        Me.TextBox1.Size = New System.Drawing.Size(193, 44)
        Me.TextBox1.TabIndex = 0
        '
        'Button1
        '
        Me.Button1.Location = New System.Drawing.Point(172, 112)
        Me.Button1.Name = "Button1"
        Me.Button1.Size = New System.Drawing.Size(75, 23)
        Me.Button1.TabIndex = 1
        Me.Button1.Text = "&Add"
        Me.Button1.UseVisualStyleBackColor = True
        '
        'Button2
        '
        Me.Button2.Location = New System.Drawing.Point(253, 112)
        Me.Button2.Name = "Button2"
        Me.Button2.Size = New System.Drawing.Size(75, 23)
        Me.Button2.TabIndex = 2
        Me.Button2.Text = "Close"
        Me.Button2.UseVisualStyleBackColor = True
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.Location = New System.Drawing.Point(16, 19)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(66, 13)
        Me.Label1.TabIndex = 3
        Me.Label1.Text = "Loan name :"
        '
        'Label164
        '
        Me.Label164.AutoSize = True
        Me.Label164.Font = New System.Drawing.Font("Gisha", 14.25!, System.Drawing.FontStyle.Bold)
        Me.Label164.ForeColor = System.Drawing.Color.FromArgb(CType(CType(255, Byte), Integer), CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer))
        Me.Label164.Location = New System.Drawing.Point(79, 11)
        Me.Label164.Name = "Label164"
        Me.Label164.Size = New System.Drawing.Size(19, 23)
        Me.Label164.TabIndex = 355
        Me.Label164.Text = "*"
        '
        'chknondeductible
        '
        Me.chknondeductible.AutoSize = True
        Me.chknondeductible.Location = New System.Drawing.Point(103, 62)
        Me.chknondeductible.Name = "chknondeductible"
        Me.chknondeductible.Size = New System.Drawing.Size(137, 17)
        Me.chknondeductible.TabIndex = 356
        Me.chknondeductible.Text = "Nondeductible to salary"
        Me.chknondeductible.UseVisualStyleBackColor = True
        '
        'lnklblleave
        '
        Me.lnklblleave.AutoSize = True
        Me.lnklblleave.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lnklblleave.LinkBehavior = System.Windows.Forms.LinkBehavior.HoverUnderline
        Me.lnklblleave.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.lnklblleave.Location = New System.Drawing.Point(16, 120)
        Me.lnklblleave.Name = "lnklblleave"
        Me.lnklblleave.Size = New System.Drawing.Size(70, 15)
        Me.lnklblleave.TabIndex = 357
        Me.lnklblleave.TabStop = True
        Me.lnklblleave.Text = "Vi&ew others"
        '
        'dgvproduct
        '
        Me.dgvproduct.AllowUserToAddRows = False
        Me.dgvproduct.AllowUserToDeleteRows = False
        Me.dgvproduct.AllowUserToResizeColumns = False
        Me.dgvproduct.AllowUserToResizeRows = False
        DataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.[True]
        Me.dgvproduct.AlternatingRowsDefaultCellStyle = DataGridViewCellStyle1
        Me.dgvproduct.BackgroundColor = System.Drawing.Color.White
        Me.dgvproduct.Columns.AddRange(New System.Windows.Forms.DataGridViewColumn() {Me.RowID, Me.PartNo, Me.Strength})
        DataGridViewCellStyle3.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle3.BackColor = System.Drawing.SystemColors.Window
        DataGridViewCellStyle3.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        DataGridViewCellStyle3.ForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle3.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle3.SelectionForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle3.WrapMode = System.Windows.Forms.DataGridViewTriState.[True]
        Me.dgvproduct.DefaultCellStyle = DataGridViewCellStyle3
        Me.dgvproduct.GridColor = System.Drawing.Color.FromArgb(CType(CType(208, Byte), Integer), CType(CType(215, Byte), Integer), CType(CType(229, Byte), Integer))
        Me.dgvproduct.Location = New System.Drawing.Point(19, 151)
        Me.dgvproduct.MultiSelect = False
        Me.dgvproduct.Name = "dgvproduct"
        Me.dgvproduct.RowHeadersWidthSizeMode = System.Windows.Forms.DataGridViewRowHeadersWidthSizeMode.DisableResizing
        DataGridViewCellStyle4.WrapMode = System.Windows.Forms.DataGridViewTriState.[True]
        Me.dgvproduct.RowsDefaultCellStyle = DataGridViewCellStyle4
        Me.dgvproduct.Size = New System.Drawing.Size(309, 244)
        Me.dgvproduct.TabIndex = 358
        '
        'RowID
        '
        Me.RowID.HeaderText = "RowID"
        Me.RowID.Name = "RowID"
        Me.RowID.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.RowID.Visible = False
        '
        'PartNo
        '
        DataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.[True]
        Me.PartNo.DefaultCellStyle = DataGridViewCellStyle2
        Me.PartNo.HeaderText = "Loan Name"
        Me.PartNo.MaxInputLength = 50
        Me.PartNo.Name = "PartNo"
        Me.PartNo.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.PartNo.Width = 133
        '
        'Strength
        '
        Me.Strength.HeaderText = "Nondeductible to salary"
        Me.Strength.Name = "Strength"
        Me.Strength.Resizable = System.Windows.Forms.DataGridViewTriState.[True]
        Me.Strength.Width = 133
        '
        'LoanType
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.BackColor = System.Drawing.Color.White
        Me.ClientSize = New System.Drawing.Size(340, 407)
        Me.Controls.Add(Me.dgvproduct)
        Me.Controls.Add(Me.lnklblleave)
        Me.Controls.Add(Me.chknondeductible)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.Button2)
        Me.Controls.Add(Me.Button1)
        Me.Controls.Add(Me.TextBox1)
        Me.Controls.Add(Me.Label164)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
        Me.KeyPreview = True
        Me.MaximizeBox = False
        Me.MinimizeBox = False
        Me.Name = "LoanType"
        Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen
        CType(Me.dgvproduct, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents TextBox1 As System.Windows.Forms.TextBox
    Friend WithEvents Button1 As System.Windows.Forms.Button
    Friend WithEvents Button2 As System.Windows.Forms.Button
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents Label164 As System.Windows.Forms.Label
    Friend WithEvents chknondeductible As System.Windows.Forms.CheckBox
    Friend WithEvents lnklblleave As System.Windows.Forms.LinkLabel
    Friend WithEvents dgvproduct As DevComponents.DotNetBar.Controls.DataGridViewX
    Friend WithEvents RowID As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents PartNo As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Strength As System.Windows.Forms.DataGridViewCheckBoxColumn
End Class
