Imports System.Data.Entity
Imports System.Threading.Tasks
Imports AccuPay.Entity

Public Class AllowanceTypeForm
    Public ReadOnly Property HasChanged As Boolean

    Public Sub New()

        ' This call is required by the designer.
        InitializeComponent()

        ' Add any initialization after the InitializeComponent() call.

    End Sub

    Private Async Sub AllowanceTypeForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        gridAllowanceTypes.AutoGenerateColumns = False
        Await LoadAllowanceTypesAsync()
    End Sub

    Private Async Sub btnNew_Click(sender As Object, e As EventArgs) Handles btnNew.Click
        Dim form = New NewAllowanceTypeForm
        form.ShowDialog()
        If form.Succeed Then
            Await LoadAllowanceTypesAsync()
        End If
    End Sub

    Private Async Function LoadAllowanceTypesAsync() As Task
        Using context = New DatabaseContext
            Dim products = Await context.Products.
                AsNoTracking().
                Include(Function(p) p.Category).
                Where(Function(p) p.OrganizationID = z_OrganizationID).
                Where(Function(p) p.CategoryText = ProductConstant.ALLOWANCE_TYPE_CATEGORY).
                OrderBy(Function(p) p.PartNo).
                ToListAsync()

            gridAllowanceTypes.DataSource = products.
                Select(Function(p) New AllowanceType(p)).
                ToList()
        End Using
    End Function

    Private Async Sub btnSave_Click(sender As Object, e As EventArgs) Handles btnSave.Click
        CommitGridViewChanges()

        Dim models = GetProducts(hasChanges:=True)

        If Not models.Any Then Return

        Dim rowIds = models.
            Select(Function(m) m.Id).
            ToArray()

        Using context = New DatabaseContext
            Dim products = Await context.Products.
                Where(Function(p) rowIds.Contains(p.RowID.Value)).
                ToListAsync()

            For Each product In products
                Dim model = models.FirstOrDefault(Function(m) product.RowID = m.Id)

                product.ApplyAllowanceTypeChanges(userId:=user_row_id,
                    allowanceTypeName:=model.Name,
                    useInSss:=model.UseInSss,
                    useIn13thMonth:=model.UseIn13thMonth,
                    isTaxable:=model.IsTaxable)

                context.Entry(product).State = EntityState.Modified
            Next

            Await context.SaveChangesAsync()
        End Using
    End Sub

    Private Function GetProducts(Optional hasChanges As Boolean = False) As List(Of AllowanceType)
        Dim rows = gridAllowanceTypes.Rows.OfType(Of DataGridViewRow).
            Where(Function(r) Not r.IsNewRow).
            Select(Function(r) GetProduct(r)).
            ToList()

        If hasChanges Then
            Return rows.
                Where(Function(a) a.HasChanged = hasChanges).
                ToList()
        End If

        Return rows.ToList()
    End Function

    Private Function GetProduct(gridRow As DataGridViewRow) As AllowanceType
        Return DirectCast(gridRow.DataBoundItem, AllowanceType)
    End Function

    Private Async Sub btnCancel_Click(sender As Object, e As EventArgs) Handles btnCancel.Click
        CommitGridViewChanges()
        Await LoadAllowanceTypesAsync()
    End Sub

    Private Sub btnClose_Click(sender As Object, e As EventArgs) Handles btnClose.Click
        Close()
    End Sub

    Private Sub PayPeriodGridView_CellContentClick(sender As Object, e As DataGridViewCellEventArgs) Handles gridAllowanceTypes.CellContentClick

    End Sub

    Private Sub CommitGridViewChanges()
        gridAllowanceTypes.EndEdit()
    End Sub

    Private Sub AllowanceTypeForm_FormClosing(sender As Object, e As FormClosingEventArgs) Handles Me.FormClosing
        _HasChanged = True
    End Sub

    Private Class AllowanceType
        Private ReadOnly _product As Product

        Public Sub New(product As Product)
            _product = product

            With _product
                Id = .RowID
                Name = .PartNo
                UseInSss = .UseInSss
                UseIn13thMonth = .UseIn13thMonth
                IsTaxable = .IsTaxable
            End With
        End Sub

        Public ReadOnly Property Id As Integer
        Public Property Name As String
        Public Property UseInSss As Boolean
        Public Property UseIn13thMonth As Boolean
        Public Property IsTaxable As Boolean

        Public ReadOnly Property HasChanged As Boolean
            Get
                Return Name <> _product.PartNo OrElse
                    UseInSss <> _product.UseInSss OrElse
                    UseIn13thMonth <> _product.UseIn13thMonth OrElse
                    IsTaxable <> _product.IsTaxable
            End Get
        End Property
    End Class

End Class