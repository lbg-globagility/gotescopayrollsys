<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class PayPeriodGUI
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
        Me.dgvpaypers = New System.Windows.Forms.DataGridView()
        Me.Column1 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Column2 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Column3 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Column15 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Column16 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Column4 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Column5 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Column6 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Column7 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Column8 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Column9 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Column10 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Column11 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Column12 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Column13 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.Column14 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.SSSContribSched = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.PhHContribSched = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.HDMFContribSched = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.PayPeriodMinWageValue = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.linkNxt = New System.Windows.Forms.LinkLabel()
        Me.linkPrev = New System.Windows.Forms.LinkLabel()
        Me.Button1 = New System.Windows.Forms.Button()
        Me.Button2 = New System.Windows.Forms.Button()
        Me.Label2 = New System.Windows.Forms.Label()
        Me.lblpapyperiodval = New System.Windows.Forms.Label()
        Me.tstrip = New System.Windows.Forms.ToolStrip()
        Me.ToolStripButton1 = New System.Windows.Forms.ToolStripButton()
        Me.ToolStripButton2 = New System.Windows.Forms.ToolStripButton()
        Me.chkbx13monCalcInclude = New System.Windows.Forms.CheckBox()
        Me.Panel2 = New System.Windows.Forms.Panel()
        Me.lblgrouping = New System.Windows.Forms.Label()
        Me.cboxDivisions = New System.Windows.Forms.ComboBox()
        Me.Label124 = New System.Windows.Forms.Label()
        Me.pnlDivision = New System.Windows.Forms.Panel()
        Me.Panel1 = New System.Windows.Forms.Panel()
        CType(Me.dgvpaypers, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.tstrip.SuspendLayout()
        Me.Panel2.SuspendLayout()
        Me.pnlDivision.SuspendLayout()
        Me.Panel1.SuspendLayout()
        Me.SuspendLayout()
        '
        'dgvpaypers
        '
        Me.dgvpaypers.AllowUserToAddRows = False
        Me.dgvpaypers.AllowUserToDeleteRows = False
        Me.dgvpaypers.AllowUserToOrderColumns = True
        Me.dgvpaypers.AllowUserToResizeColumns = False
        Me.dgvpaypers.AllowUserToResizeRows = False
        Me.dgvpaypers.BackgroundColor = System.Drawing.Color.White
        Me.dgvpaypers.BorderStyle = System.Windows.Forms.BorderStyle.None
        Me.dgvpaypers.ColumnHeadersHeight = 38
        Me.dgvpaypers.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing
        Me.dgvpaypers.Columns.AddRange(New System.Windows.Forms.DataGridViewColumn() {Me.Column1, Me.Column2, Me.Column3, Me.Column15, Me.Column16, Me.Column4, Me.Column5, Me.Column6, Me.Column7, Me.Column8, Me.Column9, Me.Column10, Me.Column11, Me.Column12, Me.Column13, Me.Column14, Me.SSSContribSched, Me.PhHContribSched, Me.HDMFContribSched, Me.PayPeriodMinWageValue})
        Me.dgvpaypers.Dock = System.Windows.Forms.DockStyle.Fill
        Me.dgvpaypers.Location = New System.Drawing.Point(111, 0)
        Me.dgvpaypers.MultiSelect = False
        Me.dgvpaypers.Name = "dgvpaypers"
        Me.dgvpaypers.RowHeadersWidthSizeMode = System.Windows.Forms.DataGridViewRowHeadersWidthSizeMode.DisableResizing
        Me.dgvpaypers.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect
        Me.dgvpaypers.Size = New System.Drawing.Size(415, 371)
        Me.dgvpaypers.TabIndex = 0
        '
        'Column1
        '
        Me.Column1.HeaderText = "Column1"
        Me.Column1.Name = "Column1"
        Me.Column1.Visible = False
        '
        'Column2
        '
        Me.Column2.HeaderText = "Column2"
        Me.Column2.Name = "Column2"
        Me.Column2.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.Column2.Visible = False
        Me.Column2.Width = 178
        '
        'Column3
        '
        Me.Column3.HeaderText = "Column3"
        Me.Column3.Name = "Column3"
        Me.Column3.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.Column3.Visible = False
        Me.Column3.Width = 178
        '
        'Column15
        '
        Me.Column15.HeaderText = "Pay period from"
        Me.Column15.Name = "Column15"
        Me.Column15.ReadOnly = True
        Me.Column15.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.Column15.Width = 135
        '
        'Column16
        '
        Me.Column16.HeaderText = "Pay period to"
        Me.Column16.Name = "Column16"
        Me.Column16.ReadOnly = True
        Me.Column16.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.Column16.Width = 135
        '
        'Column4
        '
        Me.Column4.HeaderText = "Column4"
        Me.Column4.Name = "Column4"
        Me.Column4.Visible = False
        Me.Column4.Width = 60
        '
        'Column5
        '
        Me.Column5.HeaderText = "Column5"
        Me.Column5.Name = "Column5"
        Me.Column5.Visible = False
        '
        'Column6
        '
        Me.Column6.HeaderText = "Column6"
        Me.Column6.Name = "Column6"
        Me.Column6.Visible = False
        '
        'Column7
        '
        Me.Column7.HeaderText = "Column7"
        Me.Column7.Name = "Column7"
        Me.Column7.Visible = False
        '
        'Column8
        '
        Me.Column8.HeaderText = "Column8"
        Me.Column8.Name = "Column8"
        Me.Column8.Visible = False
        '
        'Column9
        '
        Me.Column9.HeaderText = "Column9"
        Me.Column9.Name = "Column9"
        Me.Column9.Visible = False
        '
        'Column10
        '
        Me.Column10.HeaderText = "Column10"
        Me.Column10.Name = "Column10"
        Me.Column10.Visible = False
        '
        'Column11
        '
        Me.Column11.HeaderText = "Column11"
        Me.Column11.Name = "Column11"
        Me.Column11.Visible = False
        '
        'Column12
        '
        Me.Column12.HeaderText = "Column12"
        Me.Column12.Name = "Column12"
        Me.Column12.Visible = False
        '
        'Column13
        '
        Me.Column13.HeaderText = "Column13"
        Me.Column13.Name = "Column13"
        Me.Column13.Visible = False
        '
        'Column14
        '
        Me.Column14.HeaderText = "Column14"
        Me.Column14.Name = "Column14"
        Me.Column14.Visible = False
        Me.Column14.Width = 124
        '
        'SSSContribSched
        '
        Me.SSSContribSched.HeaderText = "SSSContribSched"
        Me.SSSContribSched.Name = "SSSContribSched"
        Me.SSSContribSched.Visible = False
        '
        'PhHContribSched
        '
        Me.PhHContribSched.HeaderText = "PhHContribSched"
        Me.PhHContribSched.Name = "PhHContribSched"
        Me.PhHContribSched.Visible = False
        '
        'HDMFContribSched
        '
        Me.HDMFContribSched.HeaderText = "HDMFContribSched"
        Me.HDMFContribSched.Name = "HDMFContribSched"
        Me.HDMFContribSched.Visible = False
        '
        'PayPeriodMinWageValue
        '
        Me.PayPeriodMinWageValue.HeaderText = "Minimum Wage"
        Me.PayPeriodMinWageValue.Name = "PayPeriodMinWageValue"
        Me.PayPeriodMinWageValue.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.PayPeriodMinWageValue.Width = 85
        '
        'linkNxt
        '
        Me.linkNxt.AutoSize = True
        Me.linkNxt.Dock = System.Windows.Forms.DockStyle.Right
        Me.linkNxt.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.0!)
        Me.linkNxt.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.linkNxt.Location = New System.Drawing.Point(377, 0)
        Me.linkNxt.Name = "linkNxt"
        Me.linkNxt.Size = New System.Drawing.Size(39, 15)
        Me.linkNxt.TabIndex = 1
        Me.linkNxt.TabStop = True
        Me.linkNxt.Text = "Next>"
        '
        'linkPrev
        '
        Me.linkPrev.AutoSize = True
        Me.linkPrev.Dock = System.Windows.Forms.DockStyle.Left
        Me.linkPrev.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.0!)
        Me.linkPrev.LinkColor = System.Drawing.Color.FromArgb(CType(CType(0, Byte), Integer), CType(CType(155, Byte), Integer), CType(CType(255, Byte), Integer))
        Me.linkPrev.Location = New System.Drawing.Point(0, 0)
        Me.linkPrev.Name = "linkPrev"
        Me.linkPrev.Size = New System.Drawing.Size(38, 15)
        Me.linkPrev.TabIndex = 0
        Me.linkPrev.TabStop = True
        Me.linkPrev.Text = "<Prev"
        '
        'Button1
        '
        Me.Button1.Location = New System.Drawing.Point(383, 461)
        Me.Button1.Name = "Button1"
        Me.Button1.Size = New System.Drawing.Size(75, 35)
        Me.Button1.TabIndex = 2
        Me.Button1.Text = "OK"
        Me.Button1.UseVisualStyleBackColor = True
        '
        'Button2
        '
        Me.Button2.Location = New System.Drawing.Point(463, 461)
        Me.Button2.Name = "Button2"
        Me.Button2.Size = New System.Drawing.Size(75, 35)
        Me.Button2.TabIndex = 3
        Me.Button2.Text = "Close"
        Me.Button2.UseVisualStyleBackColor = True
        '
        'Label2
        '
        Me.Label2.AutoSize = True
        Me.Label2.Font = New System.Drawing.Font("Segoe UI Semibold", 9.0!, System.Drawing.FontStyle.Bold)
        Me.Label2.Location = New System.Drawing.Point(119, 25)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(63, 15)
        Me.Label2.TabIndex = 13
        Me.Label2.Text = "Pay period"
        '
        'lblpapyperiodval
        '
        Me.lblpapyperiodval.AutoSize = True
        Me.lblpapyperiodval.Font = New System.Drawing.Font("Segoe UI Semibold", 9.0!, System.Drawing.FontStyle.Bold)
        Me.lblpapyperiodval.Location = New System.Drawing.Point(178, 25)
        Me.lblpapyperiodval.Name = "lblpapyperiodval"
        Me.lblpapyperiodval.Size = New System.Drawing.Size(32, 15)
        Me.lblpapyperiodval.TabIndex = 14
        Me.lblpapyperiodval.Text = "-----"
        '
        'tstrip
        '
        Me.tstrip.AutoSize = False
        Me.tstrip.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None
        Me.tstrip.CanOverflow = False
        Me.tstrip.Dock = System.Windows.Forms.DockStyle.Left
        Me.tstrip.GripStyle = System.Windows.Forms.ToolStripGripStyle.Hidden
        Me.tstrip.ImageScalingSize = New System.Drawing.Size(20, 20)
        Me.tstrip.Items.AddRange(New System.Windows.Forms.ToolStripItem() {Me.ToolStripButton1, Me.ToolStripButton2})
        Me.tstrip.LayoutStyle = System.Windows.Forms.ToolStripLayoutStyle.Flow
        Me.tstrip.Location = New System.Drawing.Point(0, 0)
        Me.tstrip.Name = "tstrip"
        Me.tstrip.Size = New System.Drawing.Size(111, 371)
        Me.tstrip.TabIndex = 281
        Me.tstrip.Text = "ToolStrip1"
        '
        'ToolStripButton1
        '
        Me.ToolStripButton1.AutoSize = False
        Me.ToolStripButton1.ImageTransparentColor = System.Drawing.Color.Magenta
        Me.ToolStripButton1.Name = "ToolStripButton1"
        Me.ToolStripButton1.Overflow = System.Windows.Forms.ToolStripItemOverflow.Never
        Me.ToolStripButton1.Size = New System.Drawing.Size(111, 50)
        Me.ToolStripButton1.Text = "WEEKLY"
        Me.ToolStripButton1.Visible = False
        '
        'ToolStripButton2
        '
        Me.ToolStripButton2.AutoSize = False
        Me.ToolStripButton2.ImageTransparentColor = System.Drawing.Color.Magenta
        Me.ToolStripButton2.Name = "ToolStripButton2"
        Me.ToolStripButton2.Overflow = System.Windows.Forms.ToolStripItemOverflow.Never
        Me.ToolStripButton2.Size = New System.Drawing.Size(111, 50)
        Me.ToolStripButton2.Text = "SEMI-MONTHLY"
        '
        'chkbx13monCalcInclude
        '
        Me.chkbx13monCalcInclude.AutoSize = True
        Me.chkbx13monCalcInclude.Font = New System.Drawing.Font("Segoe UI", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.chkbx13monCalcInclude.Location = New System.Drawing.Point(10, 479)
        Me.chkbx13monCalcInclude.Name = "chkbx13monCalcInclude"
        Me.chkbx13monCalcInclude.Size = New System.Drawing.Size(177, 17)
        Me.chkbx13monCalcInclude.TabIndex = 282
        Me.chkbx13monCalcInclude.Text = "Include thirteenth month pay"
        Me.chkbx13monCalcInclude.UseVisualStyleBackColor = True
        '
        'Panel2
        '
        Me.Panel2.Controls.Add(Me.linkNxt)
        Me.Panel2.Controls.Add(Me.linkPrev)
        Me.Panel2.Location = New System.Drawing.Point(122, 416)
        Me.Panel2.Name = "Panel2"
        Me.Panel2.Size = New System.Drawing.Size(416, 15)
        Me.Panel2.TabIndex = 4
        '
        'lblgrouping
        '
        Me.lblgrouping.AutoSize = True
        Me.lblgrouping.Location = New System.Drawing.Point(0, 9)
        Me.lblgrouping.Name = "lblgrouping"
        Me.lblgrouping.Size = New System.Drawing.Size(40, 13)
        Me.lblgrouping.TabIndex = 290
        Me.lblgrouping.Text = "Group"
        '
        'cboxDivisions
        '
        Me.cboxDivisions.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cboxDivisions.FormattingEnabled = True
        Me.cboxDivisions.Location = New System.Drawing.Point(56, 2)
        Me.cboxDivisions.Name = "cboxDivisions"
        Me.cboxDivisions.Size = New System.Drawing.Size(147, 21)
        Me.cboxDivisions.TabIndex = 288
        '
        'Label124
        '
        Me.Label124.AutoSize = True
        Me.Label124.Font = New System.Drawing.Font("Microsoft Sans Serif", 14.25!, System.Drawing.FontStyle.Bold)
        Me.Label124.ForeColor = System.Drawing.Color.FromArgb(CType(CType(255, Byte), Integer), CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer))
        Me.Label124.Location = New System.Drawing.Point(35, 0)
        Me.Label124.Name = "Label124"
        Me.Label124.Size = New System.Drawing.Size(18, 24)
        Me.Label124.TabIndex = 289
        Me.Label124.Text = "*"
        '
        'pnlDivision
        '
        Me.pnlDivision.Controls.Add(Me.cboxDivisions)
        Me.pnlDivision.Controls.Add(Me.lblgrouping)
        Me.pnlDivision.Controls.Add(Me.Label124)
        Me.pnlDivision.Location = New System.Drawing.Point(172, 471)
        Me.pnlDivision.Name = "pnlDivision"
        Me.pnlDivision.Size = New System.Drawing.Size(205, 25)
        Me.pnlDivision.TabIndex = 1
        '
        'Panel1
        '
        Me.Panel1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.Panel1.Controls.Add(Me.dgvpaypers)
        Me.Panel1.Controls.Add(Me.tstrip)
        Me.Panel1.Location = New System.Drawing.Point(10, 43)
        Me.Panel1.Name = "Panel1"
        Me.Panel1.Size = New System.Drawing.Size(528, 373)
        Me.Panel1.TabIndex = 0
        '
        'PayPeriodGUI
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(548, 508)
        Me.Controls.Add(Me.Panel1)
        Me.Controls.Add(Me.chkbx13monCalcInclude)
        Me.Controls.Add(Me.lblpapyperiodval)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.Button2)
        Me.Controls.Add(Me.Button1)
        Me.Controls.Add(Me.Panel2)
        Me.Controls.Add(Me.pnlDivision)
        Me.Font = New System.Drawing.Font("Segoe UI", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
        Me.MaximizeBox = False
        Me.MinimizeBox = False
        Me.Name = "PayPeriodGUI"
        Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen
        Me.Text = "List of pay period(s)"
        CType(Me.dgvpaypers, System.ComponentModel.ISupportInitialize).EndInit()
        Me.tstrip.ResumeLayout(False)
        Me.tstrip.PerformLayout()
        Me.Panel2.ResumeLayout(False)
        Me.Panel2.PerformLayout()
        Me.pnlDivision.ResumeLayout(False)
        Me.pnlDivision.PerformLayout()
        Me.Panel1.ResumeLayout(False)
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents dgvpaypers As System.Windows.Forms.DataGridView
    Friend WithEvents linkNxt As System.Windows.Forms.LinkLabel
    Friend WithEvents linkPrev As System.Windows.Forms.LinkLabel
    Friend WithEvents Button1 As System.Windows.Forms.Button
    Friend WithEvents Button2 As System.Windows.Forms.Button
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents lblpapyperiodval As System.Windows.Forms.Label
    Friend WithEvents tstrip As System.Windows.Forms.ToolStrip
    Friend WithEvents chkbx13monCalcInclude As System.Windows.Forms.CheckBox
    Friend WithEvents Panel2 As System.Windows.Forms.Panel
    Friend WithEvents lblgrouping As System.Windows.Forms.Label
    Friend WithEvents cboxDivisions As System.Windows.Forms.ComboBox
    Friend WithEvents Label124 As System.Windows.Forms.Label
    Friend WithEvents pnlDivision As System.Windows.Forms.Panel
    Friend WithEvents Panel1 As System.Windows.Forms.Panel
    Friend WithEvents ToolStripButton1 As System.Windows.Forms.ToolStripButton
    Friend WithEvents ToolStripButton2 As System.Windows.Forms.ToolStripButton
    Friend WithEvents Column1 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Column2 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Column3 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Column15 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Column16 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Column4 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Column5 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Column6 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Column7 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Column8 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Column9 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Column10 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Column11 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Column12 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Column13 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Column14 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents SSSContribSched As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents PhHContribSched As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents HDMFContribSched As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents PayPeriodMinWageValue As System.Windows.Forms.DataGridViewTextBoxColumn
End Class
