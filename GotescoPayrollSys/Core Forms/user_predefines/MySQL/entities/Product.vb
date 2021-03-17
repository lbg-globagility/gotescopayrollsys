Option Strict On

Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel.DataAnnotations.Schema
Imports GotescoPayrollSys

Namespace Global.AccuPay.Entity

    <Table("product")>
    Public Class Product

        <Key>
        <DatabaseGenerated(DatabaseGeneratedOption.Identity)>
        Public Property RowID As Integer?

        Public Property SupplierID As Integer?

        Public Property Name As String

        Public Property OrganizationID As Integer?

        Public Property Description As String

        Public Property PartNo As String

        <DatabaseGenerated(DatabaseGeneratedOption.Identity)>
        Public Property Created As Date

        <DatabaseGenerated(DatabaseGeneratedOption.Computed)>
        Public Property LastUpd As Date?

        <NotMapped>
        Public Property LastArrivedQty As Integer?

        Public Property CreatedBy As Integer?

        Public Property LastUpdBy As Integer?

        <Column("Category")>
        Public Property CategoryText As String

        <ForeignKey("Category")>
        Public Property CategoryID As Integer?

        <NotMapped>
        Public Property AccountingAccountID As Integer?

        <NotMapped>
        Public Property Catalog As String

        <NotMapped>
        Public Property Comments As String

        Public Property Status As String

        Public Property Fixed As String

        <NotMapped>
        Public Property UnitPrice As Decimal

        <NotMapped>
        Public Property VATPercent As Decimal

        <NotMapped>
        Public Property FirstBillFlag As Char

        <NotMapped>
        Public Property SecondBillFlag As Char

        <NotMapped>
        Public Property ThirdBillFlag As Char

        <NotMapped>
        Public Property PDCFlag As Char

        <NotMapped>
        Public Property MonthlyBIllFlag As Char

        <NotMapped>
        Public Property PenaltyFlag As Char

        <NotMapped>
        Public Property WithholdingTaxPercent As Decimal

        <NotMapped>
        Public Property CostPrice As Decimal

        <NotMapped>
        Public Property UnitOfMeasure As String

        <NotMapped>
        Public Property SKU As String

        <NotMapped>
        Public Property LeadTime As Integer?

        <NotMapped>
        Public Property BarCode As String

        <NotMapped>
        Public Property BusinessUnitID As Integer?

        <NotMapped>
        Public Property LastRcvdFromShipmentDate As Date

        <NotMapped>
        Public Property LastRcvdFromShipmentCount As Integer?

        <NotMapped>
        Public Property TotalShipmentCount As Integer?

        <NotMapped>
        Public Property BookPageNo As String

        <NotMapped>
        Public Property BrandName As String

        <NotMapped>
        Public Property LastPurchaseDate As Date

        <NotMapped>
        Public Property LastSoldDate As Date

        <NotMapped>
        Public Property LastSoldCount As Integer?

        <NotMapped>
        Public Property ReOrderPoint As Integer?

        <NotMapped>
        Public Property AllocateBelowSafetyFlag As Char

        <NotMapped>
        Public Property Strength As String

        <NotMapped>
        Public Property UnitsBackordered As Integer?

        <NotMapped>
        Public Property UnitsBackorderAsOf As Date

        <NotMapped>
        Public Property DateLastInventoryCount As Date

        <NotMapped>
        Public Property TaxVAT As Decimal

        <NotMapped>
        Public Property WithholdingTax As Decimal

        <NotMapped>
        Public Property COAId As Integer?

        <NotMapped>
        Public Property ActiveData As Char

        Public Overridable Property Category As Category

        Public ReadOnly Property IsTaxable As Boolean
            Get
                If String.IsNullOrWhiteSpace(Status) Then Return False
                Return Status = "1"
            End Get
        End Property

        Public ReadOnly Property IsFixed As Boolean
            Get
                If String.IsNullOrWhiteSpace(Fixed) Then Return False
                Return Fixed = "1"
            End Get
        End Property

        Public Property UseInSss As Boolean

        Public Property UseIn13thMonth As Boolean

        Friend Shared Function NewAllowanceType(
                organizationId As Integer,
                userId As Integer,
                category As Category) As Product
            Return New Product() With {
                .OrganizationID = organizationId,
                .CreatedBy = userId,
                .CategoryText = category.CategoryName,
                .CategoryID = category.RowID}
        End Function

        Friend Sub ApplyAllowanceTypeChanges(userId As Integer,
                allowanceTypeName As String,
                useInSss As Boolean,
                useIn13thMonth As Boolean,
                isTaxable As Boolean)
            PartNo = allowanceTypeName
            Name = allowanceTypeName
            Status = If(isTaxable, "1", "0")
            _UseInSss = useInSss
            _UseIn13thMonth = useIn13thMonth
            LastUpdBy = userId
        End Sub

    End Class

End Namespace