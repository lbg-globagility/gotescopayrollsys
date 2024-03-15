<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class PayPeriodsSelectionDialog
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
        Me.Panel1 = New System.Windows.Forms.Panel()
        Me.DataGridViewXPeriods = New DevComponents.DotNetBar.Controls.DataGridViewX()
        Me.Column1 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Column2 = New System.Windows.Forms.DataGridViewCheckBoxColumn()
        Me.Column3 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Column4 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Panel4 = New System.Windows.Forms.Panel()
        Me.LinkLabelNext = New System.Windows.Forms.LinkLabel()
        Me.LinkLabelPrev = New System.Windows.Forms.LinkLabel()
        Me.Button1 = New System.Windows.Forms.Button()
        Me.PanelLoanTypes = New System.Windows.Forms.Panel()
        Me.FlowLayoutPanelLoanTypes = New System.Windows.Forms.FlowLayoutPanel()
        Me.Panel5 = New System.Windows.Forms.Panel()
        Me.LinkLabelUnSelectAll = New System.Windows.Forms.LinkLabel()
        Me.LabelSelectedLoanTypes = New System.Windows.Forms.Label()
        Me.Panel3 = New System.Windows.Forms.Panel()
        Me.LabelPeriodDisplayText = New System.Windows.Forms.Label()
        Me.ButtonClose = New System.Windows.Forms.Button()
        Me.ButtonOK = New System.Windows.Forms.Button()
        Me.DataGridViewTextBoxColumn1 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.DataGridViewTextBoxColumn2 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.DataGridViewTextBoxColumn3 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Panel2 = New System.Windows.Forms.Panel()
        Me.Panel1.SuspendLayout()
        CType(Me.DataGridViewXPeriods, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.Panel4.SuspendLayout()
        Me.PanelLoanTypes.SuspendLayout()
        Me.Panel5.SuspendLayout()
        Me.Panel3.SuspendLayout()
        Me.SuspendLayout()
        '
        'Panel1
        '
        Me.Panel1.Controls.Add(Me.DataGridViewXPeriods)
        Me.Panel1.Controls.Add(Me.Panel4)
        Me.Panel1.Dock = System.Windows.Forms.DockStyle.Fill
        Me.Panel1.Location = New System.Drawing.Point(0, 0)
        Me.Panel1.Name = "Panel1"
        Me.Panel1.Size = New System.Drawing.Size(365, 311)
        Me.Panel1.TabIndex = 0
        '
        'DataGridViewXPeriods
        '
        Me.DataGridViewXPeriods.AllowUserToAddRows = False
        Me.DataGridViewXPeriods.AllowUserToDeleteRows = False
        Me.DataGridViewXPeriods.AllowUserToOrderColumns = True
        Me.DataGridViewXPeriods.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize
        Me.DataGridViewXPeriods.Columns.AddRange(New System.Windows.Forms.DataGridViewColumn() {Me.Column1, Me.Column2, Me.Column3, Me.Column4})
        DataGridViewCellStyle3.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle3.BackColor = System.Drawing.SystemColors.Window
        DataGridViewCellStyle3.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        DataGridViewCellStyle3.ForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle3.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle3.SelectionForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle3.WrapMode = System.Windows.Forms.DataGridViewTriState.[False]
        Me.DataGridViewXPeriods.DefaultCellStyle = DataGridViewCellStyle3
        Me.DataGridViewXPeriods.Dock = System.Windows.Forms.DockStyle.Fill
        Me.DataGridViewXPeriods.GridColor = System.Drawing.Color.FromArgb(CType(CType(208, Byte), Integer), CType(CType(215, Byte), Integer), CType(CType(229, Byte), Integer))
        Me.DataGridViewXPeriods.Location = New System.Drawing.Point(0, 0)
        Me.DataGridViewXPeriods.Name = "DataGridViewXPeriods"
        Me.DataGridViewXPeriods.Size = New System.Drawing.Size(365, 287)
        Me.DataGridViewXPeriods.TabIndex = 153
        '
        'Column1
        '
        Me.Column1.HeaderText = "RowID"
        Me.Column1.Name = "Column1"
        Me.Column1.ReadOnly = True
        Me.Column1.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.Column1.Visible = False
        '
        'Column2
        '
        Me.Column2.HeaderText = "     "
        Me.Column2.Name = "Column2"
        Me.Column2.Width = 32
        '
        'Column3
        '
        Me.Column3.HeaderText = "Date from"
        Me.Column3.Name = "Column3"
        Me.Column3.ReadOnly = True
        Me.Column3.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.Column3.Width = 128
        '
        'Column4
        '
        Me.Column4.HeaderText = "Date to"
        Me.Column4.Name = "Column4"
        Me.Column4.ReadOnly = True
        Me.Column4.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.Column4.Width = 128
        '
        'Panel4
        '
        Me.Panel4.Controls.Add(Me.LinkLabelNext)
        Me.Panel4.Controls.Add(Me.LinkLabelPrev)
        Me.Panel4.Controls.Add(Me.Button1)
        Me.Panel4.Dock = System.Windows.Forms.DockStyle.Bottom
        Me.Panel4.Location = New System.Drawing.Point(0, 287)
        Me.Panel4.Name = "Panel4"
        Me.Panel4.Size = New System.Drawing.Size(365, 24)
        Me.Panel4.TabIndex = 152
        '
        'LinkLabelNext
        '
        Me.LinkLabelNext.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.LinkLabelNext.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.LinkLabelNext.LinkBehavior = System.Windows.Forms.LinkBehavior.HoverUnderline
        Me.LinkLabelNext.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.LinkLabelNext.Location = New System.Drawing.Point(281, 4)
        Me.LinkLabelNext.Name = "LinkLabelNext"
        Me.LinkLabelNext.Size = New System.Drawing.Size(81, 16)
        Me.LinkLabelNext.TabIndex = 152
        Me.LinkLabelNext.TabStop = True
        Me.LinkLabelNext.Text = "0000 →"
        Me.LinkLabelNext.TextAlign = System.Drawing.ContentAlignment.TopRight
        '
        'LinkLabelPrev
        '
        Me.LinkLabelPrev.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.LinkLabelPrev.LinkBehavior = System.Windows.Forms.LinkBehavior.HoverUnderline
        Me.LinkLabelPrev.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.LinkLabelPrev.Location = New System.Drawing.Point(0, 4)
        Me.LinkLabelPrev.Name = "LinkLabelPrev"
        Me.LinkLabelPrev.Size = New System.Drawing.Size(81, 16)
        Me.LinkLabelPrev.TabIndex = 151
        Me.LinkLabelPrev.TabStop = True
        Me.LinkLabelPrev.Text = "← 0000"
        '
        'Button1
        '
        Me.Button1.Location = New System.Drawing.Point(0, 4)
        Me.Button1.Name = "Button1"
        Me.Button1.Size = New System.Drawing.Size(81, 16)
        Me.Button1.TabIndex = 153
        Me.Button1.Text = "Button1"
        Me.Button1.UseVisualStyleBackColor = True
        '
        'PanelLoanTypes
        '
        Me.PanelLoanTypes.Controls.Add(Me.FlowLayoutPanelLoanTypes)
        Me.PanelLoanTypes.Controls.Add(Me.Panel2)
        Me.PanelLoanTypes.Controls.Add(Me.Panel5)
        Me.PanelLoanTypes.Dock = System.Windows.Forms.DockStyle.Bottom
        Me.PanelLoanTypes.Location = New System.Drawing.Point(0, 311)
        Me.PanelLoanTypes.Name = "PanelLoanTypes"
        Me.PanelLoanTypes.Size = New System.Drawing.Size(365, 80)
        Me.PanelLoanTypes.TabIndex = 1
        '
        'FlowLayoutPanelLoanTypes
        '
        Me.FlowLayoutPanelLoanTypes.AutoScroll = True
        Me.FlowLayoutPanelLoanTypes.Dock = System.Windows.Forms.DockStyle.Fill
        Me.FlowLayoutPanelLoanTypes.Location = New System.Drawing.Point(16, 24)
        Me.FlowLayoutPanelLoanTypes.Name = "FlowLayoutPanelLoanTypes"
        Me.FlowLayoutPanelLoanTypes.Size = New System.Drawing.Size(349, 56)
        Me.FlowLayoutPanelLoanTypes.TabIndex = 1
        '
        'Panel5
        '
        Me.Panel5.Controls.Add(Me.LinkLabelUnSelectAll)
        Me.Panel5.Controls.Add(Me.LabelSelectedLoanTypes)
        Me.Panel5.Dock = System.Windows.Forms.DockStyle.Top
        Me.Panel5.Location = New System.Drawing.Point(0, 0)
        Me.Panel5.Name = "Panel5"
        Me.Panel5.Size = New System.Drawing.Size(365, 24)
        Me.Panel5.TabIndex = 0
        '
        'LinkLabelUnSelectAll
        '
        Me.LinkLabelUnSelectAll.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.LinkLabelUnSelectAll.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.LinkLabelUnSelectAll.LinkBehavior = System.Windows.Forms.LinkBehavior.HoverUnderline
        Me.LinkLabelUnSelectAll.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.LinkLabelUnSelectAll.Location = New System.Drawing.Point(281, 4)
        Me.LinkLabelUnSelectAll.Name = "LinkLabelUnSelectAll"
        Me.LinkLabelUnSelectAll.Size = New System.Drawing.Size(81, 16)
        Me.LinkLabelUnSelectAll.TabIndex = 153
        Me.LinkLabelUnSelectAll.TabStop = True
        Me.LinkLabelUnSelectAll.Text = "un/select all"
        Me.LinkLabelUnSelectAll.TextAlign = System.Drawing.ContentAlignment.TopRight
        '
        'LabelSelectedLoanTypes
        '
        Me.LabelSelectedLoanTypes.AutoSize = True
        Me.LabelSelectedLoanTypes.Location = New System.Drawing.Point(0, 4)
        Me.LabelSelectedLoanTypes.Name = "LabelSelectedLoanTypes"
        Me.LabelSelectedLoanTypes.Size = New System.Drawing.Size(106, 13)
        Me.LabelSelectedLoanTypes.TabIndex = 0
        Me.LabelSelectedLoanTypes.Text = "Select Loan Type(0):"
        '
        'Panel3
        '
        Me.Panel3.Controls.Add(Me.LabelPeriodDisplayText)
        Me.Panel3.Controls.Add(Me.ButtonClose)
        Me.Panel3.Controls.Add(Me.ButtonOK)
        Me.Panel3.Dock = System.Windows.Forms.DockStyle.Bottom
        Me.Panel3.Location = New System.Drawing.Point(0, 391)
        Me.Panel3.Name = "Panel3"
        Me.Panel3.Size = New System.Drawing.Size(365, 59)
        Me.Panel3.TabIndex = 2
        '
        'LabelPeriodDisplayText
        '
        Me.LabelPeriodDisplayText.Location = New System.Drawing.Point(12, 12)
        Me.LabelPeriodDisplayText.Name = "LabelPeriodDisplayText"
        Me.LabelPeriodDisplayText.Size = New System.Drawing.Size(179, 35)
        Me.LabelPeriodDisplayText.TabIndex = 1
        '
        'ButtonClose
        '
        Me.ButtonClose.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.ButtonClose.Location = New System.Drawing.Point(278, 12)
        Me.ButtonClose.Name = "ButtonClose"
        Me.ButtonClose.Size = New System.Drawing.Size(75, 35)
        Me.ButtonClose.TabIndex = 0
        Me.ButtonClose.Text = "Close"
        Me.ButtonClose.UseVisualStyleBackColor = True
        '
        'ButtonOK
        '
        Me.ButtonOK.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.ButtonOK.Location = New System.Drawing.Point(197, 12)
        Me.ButtonOK.Name = "ButtonOK"
        Me.ButtonOK.Size = New System.Drawing.Size(75, 35)
        Me.ButtonOK.TabIndex = 0
        Me.ButtonOK.Text = "OK"
        Me.ButtonOK.UseVisualStyleBackColor = True
        '
        'DataGridViewTextBoxColumn1
        '
        Me.DataGridViewTextBoxColumn1.HeaderText = "RowID"
        Me.DataGridViewTextBoxColumn1.Name = "DataGridViewTextBoxColumn1"
        Me.DataGridViewTextBoxColumn1.ReadOnly = True
        Me.DataGridViewTextBoxColumn1.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.DataGridViewTextBoxColumn1.Visible = False
        '
        'DataGridViewTextBoxColumn2
        '
        Me.DataGridViewTextBoxColumn2.HeaderText = "Date from"
        Me.DataGridViewTextBoxColumn2.Name = "DataGridViewTextBoxColumn2"
        Me.DataGridViewTextBoxColumn2.ReadOnly = True
        Me.DataGridViewTextBoxColumn2.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.DataGridViewTextBoxColumn2.Width = 128
        '
        'DataGridViewTextBoxColumn3
        '
        Me.DataGridViewTextBoxColumn3.HeaderText = "Date to"
        Me.DataGridViewTextBoxColumn3.Name = "DataGridViewTextBoxColumn3"
        Me.DataGridViewTextBoxColumn3.ReadOnly = True
        Me.DataGridViewTextBoxColumn3.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.DataGridViewTextBoxColumn3.Width = 128
        '
        'Panel2
        '
        Me.Panel2.Dock = System.Windows.Forms.DockStyle.Left
        Me.Panel2.Location = New System.Drawing.Point(0, 24)
        Me.Panel2.Name = "Panel2"
        Me.Panel2.Size = New System.Drawing.Size(16, 56)
        Me.Panel2.TabIndex = 0
        '
        'PayPeriodsSelectionDialog
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.BackColor = System.Drawing.Color.White
        Me.ClientSize = New System.Drawing.Size(365, 450)
        Me.Controls.Add(Me.Panel1)
        Me.Controls.Add(Me.PanelLoanTypes)
        Me.Controls.Add(Me.Panel3)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
        Me.MaximizeBox = False
        Me.MinimizeBox = False
        Me.Name = "PayPeriodsSelectionDialog"
        Me.Panel1.ResumeLayout(False)
        CType(Me.DataGridViewXPeriods, System.ComponentModel.ISupportInitialize).EndInit()
        Me.Panel4.ResumeLayout(False)
        Me.PanelLoanTypes.ResumeLayout(False)
        Me.Panel5.ResumeLayout(False)
        Me.Panel5.PerformLayout()
        Me.Panel3.ResumeLayout(False)
        Me.ResumeLayout(False)

    End Sub

    Friend WithEvents Panel1 As Panel
    Friend WithEvents PanelLoanTypes As Panel
    Friend WithEvents LinkLabelPrev As LinkLabel
    Friend WithEvents Panel4 As Panel
    Friend WithEvents Panel3 As Panel
    Friend WithEvents DataGridViewXPeriods As DevComponents.DotNetBar.Controls.DataGridViewX
    Friend WithEvents ButtonClose As Button
    Friend WithEvents ButtonOK As Button
    Friend WithEvents LabelPeriodDisplayText As Label
    Friend WithEvents LinkLabelNext As LinkLabel
    Friend WithEvents FlowLayoutPanelLoanTypes As FlowLayoutPanel
    Friend WithEvents Panel5 As Panel
    Friend WithEvents LinkLabelUnSelectAll As LinkLabel
    Friend WithEvents LabelSelectedLoanTypes As Label
    Friend WithEvents DataGridViewTextBoxColumn1 As DataGridViewTextBoxColumn
    Friend WithEvents DataGridViewTextBoxColumn2 As DataGridViewTextBoxColumn
    Friend WithEvents DataGridViewTextBoxColumn3 As DataGridViewTextBoxColumn
    Friend WithEvents Column1 As DataGridViewTextBoxColumn
    Friend WithEvents Column2 As DataGridViewCheckBoxColumn
    Friend WithEvents Column3 As DataGridViewTextBoxColumn
    Friend WithEvents Column4 As DataGridViewTextBoxColumn
    Friend WithEvents Button1 As Button
    Friend WithEvents Panel2 As Panel
End Class
