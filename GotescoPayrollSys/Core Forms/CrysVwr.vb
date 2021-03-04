Imports System.IO
Imports CrystalDecisions.CrystalReports.Engine

Public Class CrysVwr

#Region "Vairable declarations"

    Private pp_rowid_from,
        pp_rowid_to As Object

    Private is_actual As Boolean = False

    Private sal_distrib As String = "Cash"

    Private specific_rpt As String = String.Empty

    Dim inputFileName As String

#End Region

#Region "Properties"

    Property PayperiodIDFrom As Object

        Get
            Return pp_rowid_from
        End Get
        Set(value As Object)
            pp_rowid_from = value
        End Set
    End Property

    Property PayperiodIDTo As Object

        Get
            Return pp_rowid_to
        End Get
        Set(value As Object)
            pp_rowid_to = value
        End Set
    End Property

    Property IsActual As Boolean

        Get
            Return is_actual
        End Get
        Set(value As Boolean)
            is_actual = value
        End Set
    End Property

    Property SalaryDistribution As String

        Get
            Return sal_distrib
        End Get
        Set(value As String)
            sal_distrib = value
        End Set
    End Property

    Property SpecificReport As String

        Get
            Return specific_rpt
        End Get
        Set(value As String)
            specific_rpt = value
        End Set
    End Property

#End Region

#Region "Event Handlers"

    Protected Overrides Sub OnLoad(e As EventArgs)

        Dim accesible_buttons =
            Panel1.Controls.Cast(Of Button) '.Where(Function(btn) Convert.ToString(btn.Tag) = specific_rpt)

        'Panel1.Visible = (accesible_buttons.Count > 0)

        'For Each obj In accesible_buttons
        '    obj.Visible = True
        'Next

        MyBase.OnLoad(e)

    End Sub

    Private Sub CrysVwr_FormClosed(sender As Object, e As FormClosedEventArgs) Handles Me.FormClosed
        If CrystalReportViewer1.ReportSource IsNot Nothing Then
            CrystalReportViewer1.ReportSource.Dispose()
        End If
    End Sub

    Private Sub CrysVwr_Load(sender As Object, e As EventArgs) Handles MyBase.Load

    End Sub

    Private Sub CrysVwr_KeyDown(sender As Object, e As KeyEventArgs) Handles Me.KeyDown, CrystalReportViewer1.KeyDown
        If e.Control AndAlso e.KeyCode = Keys.W Then
            Close()
        ElseIf e.Control AndAlso e.KeyCode = Keys.P Then
            CrystalReportViewer1.PrintReport()

        End If

    End Sub

    Private Sub CrysVwr_FormClosing(sender As Object, e As FormClosingEventArgs) Handles Me.FormClosing
        Dim result = MessageBox.Show("Do you want to Close " & Text & " ?", "", MessageBoxButtons.YesNo, MessageBoxIcon.Exclamation)
        If result = DialogResult.No Then
            e.Cancel = True
        ElseIf result = DialogResult.Yes Then
            e.Cancel = False
            CrystalReportViewer1.ReportSource.Dispose()

        End If

    End Sub

    Private Sub ToolStripButton1_Click(sender As Object, e As EventArgs) Handles ToolStripButton1.Click

        inputFileName = InputBox("Name this file as", "Export as MS Word Document").Trim
        If inputFileName.Trim.Length = 0 Then Return

        ExportAsWordDocument(inputFileName)

    End Sub

    Public Sub ExportAsWordDocument(nameOfFile As String)
        If CrystalReportViewer1.ReportSource Is Nothing Then
            Return
        End If

        If nameOfFile.Trim.Length > 0 Then
            Dim rpt As ReportClass = CrystalReportViewer1.ReportSource

            Dim fullPathFile = String.Concat(Path.GetTempPath, nameOfFile, ".doc")
            Try
                rpt.ExportToDisk(CrystalDecisions.Shared.ExportFormatType.WordForWindows,
                                 fullPathFile)
                Process.Start(fullPathFile)
            Catch ex As Exception
                MsgBox("Error occured when exporting.", MsgBoxStyle.Critical, "Export failed")
            End Try
        End If
    End Sub

    Private Sub btnExportPayrollSummaToExcel_Click(sender As Object, e As EventArgs) Handles btnExportPayrollSummaToExcel.Click

        Dim psefr As New PayrollSummaryExcelFormatReportProvider(is_actual)

        With psefr

            .PayperiodIDFrom = pp_rowid_from

            .PayperiodIDTo = pp_rowid_to

            .SalaryDistribution = sal_distrib

            .Run()

        End With

    End Sub

#End Region

End Class