Imports System.Data.Entity
Imports AccuPay.Entity

Public Class NewAllowanceTypeForm
    Public ReadOnly Property Succeed As Boolean

    Public Sub New()

        ' This call is required by the designer.
        InitializeComponent()

        ' Add any initialization after the InitializeComponent() call.

    End Sub

    Private Async Sub btnCreate_Click(sender As Object, e As EventArgs) Handles btnCreate.Click
        Using context = New DatabaseContext
            Dim allowanceTypeCategory = Await context.Categories.
                Where(Function(c) c.OrganizationID = z_OrganizationID).
                FirstOrDefaultAsync(Function(c) c.CategoryName = ProductConstant.ALLOWANCE_TYPE_CATEGORY)

            If allowanceTypeCategory Is Nothing Then Return

            Dim newAllowanceType = Product.NewAllowanceType(
                organizationId:=z_OrganizationID,
                userId:=user_row_id,
                category:=allowanceTypeCategory)

            newAllowanceType.ApplyAllowanceTypeChanges(
                userId:=user_row_id,
                allowanceTypeName:=txtAllowanceName.Text.Trim,
                useInSss:=chkUseInSss.Checked,
                useIn13thMonth:=chkUseIn13thMonth.Checked,
                isTaxable:=chkIsTaxable.Checked)

            context.Products.Add(newAllowanceType)

            Await context.SaveChangesAsync()

            _Succeed = True
        End Using
    End Sub

    Private Sub txtAllowanceName_TextChanged(sender As Object, e As EventArgs) Handles txtAllowanceName.TextChanged
        Dim isNullOrWhiteSpace = String.IsNullOrWhiteSpace(txtAllowanceName.Text)
        btnCreate.Enabled = Not isNullOrWhiteSpace
    End Sub

    Private Sub btnClose_Click(sender As Object, e As EventArgs) Handles btnClose.Click
        Close()
    End Sub

End Class