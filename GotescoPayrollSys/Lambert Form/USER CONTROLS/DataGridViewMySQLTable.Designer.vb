<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class DataGridViewMySQLTable
    Inherits System.Windows.Forms.UserControl

    'UserControl overrides dispose to clean up the component list.
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
        Dim DataGridViewCellStyle2 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()
        Me.dgv = New DevComponents.DotNetBar.Controls.DataGridViewX()
        Me.lnkFirst = New System.Windows.Forms.LinkLabel()
        Me.lnkPrev = New System.Windows.Forms.LinkLabel()
        Me.lnkLast = New System.Windows.Forms.LinkLabel()
        Me.lnkNext = New System.Windows.Forms.LinkLabel()
        Me.Panel1 = New System.Windows.Forms.Panel()
        CType(Me.dgv, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.Panel1.SuspendLayout()
        Me.SuspendLayout()
        '
        'dgv
        '
        Me.dgv.AllowUserToAddRows = False
        Me.dgv.AllowUserToDeleteRows = False
        Me.dgv.AllowUserToOrderColumns = True
        Me.dgv.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize
        DataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle2.BackColor = System.Drawing.SystemColors.Window
        DataGridViewCellStyle2.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        DataGridViewCellStyle2.ForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle2.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle2.SelectionForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.[False]
        Me.dgv.DefaultCellStyle = DataGridViewCellStyle2
        Me.dgv.Dock = System.Windows.Forms.DockStyle.Fill
        Me.dgv.GridColor = System.Drawing.Color.FromArgb(CType(CType(208, Byte), Integer), CType(CType(215, Byte), Integer), CType(CType(229, Byte), Integer))
        Me.dgv.Location = New System.Drawing.Point(0, 0)
        Me.dgv.Name = "dgv"
        Me.dgv.ReadOnly = True
        Me.dgv.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect
        Me.dgv.Size = New System.Drawing.Size(159, 125)
        Me.dgv.TabIndex = 0
        '
        'lnkFirst
        '
        Me.lnkFirst.AutoSize = True
        Me.lnkFirst.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lnkFirst.LinkBehavior = System.Windows.Forms.LinkBehavior.HoverUnderline
        Me.lnkFirst.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.lnkFirst.Location = New System.Drawing.Point(0, 4)
        Me.lnkFirst.Name = "lnkFirst"
        Me.lnkFirst.Size = New System.Drawing.Size(21, 15)
        Me.lnkFirst.TabIndex = 279
        Me.lnkFirst.TabStop = True
        Me.lnkFirst.Tag = "0"
        Me.lnkFirst.Text = "<<"
        '
        'lnkPrev
        '
        Me.lnkPrev.AutoSize = True
        Me.lnkPrev.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lnkPrev.LinkBehavior = System.Windows.Forms.LinkBehavior.HoverUnderline
        Me.lnkPrev.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.lnkPrev.Location = New System.Drawing.Point(27, 4)
        Me.lnkPrev.Name = "lnkPrev"
        Me.lnkPrev.Size = New System.Drawing.Size(14, 15)
        Me.lnkPrev.TabIndex = 280
        Me.lnkPrev.TabStop = True
        Me.lnkPrev.Tag = "1"
        Me.lnkPrev.Text = "<"
        '
        'lnkLast
        '
        Me.lnkLast.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.lnkLast.AutoSize = True
        Me.lnkLast.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lnkLast.LinkBehavior = System.Windows.Forms.LinkBehavior.HoverUnderline
        Me.lnkLast.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.lnkLast.Location = New System.Drawing.Point(138, 4)
        Me.lnkLast.Name = "lnkLast"
        Me.lnkLast.Size = New System.Drawing.Size(21, 15)
        Me.lnkLast.TabIndex = 282
        Me.lnkLast.TabStop = True
        Me.lnkLast.Tag = "3"
        Me.lnkLast.Text = ">>"
        '
        'lnkNext
        '
        Me.lnkNext.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.lnkNext.AutoSize = True
        Me.lnkNext.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lnkNext.LinkBehavior = System.Windows.Forms.LinkBehavior.HoverUnderline
        Me.lnkNext.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.lnkNext.Location = New System.Drawing.Point(118, 4)
        Me.lnkNext.Name = "lnkNext"
        Me.lnkNext.Size = New System.Drawing.Size(14, 15)
        Me.lnkNext.TabIndex = 281
        Me.lnkNext.TabStop = True
        Me.lnkNext.Tag = "2"
        Me.lnkNext.Text = ">"
        '
        'Panel1
        '
        Me.Panel1.Controls.Add(Me.lnkFirst)
        Me.Panel1.Controls.Add(Me.lnkNext)
        Me.Panel1.Controls.Add(Me.lnkLast)
        Me.Panel1.Controls.Add(Me.lnkPrev)
        Me.Panel1.Dock = System.Windows.Forms.DockStyle.Bottom
        Me.Panel1.Location = New System.Drawing.Point(0, 125)
        Me.Panel1.Name = "Panel1"
        Me.Panel1.Size = New System.Drawing.Size(159, 21)
        Me.Panel1.TabIndex = 283
        '
        'DataGridViewMySQLTable
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.Controls.Add(Me.dgv)
        Me.Controls.Add(Me.Panel1)
        Me.Name = "DataGridViewMySQLTable"
        Me.Size = New System.Drawing.Size(159, 146)
        CType(Me.dgv, System.ComponentModel.ISupportInitialize).EndInit()
        Me.Panel1.ResumeLayout(False)
        Me.Panel1.PerformLayout()
        Me.ResumeLayout(False)

    End Sub
    Friend WithEvents dgv As DevComponents.DotNetBar.Controls.DataGridViewX
    Friend WithEvents lnkFirst As System.Windows.Forms.LinkLabel
    Friend WithEvents lnkPrev As System.Windows.Forms.LinkLabel
    Friend WithEvents lnkLast As System.Windows.Forms.LinkLabel
    Friend WithEvents lnkNext As System.Windows.Forms.LinkLabel
    Friend WithEvents Panel1 As System.Windows.Forms.Panel

End Class
