Imports MySql.Data.MySqlClient
Imports System.Threading
Imports System.Threading.Tasks

Public Class PayrollGeneration

    Private model1 As New Model1
    Private new_philhealth_collect As IQueryable(Of newphilhealthimplement) = model1.NewPhilHealth.OfType(Of newphilhealthimplement)()
    'Private wtax As IQueryable(Of WithholdingTaxBracket) = model1.NewWithholdingTax.OfType(Of WithholdingTaxBracket)()
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

    Private ecoal_dat_set As New DataSet
    Private str_ecola_forgovt_contrib As String =
        "CALL ECOLA_forSSScontrib(?og_rowid, ?date_from, ?date_to);"

    'ByVal _isorgPHHdeductsched As SByte,
    'ByVal _isorgSSSdeductsched As SByte,
    'ByVal _isorgHDMFdeductsched As SByte,
    'ByVal _isorgWTaxdeductsched As SByte,

    Private sss_contrib_quer As String =
        SBConcat.ConcatResult("SELECT pss.EmployeeContributionAmount",
                              ",pss.EmployerContributionAmount",
                              " FROM paysocialsecurity pss",
                              " WHERE ?amount_worked BETWEEN pss.RangeFromAmount AND pss.RangeToAmount",
                              " LIMIT 1;")

    Private phh_contrib_quer As String =
        SBConcat.ConcatResult("SELECT phh.EmployeeShare",
                              ",phh.EmployerShare",
                              " FROM payphilhealth phh",
                              " WHERE ?amount_worked BETWEEN phh.SalaryRangeFrom AND phh.SalaryRangeTo",
                              " LIMIT 1;")

    Private ecola_allowance_name As String = "Ecola"

    Private monthlyemployee_restday_payment As New DataTable

    Private str_quer As String =
        String.Concat("CALL INSUPD_paystub_proc(",
                "?pstub_RowID",
                ",?pstub_OrganizationID",
                ",?pstub_CreatedBy",
                ",?pstub_LastUpdBy",
                ",?pstub_PayPeriodID",
                ",?pstub_EmployeeID",
                ",?pstub_TimeEntryID",
                ",?pstub_PayFromDate",
                ",?pstub_PayToDate",
                ",?pstub_TotalGrossSalary",
                ",?pstub_TotalNetSalary",
                ",?pstub_TotalTaxableSalary",
                ",?pstub_TotalEmpSSS",
                ",?pstub_TotalEmpWithholdingTax",
                ",?pstub_TotalCompSSS",
                ",?pstub_TotalEmpPhilhealth",
                ",?pstub_TotalCompPhilhealth",
                ",?pstub_TotalEmpHDMF",
                ",?pstub_TotalCompHDMF",
                ",?pstub_TotalVacationDaysLeft",
                ",?pstub_TotalLoans",
                ",?pstub_TotalBonus",
                ",?pstub_TotalAllowance",
                ",?pstub_NondeductibleTotalLoans",
                ");")

    Dim wtax_sqlquery As String =
        String.Concat("SELECT ptx.*",
                      " FROM paywithholdingtax ptx",
                      " INNER JOIN payfrequency pf ON pf.PayFrequencyType='Monthly' AND ptx.PayFrequencyID=pf.RowID",
                      " WHERE IFNULL(ptx.FilingStatusID, 0)=?fs_rowid",
                      " AND ?amount",
                      " BETWEEN ptx.TaxableIncomeFromAmount AND ptx.TaxableIncomeToAmount",
                      ";")

    Const strquery_monthemprestdaypay As String = "CALL INSUPD_monthlyemployeerestdaypayment(?og_rowid, ?e_rowid, ?pp_rowid, ?u_rowid);"

    Private employee_rowid_list As New List(Of Integer)

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

        payWTax = New SQL("SELECT * FROM paywithholdingtax;").GetFoundRows.Tables(0)

        filingStatus = New SQL("SELECT * FROM filingstatus;").GetFoundRows.Tables(0)

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

            '********************************************
            Dim params =
                New Object() {org_rowid,
                              n_PayrollDateFrom,
                              n_PayrollDateTo}

            '"CALL GET_employee_allowanceofthisperiod(?og_rowid, ?allw_freq, ?is_taxable, ?date_from, ?date_to);"

            ecoal_dat_set = New DataSet

            ecoal_dat_set = New SQL(str_ecola_forgovt_contrib,
                                    params).GetFoundRows
            '**********************
            monthlyemployee_restday_payment = New DataTable
            monthlyemployee_restday_payment =
                New SQL(String.Concat("SELECT i.*",
                                      " FROM monthlyemployee_restday_payment i",
                                      " WHERE i.OrganizationID = ?og_rowid",
                                      " AND i.`Date` BETWEEN ?date_f AND ?date_t;"),
                        params).GetFoundRows.Tables(0)
            '********************************************

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

        Static year2018 As Integer = 2018

        Dim strquery_year2018 As String =
            String.Concat("SELECT EXISTS(SELECT RowID",
                          " FROM payperiod pp",
                          " WHERE pp.RowID = ", n_PayrollRecordID,
                          " AND pp.`Year` = ", year2018, ") `Result`;")

        Dim is_year2018 As Boolean = Convert.ToBoolean(New SQL(strquery_year2018).GetFoundRow)

        Dim emp_dailytype_allowance,
            emp_monthlytype_allowance As New DataTable

        emp_monthlytype_allowance = ecoal_dat_set.Tables(0)

        emp_dailytype_allowance = ecoal_dat_set.Tables(1)


        Dim emptimeentryOfLeave As New DataTable

        Dim emptimeentryOfHoliday As New DataTable

        Dim last_enddate_cutoff_thisyear =
            New SQL("SELECT DATE_FORMAT(pp.PayToDate,@@date_format)" &
                             " FROM payperiod pp" &
                             " INNER JOIN payperiod pyp ON pyp.RowID='" & n_PayrollRecordID & "'" &
                             " AND pp.`Year`=pyp.`Year`" &
                             " AND pp.OrganizationID=pyp.OrganizationID" &
                             " AND pp.TotalGrossSalary=pyp.TotalGrossSalary" &
                             " ORDER BY pp.PayFromDate DESC,pp.PayToDate DESC" &
                             " LIMIT 1;").GetFoundRow
        Dim GET_PREVIOUSMONTHTAXAMOUNT = New SQL("CALL GET_PREVIOUSMONTHTAXAMOUNT('" & n_PayrollRecordID & "')").GetFoundRows.Tables(0)
        emptimeentryOfLeave = New DataTable 'TotalDayPay
        emptimeentryOfLeave = New SQL("SELECT ete.*,(ete.TotalDayPay - (ete.RegularHoursAmount + ete.OvertimeHoursAmount + ete.HolidayPayAmount)) AS LeavePayAmount FROM employeetimeentry ete INNER JOIN (SELECT pp.OrganizationID,MIN(pp1.PayFromDate) AS PayFromDate,MAX(pp2.PayToDate) AS PayToDate FROM payperiod pp INNER JOIN (SELECT * FROM payperiod ORDER BY PayFromDate,PayToDate) pp1 ON pp1.`Month`=pp.`Month` AND pp1.`Year`=pp.`Year` AND pp1.OrganizationID=pp.OrganizationID AND pp1.TotalGrossSalary=pp.TotalGrossSalary INNER JOIN (SELECT * FROM payperiod ORDER BY PayFromDate DESC,PayToDate DESC) pp2 ON pp2.`Month`=pp.`Month` AND pp2.`Year`=pp.`Year` AND pp2.OrganizationID=pp.OrganizationID AND pp2.TotalGrossSalary=pp.TotalGrossSalary WHERE pp.RowID='" & n_PayrollRecordID & "') i ON i.PayFromDate IS NOT NULL AND i.PayToDate IS NOT NULL AND ete.OrganizationID=i.OrganizationID AND ete.`Date` BETWEEN i.PayFromDate AND i.PayToDate AND (ete.VacationLeaveHours + ete.SickLeaveHours + ete.MaternityLeaveHours + ete.OtherLeaveHours + ete.AdditionalVLHours) > 0 AND ete.RegularHoursAmount=0 ORDER BY ete.EmployeeID,ete.`Date`;").GetFoundRows.Tables(0)
        emptimeentryOfHoliday = New DataTable 'HolidayPayAmount
        emptimeentryOfHoliday = New SQL("SELECT ete.*,i.* FROM employeetimeentry ete INNER JOIN payrate pr ON pr.RowID=ete.PayRateID AND pr.PayType!='Regular Day' INNER JOIN (SELECT pp.OrganizationID,MIN(pp1.PayFromDate) AS PayFromDate, MIN(pp1.PayToDate) AS PayFromDate1, MAX(pp2.PayToDate) AS PayToDate, MAX(pp2.PayFromDate) AS PayToDate1 FROM payperiod pp INNER JOIN (SELECT * FROM payperiod ORDER BY PayFromDate,PayToDate) pp1 ON pp1.`Month`=pp.`Month` AND pp1.`Year`=pp.`Year` AND pp1.OrganizationID=pp.OrganizationID AND pp1.TotalGrossSalary=pp.TotalGrossSalary INNER JOIN (SELECT * FROM payperiod ORDER BY PayFromDate DESC,PayToDate DESC) pp2 ON pp2.`Month`=pp.`Month` AND pp2.`Year`=pp.`Year` AND pp2.OrganizationID=pp.OrganizationID AND pp2.TotalGrossSalary=pp.TotalGrossSalary WHERE pp.RowID='" & n_PayrollRecordID & "') i ON i.PayFromDate IS NOT NULL AND i.PayToDate IS NOT NULL AND ete.OrganizationID=i.OrganizationID AND ete.`Date` BETWEEN i.PayFromDate AND i.PayToDate AND ete.HolidayPayAmount > 0 AND ete.RegularHoursAmount=0 ORDER BY ete.EmployeeID,ete.`Date`;").GetFoundRows.Tables(0)
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

        payWTax = New SQL("SELECT * FROM paywithholdingtax;" &
                                          "").GetFoundRows.Tables(0)

        filingStatus = New SQL("SELECT * FROM filingstatus;" &
                                          "").GetFoundRows.Tables(0)

        Dim phh As New DataTable
        phh = New SQL("SELECT * FROM payphilhealth;").GetFoundRows.Tables(0)

        Dim sss As New DataTable
        sss = New SQL("SELECT * FROM paysocialsecurity;").GetFoundRows.Tables(0)


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
                                            If(drow("PayFrequencyID") = 3, EXECQUER("SELECT COUNT(RowID) FROM employeetimeentry WHERE EmployeeID='" & employee_ID & "' AND Date BETWEEN '" & n_PayrollDateFrom & "' AND '" & n_PayrollDateTo & "' AND IFNULL(TotalDayPay,0)!=0 AND OrganizationID='" & org_rowid & "';"), _
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

                Dim prior_ot_amount As Double = 0

                Dim restday_pay_formonthlyemployee As Double = 0

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
                        prior_ot_amount = ValNoComma(prev_empTimeEntry.Compute("SUM(OvertimeHoursAmount)", "EmployeeID = '" & drow("RowID") & "'"))

                        NightDiffOTAmount = ValNoComma(drowtotdaypay("NightDiffOTHoursAmount"))

                        NightDiffAmount = ValNoComma(drowtotdaypay("NightDiffHoursAmount"))

                        employee_ID = Trim(drow("RowID"))

                        Dim employment_type = StrConv(drow("EmployeeType").ToString, VbStrConv.ProperCase)

                        Dim monthly_computed_salary = ValNoComma(0)

                        Dim overall_overtime = (ValNoComma(drowtotdaypay("OvertimeHoursAmount")) _
                                                + ValNoComma(prev_empTimeEntry.Compute("SUM(OvertimeHoursAmount)", "EmployeeID = '" & drow("RowID") & "'")))

                        If employment_type = "Fixed" Then
                            grossincome = ValNoComma(drowsal("BasicPay"))

                            grossincome += (OTAmount + NightDiffAmount + NightDiffOTAmount)

                            grossincome -= (ValNoComma(drowtotdaypay("HoursLateAmount")) _
                                            + ValNoComma(drowtotdaypay("UndertimeHoursAmount")) _
                                            + ValNoComma(drowtotdaypay("Absent")))

                            'grossincome_firsthalf = ValNoComma(drowsal("BasicPay")) + _
                            '    ValNoComma(prev_empTimeEntry.Compute("SUM(OvertimeHoursAmount)", "EmployeeID = '" & drow("RowID") & "'")) + _
                            '    ValNoComma(prev_empTimeEntry.Compute("SUM(NightDiffOTHoursAmount)", "EmployeeID = '" & drow("RowID") & "'")) + _
                            '    ValNoComma(prev_empTimeEntry.Compute("SUM(NightDiffHoursAmount)", "EmployeeID = '" & drow("RowID") & "'"))

                            grossincome_firsthalf =
                                ValNoComma(prev_empTimeEntry.Compute("SUM(TotalGrossSalary)", "EmployeeID = '" & drow("RowID") & "'"))

                            monthly_computed_salary = grossincome + grossincome_firsthalf

                        ElseIf employment_type = "Monthly" Then

                            restday_pay_formonthlyemployee =
                                ValNoComma(monthlyemployee_restday_payment.Compute("SUM(AddtlRestDayPayment)", String.Concat("EmployeeID = ", drow("RowID"))))

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

                            monthly_computed_salary = ((grossincome + grossincome_firsthalf) - overall_overtime)

                        ElseIf employment_type = "Daily" Then
                            grossincome = ValNoComma(drowtotdaypay("TotalDayPay"))
                            grossincome_firsthalf = ValNoComma(prev_empTimeEntry.Compute("SUM(TotalDayPay)", "EmployeeID = '" & drow("RowID") & "'"))
                            monthly_computed_salary = ((grossincome + grossincome_firsthalf) - overall_overtime) '_
                            'monthly_computed_salary = ValNoComma(prev_empTimeEntry.Compute("SUM(RegularHoursAmount)", "EmployeeID = '" & drow("RowID") & "'")) + ValNoComma(etent_totdaypay.Compute("SUM(RegularHoursAmount)", "EmployeeID = '" & drow("RowID") & "'")) _
                            '    + ValNoComma(emptimeentryOfHoliday.Compute("SUM(HolidayPayAmount)", "EmployeeID = '" & drow("RowID") & "'")) + If(ValNoComma(emptimeentryOfLeave.Compute("SUM(LeavePayAmount)", "EmployeeID = '" & drow("RowID") & "'")) < 0, 0, ValNoComma(emptimeentryOfLeave.Compute("SUM(LeavePayAmount)", "EmployeeID = '" & drow("RowID") & "'")))
                            'monthly_computed_salary = ValNoComma(prev_empTimeEntry.Compute("SUM(RegularHoursAmount)", "EmployeeID = '" & drow("RowID") & "'")) _
                            '                      + ValNoComma(etent_totdaypay.Compute("SUM(RegularHoursAmount)", "EmployeeID = '" & drow("RowID") & "'"))
                        End If

                        'grossincome = Math.Round(grossincome, 2)
                        Dim addtl_taxable_daily_allowance = ValNoComma(prev_empTimeEntry.Compute("SUM(TaxableDailyAllowance)", "EmployeeID = '" & drow("RowID") & "'")) _
                                                            + ValNoComma(etent_totdaypay.Compute("SUM(TaxableDailyAllowance)", "EmployeeID = '" & drow("RowID") & "'"))
                        'monthly_computed_salary = ValNoComma(prev_empTimeEntry.Compute("SUM(RegularHoursAmount)", "EmployeeID = '" & drow("RowID") & "'")) _
                        '                          + ValNoComma(etent_totdaypay.Compute("SUM(RegularHoursAmount)", "EmployeeID = '" & drow("RowID") & "'"))

                        If employee_ID = 73 Then
                            Console.WriteLine("Over here")
                        End If

                        Dim str_allow_quer As String =
                            SBConcat.ConcatResult("EmployeeID=", drow("RowID"), "")
                        '                         " AND PartNo='", ecola_allowance_name, "'")

                        Dim ecola_semim_amount =
                            (ValNoComma(emp_monthlytype_allowance.Compute("MIN(AllowanceAmount)", str_allow_quer)))

                        Dim ecola_less_deduction =
                            (ValNoComma(emp_monthlytype_allowance.Compute("SUM(DeductAllowance)", str_allow_quer)))

                        Dim ecola_semim_compute = (ecola_semim_amount - Math.Round(ecola_less_deduction, 2))

                        Dim ecola_allowance_amount = (ValNoComma(emp_dailytype_allowance.Compute("SUM(TotalAllowanceAmount)",
                                                                                                 str_allow_quer)) _
                                                      + ecola_semim_compute)

                        'Dim amount_used_to_get_sss_contrib = (monthly_computed_salary + addtl_taxable_daily_allowance + ecola_allowance_amount)
                        Dim amount_used_to_get_sss_contrib = (monthly_computed_salary + ecola_allowance_amount) '_
                        '+ ValNoComma(emptimeentryOfHoliday.Compute("SUM(HolidayPayAmount)", "EmployeeID = '" & drow("RowID") & "'")) + If(ValNoComma(emptimeentryOfLeave.Compute("SUM(LeavePayAmount)", "EmployeeID = '" & drow("RowID") & "'")) < 0, 0, ValNoComma(emptimeentryOfLeave.Compute("SUM(LeavePayAmount)", "EmployeeID = '" & drow("RowID") & "'")))

                        Dim sss_ee, sss_er As Double

                        'If Convert.ToString(drow("EmployeeType")) = "Daily" Then

                        '    'For Daily employees
                        '    sss_ee = ValNoComma(sss.Compute("MIN(EmployeeContributionAmount)", "RangeFromAmount <= " & amount_used_to_get_sss_contrib & " AND " & amount_used_to_get_sss_contrib & " <= RangeToAmount"))
                        '    sss_er = ValNoComma(sss.Compute("MIN(EmployerContributionAmount)", "RangeFromAmount <= " & amount_used_to_get_sss_contrib & " AND " & amount_used_to_get_sss_contrib & " <= RangeToAmount"))

                        'Else

                        ''For Monthly employees ''' (or for Daily employees also)
                        'sss_ee = ValNoComma(sss.Compute("MIN(EmployeeContributionAmount)", String.Concat("RowID = ", ValNoComma(drowsal("PaySocialSecurityID")))))
                        'sss_er = ValNoComma(sss.Compute("MIN(EmployerContributionAmount)", String.Concat("RowID = ", ValNoComma(drowsal("PaySocialSecurityID")))))

                        Dim sss_param = New Object() {amount_used_to_get_sss_contrib}

                        Dim sss_sql As New SQL(sss_contrib_quer, sss_param)
                        Dim catch_result As New DataTable
                        catch_result = sss_sql.GetFoundRows.Tables(0)
                        For Each ss_row As DataRow In catch_result.Rows
                            sss_ee = ss_row(0)
                            sss_er = ss_row(1)
                        Next

                        'End If

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

                        'Dim phh_ee = ValNoComma(phh.Compute("MIN(EmployeeShare)", String.Concat("RowID = ", ValNoComma(drowsal("PayPhilhealthID")))))
                        'Dim phh_er = ValNoComma(phh.Compute("MIN(EmployerShare)", String.Concat("RowID = ", ValNoComma(drowsal("PayPhilhealthID")))))
                        ''Dim phh_ee = ValNoComma(phh.Compute("MIN(EmployeeShare)", "SalaryRangeFrom <= " & amount_used_to_get_sss_contrib & " AND " & amount_used_to_get_sss_contrib & " <= SalaryRangeTo")) 'monthly_computed_salary
                        ''Dim phh_er = ValNoComma(phh.Compute("MIN(EmployerShare)", "SalaryRangeFrom <= " & amount_used_to_get_sss_contrib & " AND " & amount_used_to_get_sss_contrib & " <= SalaryRangeTo")) 'monthly_computed_salary
                        ' ''Dim phh_ee = ValNoComma(phh.Compute("MIN(EmployeeShare)", "RowID = " & ValNoComma(drowsal("PayPhilhealthID"))))
                        ' ''Dim phh_er = ValNoComma(phh.Compute("MIN(EmployerShare)", "RowID = " & ValNoComma(drowsal("PayPhilhealthID"))))

                        Dim phh_ee, phh_er As Double
                        Dim phh_param = New Object() {amount_used_to_get_sss_contrib}

                        Dim phh_sql As New SQL(phh_contrib_quer, phh_param)
                        Dim caught_result As New DataTable
                        'If is_year2018 = False Then
                        If is_year2018 Then
                            ''Dim new2018PhilHealtContrib As String =
                            ''    String.Concat("SELECT GET_PhilHealthContribNewImplement(", amount_used_to_get_sss_contrib, ", TRUE) `EmployeeShare`",
                            ''                  ", GET_PhilHealthContribNewImplement(", amount_used_to_get_sss_contrib, ", FALSE) `EmployerShare`",
                            ''                  ";")

                            ''caught_result = New SQL(new2018PhilHealtContrib).GetFoundRows.Tables(0)
                            phh_ee = CalcNewPhilHealth(amount_used_to_get_sss_contrib, True, CDec(drowsal("PhilHealthDeduction")))
                            phh_er = CalcNewPhilHealth(amount_used_to_get_sss_contrib, False, CDec(drowsal("PhilHealthDeduction")))
                        Else
                            caught_result = phh_sql.GetFoundRows.Tables(0)
                            For Each phh_row As DataRow In caught_result.Rows
                                phh_ee = phh_row(0)
                                phh_er = phh_row(1)
                            Next
                        End If

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

                        If isEndOfMonth = isorgWTaxdeductsched Then

                            emp_taxabsal = grossincome - _
                                            (pstub_TotalEmpSSS + pstub_TotalEmpPhilhealth + pstub_TotalEmpHDMF)

                            'the_taxable_salary = (grossincome + grossincome_firsthalf) -
                            '                     (pstub_TotalEmpSSS + pstub_TotalEmpPhilhealth + pstub_TotalEmpHDMF)
                            'amount_used_to_get_sss_contrib
                            the_taxable_salary = (monthly_computed_salary _
                                                  - (pstub_TotalEmpSSS + pstub_TotalEmpPhilhealth + pstub_TotalEmpHDMF))

                            'the_taxable_salary -= (prior_ot_amount + OTAmount)

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

                                If is_year2018 Then
                                    'If is_year2018 = False Then
                                    wtx_sqlquery = Replace(wtax_sqlquery, "?fs_rowid", "IFNULL(ptx.FilingStatusID, 0)")
                                    wtx_sqlquery = Replace(wtx_sqlquery, "?amount", the_taxable_salary)
                                    wtx_sqlquery = Replace(wtx_sqlquery, ";", String.Concat(" AND MAKEDATE(", year2018, ", 1) BETWEEN ptx.EffectiveDateFrom AND ptx.EffectiveDateTo;"))
                                End If

                                Dim sel_wtax = New SQL(wtx_sqlquery).GetFoundRows.Tables(0)

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

                            Dim ot_to_less = (prior_ot_amount + OTAmount)

                            If (the_taxable_salary - ot_to_less) > 0 Then

                                the_taxable_salary -= ot_to_less

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

                                If is_year2018 Then
                                    'If is_year2018 = False Then
                                    wtx_sqlquery = Replace(wtax_sqlquery, "?fs_rowid", "IFNULL(ptx.FilingStatusID, 0)")
                                    wtx_sqlquery = Replace(wtx_sqlquery, "?amount", the_taxable_salary)
                                    wtx_sqlquery = Replace(wtx_sqlquery, ";", String.Concat(" AND MAKEDATE(", year2018, ", 1) BETWEEN ptx.EffectiveDateFrom AND ptx.EffectiveDateTo;"))
                                End If

                                Dim sel_wtax = New SQL(wtx_sqlquery).GetFoundRows.Tables(0)

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
                    New SQL("SELECT EXISTS(SELECT RowID" &
                                     " FROM paystub" &
                                     " WHERE EmployeeID='" & drow("RowID") & "'" &
                                     " AND OrganizationID='" & org_rowid & "'" &
                                     " AND PayFromDate='" & n_PayrollDateFrom & "'" &
                                     " AND PayToDate='" & n_PayrollDateTo & "');")

                If isPayStubExists.GetFoundRow = "0" Then

                    If ValNoComma(Me.VeryFirstPayPeriodIDOfThisYear) = ValNoComma(n_PayrollRecordID) Then
                        'this means, the very first cut off of this year falls here
                        'so system should reset all leave balance to zero(0)

                        Dim new_ExecuteQuery As _
                            New SQL("UPDATE employee e SET" &
                                             " e.LeaveBalance = 0" &
                                             ",e.SickLeaveBalance = 0" &
                                             ",e.MaternityLeaveBalance = 0" &
                                             ",e.OtherLeaveBalance = 0" &
                                             ",e.LastUpd=CURRENT_TIMESTAMP()" &
                                             ",e.LastUpdBy='" & user_row_id & "'" &
                                             " WHERE e.RowID='" & drow("RowID") & "'" &
                                             " AND e.OrganizationID='" & org_rowid & "';")
                        new_ExecuteQuery.ExecuteQuery()
                        '",e.AdditionalVLBalance = 0" &

                    End If
                End If

                Dim thirteenthmoval = Val(0)

                Dim _gross, _net As Double

                _gross =
                    (grossincome + totalemployeebonus + totalnotaxemployeebonus + totalnotaxemployeeallownce + totalemployeeallownce + restday_pay_formonthlyemployee)

                _net =
                    (tot_net_pay + totalemployeebonus + totalnotaxemployeebonus + totalnotaxemployeeallownce + totalemployeeallownce + thirteenthmoval + restday_pay_formonthlyemployee)

                Dim paystub_params =
                    New Object() {DBNull.Value,
                                  org_rowid,
                                  user_row_id,
                                  user_row_id,
                                  n_PayrollRecordID,
                                  Convert.ToInt32(drow("RowID")),
                                  DBNull.Value,
                                  n_PayrollDateFrom,
                                  n_PayrollDateTo,
                                  _gross,
                                  _net,
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
                                  loan_nondeductibleamount}

                'str_quer
                'New SQL("INSUPD_paystub_proc", 255,
                Dim n_ExecSQLProcedure =
                    New SQL(str_quer,
                                         paystub_params)

                n_ExecSQLProcedure.ExecuteQuery()

                If n_ExecSQLProcedure.HasError Then
                    Console.WriteLine(String.Concat("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@DEAD LOCK ERROR@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
                                                    Convert.ToInt32(drow("RowID"))))
                    Throw n_ExecSQLProcedure.ErrorException
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

                Dim err_msg As String =
                    SBConcat.ConcatResult(getErrExcptn(ex, MyBase.ToString),
                                          vbNewLine,
                                          "TheDeadlockError",
                                          vbNewLine,
                                          String.Concat(Convert.ToString(drow("RowID")), "@", Convert.ToString(drow("EmployeeID"))))

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
                employee_rowid_list.Add(Convert.ToInt32(drow("RowID")))
            End Try

        Next

        'EXECQUER("CALL `RECOMPUTE_thirteenthmonthpay`('" & orgztnID & "','" & n_PayrollRecordID & "','" & z_User & "');")

        Dim str_query_recompute_13thmonthpay As String =
            SBConcat.ConcatResult("CALL RECOMPUTE_thirteenthmonthpay(?og_rowid, ?pp_rowid, ?u_rowid);")

        Dim para_meters =
            New Object() {org_rowid, n_PayrollRecordID, user_row_id}

        Dim exec_str_query_recompute_13thmonthpay As New SQL(str_query_recompute_13thmonthpay,
                                                             para_meters)

        exec_str_query_recompute_13thmonthpay.ExecuteQuery()


        If withthirteenthmonthpay = 1 Then

            'EXECQUER("CALL `RELEASE_thirteenthmonthpay`('" & orgztnID & "','" & n_PayrollRecordID & "','" & z_User & "');")

            Dim str_query_release_13thmonthpay As String =
                SBConcat.ConcatResult("CALL RECOMPUTE_thirteenthmonthpay(?og_rowid, ?pp_rowid, ?u_rowid);")

            Dim exec_str_query_release_13thmonthpay As New SQL(str_query_release_13thmonthpay,
                                                               para_meters)

            exec_str_query_release_13thmonthpay.ExecuteQuery()

        End If

        payWTax.Dispose()

        filingStatus.Dispose()

    End Sub

    Private Function CalcNewPhilHealth(amount_worked As Decimal, is_for_employee As Boolean, Optional new_philhealth_deduction As Decimal = 0) As Decimal
        Static base_multiplier As Decimal = 0.01
        Static half_divisor As Decimal = 2

        Dim return_value, value1, value2 As Decimal

        'Dim contrib_amout, _rate, min_contrib, max_contrib As Decimal

        'For Each _phh As newphilhealthimplement In new_philhealth_collect

        '    _rate = (_phh.Rate * base_multiplier)

        '    contrib_amout = (_rate * amount_worked)

        '    min_contrib = _phh.MinimumContribution
        '    max_contrib = _phh.MaximumContribution

        '    If min_contrib > contrib_amout Then
        '        contrib_amout = min_contrib
        '    ElseIf max_contrib < contrib_amout Then
        '        contrib_amout = max_contrib
        '    End If

        '    'value1 = (contrib_amout / half_divisor)
        '    'value2 = (contrib_amout - value1)
        '    '
        value1 = (new_philhealth_deduction / half_divisor)
        value2 = (new_philhealth_deduction - value1)

        Dim number_array = New Decimal() {value1, value2}

        If is_for_employee Then
            return_value = number_array.Min
        Else
            return_value = number_array.Max
        End If
        'Next

        Return return_value
    End Function

    Sub PayrollGeneration_BackgourndWork(sender As Object, e As System.ComponentModel.DoWorkEventArgs)

        DoProcess()

        'For i = 0 To 19
        '    Thread.Sleep(3000)
        'Next

        'Dim dfsd As String = DirectCast(sender, System.ComponentModel.BackgroundWorker).ToString
        'Console.WriteLine(String.Concat(dfsd, " @@ ", employee_dattab.TableName))

    End Sub
    '
    Sub PayrollGeneration_RunWorkerCompleted(sender As Object, e As System.ComponentModel.RunWorkerCompletedEventArgs)

        Static str_query As String = "CALL INSUPD_monthlyemployeerestdaypayment(?og_rowid, ?e_rowid, ?pp_rowid, ?u_rowid);"
        Static str_query2 As String = "CALL INSUPD_paystubitemallowances(?og_rowid, ?e_rowid, ?pp_rowid, ?u_rowid);"

        Dim i = 0

        For Each e_rowid In employee_rowid_list

            Dim _params =
                New Object() {org_rowid, e_rowid, n_PayrollRecordID, user_row_id}

            Dim sql As New SQL(str_query, _params)

            Dim sql2 As New SQL(str_query2, _params)

            Try
                Dim _task As Task = Task.Run(Sub()
                                                 sql.ExecuteQuery()
                                                 sql2.ExecuteQuery()
                                             End Sub)
                _task.Wait()
                '###################################################################
                'Dim _task As New Thread(AddressOf sql.ExecuteQuery) _
                '    With {.IsBackground = True, .Priority = ThreadPriority.Lowest}
                '_task.Start()

                'Dim _task2 As New Thread(AddressOf sql2.ExecuteQuery) _
                '    With {.IsBackground = True, .Priority = ThreadPriority.Lowest}
                '_task2.Start()

                Console.WriteLine(String.Concat("Executing Task", i))
            Catch ex As Exception
                Console.WriteLine(String.Concat("Error in Task", i, " : ", ex.Message))
            Finally
                i += 1
            End Try

        Next

    End Sub

End Class
