<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()>
Partial Class NewAllowanceTypeForm
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()>
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
    <System.Diagnostics.DebuggerStepThrough()>
    Private Sub InitializeComponent()
        Me.btnCreate = New System.Windows.Forms.Button()
        Me.btnClose = New System.Windows.Forms.Button()
        Me.txtAllowanceName = New System.Windows.Forms.TextBox()
        Me.chkIsTaxable = New System.Windows.Forms.CheckBox()
        Me.chkUseInSss = New System.Windows.Forms.CheckBox()
        Me.chkUseIn13thMonth = New System.Windows.Forms.CheckBox()
        Me.Label1 = New System.Windows.Forms.Label()
        Me.SuspendLayout()
        '
        'btnCreate
        '
        Me.btnCreate.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnCreate.DialogResult = System.Windows.Forms.DialogResult.OK
        Me.btnCreate.Enabled = False
        Me.btnCreate.Location = New System.Drawing.Point(184, 109)
        Me.btnCreate.Name = "btnCreate"
        Me.btnCreate.Size = New System.Drawing.Size(75, 23)
        Me.btnCreate.TabIndex = 4
        Me.btnCreate.Text = "&Create"
        Me.btnCreate.UseVisualStyleBackColor = True
        '
        'btnClose
        '
        Me.btnClose.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnClose.DialogResult = System.Windows.Forms.DialogResult.Cancel
        Me.btnClose.Location = New System.Drawing.Point(265, 109)
        Me.btnClose.Name = "btnClose"
        Me.btnClose.Size = New System.Drawing.Size(75, 23)
        Me.btnClose.TabIndex = 5
        Me.btnClose.Text = "Close"
        Me.btnClose.UseVisualStyleBackColor = True
        '
        'txtAllowanceName
        '
        Me.txtAllowanceName.Location = New System.Drawing.Point(110, 12)
        Me.txtAllowanceName.Name = "txtAllowanceName"
        Me.txtAllowanceName.Size = New System.Drawing.Size(230, 22)
        Me.txtAllowanceName.TabIndex = 0
        '
        'chkIsTaxable
        '
        Me.chkIsTaxable.AutoSize = True
        Me.chkIsTaxable.Location = New System.Drawing.Point(110, 86)
        Me.chkIsTaxable.Name = "chkIsTaxable"
        Me.chkIsTaxable.Size = New System.Drawing.Size(75, 17)
        Me.chkIsTaxable.TabIndex = 1
        Me.chkIsTaxable.Text = "Is Taxable"
        Me.chkIsTaxable.UseVisualStyleBackColor = True
        Me.chkIsTaxable.Visible = False
        '
        'chkUseInSss
        '
        Me.chkUseInSss.AutoSize = True
        Me.chkUseInSss.Location = New System.Drawing.Point(110, 40)
        Me.chkUseInSss.Name = "chkUseInSss"
        Me.chkUseInSss.Size = New System.Drawing.Size(79, 17)
        Me.chkUseInSss.TabIndex = 2
        Me.chkUseInSss.Text = "Use in SSS"
        Me.chkUseInSss.UseVisualStyleBackColor = True
        '
        'chkUseIn13thMonth
        '
        Me.chkUseIn13thMonth.AutoSize = True
        Me.chkUseIn13thMonth.Location = New System.Drawing.Point(110, 63)
        Me.chkUseIn13thMonth.Name = "chkUseIn13thMonth"
        Me.chkUseIn13thMonth.Size = New System.Drawing.Size(121, 17)
        Me.chkUseIn13thMonth.TabIndex = 3
        Me.chkUseIn13thMonth.Text = "Use in 13th month"
        Me.chkUseIn13thMonth.UseVisualStyleBackColor = True
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.Location = New System.Drawing.Point(12, 21)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(92, 13)
        Me.Label1.TabIndex = 3
        Me.Label1.Text = "Allowance Name"
        '
        'NewAllowanceTypeForm
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.BackColor = System.Drawing.Color.White
        Me.ClientSize = New System.Drawing.Size(352, 144)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.chkUseIn13thMonth)
        Me.Controls.Add(Me.chkUseInSss)
        Me.Controls.Add(Me.chkIsTaxable)
        Me.Controls.Add(Me.txtAllowanceName)
        Me.Controls.Add(Me.btnClose)
        Me.Controls.Add(Me.btnCreate)
        Me.Font = New System.Drawing.Font("Segoe UI", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
        Me.KeyPreview = True
        Me.MaximizeBox = False
        Me.MinimizeBox = False
        Me.Name = "NewAllowanceTypeForm"
        Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub

    Friend WithEvents btnCreate As Button
    Friend WithEvents btnClose As Button
    Friend WithEvents txtAllowanceName As TextBox
    Friend WithEvents chkIsTaxable As CheckBox
    Friend WithEvents chkUseInSss As CheckBox
    Friend WithEvents chkUseIn13thMonth As CheckBox
    Friend WithEvents Label1 As Label
End Class
