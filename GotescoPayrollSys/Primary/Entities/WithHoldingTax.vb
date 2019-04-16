Option Strict On
Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel.DataAnnotations.Schema

<Table("paywithholdingtax")>
Public Class WithHoldingTax
    <Key>
    <DatabaseGenerated(DatabaseGeneratedOption.Identity)>
    Public Property RowID As Integer

    <DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    Public Property Created As DateTime

    <DatabaseGenerated(DatabaseGeneratedOption.Computed)>
    Public Property LastUpd As DateTime?

    Public Property CreatedBy As Integer?
    Public Property LastUpdBy As Integer?
    Public Property PayFrequencyID As Integer
    Public Property FilingStatusID As Integer?
    Public Property EffectiveDateFrom As Date?
    Public Property EffectiveDateTo As Date?
    Public Property ExemptionAmount As Decimal?
    Public Property ExemptionInExcessAmount As Decimal?
    Public Property TaxableIncomeFromAmount As Decimal?
    Public Property TaxableIncomeToAmount As Decimal?
End Class
