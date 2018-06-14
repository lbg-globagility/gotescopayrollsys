<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class PayPeriodSelectionWithLoanTypes
    Inherits GotescoPayrollSys.PayrollSummaDateSelection

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
        Me.cboxLoanTypes = New System.Windows.Forms.ComboBox()
        Me.Label6 = New System.Windows.Forms.Label()
        Me.SuspendLayout()
        '
        'cboxLoanTypes
        '
        Me.cboxLoanTypes.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cboxLoanTypes.FormattingEnabled = True
        Me.cboxLoanTypes.Location = New System.Drawing.Point(177, 418)
        Me.cboxLoanTypes.Name = "cboxLoanTypes"
        Me.cboxLoanTypes.Size = New System.Drawing.Size(121, 21)
        Me.cboxLoanTypes.TabIndex = 525
        '
        'Label6
        '
        Me.Label6.AutoSize = True
        Me.Label6.Location = New System.Drawing.Point(108, 426)
        Me.Label6.Name = "Label6"
        Me.Label6.Size = New System.Drawing.Size(58, 13)
        Me.Label6.TabIndex = 526
        Me.Label6.Text = "Loan Type"
        '
        'PayPeriodSelectionWithLoanTypes
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(446, 539)
        Me.Controls.Add(Me.Label6)
        Me.Controls.Add(Me.cboxLoanTypes)
        Me.Name = "PayPeriodSelectionWithLoanTypes"
        Me.Controls.SetChildIndex(Me.cboxLoanTypes, 0)
        Me.Controls.SetChildIndex(Me.Label6, 0)
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents cboxLoanTypes As System.Windows.Forms.ComboBox
    Friend WithEvents Label6 As System.Windows.Forms.Label
End Class
