Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel.DataAnnotations.Schema

<Table("newphilhealthimplement")>
Public Class newphilhealthimplement
    <Key>
    Public Property RowID As Integer
    Public Property DeductionType As String

    Public Property Rate As Decimal

    Public Property MinimumContribution As Decimal

    Public Property MaximumContribution As Decimal

End Class
