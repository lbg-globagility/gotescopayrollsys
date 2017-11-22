Imports MySql.Data.MySqlClient
Imports System.Threading
Imports System.Threading.Tasks

Public Class PayrollGeneration

    Private employee_dattab As DataTable
    Private isEndOfMonth As String
    Private isorgPHHdeductsched As SByte
    Private isorgSSSdeductsched As SByte
    Private isorgHDMFdeductsched As SByte
    Private isorgWTaxdeductsched As SByte
    Private esal_dattab As DataTable
    Private emp_loans As DataTable
    Private emp_bonus As DataTable
    Private emp_allowanceDaily As DataTable
    Private emp_allowanceMonthly As DataTable
    Private emp_allowanceOnce As DataTable
    Private emp_allowanceSemiM As DataTable
    Private emp_allowanceWeekly As DataTable
    Private notax_allowanceDaily As DataTable
    Private notax_allowanceMonthly As DataTable
    Private notax_allowanceOnce As DataTable
    Private notax_allowanceSemiM As DataTable
    Private notax_allowanceWeekly As DataTable
    Private emp_bonusDaily As DataTable
    Private emp_bonusMonthly As DataTable
    Private emp_bonusOnce As DataTable
    Private emp_bonusSemiM As DataTable
    Private emp_bonusWeekly As DataTable
    Private notax_bonusDaily As DataTable
    Private notax_bonusMonthly As DataTable
    Private notax_bonusOnce As DataTable
    Private notax_bonusSemiM As DataTable
    Private notax_bonusWeekly As DataTable
    Private numofdaypresent As DataTable
    Private etent_totdaypay As DataTable
    Private dtemployeefirsttimesalary As DataTable
    Private prev_empTimeEntry As DataTable
    Private VeryFirstPayPeriodIDOfThisYear As Object
    Private withthirteenthmonthpay As SByte

    Private payWTax As DataTable

    Private filingStatus As DataTable

    Private fixedNonTaxableMonthlyAllowances As DataTable
    Private fixedTaxableMonthlyAllowances As DataTable

    Private Delegate Sub NotifyMainWindow(ByVal progress_index As Integer)
    Private m_NotifyMainWindow As NotifyMainWindow

    Private form_caller As Form

    'ByVal _isorgPHHdeductsched As SByte,
    'ByVal _isorgSSSdeductsched As SByte,
    'ByVal _isorgHDMFdeductsched As SByte,
    'ByVal _isorgWTaxdeductsched As SByte,
    Sub New(ByVal _employee_dattab As DataTable,
                  ByVal _isEndOfMonth As String,
                  ByVal _esal_dattab As DataTable,
                  ByVal _emp_loans As DataTable,
                  ByVal _emp_bonus As DataTable,
                  ByVal _emp_allowanceDaily As DataTable,
                  ByVal _emp_allowanceMonthly As DataTable,
                  ByVal _emp_allowanceOnce As DataTable,
                  ByVal _emp_allowanceSemiM As DataTable,
                  ByVal _emp_allowanceWeekly As DataTable,
                  ByVal _notax_allowanceDaily As DataTable,
                  ByVal _notax_allowanceMonthly As DataTable,
                  ByVal _notax_allowanceOnce As DataTable,
                  ByVal _notax_allowanceSemiM As DataTable,
                  ByVal _notax_allowanceWeekly As DataTable,
                  ByVal _emp_bonusDaily As DataTable,
                  ByVal _emp_bonusMonthly As DataTable,
                  ByVal _emp_bonusOnce As DataTable,
                  ByVal _emp_bonusSemiM As DataTable,
                  ByVal _emp_bonusWeekly As DataTable,
                  ByVal _notax_bonusDaily As DataTable,
                  ByVal _notax_bonusMonthly As DataTable,
                  ByVal _notax_bonusOnce As DataTable,
                  ByVal _notax_bonusSemiM As DataTable,
                  ByVal _notax_bonusWeekly As DataTable,
                  ByVal _numofdaypresent As DataTable,
                  ByVal _etent_totdaypay As DataTable,
                  ByVal _dtemployeefirsttimesalary As DataTable,
                  ByVal _prev_empTimeEntry As DataTable,
                  ByVal _VeryFirstPayPeriodIDOfThisYear As Object,
                  ByVal _withthirteenthmonthpay As SByte,
                  Optional pay_stub_frm As PayStub = Nothing)

        form_caller = pay_stub_frm

        employee_dattab = _employee_dattab
        isEndOfMonth = _isEndOfMonth
        'isorgPHHdeductsched = _isorgPHHdeductsched
        'isorgSSSdeductsched = _isorgSSSdeductsched
        'isorgHDMFdeductsched = _isorgHDMFdeductsched
        'isorgWTaxdeductsched = _isorgWTaxdeductsched
        esal_dattab = _esal_dattab
        emp_loans = _emp_loans
        emp_bonus = _emp_bonus
        emp_allowanceDaily = _emp_allowanceDaily
        emp_allowanceMonthly = _emp_allowanceMonthly
        emp_allowanceOnce = _emp_allowanceOnce
        emp_allowanceSemiM = _emp_allowanceSemiM
        emp_allowanceWeekly = _emp_allowanceWeekly
        notax_allowanceDaily = _notax_allowanceDaily
        notax_allowanceMonthly = _notax_allowanceMonthly
        notax_allowanceOnce = _notax_allowanceOnce
        notax_allowanceSemiM = _notax_allowanceSemiM
        notax_allowanceWeekly = _notax_allowanceWeekly
        emp_bonusDaily = _emp_bonusDaily
        emp_bonusMonthly = _emp_bonusMonthly
        emp_bonusOnce = _emp_bonusOnce
        emp_bonusSemiM = _emp_bonusSemiM
        emp_bonusWeekly = _emp_bonusWeekly
        notax_bonusDaily = _notax_bonusDaily
        notax_bonusMonthly = _notax_bonusMonthly
        notax_bonusOnce = _notax_bonusOnce
        notax_bonusSemiM = _notax_bonusSemiM
        notax_bonusWeekly = _notax_bonusWeekly
        numofdaypresent = _numofdaypresent
        etent_totdaypay = _etent_totdaypay
        dtemployeefirsttimesalary = _dtemployeefirsttimesalary
        prev_empTimeEntry = _prev_empTimeEntry
        VeryFirstPayPeriodIDOfThisYear = _VeryFirstPayPeriodIDOfThisYear
        withthirteenthmonthpay = _withthirteenthmonthpay

        payWTax = New MySQLQueryToDataTable("SELECT * FROM paywithholdingtax;" &
                                          "").ResultTable

        filingStatus = New MySQLQueryToDataTable("SELECT * FROM filingstatus;" &
                                          "").ResultTable

        m_NotifyMainWindow = AddressOf pay_stub_frm.ProgressCounter

    End Sub

    Private n_PayrollDateFrom As Object = Nothing

    Property PayrollDateFrom As Object

        Get
            Return n_PayrollDateFrom
        End Get

        Set(value As Object)
            n_PayrollDateFrom = value

        End Set

    End Property

    Private n_PayrollDateTo As Object = Nothing

    Property PayrollDateTo As Object

        Get
            Return n_PayrollDateTo
        End Get

        Set(value As Object)
            n_PayrollDateTo = value

        End Set

    End Property

    Private n_PayrollRecordID As Object = Nothing

    Property PayrollRecordID As Object

        Get
            Return n_PayrollRecordID
        End Get

        Set(value As Object)
            n_PayrollRecordID = value

        End Set

    End Property

    'n_PayrollRecordID

    Private strPHHdeductsched,
        strSSSdeductsched,
        strHDMFdeductsched As String

    Private n_PayStub As New PayStub

    Private mysql_conn As MySqlConnection

    Dim myTrans As MySqlTransaction

    Sub DoProcess()

        Dim emptimeentryOfLeave As New DataTable

        Dim emptimeentryOfHoliday As New DataTable

        Dim last_enddate_cutoff_thisyear =
            New ExecuteQuery("SELECT DATE_FORMAT(pp.PayToDate,@@date_format)" &
                             " FROM payperiod pp" &
                             " INNER JOIN payperiod pyp ON pyp.RowID='" & n_PayrollRecordID & "'" &
                             " AND pp.`Year`=pyp.`Year`" &
                             " AND pp.OrganizationID=pyp.OrganizationID" &
                             " AND pp.TotalGrossSalary=pyp.TotalGrossSalary" &
                             " ORDER BY pp.PayFromDate DESC,pp.PayToDate DESC" &
                             " LIMIT 1;").Result
        Dim GET_PREVIOUSMONTHTAXAMOUNT = New SQLQueryToDatatable("CALL GET_PREVIOUSMONTHTAXAMOUNT('" & n_PayrollRecordID & "')").ResultTable
        emptimeentryOfLeave = New DataTable 'TotalDayPay
        emptimeentryOfLeave = New SQLQueryToDatatable("SELECT ete.*,(ete.TotalDayPay - (ete.RegularHoursAmount + ete.OvertimeHoursAmount + ete.HolidayPayAmount)) AS LeavePayAmount FROM employeetimeentry ete INNER JOIN (SELECT pp.OrganizationID,MIN(pp1.PayFromDate) AS PayFromDate,MAX(pp2.PayToDate) AS PayToDate FROM payperiod pp INNER JOIN (SELECT * FROM payperiod ORDER BY PayFromDate,PayToDate) pp1 ON pp1.`Month`=pp.`Month` AND pp1.`Year`=pp.`Year` AND pp1.OrganizationID=pp.OrganizationID AND pp1.TotalGrossSalary=pp.TotalGrossSalary INNER JOIN (SELECT * FROM payperiod ORDER BY PayFromDate DESC,PayToDate DESC) pp2 ON pp2.`Month`=pp.`Month` AND pp2.`Year`=pp.`Year` AND pp2.OrganizationID=pp.OrganizationID AND pp2.TotalGrossSalary=pp.TotalGrossSalary WHERE pp.RowID='" & n_PayrollRecordID & "') i ON i.PayFromDate IS NOT NULL AND i.PayToDate IS NOT NULL AND ete.OrganizationID=i.OrganizationID AND ete.`Date` BETWEEN i.PayFromDate AND i.PayToDate AND (ete.VacationLeaveHours + ete.SickLeaveHours + ete.MaternityLeaveHours + ete.OtherLeaveHours + ete.AdditionalVLHours) > 0 AND ete.RegularHoursAmount=0 ORDER BY ete.EmployeeID,ete.`Date`;").ResultTable
        emptimeentryOfHoliday = New DataTable 'HolidayPayAmount
        emptimeentryOfHoliday = New SQLQueryToDatatable("SELECT ete.*,i.* FROM employeetimeentry ete INNER JOIN payrate pr ON pr.RowID=ete.PayRateID AND pr.PayType!='Regular Day' INNER JOIN (SELECT pp.OrganizationID,MIN(pp1.PayFromDate) AS PayFromDate, MIN(pp1.PayToDate) AS PayFromDate1, MAX(pp2.PayToDate) AS PayToDate, MAX(pp2.PayFromDate) AS PayToDate1 FROM payperiod pp INNER JOIN (SELECT * FROM payperiod ORDER BY PayFromDate,PayToDate) pp1 ON pp1.`Month`=pp.`Month` AND pp1.`Year`=pp.`Year` AND pp1.OrganizationID=pp.OrganizationID AND pp1.TotalGrossSalary=pp.TotalGrossSalary INNER JOIN (SELECT * FROM payperiod ORDER BY PayFromDate DESC,PayToDate DESC) pp2 ON pp2.`Month`=pp.`Month` AND pp2.`Year`=pp.`Year` AND pp2.OrganizationID=pp.OrganizationID AND pp2.TotalGrossSalary=pp.TotalGrossSalary WHERE pp.RowID='" & n_PayrollRecordID & "') i ON i.PayFromDate IS NOT NULL AND i.PayToDate IS NOT NULL AND ete.OrganizationID=i.OrganizationID AND ete.`Date` BETWEEN i.PayFromDate AND i.PayToDate AND ete.HolidayPayAmount > 0 AND ete.RegularHoursAmount=0 ORDER BY ete.EmployeeID,ete.`Date`;").ResultTable
        'Dim the_MinimumWageAmount = ValNoComma(drow("MinimumWageAmount"))
        Dim the_MinimumWageAmount = ValNoComma(New ExecuteQuery("SELECT MinimumWageValue FROM payperiod WHERE RowID='" & n_PayrollRecordID & "';").Result)

        'Dim sel_employee_dattab = employee_dattab.Select("PositionID IS NULL")

        'If sel_employee_dattab.Count = -1 Then

        '    For Each drow In sel_employee_dattab

        '        pause_process_message = "Employee '" & drow("EmployeeID") & "' has no position." & _
        '            vbNewLine & "Please supply his/her position before proceeding to payroll."

        '        e.Cancel = True

        '        If bgworkgenpayroll.CancellationPending Then

        '            bgworkgenpayroll.CancelAsync()

        '        End If

        '    Next

        'End If

        'If e.Cancel = False Then

        'End If

        payWTax = New SQLQueryToDatatable("SELECT * FROM paywithholdingtax;" &
                                          "").ResultTable

        filingStatus = New SQLQueryToDatatable("SELECT * FROM filingstatus;" &
                                          "").ResultTable

        Dim phh As New DataTable
        phh = New SQLQueryToDatatable("SELECT * FROM payphilhealth;").ResultTable

        Dim sss As New DataTable
        sss = New SQLQueryToDatatable("SELECT * FROM paysocialsecurity;").ResultTable


        Dim emp_count = employee_dattab.Rows.Count

        Dim progress_index As Integer = 1

        Dim emptaxabsal As Decimal = 0
        Dim empnetsal As Decimal = 0
        Dim emp_taxabsal = Val(0)

        Dim tax_amount = Val(0)

        Dim grossincome = Val(0)

        Dim grossincome_firsthalf = Val(0)

        Dim date_to_use = If(CDate(n_PayrollDateFrom) > CDate(n_PayrollDateTo), CDate(n_PayrollDateFrom), CDate(n_PayrollDateTo))

        Dim dateStr_to_use = Format(CDate(date_to_use), "yyyy-MM-dd")

        Dim numberofweeksthismonth = _
            EXECQUER("SELECT `COUNTTHEWEEKS`('" & dateStr_to_use & "');")

        'Dim sel_row = employee_dattab.Rows.Cast(Of DataRow)()

        'Parallel.ForEach(sel_row, Sub(drow)

        '                              If ValNoComma(drow("RowID")) = 57 Then

        '                              End If

        '                          End Sub)

        'For Each drow As DataRow In employee_dattab.Rows

        '    Dim procparam_array = New String() {orgztnID,
        '                                        Convert.ToInt32(drow("RowID")),
        '                                        z_User,
        '                                        n_PayrollDateFrom, n_PayrollDateTo}
        '    Dim n_ExecSQLProcedure As New  _
        '        ExecSQLProcedure("LEAVE_gainingbalance", 192,
        '                         procparam_array)

        '    If n_ExecSQLProcedure.HasError Then
        '        Dim lv_gainbal_haserr As Boolean = True
        '        Console.WriteLine(String.Concat("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@LEAVE_gainingbalance error in ", Convert.ToInt32(drow("RowID"))))
        '    End If

        'Next

        For Each drow As DataRow In employee_dattab.Rows

            Try

                If ValNoComma(drow("RowID")) = 57 Then
                    Dim call_lambert = "Over here"
                End If

                strPHHdeductsched = drow("PhHealthDeductSched").ToString
                If drow("PhHealthDeductSched").ToString = "End of the month" Then

                    isorgPHHdeductsched = 0

                ElseIf drow("PhHealthDeductSched").ToString = "First half" Then

                    isorgPHHdeductsched = 1

                ElseIf drow("PhHealthDeductSched").ToString = "Per pay period" Then

                    isorgPHHdeductsched = 2

                End If


                strSSSdeductsched = drow("SSSDeductSched").ToString
                If drow("SSSDeductSched").ToString = "End of the month" Then

                    isorgSSSdeductsched = 0

                ElseIf drow("SSSDeductSched").ToString = "First half" Then

                    isorgSSSdeductsched = 1

                ElseIf drow("SSSDeductSched").ToString = "Per pay period" Then

                    isorgSSSdeductsched = 2

                End If


                strHDMFdeductsched = drow("HDMFDeductSched").ToString
                If drow("HDMFDeductSched").ToString = "End of the month" Then

                    isorgHDMFdeductsched = 0

                ElseIf drow("HDMFDeductSched").ToString = "First half" Then

                    isorgHDMFdeductsched = 1

                ElseIf drow("HDMFDeductSched").ToString = "Per pay period" Then

                    isorgHDMFdeductsched = 2

                End If


                If drow("WTaxDeductSched").ToString = "End of the month" _
                    Or drow("WTaxDeductSched").ToString = "First half of next month" Then

                    isorgWTaxdeductsched = 0

                ElseIf drow("WTaxDeductSched").ToString = "First half" Then

                    isorgWTaxdeductsched = 1

                ElseIf drow("WTaxDeductSched").ToString = "Per pay period" Then

                    isorgWTaxdeductsched = 2

                End If


                Dim employee_ID = Trim(drow("RowID"))

                Dim org_WorkDaysPerYear = Convert.ToInt32(drow("WorkDaysPerYear"))

                Dim divisorMonthlys = If(drow("PayFrequencyID") = 1, 2, _
                                         If(drow("PayFrequencyID") = 2, 1, _
                                            If(drow("PayFrequencyID") = 3, EXECQUER("SELECT COUNT(RowID) FROM employeetimeentry WHERE EmployeeID='" & employee_ID & "' AND Date BETWEEN '" & n_PayrollDateFrom & "' AND '" & n_PayrollDateTo & "' AND IFNULL(TotalDayPay,0)!=0 AND OrganizationID='" & orgztnID & "';"), _
                                               numberofweeksthismonth)))


                Dim rowempsal = esal_dattab.Select("EmployeeID = '" & drow("RowID") & "'")

                Dim emp_loan = emp_loans.Select("EmployeeID = '" & drow("RowID") & "' AND Nondeductible = '0'")

                Dim emp_bon = emp_bonus.Select("EmployeeID = '" & drow("RowID") & "'")








                Dim day_allowance = emp_allowanceDaily.Select("EmployeeID = '" & drow("RowID") & "'")

                Dim month_allowance = emp_allowanceMonthly.Select("EmployeeID = '" & drow("RowID") & "'")

                Dim once_allowance = emp_allowanceOnce.Select("EmployeeID = '" & drow("RowID") & "'")

                Dim semim_allowance = emp_allowanceSemiM.Select("EmployeeID = '" & drow("RowID") & "'")

                Dim week_allowance = emp_allowanceWeekly.Select("EmployeeID = '" & drow("RowID") & "'")

                'emp_allowanceSemiM

                'emp_allowanceWeekly




                Dim daynotax_allowance = notax_allowanceDaily.Select("EmployeeID = '" & drow("RowID") & "'")

                Dim monthnotax_allowance = notax_allowanceMonthly.Select("EmployeeID = '" & drow("RowID") & "'")

                Dim oncenotax_allowance = notax_allowanceOnce.Select("EmployeeID = '" & drow("RowID") & "'")

                Dim semimnotax_allowance = notax_allowanceSemiM.Select("EmployeeID = '" & drow("RowID") & "'")

                Dim weeknotax_allowance = notax_allowanceWeekly.Select("EmployeeID = '" & drow("RowID") & "'")

                'notax_allowanceSemiM

                'notax_allowanceWeekly




                Dim day_bon = emp_bonusDaily.Select("EmployeeID = '" & drow("RowID") & "'")

                Dim month_bon = emp_bonusMonthly.Select("EmployeeID = '" & drow("RowID") & "'")

                Dim once_bon = emp_bonusOnce.Select("EmployeeID = '" & drow("RowID") & "'")

                Dim semim_bon = emp_bonusSemiM.Select("EmployeeID = '" & drow("RowID") & "'")

                Dim week_bon = emp_bonusWeekly.Select("EmployeeID = '" & drow("RowID") & "'")

                'emp_bonusSemiM

                'emp_bonusWeekly



                Dim daynotax_bon = notax_bonusDaily.Select("EmployeeID = '" & drow("RowID") & "'")

                Dim monthnotax_bon = notax_bonusMonthly.Select("EmployeeID = '" & drow("RowID") & "'")

                Dim oncenotax_bon = notax_bonusOnce.Select("EmployeeID = '" & drow("RowID") & "'")

                Dim semimnotax_bon = notax_bonusSemiM.Select("EmployeeID = '" & drow("RowID") & "'")

                Dim weeknotax_bon = notax_bonusWeekly.Select("EmployeeID = '" & drow("RowID") & "'")

                'notax_bonusSemiM

                'notax_bonusWeekly




                Dim valemp_loan = Val(0)
                For Each drowloan In emp_loan
                    valemp_loan = drowloan("DeductionAmount")
                Next

                'Dim valemp_bon = Val(0)
                'For Each drowbon In emp_bon
                '    valemp_bon = drowbon("BonusAmount")
                'Next



                Dim valday_allowance = ValNoComma(emp_allowanceDaily.Compute("SUM(TotalAllowanceAmount)", "EmployeeID = '" & drow("RowID") & "'"))
                'GET_employeeallowance(drow("RowID").ToString, _
                '                  "Daily", _
                '                  drow("EmployeeType").ToString, _
                '                  "1")

                Dim valmonth_allowance = ValNoComma(emp_allowanceMonthly.Compute("SUM(TotalAllowanceAmount)", "EmployeeID = '" & drow("RowID") & "'"))

                'If isEndOfMonth = 1 Then

                '    For Each drowmonallow In month_allowance

                '        valmonth_allowance = drowmonallow("TotalAllowanceAmount") ' / divisorMonthlys

                '        Exit For

                '    Next

                'End If

                Dim valonce_allowance = 0.0
                For Each drowonceallow In once_allowance
                    'valonce_allowance = drowonceallow("TotalAllowanceAmount")
                Next

                Dim valsemim_allowance = ValNoComma(emp_allowanceSemiM.Compute("SUM(TotalAllowanceAmount)", "EmployeeID = '" & drow("RowID") & "'"))
                'For Each drowsemimallow In semim_allowance
                '    valonce_allowance = drowsemimallow("TotalAllowanceAmount")
                'Next

                Dim valweek_allowance = 0.0
                For Each drowweekallow In week_allowance
                    'valweek_allowance = drowweekallow("TotalAllowanceAmount")
                Next


                'this is taxable                                ' / divisorMonthlys
                Dim totalemployeeallownce = (valday_allowance _
                                             + (valmonth_allowance) _
                                             + valonce_allowance _
                                             + valsemim_allowance _
                                             + valweek_allowance)



                Dim valdaynotax_allowance = ValNoComma(notax_allowanceDaily.Compute("SUM(TotalAllowanceAmount)", "EmployeeID = '" & drow("RowID") & "'"))
                'GET_employeeallowance(drow("RowID").ToString, _
                '                  "Daily", _
                '                  drow("EmployeeType").ToString, _
                '                  "0")

                Dim valmonthnotax_allowance = ValNoComma(notax_allowanceMonthly.Compute("SUM(TotalAllowanceAmount)", "EmployeeID = '" & drow("RowID") & "'"))

                'If isEndOfMonth = 1 Then

                '    For Each drowmonallow In monthnotax_allowance

                '        valmonthnotax_allowance = drowmonallow("TotalAllowanceAmount") ' / divisorMonthlys

                '        Exit For

                '    Next

                'End If

                Dim valoncenotax_allowance = 0.0
                For Each drowonceallow In oncenotax_allowance
                    'valoncenotax_allowance = drowonceallow("TotalAllowanceAmount")
                Next

                Dim valsemimnotax_allowance = ValNoComma(notax_allowanceSemiM.Compute("SUM(TotalAllowanceAmount)", "EmployeeID = '" & drow("RowID") & "'"))
                'For Each drowsemimallow In semimnotax_allowance
                '    valoncenotax_allowance = drowsemimallow("TotalAllowanceAmount")
                'Next

                Dim valweeknotax_allowance = 0.0
                For Each drowweekallow In weeknotax_allowance
                    'valweeknotax_allowance = drowweekallow("TotalAllowanceAmount")
                Next





                'this is non-taxable                                        ' / divisorMonthlys
                '+ valsemimonnotax_allowance _
                Dim totalnotaxemployeeallownce = (valdaynotax_allowance _
                                                  + (valmonthnotax_allowance) _
                                                  + valoncenotax_allowance _
                                                  + valsemimnotax_allowance _
                                                  + valweeknotax_allowance)





                Dim valday_bon = ValNoComma(emp_bonusDaily.Compute("SUM(TotalBonusAmount)", "EmployeeID = '" & drow("RowID") & "'"))
                'For Each drowdaybon In day_bon
                '    Exit For
                '    valday_bon = drowdaybon("BonusAmount")
                '    If drow("EmployeeType").ToString = "Fixed" Then
                '        valday_bon = valday_bon * numofweekdays 'numofweekends
                '    Else
                '        Dim daymultiplier = numofdaypresent.Select("EmployeeID = '" & drow("RowID") & "'")
                '        For Each drowdaymultip In daymultiplier
                '            Dim i_val = Val(drowdaymultip("DaysAttended"))
                '            valday_bon = valday_bon * i_val
                '            Exit For
                '        Next

                '    End If

                '    Exit For
                'Next

                Dim valmonth_bon = ValNoComma(emp_bonusMonthly.Compute("SUM(TotalBonusAmount)", "EmployeeID = '" & drow("RowID") & "'"))

                'If isEndOfMonth = 1 Then

                '    For Each drowmonbon In month_bon
                '        valmonth_bon = drowmonbon("BonusAmount")
                '    Next

                'End If

                Dim valonce_bon = ValNoComma(emp_bonusOnce.Compute("SUM(TotalBonusAmount)", "EmployeeID = '" & drow("RowID") & "'"))
                'For Each drowoncebon In once_bon
                '    valonce_bon = drowoncebon("BonusAmount")
                'Next

                Dim valsemim_bon = ValNoComma(emp_bonusSemiM.Compute("SUM(TotalBonusAmount)", "EmployeeID = '" & drow("RowID") & "'"))
                'For Each drowsemimbon In semim_bon
                '    valonce_bon = drowsemimbon("BonusAmount")
                'Next

                Dim valweek_bon = 0.0
                For Each drowweekbon In week_bon
                    valonce_bon = drowweekbon("BonusAmount")
                Next

                If Convert.ToInt16(drow("RowID")) = 70 Then
                    Dim call_me = "Hey! over here"
                End If

                'this is taxable                        ' / divisorMonthlys
                Dim totalemployeebonus = (valday_bon _
                                          + valmonth_bon _
                                          + valonce_bon _
                                          + valsemim_bon _
                                          + valweek_bon)




                Dim valdaynotax_bon = ValNoComma(notax_bonusDaily.Compute("SUM(TotalBonusAmount)", "EmployeeID = '" & drow("RowID") & "'"))
                'For Each drowdaybon In daynotax_bon
                '    valdaynotax_bon = drowdaybon("BonusAmount")

                '    If drow("EmployeeType").ToString = "Fixed" Then
                '        valdaynotax_bon = valdaynotax_bon * numofweekdays 'numofweekends
                '    Else
                '        Dim daymultiplier = numofdaypresent.Select("EmployeeID = '" & drow("RowID") & "'")
                '        For Each drowdaymultip In daymultiplier
                '            Dim i_val = Val(drowdaymultip("DaysAttended"))
                '            valdaynotax_bon = valdaynotax_bon * i_val
                '            Exit For
                '        Next

                '    End If

                '    Exit For
                'Next

                Dim valmonthnotax_bon = ValNoComma(notax_bonusMonthly.Compute("SUM(TotalBonusAmount)", "EmployeeID = '" & drow("RowID") & "'"))

                'If isEndOfMonth = 1 Then

                '    For Each drowmonbon In monthnotax_bon
                '        valmonthnotax_bon = drowmonbon("BonusAmount")
                '    Next

                'End If

                Dim valoncenotax_bon = ValNoComma(notax_bonusOnce.Compute("SUM(TotalBonusAmount)", "EmployeeID = '" & drow("RowID") & "'"))
                'For Each drowoncebon In oncenotax_bon
                '    valoncenotax_bon = drowoncebon("BonusAmount")
                'Next

                Dim valsemimnotax_bon = ValNoComma(notax_bonusSemiM.Compute("SUM(TotalBonusAmount)", "EmployeeID = '" & drow("RowID") & "'"))
                'For Each drowsemimbon In semimnotax_bon
                '    valoncenotax_bon = drowsemimbon("BonusAmount")
                'Next

                Dim valweeknotax_bon = 0.0
                For Each drowweekbon In weeknotax_bon
                    valoncenotax_bon = drowweekbon("BonusAmount")
                Next



                'this is non-taxable
                Dim totalnotaxemployeebonus = Val(0)

                '(valdaynotax_bon _
                '+ (valmonthnotax_bon / divisorMonthlys) _
                '+ valoncenotax_bon _
                '+ valsemimnotax_bon _
                '+ valweeknotax_bon)

                totalnotaxemployeebonus = valdaynotax_bon
                totalnotaxemployeebonus += valoncenotax_bon
                totalnotaxemployeebonus += valsemimnotax_bon
                totalnotaxemployeebonus += valweeknotax_bon

                totalnotaxemployeebonus += valmonthnotax_bon ' / divisorMonthlys







                Dim emptotdaypay = etent_totdaypay.Select("EmployeeID = '" & drow("RowID") & "'")

                grossincome = Val(0)

                Dim pstub_TotalEmpSSS = Val(0)
                Dim pstub_TotalCompSSS = Val(0)
                Dim pstub_TotalEmpPhilhealth = Val(0)
                Dim pstub_TotalCompPhilhealth = Val(0)
                Dim pstub_TotalEmpHDMF = Val(0)
                Dim pstub_TotalCompHDMF = Val(0)
                Dim pstub_TotalVacationDaysLeft = Val(0)
                Dim pstub_TotalLoans = Val(0)
                Dim pstub_TotalBonus = Val(0)
                emp_taxabsal = Val(0)
                emptaxabsal = Val(0)
                empnetsal = Val(0)
                tax_amount = Val(0)

                Dim pstub_TotalAllowance = Val(0)

                Dim the_taxable_salary = ValNoComma(0)

                For Each drowtotdaypay In emptotdaypay

                    grossincome = Val(0)
                    grossincome_firsthalf = Val(0)
                    pstub_TotalEmpSSS = Val(0)
                    pstub_TotalCompSSS = Val(0)
                    pstub_TotalEmpPhilhealth = Val(0)
                    pstub_TotalCompPhilhealth = Val(0)
                    pstub_TotalEmpHDMF = Val(0)
                    pstub_TotalCompHDMF = Val(0)
                    pstub_TotalVacationDaysLeft = Val(0)
                    pstub_TotalLoans = Val(0)
                    pstub_TotalBonus = Val(0)
                    emp_taxabsal = Val(0)
                    emptaxabsal = Val(0)
                    empnetsal = Val(0)
                    tax_amount = Val(0)
                    Dim OTAmount = Val(0)
                    Dim NightDiffOTAmount = Val(0)
                    Dim NightDiffAmount = Val(0)

                    For Each drowsal In rowempsal

                        Dim skipgovtdeduct As Boolean = Convert.ToInt16(drow("IsFirstTimeSalary"))

                        emptaxabsal = 0
                        empnetsal = 0
                        emp_taxabsal = 0

                        OTAmount = ValNoComma(drowtotdaypay("OvertimeHoursAmount"))

                        NightDiffOTAmount = ValNoComma(drowtotdaypay("NightDiffOTHoursAmount"))

                        NightDiffAmount = ValNoComma(drowtotdaypay("NightDiffHoursAmount"))

                        employee_ID = Trim(drow("RowID"))

                        Dim employment_type = StrConv(drow("EmployeeType").ToString, VbStrConv.ProperCase)

                        Dim monthly_computed_salary = ValNoComma(0)

                        If employee_ID = 64 Then
                            Console.WriteLine("Over here")
                        End If

                        If employment_type = "Fixer" Then
                            grossincome = ValNoComma(drowsal("BasicPay"))
                            grossincome = grossincome + (OTAmount + NightDiffAmount + NightDiffOTAmount)

                            grossincome_firsthalf = ValNoComma(drowsal("BasicPay")) + _
                                ValNoComma(prev_empTimeEntry.Compute("SUM(OvertimeHoursAmount)", "EmployeeID = '" & drow("RowID") & "'")) + _
                                ValNoComma(prev_empTimeEntry.Compute("SUM(NightDiffOTHoursAmount)", "EmployeeID = '" & drow("RowID") & "'")) + _
                                ValNoComma(prev_empTimeEntry.Compute("SUM(NightDiffHoursAmount)", "EmployeeID = '" & drow("RowID") & "'"))

                            monthly_computed_salary = grossincome + grossincome_firsthalf

                        ElseIf employment_type = "Monthly" Or employment_type = "Fixed" Then

                            If skipgovtdeduct And employment_type = "Monthly" Then
                                grossincome = ValNoComma(drowtotdaypay("TotalDayPay"))

                                grossincome_firsthalf = ValNoComma(prev_empTimeEntry.Compute("SUM(TotalDayPay)", "EmployeeID = '" & drow("RowID") & "'"))

                            Else

                                grossincome = ValNoComma(drowsal("BasicPay")) ' + ValNoComma(emptimeentryOfHoliday.Compute("SUM(HolidayPayAmount)", "EmployeeID = '" & drow("RowID") & "' AND PayFromDate <= Date AND Date <= PayFromDate1"))
                                'grossincome = grossincome + (OTAmount + NightDiffAmount + NightDiffOTAmount)

                                grossincome -= (ValNoComma(drowtotdaypay("HoursLateAmount")) _
                                                + ValNoComma(drowtotdaypay("UndertimeHoursAmount")) _
                                                + ValNoComma(drowtotdaypay("Absent")))
                                grossincome += ValNoComma(drowtotdaypay("OvertimeHoursAmount"))
                                'n_PayrollRecordID
                                grossincome_firsthalf = ValNoComma(drowsal("BasicPay")) '+ _
                                'ValNoComma(prev_empTimeEntry.Compute("SUM(OvertimeHoursAmount)", "EmployeeID = " & drow("RowID").ToString)) + _
                                'ValNoComma(prev_empTimeEntry.Compute("SUM(NightDiffOTHoursAmount)", "EmployeeID = " & drow("RowID").ToString)) + _
                                'ValNoComma(prev_empTimeEntry.Compute("SUM(NightDiffHoursAmount)", "EmployeeID = " & drow("RowID").ToString))
                                grossincome_firsthalf += 0 'ValNoComma(emptimeentryOfHoliday.Compute("SUM(HolidayPayAmount)", "EmployeeID = '" & drow("RowID") & "' AND PayToDate1 <= Date AND Date <= PayToDate"))
                                grossincome_firsthalf -=
                                    (ValNoComma(prev_empTimeEntry.Compute("SUM(HoursLateAmount)", "EmployeeID = '" & drow("RowID") & "'")) _
                                    + ValNoComma(prev_empTimeEntry.Compute("SUM(UndertimeHoursAmount)", "EmployeeID = '" & drow("RowID") & "'")) _
                                    + ValNoComma(prev_empTimeEntry.Compute("SUM(Absent)", "EmployeeID = '" & drow("RowID") & "'")))
                                grossincome_firsthalf += ValNoComma(prev_empTimeEntry.Compute("SUM(OvertimeHoursAmount)", "EmployeeID = '" & drow("RowID") & "'"))
                            End If

                            monthly_computed_salary = grossincome + grossincome_firsthalf

                        ElseIf employment_type = "Daily" Then
                            grossincome = ValNoComma(drowtotdaypay("TotalDayPay"))
                            grossincome_firsthalf = ValNoComma(prev_empTimeEntry.Compute("SUM(TotalDayPay)", "EmployeeID = '" & drow("RowID") & "'"))
                            'monthly_computed_salary = grossincome + grossincome_firsthalf _
                            monthly_computed_salary = ValNoComma(prev_empTimeEntry.Compute("SUM(RegularHoursAmount)", "EmployeeID = '" & drow("RowID") & "'")) + ValNoComma(etent_totdaypay.Compute("SUM(RegularHoursAmount)", "EmployeeID = '" & drow("RowID") & "'")) _
                                + ValNoComma(emptimeentryOfHoliday.Compute("SUM(HolidayPayAmount)", "EmployeeID = '" & drow("RowID") & "'")) + If(ValNoComma(emptimeentryOfLeave.Compute("SUM(LeavePayAmount)", "EmployeeID = '" & drow("RowID") & "'")) < 0, 0, ValNoComma(emptimeentryOfLeave.Compute("SUM(LeavePayAmount)", "EmployeeID = '" & drow("RowID") & "'")))
                            'monthly_computed_salary = ValNoComma(prev_empTimeEntry.Compute("SUM(RegularHoursAmount)", "EmployeeID = '" & drow("RowID") & "'")) _
                            '                      + ValNoComma(etent_totdaypay.Compute("SUM(RegularHoursAmount)", "EmployeeID = '" & drow("RowID") & "'"))
                        End If

                        'grossincome = Math.Round(grossincome, 2)
                        Dim addtl_taxable_daily_allowance = ValNoComma(prev_empTimeEntry.Compute("SUM(TaxableDailyAllowance)", "EmployeeID = '" & drow("RowID") & "'")) _
                                                            + ValNoComma(etent_totdaypay.Compute("SUM(TaxableDailyAllowance)", "EmployeeID = '" & drow("RowID") & "'"))
                        'monthly_computed_salary = ValNoComma(prev_empTimeEntry.Compute("SUM(RegularHoursAmount)", "EmployeeID = '" & drow("RowID") & "'")) _
                        '                          + ValNoComma(etent_totdaypay.Compute("SUM(RegularHoursAmount)", "EmployeeID = '" & drow("RowID") & "'"))
                        Dim amount_used_to_get_sss_contrib = (monthly_computed_salary + addtl_taxable_daily_allowance) '_
                        '+ ValNoComma(emptimeentryOfHoliday.Compute("SUM(HolidayPayAmount)", "EmployeeID = '" & drow("RowID") & "'")) + If(ValNoComma(emptimeentryOfLeave.Compute("SUM(LeavePayAmount)", "EmployeeID = '" & drow("RowID") & "'")) < 0, 0, ValNoComma(emptimeentryOfLeave.Compute("SUM(LeavePayAmount)", "EmployeeID = '" & drow("RowID") & "'")))

                        Dim sss_ee, sss_er As Double

                        If Convert.ToString(drow("EmployeeType")) = "Daily" Then

                            'For Daily employees
                            sss_ee = ValNoComma(sss.Compute("MIN(EmployeeContributionAmount)", "RangeFromAmount <= " & amount_used_to_get_sss_contrib & " AND " & amount_used_to_get_sss_contrib & " <= RangeToAmount"))
                            sss_er = ValNoComma(sss.Compute("MIN(EmployerContributionAmount)", "RangeFromAmount <= " & amount_used_to_get_sss_contrib & " AND " & amount_used_to_get_sss_contrib & " <= RangeToAmount"))
                            '
                        Else

                            'For Monthly employees
                            sss_ee = ValNoComma(sss.Compute("MIN(EmployeeContributionAmount)", String.Concat("RowID = ", ValNoComma(drowsal("PaySocialSecurityID")))))
                            sss_er = ValNoComma(sss.Compute("MIN(EmployerContributionAmount)", String.Concat("RowID = ", ValNoComma(drowsal("PaySocialSecurityID")))))

                        End If

                        If isEndOfMonth = isorgSSSdeductsched Then
                            'pstub_TotalEmpSSS = CDec(drowsal("EmployeeContributionAmount"))
                            'pstub_TotalCompSSS = CDec(drowsal("EmployerContributionAmount"))

                            pstub_TotalEmpSSS = sss_ee
                            pstub_TotalCompSSS = sss_er

                        Else
                            If isorgSSSdeductsched = 2 Then 'Per pay period
                                'pstub_TotalEmpSSS = CDec(drowsal("EmployeeContributionAmount"))
                                'pstub_TotalCompSSS = CDec(drowsal("EmployerContributionAmount"))

                                pstub_TotalEmpSSS = sss_ee
                                pstub_TotalCompSSS = sss_er

                                pstub_TotalEmpSSS = pstub_TotalEmpSSS / ValNoComma(drow("PAYFREQUENCY_DIVISOR"))
                                pstub_TotalCompSSS = pstub_TotalCompSSS / ValNoComma(drow("PAYFREQUENCY_DIVISOR"))

                            End If

                        End If

                        Dim phh_ee = ValNoComma(phh.Compute("MIN(EmployeeShare)", String.Concat("RowID = ", ValNoComma(drowsal("PayPhilhealthID")))))
                        Dim phh_er = ValNoComma(phh.Compute("MIN(EmployerShare)", String.Concat("RowID = ", ValNoComma(drowsal("PayPhilhealthID")))))
                        'Dim phh_ee = ValNoComma(phh.Compute("MIN(EmployeeShare)", "SalaryRangeFrom <= " & amount_used_to_get_sss_contrib & " AND " & amount_used_to_get_sss_contrib & " <= SalaryRangeTo")) 'monthly_computed_salary
                        'Dim phh_er = ValNoComma(phh.Compute("MIN(EmployerShare)", "SalaryRangeFrom <= " & amount_used_to_get_sss_contrib & " AND " & amount_used_to_get_sss_contrib & " <= SalaryRangeTo")) 'monthly_computed_salary
                        ''Dim phh_ee = ValNoComma(phh.Compute("MIN(EmployeeShare)", "RowID = " & ValNoComma(drowsal("PayPhilhealthID"))))
                        ''Dim phh_er = ValNoComma(phh.Compute("MIN(EmployerShare)", "RowID = " & ValNoComma(drowsal("PayPhilhealthID"))))

                        If isEndOfMonth = isorgPHHdeductsched Then
                            'pstub_TotalEmpPhilhealth = CDec(drowsal("EmployeeShare"))
                            'pstub_TotalCompPhilhealth = CDec(drowsal("EmployerShare"))

                            pstub_TotalEmpPhilhealth = phh_ee
                            pstub_TotalCompPhilhealth = phh_er

                        Else
                            If isorgPHHdeductsched = 2 Then 'Per pay period
                                'pstub_TotalEmpPhilhealth = CDec(drowsal("EmployeeShare"))
                                'pstub_TotalCompPhilhealth = CDec(drowsal("EmployerShare"))

                                pstub_TotalEmpPhilhealth = phh_ee
                                pstub_TotalCompPhilhealth = phh_er

                                pstub_TotalEmpPhilhealth = pstub_TotalEmpPhilhealth / ValNoComma(drow("PAYFREQUENCY_DIVISOR"))
                                pstub_TotalCompPhilhealth = pstub_TotalCompPhilhealth / ValNoComma(drow("PAYFREQUENCY_DIVISOR"))

                            End If

                        End If

                        If isEndOfMonth = isorgHDMFdeductsched Then
                            pstub_TotalEmpHDMF = CDec(drowsal("HDMFAmount"))
                            pstub_TotalCompHDMF = 100 'CDec(drowsal("HDMFAmount"))

                        Else
                            If isorgHDMFdeductsched = 2 Then 'Per pay period
                                pstub_TotalEmpHDMF = CDec(drowsal("HDMFAmount"))
                                pstub_TotalCompHDMF = 100 'CDec(drowsal("HDMFAmount"))

                                pstub_TotalEmpHDMF = pstub_TotalEmpHDMF / ValNoComma(drow("PAYFREQUENCY_DIVISOR"))
                                pstub_TotalCompHDMF = 100 / ValNoComma(drow("PAYFREQUENCY_DIVISOR"))

                            End If

                        End If

                        Dim sel_dtemployeefirsttimesalary = dtemployeefirsttimesalary.Select("EmployeeID = '" & drow("RowID") & "'")

                        If skipgovtdeduct _
                            And sel_dtemployeefirsttimesalary.Count <> 0 Then

                            pstub_TotalEmpSSS = 0
                            pstub_TotalCompSSS = 0

                            pstub_TotalEmpPhilhealth = 0
                            pstub_TotalCompPhilhealth = 0

                            pstub_TotalEmpHDMF = 0
                            pstub_TotalCompHDMF = 0

                        End If

                        Dim the_EmpRatePerDay = ValNoComma(drow("EmpRatePerDay"))

                        Dim isMinimumWage = (Math.Round(ValNoComma(drow("EmpRatePerDay")), 2) <= the_MinimumWageAmount)

                        Dim _eRowID = Convert.ToInt32(drow("RowID"))
                        If _eRowID = 8 Then : Dim call_bert = "over here" : End If
                        If isEndOfMonth = isorgWTaxdeductsched Then

                            emp_taxabsal = grossincome - _
                                            (pstub_TotalEmpSSS + pstub_TotalEmpPhilhealth + pstub_TotalEmpHDMF)

                            the_taxable_salary = (grossincome + grossincome_firsthalf) - _
                                            (pstub_TotalEmpSSS + pstub_TotalEmpPhilhealth + pstub_TotalEmpHDMF)

                            If isMinimumWage Then

                                tax_amount = 0

                            Else

                                'Dim paywithholdingtax = retAsDatTbl("SELECT ExemptionAmount,TaxableIncomeFromAmount,ExemptionInExcessAmount" & _
                                '                                    " FROM paywithholdingtax" & _
                                '                                    " WHERE FilingStatusID=(SELECT RowID FROM filingstatus WHERE MaritalStatus='" & drow("MaritalStatus").ToString & "' AND Dependent=" & drow("NoOfDependents").ToString & ")" & _
                                '                                    " AND " & emp_taxabsal & " BETWEEN TaxableIncomeFromAmount AND TaxableIncomeToAmount" & _
                                '                                    " AND DATEDIFF(CURRENT_DATE(),COALESCE(EffectiveDateTo,COALESCE(EffectiveDateFrom,CURRENT_DATE()))) >= 0" & _
                                '                                    " AND PayFrequencyID='" & drow("PayFrequencyID").ToString & "'" & _
                                '                                    " ORDER BY DATEDIFF(CURRENT_DATE(),COALESCE(EffectiveDateTo,COALESCE(EffectiveDateFrom,CURRENT_DATE())))" & _
                                '                                    " LIMIT 1;")

                                'payWTax,filingStatus

                                Dim sel_filingStatus = filingStatus.Select("MaritalStatus = '" & drow("MaritalStatus").ToString & "' AND Dependent = " & drow("NoOfDependents").ToString)

                                Dim fstat_id = 1

                                For Each fstatrow In sel_filingStatus
                                    fstat_id = fstatrow("RowID")
                                Next

                                Dim wtx_sqlquery As String =
                                    String.Concat("SELECT ptx.*",
                                                  " FROM paywithholdingtax ptx",
                                                  " INNER JOIN payfrequency pf ON pf.PayFrequencyType='Monthly' AND ptx.PayFrequencyID=pf.RowID",
                                                  " WHERE ptx.FilingStatusID=", fstat_id,
                                                  " AND ", the_taxable_salary,
                                                  " BETWEEN ptx.TaxableIncomeFromAmount AND ptx.TaxableIncomeToAmount",
                                                  ";")

                                Dim sel_wtax = New SQLQueryToDatatable(wtx_sqlquery).ResultTable

                                'Dim sel_payWTax = payWTax.Select("FilingStatusID = " & fstat_id &
                                '                                 " AND PayFrequencyID = 2 AND " &
                                '                                 "TaxableIncomeFromAmount <= " & the_taxable_salary & " AND " & the_taxable_salary & " <= TaxableIncomeToAmount" &
                                '                                 "")

                                Dim sel_payWTax() = sel_wtax.Select

                                '" AND PayFrequencyID = " & drow("PayFrequencyID").ToString & " AND " &
                                'Dim GET_employeetaxableincome = EXECQUER("SELECT `GET_employeetaxableincome`('" & drow("RowID") & "', '" & orgztnID & "', '" & n_PayrollDateFrom & "','" & grossincome & "');")


                                'For Each drowtax As DataRow In paywithholdingtax.rows
                                For Each drowtax In sel_payWTax
                                    Dim taxrowID = drowtax("RowID")
                                    'emp_taxabsal = emptaxabsal - (Val(drowtax("ExemptionAmount")) + _
                                    '             ((emptaxabsal - Val(drowtax("TaxableIncomeFromAmount"))) * Val(drowtax("ExemptionInExcessAmount"))) _
                                    '                             )

                                    'Dim the_values = Split(GET_employeetaxableincome, ";")
                                    
                                    tax_amount =
                                        ((the_taxable_salary - ValNoComma(drowtax("TaxableIncomeFromAmount"))) * ValNoComma(drowtax("ExemptionInExcessAmount"))) _
                                        + ValNoComma(drowtax("ExemptionAmount"))
                                    'ValNoComma(the_values(1))

                                    Exit For

                                Next

                            End If

                        Else
                            'PAYFREQUENCY_DIVISOR

                            emp_taxabsal = grossincome - _
                                            (pstub_TotalEmpSSS + pstub_TotalEmpPhilhealth + pstub_TotalEmpHDMF)

                            If isorgWTaxdeductsched = 2 Then
                                the_taxable_salary = emp_taxabsal
                            Else

                                If isEndOfMonth = isorgWTaxdeductsched Then

                                    the_taxable_salary = grossincome - _
                                                        (pstub_TotalEmpSSS + pstub_TotalEmpPhilhealth + pstub_TotalEmpHDMF)

                                End If

                            End If

                            If isMinimumWage Then

                                tax_amount = 0

                            ElseIf isorgWTaxdeductsched = 2 Then

                                'Dim paywithholdingtax = retAsDatTbl("SELECT ExemptionAmount,TaxableIncomeFromAmount,ExemptionInExcessAmount" & _
                                '                                    " FROM paywithholdingtax" & _
                                '                                    " WHERE FilingStatusID=(SELECT RowID FROM filingstatus WHERE MaritalStatus='" & drow("MaritalStatus").ToString & "' AND Dependent=" & drow("NoOfDependents").ToString & ")" & _
                                '                                    " AND " & emp_taxabsal & " BETWEEN TaxableIncomeFromAmount AND TaxableIncomeToAmount" & _
                                '                                    " AND DATEDIFF(CURRENT_DATE(),COALESCE(EffectiveDateTo,COALESCE(EffectiveDateFrom,CURRENT_DATE()))) >= 0" & _
                                '                                    " AND PayFrequencyID='" & drow("PayFrequencyID").ToString & "'" & _
                                '                                    " ORDER BY DATEDIFF(CURRENT_DATE(),COALESCE(EffectiveDateTo,COALESCE(EffectiveDateFrom,CURRENT_DATE())))" & _
                                '                                    " LIMIT 1;")

                                'payWTax,filingStatus

                                Dim sel_filingStatus = filingStatus.Select("MaritalStatus = '" & drow("MaritalStatus").ToString & "' AND Dependent = " & drow("NoOfDependents").ToString)

                                Dim fstat_id = 1

                                For Each fstatrow In sel_filingStatus
                                    fstat_id = fstatrow("RowID")
                                Next
                                
                                Dim wtx_sqlquery As String =
                                    String.Concat("SELECT ptx.*",
                                                  " FROM paywithholdingtax ptx",
                                                  " INNER JOIN payfrequency pf ON pf.PayFrequencyType='Monthly' AND ptx.PayFrequencyID=pf.RowID",
                                                  " WHERE ptx.FilingStatusID=", fstat_id,
                                                  " AND ", the_taxable_salary,
                                                  " BETWEEN ptx.TaxableIncomeFromAmount AND ptx.TaxableIncomeToAmount",
                                                  ";")

                                Dim sel_wtax = New SQLQueryToDatatable(wtx_sqlquery).ResultTable

                                'Dim sel_payWTax = payWTax.Select("FilingStatusID = " & fstat_id &
                                '                                 " AND PayFrequencyID = 2 AND " &
                                '                                 "TaxableIncomeFromAmount <= " & the_taxable_salary & " AND " & the_taxable_salary & " <= TaxableIncomeToAmount" &
                                '                                 "")

                                Dim sel_payWTax() = sel_wtax.Select

                                '" AND PayFrequencyID = " & drow("PayFrequencyID").ToString & " AND " &
                                'Dim GET_employeetaxableincome = EXECQUER("SELECT `GET_employeetaxableincome`('" & drow("RowID") & "', '" & orgztnID & "', '" & n_PayrollDateFrom & "','" & grossincome & "');")


                                'For Each drowtax As DataRow In paywithholdingtax.rows
                                For Each drowtax In sel_payWTax
                                    Dim taxrowID = drowtax("RowID")
                                    'emp_taxabsal = emptaxabsal - (Val(drowtax("ExemptionAmount")) + _
                                    '             ((emptaxabsal - Val(drowtax("TaxableIncomeFromAmount"))) * Val(drowtax("ExemptionInExcessAmount"))) _
                                    '                             )

                                    'Dim the_values = Split(GET_employeetaxableincome, ";")
                                    
                                    tax_amount =
                                        ((the_taxable_salary - ValNoComma(drowtax("TaxableIncomeFromAmount"))) * ValNoComma(drowtax("ExemptionInExcessAmount"))) _
                                        + ValNoComma(drowtax("ExemptionAmount"))

                                    tax_amount = tax_amount / ValNoComma(drow("PAYFREQUENCY_DIVISOR"))

                                    Exit For

                                Next

                            End If

                        End If

                        If drow("WTaxDeductSched").ToString = "First half of next month" _
                            And isEndOfMonth = "1" Then

                            'get the 'withholding tax' paystubitem amount of end of the month of the preceding month

                            tax_amount =
                                ValNoComma(GET_PREVIOUSMONTHTAXAMOUNT.Compute("MIN(TotalEmpWithholdingTax)",
                                                                              "eRowID = '" & drow("RowID").ToString & "'"))

                        End If

                        Exit For

                    Next

                    Exit For

                Next

                'First half of next month - deduction schedule
                Dim last_tax_amount = tax_amount 'If(drow("WTaxDeductSched").ToString = "First half of next month", 0, tax_amount)
                Dim tot_net_pay = emp_taxabsal - valemp_loan - last_tax_amount

                'emptaxabsal

                the_taxable_salary = the_taxable_salary

                Dim loan_nondeductible = emp_loans.Select("EmployeeID = '" & drow("RowID") & "' AND Nondeductible = '1'")

                Dim loan_nondeductibleamount = ValNoComma(0)
                For Each lrow In loan_nondeductible
                    loan_nondeductibleamount = ValNoComma(lrow("DeductionAmount"))
                Next

                Dim isPayStubExists As _
                    New ExecuteQuery("SELECT EXISTS(SELECT RowID" &
                                     " FROM paystub" &
                                     " WHERE EmployeeID='" & drow("RowID") & "'" &
                                     " AND OrganizationID='" & orgztnID & "'" &
                                     " AND PayFromDate='" & n_PayrollDateFrom & "'" &
                                     " AND PayToDate='" & n_PayrollDateTo & "');")

                If isPayStubExists.Result = "0" Then

                    If ValNoComma(Me.VeryFirstPayPeriodIDOfThisYear) = ValNoComma(n_PayrollRecordID) Then
                        'this means, the very first cut off of this year falls here
                        'so system should reset all leave balance to zero(0)

                        Dim new_ExecuteQuery As _
                            New ExecuteQuery("UPDATE employee e SET" &
                                             " e.LeaveBalance = 0" &
                                             ",e.SickLeaveBalance = 0" &
                                             ",e.MaternityLeaveBalance = 0" &
                                             ",e.OtherLeaveBalance = 0" &
                                             ",e.LastUpd=CURRENT_TIMESTAMP()" &
                                             ",e.LastUpdBy='" & z_User & "'" &
                                             " WHERE e.RowID='" & drow("RowID") & "'" &
                                             " AND e.OrganizationID='" & orgztnID & "';")

                        '",e.AdditionalVLBalance = 0" &

                    End If

                    '#######################################################################################################################################################

                    'Dim max_existing_payroll_ordinalval = ValNoComma(New ExecuteQuery("SELECT pp.OrdinalValue FROM paystub ps INNER JOIN payperiod pp ON pp.RowID=ps.PayPeriodID WHERE ps.EmployeeID='" & drow("RowID") & "' AND ps.OrganizationID='" & orgztnID & "' ORDER BY ps.PayFromDate DESC,ps.PayToDate DESC LIMIT 1;").Result)

                    ''Dim hasatleastpayroll = ValNoComma(New ExecuteQuery("SELECT EXISTS(SELECT pp.OrdinalValue FROM paystub ps INNER JOIN payperiod pp ON pp.RowID=ps.PayPeriodID WHERE ps.EmployeeID='" & drow("RowID") & "' AND ps.OrganizationID='" & orgztnID & "' ORDER BY ps.PayFromDate DESC,ps.PayToDate DESC LIMIT 1);").Result)

                    ''If hasatleastpayroll > 0 Then
                    ''    max_existing_payroll_ordinalval = ValNoComma(New ExecuteQuery("SELECT pp.OrdinalValue FROM paystub ps INNER JOIN payperiod pp ON pp.RowID=ps.PayPeriodID WHERE ps.EmployeeID='" & drow("RowID") & "' AND ps.OrganizationID='" & orgztnID & "' ORDER BY ps.PayFromDate DESC,ps.PayToDate DESC LIMIT 1;").Result)
                    ''End If

                    ''accrual of typical leaves
                    'Dim n_ExecuteQuery As _
                    '    New ExecuteQuery("UPDATE employee e" &
                    '                     " INNER JOIN payperiod pp ON pp.RowID='" & n_PayrollRecordID & "' AND pp.TotalGrossSalary=e.PayFrequencyID" &
                    '                     " AND pp.OrdinalValue > " & max_existing_payroll_ordinalval &
                    '                     " SET" &
                    '                     " e.LeaveBalance=pp.OrdinalValue * e.LeavePerPayPeriod" &
                    '                     ",e.SickLeaveBalance=pp.OrdinalValue * e.SickLeavePerPayPeriod" &
                    '                     ",e.MaternityLeaveBalance=pp.OrdinalValue * e.MaternityLeavePerPayPeriod" &
                    '                     ",e.OtherLeaveBalance=pp.OrdinalValue * e.OtherLeavePerPayPeriod" &
                    '                     ",e.LastUpd=CURRENT_TIMESTAMP()" &
                    '                     ",e.LastUpdBy='" & z_User & "'" &
                    '                     " WHERE e.RowID='" & drow("RowID") & "'" &
                    '                     " AND e.OrganizationID='" & orgztnID & "'" &
                    '                     " AND (e.DateRegularized <= '" & n_PayrollDateFrom & "'" &
                    '                     " OR e.DateRegularized <= '" & n_PayrollDateTo & "');")
                    ''" e.LeaveBalance=e.LeaveBalance + e.LeavePerPayPeriod" &
                    ''",e.SickLeaveBalance=e.SickLeaveBalance + e.SickLeavePerPayPeriod" &
                    ''",e.MaternityLeaveBalance=e.MaternityLeaveBalance + e.MaternityLeavePerPayPeriod" &
                    ''",e.OtherLeaveBalance=e.OtherLeaveBalance + e.OtherLeavePerPayPeriod" &

                    ''" AND e.DateRegularized <= '" & n_PayrollDateFrom & "'" &
                    ''" OR e.DateRegularized <= '" & n_PayrollDateTo & "');")

                    ''years of service is between 5th and 10th
                    'n_ExecuteQuery =
                    '    New ExecuteQuery("UPDATE employee e" &
                    '                     " INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID" &
                    '                     " SET e.AdditionalVLPerPayPeriod=(e.LeaveTenthYearService / (PAYFREQUENCY_DIVISOR(pf.PayFrequencyType) * MONTH(SUBDATE(MAKEDATE(YEAR(CURDATE()),1), INTERVAL 1 DAY))))" &
                    '                     ",e.LastUpd=CURRENT_TIMESTAMP()" &
                    '                     ",e.LastUpdBy='" & z_User & "'" &
                    '                     " WHERE e.RowID='" & drow("RowID") & "'" &
                    '                     " AND e.OrganizationID='" & orgztnID & "'" &
                    '                     " AND IF(ADDDATE(e.DateRegularized,INTERVAL 5 YEAR) BETWEEN '" & n_PayrollDateFrom & "' AND '" & n_PayrollDateTo & "', '" & n_PayrollDateTo & "', '" & n_PayrollDateFrom & "')" &
                    '                     " BETWEEN ADDDATE(e.DateRegularized,INTERVAL 5 YEAR) AND ADDDATE(e.DateRegularized,INTERVAL 10 YEAR);")
                    ''" AND '" & n_PayrollDateFrom & "' BETWEEN ADDDATE(e.DateRegularized,INTERVAL 5 YEAR) AND ADDDATE(e.DateRegularized,INTERVAL 10 YEAR);")
                    ''IF(ADDDATE(e.DateRegularized,INTERVAL 5 YEAR) BETWEEN '" & n_PayrollDateFrom & "' AND '" & n_PayrollDateTo & "', '" & n_PayrollDateTo & "', '" & n_PayrollDateFrom & "')

                    'n_ExecuteQuery =
                    '    New ExecuteQuery("UPDATE employee e" &
                    '                     " INNER JOIN payperiod pp ON pp.RowID='" & n_PayrollRecordID & "' AND pp.TotalGrossSalary=e.PayFrequencyID" &
                    '                     " AND pp.OrdinalValue > " & max_existing_payroll_ordinalval &
                    '                     " SET" &
                    '                     " e.AdditionalVLBalance=pp.OrdinalValue * e.AdditionalVLPerPayPeriod" &
                    '                     ",e.LastUpd=CURRENT_TIMESTAMP()" &
                    '                     ",e.LastUpdBy='" & z_User & "'" &
                    '                     " WHERE e.RowID='" & drow("RowID") & "'" &
                    '                     " AND e.OrganizationID='" & orgztnID & "'" &
                    '                     " AND e.AdditionalVLPerPayPeriod > 0" &
                    '                     " AND YEAR(ADDDATE(e.DateRegularized,INTERVAL 5 YEAR)) < (pp.`Year` * 1)" &
                    '                     " AND '" & n_PayrollDateFrom & "' BETWEEN ADDDATE(e.DateRegularized,INTERVAL 5 YEAR) AND ADDDATE(e.DateRegularized,INTERVAL 10 YEAR);" &
                    '                     "" &
                    '                     "UPDATE employee e" &
                    '                     " INNER JOIN payperiod pp ON pp.RowID='" & n_PayrollRecordID & "' AND pp.TotalGrossSalary=e.PayFrequencyID" &
                    '                     " AND pp.OrdinalValue > " & max_existing_payroll_ordinalval &
                    '                     " SET" &
                    '                     " e.AdditionalVLBalance=e.AdditionalVLBalance + e.AdditionalVLPerPayPeriod" &
                    '                     ",e.LastUpd=CURRENT_TIMESTAMP()" &
                    '                     ",e.LastUpdBy='" & z_User & "'" &
                    '                     " WHERE e.RowID='" & drow("RowID") & "'" &
                    '                     " AND e.OrganizationID='" & orgztnID & "'" &
                    '                     " AND e.AdditionalVLPerPayPeriod > 0" &
                    '                     " AND YEAR(ADDDATE(e.DateRegularized,INTERVAL 5 YEAR)) = pp.`Year`" &
                    '                     " AND '" & n_PayrollDateTo & "' BETWEEN ADDDATE(e.DateRegularized,INTERVAL 5 YEAR) AND '" & last_enddate_cutoff_thisyear & "';")
                    ''" AND ADDDATE(e.DateRegularized,INTERVAL 5 YEAR) BETWEEN '" & n_PayrollDateFrom & "' AND '" & n_PayrollDateTo & "';")
                    ''
                    ''" e.AdditionalVLBalance=e.AdditionalVLBalance + e.AdditionalVLPerPayPeriod" &
                    ''" AND '" & n_PayrollDateFrom & "' BETWEEN ADDDATE(e.DateRegularized,INTERVAL 5 YEAR) AND ADDDATE(e.DateRegularized,INTERVAL 10 YEAR);")

                    ''years of service is between 10th and 15th
                    'n_ExecuteQuery =
                    '    New ExecuteQuery("UPDATE employee e" &
                    '                     " INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID" &
                    '                     " SET e.AdditionalVLPerPayPeriod=(e.LeaveFifteenthYearService / (PAYFREQUENCY_DIVISOR(pf.PayFrequencyType) * MONTH(SUBDATE(MAKEDATE(YEAR(CURDATE()),1), INTERVAL 1 DAY))))" &
                    '                     ",e.LastUpd=CURRENT_TIMESTAMP()" &
                    '                     ",e.LastUpdBy='" & z_User & "'" &
                    '                     " WHERE e.RowID='" & drow("RowID") & "'" &
                    '                     " AND e.OrganizationID='" & orgztnID & "'" &
                    '                     " AND IF(ADDDATE(ADDDATE(e.DateRegularized,INTERVAL 10 YEAR),INTERVAL 1 DAY) BETWEEN '" & n_PayrollDateFrom & "' AND '" & n_PayrollDateTo & "', '" & n_PayrollDateTo & "', '" & n_PayrollDateFrom & "')" &
                    '                     " BETWEEN ADDDATE(ADDDATE(e.DateRegularized,INTERVAL 10 YEAR),INTERVAL 1 DAY) AND ADDDATE(e.DateRegularized,INTERVAL 15 YEAR);")
                    'n_ExecuteQuery =
                    '    New ExecuteQuery("UPDATE employee e" &
                    '                     " INNER JOIN payperiod pp ON pp.RowID='" & n_PayrollRecordID & "' AND pp.TotalGrossSalary=e.PayFrequencyID" &
                    '                     " AND pp.OrdinalValue > " & max_existing_payroll_ordinalval &
                    '                     " SET" &
                    '                     " e.AdditionalVLBalance=pp.OrdinalValue * e.AdditionalVLPerPayPeriod" &
                    '                     ",e.LastUpd=CURRENT_TIMESTAMP()" &
                    '                     ",e.LastUpdBy='" & z_User & "'" &
                    '                     " WHERE e.RowID='" & drow("RowID") & "'" &
                    '                     " AND e.OrganizationID='" & orgztnID & "'" &
                    '                     " AND e.AdditionalVLPerPayPeriod > 0" &
                    '                     " AND YEAR(ADDDATE(ADDDATE(e.DateRegularized,INTERVAL 10 YEAR),INTERVAL 1 DAY)) < pp.`Year`" &
                    '                     " AND '" & n_PayrollDateFrom & "' BETWEEN ADDDATE(ADDDATE(e.DateRegularized,INTERVAL 10 YEAR),INTERVAL 1 DAY) AND ADDDATE(e.DateRegularized,INTERVAL 15 YEAR);" &
                    '                     "" &
                    '                     "UPDATE employee e" &
                    '                     " INNER JOIN payperiod pp ON pp.RowID='" & n_PayrollRecordID & "' AND pp.TotalGrossSalary=e.PayFrequencyID" &
                    '                     " AND pp.OrdinalValue > " & max_existing_payroll_ordinalval &
                    '                     " SET" &
                    '                     " e.AdditionalVLBalance=e.AdditionalVLBalance + e.AdditionalVLPerPayPeriod" &
                    '                     ",e.LastUpd=CURRENT_TIMESTAMP()" &
                    '                     ",e.LastUpdBy='" & z_User & "'" &
                    '                     " WHERE e.RowID='" & drow("RowID") & "'" &
                    '                     " AND e.OrganizationID='" & orgztnID & "'" &
                    '                     " AND e.AdditionalVLPerPayPeriod > 0" &
                    '                     " AND YEAR(ADDDATE(ADDDATE(e.DateRegularized,INTERVAL 10 YEAR),INTERVAL 1 DAY)) = pp.`Year`" &
                    '                     " AND '" & n_PayrollDateTo & "' BETWEEN ADDDATE(ADDDATE(e.DateRegularized,INTERVAL 10 YEAR),INTERVAL 1 DAY) AND '" & last_enddate_cutoff_thisyear & "';")
                    ''" AND ADDDATE(ADDDATE(e.DateRegularized,INTERVAL 10 YEAR),INTERVAL 1 DAY) BETWEEN '" & n_PayrollDateFrom & "' AND '" & n_PayrollDateTo & "';")
                    ''
                    ''" e.AdditionalVLBalance=e.AdditionalVLBalance + e.AdditionalVLPerPayPeriod" &
                    ''" AND '" & n_PayrollDateFrom & "' BETWEEN ADDDATE(ADDDATE(e.DateRegularized,INTERVAL 10 YEAR),INTERVAL 1 DAY) AND ADDDATE(e.DateRegularized,INTERVAL 15 YEAR);")

                    ''years of service is greater than 15
                    'n_ExecuteQuery =
                    '    New ExecuteQuery("UPDATE employee e" &
                    '                     " INNER JOIN payfrequency pf ON pf.RowID=e.PayFrequencyID" &
                    '                     " SET e.AdditionalVLPerPayPeriod=(e.LeaveAboveFifteenthYearService / (PAYFREQUENCY_DIVISOR(pf.PayFrequencyType) * MONTH(SUBDATE(MAKEDATE(YEAR(CURDATE()),1), INTERVAL 1 DAY))))" &
                    '                     ",e.LastUpd=CURRENT_TIMESTAMP()" &
                    '                     ",e.LastUpdBy='" & z_User & "'" &
                    '                     " WHERE e.RowID='" & drow("RowID") & "'" &
                    '                     " AND e.OrganizationID='" & orgztnID & "'" &
                    '                     " AND IF(ADDDATE(ADDDATE(e.DateRegularized,INTERVAL 15 YEAR),INTERVAL 1 DAY) BETWEEN '" & n_PayrollDateFrom & "' AND '" & n_PayrollDateTo & "', '" & n_PayrollDateTo & "', '" & n_PayrollDateFrom & "')" &
                    '                     " BETWEEN ADDDATE(ADDDATE(e.DateRegularized,INTERVAL 15 YEAR),INTERVAL 1 DAY) AND LAST_DAY(DATE_FORMAT(CURDATE(),'%Y-12-01'));") 'ADDDATE(e.DateRegularized,INTERVAL 99 YEAR)
                    'n_ExecuteQuery =
                    '    New ExecuteQuery("UPDATE employee e" &
                    '                     " INNER JOIN payperiod pp ON pp.RowID='" & n_PayrollRecordID & "' AND pp.TotalGrossSalary=e.PayFrequencyID" &
                    '                     " AND pp.OrdinalValue > " & max_existing_payroll_ordinalval &
                    '                     " SET" &
                    '                     " e.AdditionalVLBalance=pp.OrdinalValue * e.AdditionalVLPerPayPeriod" &
                    '                     ",e.LastUpd=CURRENT_TIMESTAMP()" &
                    '                     ",e.LastUpdBy='" & z_User & "'" &
                    '                     " WHERE e.RowID='" & drow("RowID") & "'" &
                    '                     " AND e.OrganizationID='" & orgztnID & "'" &
                    '                     " AND e.AdditionalVLPerPayPeriod > 0" &
                    '                     " AND YEAR(ADDDATE(ADDDATE(e.DateRegularized,INTERVAL 15 YEAR),INTERVAL 1 DAY)) < pp.`Year`" &
                    '                     " AND '" & n_PayrollDateFrom & "' BETWEEN ADDDATE(ADDDATE(e.DateRegularized,INTERVAL 15 YEAR),INTERVAL 1 DAY) AND LAST_DAY(DATE_FORMAT(CURDATE(),'%Y-12-01'));" &
                    '                     "" &
                    '                     "UPDATE employee e" &
                    '                     " INNER JOIN payperiod pp ON pp.RowID='" & n_PayrollRecordID & "' AND pp.TotalGrossSalary=e.PayFrequencyID" &
                    '                     " AND pp.OrdinalValue > " & max_existing_payroll_ordinalval &
                    '                     " SET" &
                    '                     " e.AdditionalVLBalance=e.AdditionalVLBalance + e.AdditionalVLPerPayPeriod" &
                    '                     ",e.LastUpd=CURRENT_TIMESTAMP()" &
                    '                     ",e.LastUpdBy='" & z_User & "'" &
                    '                     " WHERE e.RowID='" & drow("RowID") & "'" &
                    '                     " AND e.OrganizationID='" & orgztnID & "'" &
                    '                     " AND e.AdditionalVLPerPayPeriod > 0" &
                    '                     " AND YEAR(ADDDATE(ADDDATE(e.DateRegularized,INTERVAL 15 YEAR),INTERVAL 1 DAY)) = pp.`Year`" &
                    '                     " AND '" & n_PayrollDateTo & "' BETWEEN ADDDATE(ADDDATE(e.DateRegularized,INTERVAL 15 YEAR),INTERVAL 1 DAY) AND '" & last_enddate_cutoff_thisyear & "';")
                    ''" AND ADDDATE(ADDDATE(e.DateRegularized,INTERVAL 15 YEAR),INTERVAL 1 DAY) BETWEEN '" & n_PayrollDateFrom & "' AND '" & n_PayrollDateTo & "';")
                    ''
                    ''" e.AdditionalVLBalance=e.AdditionalVLBalance + e.AdditionalVLPerPayPeriod" &
                    ''" AND '" & n_PayrollDateFrom & "' BETWEEN ADDDATE(ADDDATE(e.DateRegularized,INTERVAL 15 YEAR),INTERVAL 1 DAY) AND ADDDATE(e.DateRegularized,INTERVAL 99 YEAR);")

                    '#######################################################################################################################################################

                End If

                'Dim procparam_array = New String() {orgztnID,
                '                                    Convert.ToInt32(drow("RowID")),
                '                                    z_User,
                '                                    n_PayrollDateFrom, n_PayrollDateTo}
                'Dim exec_sqlproc As New  _
                '    ExecSQLProcedure("LEAVE_gainingbalance", 256,
                '                     procparam_array)
                'If exec_sqlproc.HasError Then
                '    Dim lv_gainbal_haserr As Boolean = True
                '    Console.WriteLine(String.Concat("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@LEAVE_gainingbalance@PayStub_Class error in employee.RowID", Convert.ToInt32(drow("RowID"))))

                'End If

                Dim thirteenthmoval = Val(0)
                ''INSUPD_paystub
                Dim n_ExecSQLProcedure = New  _
                    ExecSQLProcedure("INSUPD_paystub_proc", 255,
                                     DBNull.Value,
                                     orgztnID,
                                     z_User,
                                     z_User,
                                     n_PayrollRecordID,
                                     Convert.ToInt32(drow("RowID")),
                                     DBNull.Value,
                                     n_PayrollDateFrom,
                                     n_PayrollDateTo,
                                     grossincome + totalemployeebonus + totalnotaxemployeebonus + totalnotaxemployeeallownce + totalemployeeallownce,
                                     tot_net_pay + totalemployeebonus + totalnotaxemployeebonus + totalnotaxemployeeallownce + totalemployeeallownce + thirteenthmoval,
                                     the_taxable_salary,
                                     pstub_TotalEmpSSS,
                                     tax_amount,
                                     pstub_TotalCompSSS,
                                     pstub_TotalEmpPhilhealth,
                                     pstub_TotalCompPhilhealth,
                                     pstub_TotalEmpHDMF,
                                     pstub_TotalCompHDMF,
                                     0,
                                     valemp_loan,
                                     totalemployeebonus + totalnotaxemployeebonus,
                                     totalemployeeallownce + totalnotaxemployeeallownce,
                                     loan_nondeductibleamount)

                If n_ExecSQLProcedure.HasError Then
                    Console.WriteLine(String.Concat("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@DEAD LOCK ERROR@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
                                                    Convert.ToInt32(drow("RowID"))))
                End If

                Dim i_progress As Integer = CInt((100 * progress_index) / emp_count)

                progress_index += 1

                Dim params_value =
                    New Object() {1,
                                  Convert.ToInt32(drow("RowID"))}

                form_caller.Invoke(m_NotifyMainWindow,
                                   Convert.ToInt32(drow("RowID"))) ', Convert.ToInt32(drow("RowID"))

                Dim my_cmd As String = String.Concat(Convert.ToString(drow("RowID")), "@", Convert.ToString(drow("EmployeeID")))
                Console.WriteLine(my_cmd)

            Catch ex As Exception

                Dim err_msg As String = getErrExcptn(ex, MyBase.ToString)

                Console.WriteLine(err_msg)

                MsgBox(String.Concat(err_msg, vbNewLine,
                                     "error occured for EMPLOYEE[", Convert.ToString(drow("EmployeeID")), "]"))

            Finally

                'Dim string_query As String =
                '    String.Concat("CALL",
                '                  " LEAVE_gainingbalance(", orgztnID,
                '                  ", ", Convert.ToInt32(drow("RowID")),
                '                  ", ", z_User,
                '                  ", '", n_PayrollDateFrom, "'",
                '                  ", '", n_PayrollDateTo, "');")

                'Dim exec_quer As _
                '    New ExecuteQuery(string_query, 1024)

                'If exec_quer.HasError Then
                '    Console.WriteLine(String.Concat("Error occured for employee - ", Convert.ToInt32(drow("RowID")), vbNewLine, exec_quer.ErrorMessage))

                'End If

            End Try

        Next

        EXECQUER("CALL `RECOMPUTE_thirteenthmonthpay`('" & orgztnID & "','" & n_PayrollRecordID & "','" & z_User & "');")

        If withthirteenthmonthpay = 1 Then

            EXECQUER("CALL `RELEASE_thirteenthmonthpay`('" & orgztnID & "','" & n_PayrollRecordID & "','" & z_User & "');")

        End If

        payWTax.Dispose()

        filingStatus.Dispose()

    End Sub

    Sub PayrollGeneration_BackgourndWork(sender As Object, e As System.ComponentModel.DoWorkEventArgs)
        DoProcess()

        'For i = 0 To 19
        '    Thread.Sleep(3000)
        'Next

        'Dim dfsd As String = DirectCast(sender, System.ComponentModel.BackgroundWorker).ToString
        'Console.WriteLine(String.Concat(dfsd, " @@ ", employee_dattab.TableName))

    End Sub

