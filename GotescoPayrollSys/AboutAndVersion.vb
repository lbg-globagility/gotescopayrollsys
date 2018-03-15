Imports System.Configuration

Public Class AboutAndVersion

#Region "CHANGE LOGS"
    '©
#Region "version 1.1.7"
    '2017-11-20
    '- department managers monitors the approval of leave, ot, and ob before handing over to HR
    '- system user can tagged as department manager
    '- assignment of employee's dept. manager can be found in employee personal profile

#End Region

#Region "version 1.1.6"
    '2017-10-27
    '- fix a leave during a special non-working holiday
    '- fix codes to properly reset and gain leave balance according to employee's years of service
    '- try to fix dead lock error during payroll generation

#End Region

#Region "version 1.1.5"
    '2017-10-20
    '- 

#End Region

#Region "version 1.1.4"
    '2017-10-18
    '- fix semi-monthly allowance computation
    '- Taxable income is equal to ((Basic_regular + Paid_leave + Paid_holiday) - (SSS + PhilHealth + HDMF))

#End Region

#Region "version 1.1.3"
    '2017-09-13
    '- PayrollGeneration.vb -- SSS contribution computation, Ecola should also be included

#End Region

#Region "version 1.1.2"
    '2017-09-08
    '- fix some issues with the pay slip

    '2017-09-07
    '- PayrollGeneration.vb -- SSS contribution computation, overtime should not be included

#End Region

#Region "version 1.1.1"
    '2017-08-02
    '- resolve the issue on absent during holiday, there should be no absent amount given that date is a holiday

    '2017-08-01
    'NOTE : - need to execute the update statement for `payperiod` table to update the proper ordinal values of weekly basis cut offs
    '         (use this : UPDATE payperiod pp SET pp.LastUpd=IFNULL(ADDDATE(pp.LastUpd, INTERVAL 1 SECOND), CURRENT_TIMESTAMP()), pp.LastUpdBy=IFNULL(pp.LastUpdBy, pp.CreatedBy) WHERE pp.TotalGrossSalary=4)

    '2017-07-21
    'TODO : correct the proper gov't contribution for Daily, Monthly, and Fixed types of employee

    '2017-07-19
    'TODO : please correct the gross income during the view of paystub - actual
    '       (paystub - declared displays gross income very fine)
    '     : sss & phil health, try not to get the amount on the computed basic pay, but rather from the given salary

    '2017-07-18
    'TODO : proper calculation of ecola for payroll/paystub
    '     : change allowance calc in triggers for paystub, for paystubitem table

    '2017-06-29
    'TODO : single print of pay slip, please correct the figures compare to bulk print of pay slips
    '     : bakit walang hours sa payroll, pay slip ? kasi di pa na-encode ang assigned duty shift

#End Region

#End Region

#Region "Variables"

    Private ver_confg As Specialized.NameValueCollection = ConfigurationManager.AppSettings

#End Region

#Region "Event handler"

    Protected Overrides Function ProcessCmdKey(ByRef msg As Message, keyData As Keys) As Boolean
        If keyData = Keys.Escape Then
            Me.Close()
            Return False
        Else
            Return MyBase.ProcessCmdKey(msg, keyData)
        End If
    End Function

    Private Sub AboutAndVersion_Load(sender As Object, e As EventArgs) Handles Me.Load

        lblContent.Text = ""

    End Sub

#End Region

#Region "Properties"
    ''' <summary>
    ''' Returns the version of this software.
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    ReadOnly Property VersionCode As String
        Get
            Dim ver_code As String = ver_confg.GetValues("VersionUpdate").FirstOrDefault

            Return ver_code

        End Get

    End Property

#End Region

End Class