End Class

Friend Class MySQLQueryToDataTable

    Private priv_conn As New MySqlConnection

    Private priv_da As New MySqlDataAdapter

    Private priv_cmd As New MySqlCommand

    Sub New(SQLProcedureName As String,
            Optional cmd_time_out As Integer = 0)

        'Static mysql_conn_text As String = mysql_conn_text

        'Dim n_DataBaseConnection As New DataBaseConnection

        If cmd_time_out > 0 Then

            priv_conn.ConnectionString = mysql_conn_text &
                "default command timeout=" & cmd_time_out & ";"

        Else

            priv_conn.ConnectionString = mysql_conn_text

        End If

        SQLProcedureName = SQLProcedureName.Trim

        Try

            If priv_conn.State = ConnectionState.Open Then
                priv_conn.Close()

            End If

            priv_conn.Open()

            priv_cmd = New MySqlCommand

            With priv_cmd

                .Parameters.Clear()

                .Connection = priv_conn

                .CommandText = SQLProcedureName

                .CommandType = CommandType.Text

                priv_da.SelectCommand = priv_cmd

                priv_da.Fill(n_ResultTable)

            End With

        Catch ex As Exception
            _hasError = True
            'MsgBox()
            Console.WriteLine(getErrExcptn(ex, MyBase.ToString))
        Finally
            priv_cmd.Connection.Close()

            priv_da.Dispose()
            
            priv_conn.Close()

            priv_conn.Dispose()

            priv_cmd.Dispose()

        End Try

    End Sub

    Dim n_ResultTable As New DataTable

    Property ResultTable As DataTable

        Get
            Return n_ResultTable

        End Get

        Set(value As DataTable)

            n_ResultTable = value

        End Set

    End Property

    Dim _hasError As Boolean = False

    Property HasError As Boolean

        Get
            Return _hasError

        End Get

        Set(value As Boolean)
            _hasError = value

        End Set

    End Property

End Class

Friend Class MySQLExecuteQuery

    Private priv_conn As New MySqlConnection

    Private priv_da As New MySqlDataAdapter

    Private priv_cmd As New MySqlCommand

    Private getResult = Nothing

    Dim dr As MySqlDataReader

    Sub New(ByVal cmdsql As String,
            Optional cmd_time_out As Integer = 0)

        Static except_this_string() As String = {"CALL", "UPDATE", "DELETE"}

        'Dim n_DataBaseConnection As New DataBaseConnection

        If cmd_time_out > 0 Then
            'mysql_conn_text
            priv_conn.ConnectionString = mysql_conn_text &
                "default command timeout=" & cmd_time_out & ";"

        Else
            'mysql_conn_text
            priv_conn.ConnectionString = mysql_conn_text

        End If

        Try

            If priv_conn.State = ConnectionState.Open Then : priv_conn.Close() : End If

            priv_conn.Open()

            priv_cmd = New MySqlCommand

            With priv_cmd

                .CommandType = CommandType.Text

                .Connection = priv_conn

                .CommandText = cmdsql

                If cmd_time_out > 0 Then
                    .CommandTimeout = cmd_time_out
                End If

                If cmdsql.Contains("CALL") Then

                    .ExecuteNonQuery()

                ElseIf FindingWordsInString(cmdsql,
                                            except_this_string) Then

                    .ExecuteNonQuery()

                Else

                    dr = .ExecuteReader()

                End If

            End With

            If cmdsql.Contains("CALL") Then
                getResult = Nothing
            ElseIf FindingWordsInString(cmdsql,
                                        except_this_string) Then
                getResult = Nothing
            Else

                If dr.Read = True Then

                    If IsDBNull(dr(0)) Then
                        getResult = String.Empty
                    Else
                        getResult = dr(0)

                    End If

                Else
                    getResult = Nothing

                End If

            End If

        Catch ex As Exception

            _hasError = True
            _error_message = getErrExcptn(ex, MyBase.ToString)
            'MsgBox(_error_message, , cmdsql)
            Console.WriteLine(_error_message)
        Finally
            priv_cmd.Connection.Close()

            If dr IsNot Nothing Then
                dr.Close()
                dr.Dispose()
            End If
            
            priv_conn.Close()

            priv_conn.Dispose()

            priv_cmd.Dispose()

        End Try

    End Sub

    Property Result As Object

        Get
            Return getResult

        End Get

        Set(value As Object)
            getResult = value

        End Set

    End Property

    Sub ExecuteQuery()

    End Sub

    Dim _hasError As Boolean = False

    Property HasError As Boolean

        Get
            Return _hasError

        End Get

        Set(value As Boolean)
            _hasError = value

        End Set

    End Property

    Dim _error_message As String = String.Empty

    Property ErrorMessage As String

        Get
            Return _error_message

        End Get

        Set(value As String)
            _error_message = value

        End Set

    End Property

End Class