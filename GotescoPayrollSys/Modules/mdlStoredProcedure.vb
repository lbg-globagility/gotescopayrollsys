Imports MySql.Data.MySqlClient

Module mdlStoredProcedure

    Public connectionString As String = mysql_conn_text

    Public connection As MySqlConnection = New MySqlConnection(connectionString)

    Public Function sp_employeedisciplinaryaction(ByVal Created As DateTime,
                                 ByVal CreatedBy As Integer,
                                 ByVal LastUpD As DateTime,
                                 ByVal OrganizationID As Integer,
                                 ByVal lastupdby As Integer,
                                 ByVal action As String,
                                 ByVal comments As String,
                                 ByVal FindingDec As String,
                                 ByVal FindingID As Integer,
                                 ByVal EmpID As Integer,
                                 ByVal DateFrom As Date,
                                 ByVal DateTo As Date,
                                 Optional Penalty As Object = Nothing)

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("sp_employeedisciplinaryaction", connection)
        With SQL_command
            Try
                .Connection.Open()
                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_Createdby", CreatedBy)
                .Parameters.AddWithValue("I_lastupd", LastUpD)
                .Parameters.AddWithValue("I_OrganizationID", OrganizationID)
                .Parameters.AddWithValue("I_lastupdby", lastupdby)
                .Parameters.AddWithValue("I_EmployeeID", EmpID)
                .Parameters.AddWithValue("I_DateFrom", DateFrom)
                .Parameters.AddWithValue("I_DateTo", DateTo)
                .Parameters.AddWithValue("I_FindingID", FindingID)
                .Parameters.AddWithValue("I_FindingDescription", FindingDec)
                .Parameters.AddWithValue("I_Action", action)
                .Parameters.AddWithValue("I_Comments", comments)
                .Parameters.AddWithValue("I_Penalty", If(Penalty = Nothing, DBNull.Value, Penalty))

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function sp_finding(ByVal Created As DateTime,
                                  ByVal CreatedBy As Integer,
                                  ByVal LastUpD As DateTime,
                                  ByVal OrganizationID As Integer,
                                  ByVal lastupdby As Integer,
                                  ByVal PartNo As String,
                                  ByVal Description As String,
                                  Optional CategoryID As String = Nothing)

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("sp_finding", connection)
        With SQL_command
            Try
                .Connection.Open()

                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_Createdby", CreatedBy)
                .Parameters.AddWithValue("I_lastupd", LastUpD)
                .Parameters.AddWithValue("I_OrganizationID", OrganizationID)
                .Parameters.AddWithValue("I_lastupdby", lastupdby)
                .Parameters.AddWithValue("I_Description", Description)
                .Parameters.AddWithValue("I_PartNo", PartNo)
                .Parameters.AddWithValue("I_CategoryID", If(CategoryID = Nothing, DBNull.Value, CategoryID))

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function sp_promotion(ByVal Created As DateTime,
                                      ByVal CreatedBy As Integer,
                                      ByVal LastUpD As DateTime,
                                      ByVal OrganizationID As Integer,
                                      ByVal lastupdby As Integer,
                                      ByVal EffectiveDate As Date,
                                      ByVal postfrom As String,
                                      ByVal postto As String,
                                      ByVal empsalaryid As Object,
                                      ByVal flg As String,
                                      ByVal empid As Integer,
                                      Optional I_Reason As String = Nothing,
                                      Optional I_NewAmount As Object = Nothing)
        '
        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("sp_emppromotion", connection)
        With SQL_command
            Try
                .Connection.Open()

                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_Createdby", CreatedBy)
                .Parameters.AddWithValue("I_lastupd", LastUpD)
                .Parameters.AddWithValue("I_OrganizationID", OrganizationID)
                .Parameters.AddWithValue("I_lastupdby", lastupdby)
                .Parameters.AddWithValue("I_EffectiveDate", EffectiveDate)
                .Parameters.AddWithValue("I_PositionFrom", postfrom)
                .Parameters.AddWithValue("I_PositionTo", postto)
                .Parameters.AddWithValue("I_EmployeeID", empid)
                .Parameters.AddWithValue("I_CompensationChange", flg)
                .Parameters.AddWithValue("I_EmployeeSalaryID", If(empsalaryid = Nothing, DBNull.Value, empsalaryid))
                .Parameters.AddWithValue("I_Reason", I_Reason)
                .Parameters.AddWithValue("I_NewAmount", ValNoComma(I_NewAmount))

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return

    End Function

    Public Function sp_employeeshiftentry(ByVal Created As DateTime,
                                      ByVal CreatedBy As Integer,
                                      ByVal LastUpD As DateTime,
                                      ByVal OrganizationID As Integer,
                                      ByVal lastupdby As Integer,
                                      ByVal Effectivefrom As Date,
                                      ByVal Effectiveto As Date,
                                      ByVal EmployeeID As Integer,
                                      ByVal ShiftID As Integer,
                                      ByVal nightshift As String,
                                      Optional restday As String = Nothing)

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("sp_employeeshiftentry", connection)
        With SQL_command
            Try
                .Connection.Open()

                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_Createdby", CreatedBy)
                .Parameters.AddWithValue("I_lastupd", LastUpD)
                .Parameters.AddWithValue("I_OrganizationID", OrganizationID)
                .Parameters.AddWithValue("I_lastupdby", lastupdby)
                .Parameters.AddWithValue("I_EffectiveFrom", Effectivefrom)
                .Parameters.AddWithValue("I_EffectiveTo", Effectiveto)
                .Parameters.AddWithValue("I_ShiftID", If(ShiftID = 0, DBNull.Value, ShiftID))
                .Parameters.AddWithValue("I_EmployeeID", EmployeeID)
                .Parameters.AddWithValue("I_NightShift", nightshift)
                .Parameters.AddWithValue("I_RestDay", If(restday = Nothing, 0, restday))

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function sp_shift(ByVal Created As DateTime,
                                      ByVal CreatedBy As Integer,
                                      ByVal LastUpD As DateTime,
                                      ByVal OrganizationID As Integer,
                                      ByVal lastupdby As Integer,
                                      ByVal timefrom As DateTime,
                                      ByVal timeto As DateTime,
                                      Optional divisor_to_dailyrate As Object = Nothing,
                                      Optional LunchTimeFrom As Object = Nothing,
                                      Optional LunchTimeTo As Object = Nothing)

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("sp_Shift", connection)
        With SQL_command
            Try
                .Connection.Open()

                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_Createdby", CreatedBy)
                .Parameters.AddWithValue("I_lastupd", LastUpD)
                .Parameters.AddWithValue("I_OrganizationID", OrganizationID)
                .Parameters.AddWithValue("I_lastupdby", lastupdby)
                .Parameters.AddWithValue("I_TimeFrom", Format(CDate(timefrom), "HH:mm"))
                .Parameters.AddWithValue("I_TimeTo", Format(CDate(timeto), "HH:mm"))
                .Parameters.AddWithValue("divisor_to_dailyrate", divisor_to_dailyrate)
                .Parameters.AddWithValue("LunchTimeFrom", LunchTimeFrom)
                .Parameters.AddWithValue("LunchTimeTo", LunchTimeTo)

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function sp_listupd(ByVal RowID As Integer,
                                       ByVal DisplayValue As String,
                                       ByVal LIC As String,
                                       ByVal Type As String,
                                       ByVal ParentLIC As String,
                                       ByVal Active As String,
                                       ByVal Description As String,
                                       ByVal Created As DateTime,
                                       ByVal CreatedBy As Integer,
                                       ByVal LastUpD As DateTime,
                                       ByVal orderby As Integer,
                                       ByVal lastupdby As Integer)

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("U_ListofValue", connection)
        With SQL_command
            Try
                .Connection.Open()
                .Parameters.AddWithValue("U_RowID", RowID)
                .Parameters.AddWithValue("U_DisplayValue", DisplayValue)
                .Parameters.AddWithValue("U_LIC", LIC)
                .Parameters.AddWithValue("U_Type", Type)
                .Parameters.AddWithValue("U_ParentLIC", ParentLIC)
                .Parameters.AddWithValue("U_Active", Active)
                .Parameters.AddWithValue("U_Description", Description)
                .Parameters.AddWithValue("U_Created", Created)
                .Parameters.AddWithValue("U_Createdby", CreatedBy)
                .Parameters.AddWithValue("U_lastupd", LastUpD)
                .Parameters.AddWithValue("U_orderby", orderby)
                .Parameters.AddWithValue("U_lastupdby", lastupdby)
                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function SP_EducBackGround(ByVal Created As DateTime,
                            ByVal CreatedBy As Integer,
                            ByVal LastUpd As DateTime,
                            ByVal LastUpdBy As Integer,
                            ByVal OrgID As Integer,
                            ByVal EmpID As Integer,
                            ByVal datefrom As String,
                            ByVal dateto As String,
                            ByVal course As String,
                            ByVal school As String,
                            ByVal Degree As String,
                            ByVal minor As String,
                            ByVal EducType As String,
                            ByVal Remarks As String) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("SP_employeeeducation", connection)
        With SQL_command
            Try
                .Connection.Open()
                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_CreatedBy", CreatedBy)
                .Parameters.AddWithValue("I_LastUpd", LastUpd)
                .Parameters.AddWithValue("I_LastUpdBy", LastUpdBy)
                .Parameters.AddWithValue("I_OrganizationID", OrgID)
                .Parameters.AddWithValue("I_EmployeeID", EmpID)
                .Parameters.AddWithValue("I_DateFrom", datefrom)
                .Parameters.AddWithValue("I_DateTo", dateto)
                .Parameters.AddWithValue("I_Course", course)
                .Parameters.AddWithValue("I_School", school)
                .Parameters.AddWithValue("I_Degree", Degree)
                .Parameters.AddWithValue("I_Minor", minor)
                .Parameters.AddWithValue("I_EducationType", EducType)
                .Parameters.AddWithValue("I_Remarks", Remarks)

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    'SP_employeeeducationUpdate

    Public Function SP_employeeeducationUpdate(ByVal datefrom As String,
                          ByVal dateto As String,
                          ByVal course As String,
                          ByVal school As String,
                          ByVal Degree As String,
                          ByVal minor As String,
                          ByVal EducType As String,
                          ByVal Remarks As String,
                          ByVal RowID As Integer) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("SP_employeeeducationUpdate", connection)
        With SQL_command
            Try
                .Connection.Open()
                .Parameters.AddWithValue("I_DateFrom", datefrom)
                .Parameters.AddWithValue("I_DateTo", dateto)
                .Parameters.AddWithValue("I_Course", course)
                .Parameters.AddWithValue("I_School", school)
                .Parameters.AddWithValue("I_Degree", Degree)
                .Parameters.AddWithValue("I_Minor", minor)
                .Parameters.AddWithValue("I_EducationType", EducType)
                .Parameters.AddWithValue("I_Remarks", Remarks)
                .Parameters.AddWithValue("I_RowID", RowID)

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function I_PositionViewproc(ByVal position As Integer,
                                   ByVal viewid As Integer,
                                   ByVal create As String,
                                   ByVal orgid As Integer,
                                   ByVal read As String,
                                   ByVal update As String,
                                   ByVal delete As String,
                                   ByVal Created As DateTime,
                                   ByVal CreatedBy As Integer,
                                   ByVal LastUpD As DateTime,
                                   ByVal lastupdby As Integer) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("I_PositionView", connection)
        With SQL_command
            Try
                .Connection.Open()
                .Parameters.AddWithValue("I_PositionID", position)
                .Parameters.AddWithValue("I_ViewID", viewid)
                .Parameters.AddWithValue("I_Creates", create)
                .Parameters.AddWithValue("I_OrganizationID", orgid)
                .Parameters.AddWithValue("I_ReadOnly", read)
                .Parameters.AddWithValue("I_Updates", update)
                .Parameters.AddWithValue("I_deleting", delete)
                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_Createdby", CreatedBy)
                .Parameters.AddWithValue("I_lastupd", LastUpD)
                .Parameters.AddWithValue("I_lastupdby", lastupdby)
                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function I_AuditTrail(ByVal Created As DateTime,
                                ByVal CreatedBy As Integer,
                                ByVal LastUpd As DateTime,
                                ByVal LastUpdBy As Integer,
                                ByVal OrgID As Integer,
                                ByVal ViewID As Integer,
                                ByVal FieldChanged As String,
                                ByVal ChangedRowID As Integer,
                                ByVal OldValue As String,
                                ByVal NewValue As String,
                                ByVal ActionPerformed As String) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("I_audittrail", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_CreatedBy", CreatedBy)
                .Parameters.AddWithValue("I_LastUpd", LastUpd)
                .Parameters.AddWithValue("I_LastUpdBy", LastUpdBy)
                .Parameters.AddWithValue("I_OrganizationID", OrgID)
                .Parameters.AddWithValue("I_ViewID", ViewID)
                .Parameters.AddWithValue("I_FieldChanged", FieldChanged)
                .Parameters.AddWithValue("I_ChangedRowID", ChangedRowID)
                .Parameters.AddWithValue("I_OldValue", OldValue)
                .Parameters.AddWithValue("I_NewValue", NewValue)
                .Parameters.AddWithValue("I_ActionPerformed", ActionPerformed)

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function I_address(ByVal I_StreetAddress1 As String,
      ByVal I_StreetAddress2 As String,
      ByVal I_CityTown As String,
      ByVal I_Country As String,
      ByVal I_State As String,
      ByVal I_CreatedBy As Integer,
      ByVal I_LastUpdBy As Integer,
      ByVal I_Created As DateTime,
      ByVal I_LastUpd As DateTime,
      ByVal I_ZipCode As String,
      ByVal I_Barangay As String) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("I_address", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("I_StreetAddress1", I_StreetAddress1)
                .Parameters.AddWithValue("I_StreetAddress2", I_StreetAddress2)
                .Parameters.AddWithValue("I_CityTown", I_CityTown)
                .Parameters.AddWithValue("I_Country", I_Country)
                .Parameters.AddWithValue("I_State", I_State)
                .Parameters.AddWithValue("I_CreatedBy", I_CreatedBy)
                .Parameters.AddWithValue("I_LastUpdBy", I_LastUpdBy)
                .Parameters.AddWithValue("I_Created", I_Created)
                .Parameters.AddWithValue("I_LastUpd", I_LastUpd)
                .Parameters.AddWithValue("I_ZipCode", I_ZipCode)
                .Parameters.AddWithValue("I_Barangay", I_Barangay)

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function sp_list(ByVal DisplayValue As String,
                                           ByVal LIC As String,
                                           ByVal Type As String,
                                           ByVal ParentLIC As String,
                                           ByVal Active As String,
                                           ByVal Description As String,
                                          ByVal Created As DateTime,
                                          ByVal CreatedBy As String,
                                          ByVal LastUpD As DateTime,
                                          ByVal orderby As Integer,
                                          ByVal lastupdby As String) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("I_ListValue", connection)
        With SQL_command
            Try
                .Connection.Open()
                .Parameters.AddWithValue("I_DisplayValue", DisplayValue)
                .Parameters.AddWithValue("I_LIC", LIC)
                .Parameters.AddWithValue("I_Type", Type)
                .Parameters.AddWithValue("I_ParentLIC", ParentLIC)
                .Parameters.AddWithValue("I_Active", Active)
                .Parameters.AddWithValue("I_Description", Description)
                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_Createdby", CreatedBy)
                .Parameters.AddWithValue("I_lastupd", LastUpD)
                .Parameters.AddWithValue("I_orderby", orderby)
                .Parameters.AddWithValue("I_lastupdby", lastupdby)
                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function SP_payfrequency(ByVal Createdby As Integer,
          ByVal LastUpdby As Integer,
          ByVal Created As DateTime,
          ByVal LastUpd As DateTime,
          ByVal paytype As String,
          ByVal paystart As Date) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("SP_payfrequency", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("I_CreatedBy", Createdby)
                .Parameters.AddWithValue("I_LastUpdBy", LastUpdby)
                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_LastUpd", LastUpd)
                .Parameters.AddWithValue("I_PayFrequencyType", paytype)
                .Parameters.AddWithValue("I_PayFrequencyStartDate", paystart)

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error SP_payfrequency Stored Procedure")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function SP_FilingStatus(ByVal Createdby As Integer,
      ByVal LastUpdby As Integer,
      ByVal Created As DateTime,
      ByVal LastUpd As DateTime,
      ByVal filingstatus As String,
      ByVal maritalstatus As String,
      ByVal dependent As Integer) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("SP_filingstatus", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("I_CreatedBy", Createdby)
                .Parameters.AddWithValue("I_LastUpdBy", LastUpdby)
                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_LastUpd", LastUpd)
                .Parameters.AddWithValue("I_filingstatus", filingstatus)
                .Parameters.AddWithValue("I_maritalstatus", maritalstatus)
                .Parameters.AddWithValue("I_dependent", dependent)

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error SP_payfrequency Stored Procedure")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function SP_EmployeeSalary(ByVal Createdby As Integer,
                                      ByVal LastUpdby As Integer,
                                      ByVal Created As DateTime,
                                      ByVal LastUpd As DateTime,
                                      ByVal filingstatus As Integer,
                                      ByVal maritalstatus As String,
                                      ByVal dependent As Integer,
                                      ByVal orgid As Integer,
                                      ByVal empid As Integer,
                                      ByVal sssid As Integer,
                                      ByVal philhealthid As Integer,
                                      ByVal hdmfid As Double,
                                      ByVal basicpay As Double,
                                      ByVal datefrom As Date,
                                      ByVal dateto As Date) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("SP_EmployeeSalary", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("I_CreatedBy", Createdby)
                .Parameters.AddWithValue("I_LastUpdBy", LastUpdby)
                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_LastUpd", LastUpd)
                .Parameters.AddWithValue("I_filingstatusID", filingstatus)
                .Parameters.AddWithValue("I_maritalstatus", maritalstatus)
                .Parameters.AddWithValue("I_NoofDependents", dependent)
                .Parameters.AddWithValue("I_OrganizationID", orgid)
                .Parameters.AddWithValue("I_EmployeeID", empid)
                .Parameters.AddWithValue("I_PaySocialSecurityID", sssid)
                .Parameters.AddWithValue("I_PayPhilhealthID", philhealthid)
                .Parameters.AddWithValue("I_HDMFAmount", hdmfid)
                .Parameters.AddWithValue("I_BasicPay", basicpay)
                .Parameters.AddWithValue("I_EffectiveDateFrom", datefrom)
                .Parameters.AddWithValue("I_EffectiveDateTo", dateto)
                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error SP_EmployeeSalary Stored Procedure")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    '   	`OrganizationID` INT(10),
    '`Created` DATETIME,
    '`CreatedBy` INT(10),
    '`LastUpd` DATETIME,
    '`LastUpdBy` INT(10),
    '`EmployeeID` INT(10),
    '`LoanNumber` INT(10),
    '`DedEffectiveDateFrom` DATE,
    '`DedEffectiveDateTo` DATE,
    '`TotalLoanAmount` DECIMAL(10,2),
    '`DeductionSchedule` VARCHAR(50),
    '`TotalBalanceLeft` DECIMAL(10,2),
    '`DeductionAmount` DECIMAL(10,2),
    '`Status` VARCHAR(50),
    '`DeductionPercentage` DECIMAL(10,2),
    '`NoOfPayPeriod` DECIMAL(10,2),
    '`Comments` VARCHAR(2000)
    Public Function SP_LoadSchedule(ByVal Createdby As Integer,
                                  ByVal LastUpdby As Integer,
                                  ByVal Created As DateTime,
                                  ByVal LastUpd As DateTime,
                                  ByVal LoanNumber As String,
                                  ByVal DedEffectiveDateFrom As Date,
                                  ByVal DedEffectiveDateTo As Date,
                                  ByVal orgid As Integer,
                                  ByVal empid As Integer,
                                  ByVal TotalLoanAmount As Double,
                                  ByVal DeductionSchedule As String,
                                  ByVal TotalBalanceLeft As Double,
                                  ByVal DeductionAmount As Double,
                                  ByVal noofpayperiod As Double,
                                  ByVal Comments As String,
                                  ByVal Status As String,
                                  ByVal DeductionPercentage As Double,
                                  Optional LoanTypeID As String = Nothing,
                                  Optional DeductionSched As String = Nothing) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("sp_empschedule", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("I_CreatedBy", Createdby)
                .Parameters.AddWithValue("I_LastUpdBy", LastUpdby)
                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_LastUpd", LastUpd)
                .Parameters.AddWithValue("I_LoanNumber", LoanNumber)
                .Parameters.AddWithValue("I_DedEffectiveDateFrom", DedEffectiveDateFrom)
                .Parameters.AddWithValue("I_DedEffectiveDateTo", DedEffectiveDateTo)
                .Parameters.AddWithValue("I_OrganizationID", orgid)
                .Parameters.AddWithValue("I_EmployeeID", empid)
                .Parameters.AddWithValue("I_TotalLoanAmount", TotalLoanAmount)
                .Parameters.AddWithValue("I_DeductionSchedule", DeductionSched)
                .Parameters.AddWithValue("I_TotalBalanceLeft", TotalBalanceLeft)
                .Parameters.AddWithValue("I_DeductionAmount", DeductionAmount)
                .Parameters.AddWithValue("I_noofpayperiod", noofpayperiod)
                .Parameters.AddWithValue("I_Comments", Comments)
                .Parameters.AddWithValue("I_STatus", Status)
                .Parameters.AddWithValue("I_DeductionPercentage", DeductionPercentage)
                .Parameters.AddWithValue("I_LoanTypeID", If(LoanTypeID = Nothing, DBNull.Value, LoanTypeID))

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error SP_LoadSchedule Stored Procedure")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function SP_UpdateLoadSchedule(ByVal LastUpdby As Integer,
                              ByVal LastUpd As DateTime,
                              ByVal LoanNumber As String,
                              ByVal DedEffectiveDateFrom As Date,
                              ByVal DedEffectiveDateTo As Date,
                              ByVal TotalLoanAmount As Double,
                              ByVal DeductionSchedule As String,
                              ByVal DeductionAmount As Double,
                              ByVal noofpayperiod As Double,
                              ByVal Comments As String,
                              ByVal Status As String,
                              ByVal DeductionPercentage As Double,
                              ByVal rowid As Integer,
                                  Optional LoanTypeID As String = Nothing,
                                  Optional DeductionSched As String = Nothing) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("sp_updateemploan", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("I_LastUpdBy", LastUpdby)
                .Parameters.AddWithValue("I_LastUpd", LastUpd)
                .Parameters.AddWithValue("I_LoanNumber", LoanNumber)
                .Parameters.AddWithValue("I_DedEffectiveDateFrom", DedEffectiveDateFrom)
                .Parameters.AddWithValue("I_DedEffectiveDateTo", DedEffectiveDateTo)
                .Parameters.AddWithValue("I_TotalLoanAmount", TotalLoanAmount)
                .Parameters.AddWithValue("I_DeductionSchedule", DeductionSched)
                .Parameters.AddWithValue("I_DeductionAmount", DeductionAmount)
                .Parameters.AddWithValue("I_noofpayperiod", noofpayperiod)
                .Parameters.AddWithValue("I_Comments", Comments)
                .Parameters.AddWithValue("I_STatus", Status)
                .Parameters.AddWithValue("I_DeductionPercentage", DeductionPercentage)
                .Parameters.AddWithValue("I_RowID", rowid)
                .Parameters.AddWithValue("I_LoanTypeID", If(LoanTypeID = Nothing, DBNull.Value, LoanTypeID))

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error SP_UpdateLoadSchedule Stored Procedure")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function SP_Organization(ByVal Name As String,
                                     ByVal PrimaryAddressID As Integer,
                                     ByVal PrimaryContactID As Integer,
                                     ByVal MainPhone As String,
                                     ByVal FaxNumber As String,
                                     ByVal EmailAddress As String,
                                     ByVal AltEmailAddress As String,
                                     ByVal AltPhone As String,
                                     ByVal URL As String,
                                     ByVal Created As DateTime,
                                     ByVal CreatedBy As Integer,
                                     ByVal LastUpd As DateTime,
                                     ByVal LastUpdBy As Integer,
                                     ByVal TINNumber As String,
                                     ByVal Tradename As String,
                                     ByVal orgType As String,
                                     Optional I_VacationLeaveDays As Object = Nothing,
                                     Optional I_SickLeaveDays As Object = Nothing,
                                     Optional I_MaternityLeaveDays As Object = Nothing,
                                     Optional I_OthersLeaveDays As Object = Nothing,
                                     Optional I_NightDifferentialTimeFrom As Object = Nothing,
                                     Optional I_NightDifferentialTimeTo As Object = Nothing,
                                     Optional I_NightShiftTimeFrom As Object = Nothing,
                                     Optional I_NightShiftTimeTo As Object = Nothing,
                                     Optional I_PayFrequencyID As Object = Nothing,
                                     Optional I_PhilhealthDeductionSchedule As Object = Nothing,
                                     Optional I_SSSDeductionSchedule As Object = Nothing,
                                     Optional I_PagIbigDeductionSchedule As Object = Nothing,
                                     Optional I_WorkDaysPerYear As Object = Nothing,
                                     Optional I_RDOCode As Object = Nothing,
                                     Optional I_ZIPCode As Object = Nothing,
                                     Optional WithholdingDeductionSchedule As Object = Nothing) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("I_Organization", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("I_CreatedBy", CreatedBy)
                .Parameters.AddWithValue("I_LastUpdBy", LastUpdBy)
                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_LastUpd", LastUpd)
                .Parameters.AddWithValue("I_Name", Name)
                .Parameters.AddWithValue("I_Tradename", Tradename)
                .Parameters.AddWithValue("I_PrimaryAddressID", If(PrimaryAddressID = Nothing, DBNull.Value, PrimaryAddressID))
                .Parameters.AddWithValue("I_PrimaryContactID", If(PrimaryContactID = Nothing, DBNull.Value, PrimaryContactID))
                .Parameters.AddWithValue("I_MainPhone", MainPhone)
                .Parameters.AddWithValue("I_FaxNumber", FaxNumber)
                .Parameters.AddWithValue("I_EmailAddress", EmailAddress)
                .Parameters.AddWithValue("I_AltEmailAddress", AltEmailAddress)
                .Parameters.AddWithValue("I_AltPhone", AltPhone)
                .Parameters.AddWithValue("I_URL", URL)
                .Parameters.AddWithValue("I_TINNo", TINNumber) 'OrganizationType
                .Parameters.AddWithValue("I_OrganizationType", orgType) 'OrganizationType

                .Parameters.AddWithValue("I_VacationLeaveDays", If(I_VacationLeaveDays = Nothing, DBNull.Value, I_VacationLeaveDays))
                .Parameters.AddWithValue("I_SickLeaveDays", If(I_SickLeaveDays = Nothing, DBNull.Value, I_SickLeaveDays))
                .Parameters.AddWithValue("I_MaternityLeaveDays", If(I_MaternityLeaveDays = Nothing, DBNull.Value, I_MaternityLeaveDays))
                .Parameters.AddWithValue("I_OthersLeaveDays", If(I_OthersLeaveDays = Nothing, DBNull.Value, I_OthersLeaveDays))

                .Parameters.AddWithValue("I_NightDifferentialTimeFrom", If(I_NightDifferentialTimeFrom = Nothing, DBNull.Value, I_NightDifferentialTimeFrom))
                .Parameters.AddWithValue("I_NightDifferentialTimeTo", If(I_NightDifferentialTimeTo = Nothing, DBNull.Value, I_NightDifferentialTimeTo))
                .Parameters.AddWithValue("I_NightShiftTimeFrom", If(I_NightShiftTimeFrom = Nothing, DBNull.Value, I_NightShiftTimeFrom))
                .Parameters.AddWithValue("I_NightShiftTimeTo", If(I_NightShiftTimeTo = Nothing, DBNull.Value, I_NightShiftTimeTo))

                .Parameters.AddWithValue("I_PhilhealthDeductionSchedule", If(I_PhilhealthDeductionSchedule = Nothing, DBNull.Value, I_PhilhealthDeductionSchedule))
                .Parameters.AddWithValue("I_SSSDeductionSchedule", If(I_SSSDeductionSchedule = Nothing, DBNull.Value, I_SSSDeductionSchedule))
                .Parameters.AddWithValue("I_PagIbigDeductionSchedule", If(I_PagIbigDeductionSchedule = Nothing, DBNull.Value, I_PagIbigDeductionSchedule))
                .Parameters.AddWithValue("I_WithholdingDeductionSchedule", If(WithholdingDeductionSchedule = Nothing, DBNull.Value, WithholdingDeductionSchedule))

                .Parameters.AddWithValue("I_PayFrequencyID", If(I_PayFrequencyID = Nothing, DBNull.Value, I_PayFrequencyID))

                .Parameters.AddWithValue("I_WorkDaysPerYear", If(I_WorkDaysPerYear = Nothing, 0, Val(I_WorkDaysPerYear)))

                .Parameters.AddWithValue("I_RDOCode", I_RDOCode.ToString)

                .Parameters.AddWithValue("I_ZIPCode", I_ZIPCode.ToString)

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error I_Organization Stored Procedure")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function SP_OrganizationUpdate(ByVal Name As String,
                                 ByVal PrimaryAddressID As Integer,
                                 ByVal PrimaryContactID As Object,
                                 ByVal MainPhone As String,
                                 ByVal FaxNumber As String,
                                 ByVal EmailAddress As String,
                                 ByVal AltEmailAddress As String,
                                 ByVal AltPhone As String,
                                 ByVal URL As String,
                                 ByVal LastUpd As DateTime,
                                 ByVal LastUpdBy As Integer,
                                 ByVal TINNumber As String,
                                 ByVal Tradename As String,
                                 ByVal orgType As String,
                                 ByVal RowID As Integer,
                                 Optional I_VacationLeaveDays As Object = Nothing,
                                 Optional I_SickLeaveDays As Object = Nothing,
                                 Optional I_MaternityLeaveDays As Object = Nothing,
                                 Optional I_OthersLeaveDays As Object = Nothing,
                                     Optional I_NightDifferentialTimeFrom As Object = Nothing,
                                     Optional I_NightDifferentialTimeTo As Object = Nothing,
                                     Optional I_NightShiftTimeFrom As Object = Nothing,
                                     Optional I_NightShiftTimeTo As Object = Nothing,
                                 Optional I_PayFrequencyID As Object = Nothing,
                                     Optional I_PhilhealthDeductionSchedule As Object = Nothing,
                                     Optional I_SSSDeductionSchedule As Object = Nothing,
                                     Optional I_PagIbigDeductionSchedule As Object = Nothing,
                                     Optional I_WorkDaysPerYear As Object = Nothing,
                                     Optional I_RDOCode As Object = Nothing,
                                     Optional I_ZIPCode As Object = Nothing,
                                     Optional WithholdingDeductionSchedule As Object = Nothing) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("I_OrganizationUpdate", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("I_LastUpdBy", LastUpdBy)
                .Parameters.AddWithValue("I_LastUpd", LastUpd)
                .Parameters.AddWithValue("I_Name", Name)
                .Parameters.AddWithValue("I_Tradename", Tradename)
                .Parameters.AddWithValue("I_PrimaryAddressID", If(PrimaryAddressID = Nothing, DBNull.Value, PrimaryAddressID))
                .Parameters.AddWithValue("I_PrimaryContactID", If(PrimaryContactID = Nothing, DBNull.Value, PrimaryContactID))
                .Parameters.AddWithValue("I_MainPhone", MainPhone)
                .Parameters.AddWithValue("I_FaxNumber", FaxNumber)
                .Parameters.AddWithValue("I_EmailAddress", EmailAddress)
                .Parameters.AddWithValue("I_AltEmailAddress", AltEmailAddress)
                .Parameters.AddWithValue("I_AltPhone", AltPhone)
                .Parameters.AddWithValue("I_URL", URL)
                .Parameters.AddWithValue("I_TINNo", TINNumber)
                .Parameters.AddWithValue("I_OrganizationType", orgType)
                .Parameters.AddWithValue("I_RowID", RowID)

                .Parameters.AddWithValue("I_VacationLeaveDays", If(I_VacationLeaveDays = Nothing, DBNull.Value, I_VacationLeaveDays))
                .Parameters.AddWithValue("I_SickLeaveDays", If(I_SickLeaveDays = Nothing, DBNull.Value, I_SickLeaveDays))
                .Parameters.AddWithValue("I_MaternityLeaveDays", If(I_MaternityLeaveDays = Nothing, DBNull.Value, I_MaternityLeaveDays))
                .Parameters.AddWithValue("I_OthersLeaveDays", If(I_OthersLeaveDays = Nothing, DBNull.Value, I_OthersLeaveDays))

                .Parameters.AddWithValue("I_NightDifferentialTimeFrom", If(I_NightDifferentialTimeFrom = Nothing, DBNull.Value, I_NightDifferentialTimeFrom))
                .Parameters.AddWithValue("I_NightDifferentialTimeTo", If(I_NightDifferentialTimeTo = Nothing, DBNull.Value, I_NightDifferentialTimeTo))
                .Parameters.AddWithValue("I_NightShiftTimeFrom", If(I_NightShiftTimeFrom = Nothing, DBNull.Value, I_NightShiftTimeFrom))
                .Parameters.AddWithValue("I_NightShiftTimeTo", If(I_NightShiftTimeTo = Nothing, DBNull.Value, I_NightShiftTimeTo))

                .Parameters.AddWithValue("I_PhilhealthDeductionSchedule", If(I_PhilhealthDeductionSchedule = Nothing, DBNull.Value, I_PhilhealthDeductionSchedule))
                .Parameters.AddWithValue("I_SSSDeductionSchedule", If(I_SSSDeductionSchedule = Nothing, DBNull.Value, I_SSSDeductionSchedule))
                .Parameters.AddWithValue("I_PagIbigDeductionSchedule", If(I_PagIbigDeductionSchedule = Nothing, DBNull.Value, I_PagIbigDeductionSchedule))
                .Parameters.AddWithValue("I_WithholdingDeductionSchedule", If(WithholdingDeductionSchedule = Nothing, DBNull.Value, WithholdingDeductionSchedule))

                .Parameters.AddWithValue("I_PayFrequencyID", If(I_PayFrequencyID = Nothing, DBNull.Value, I_PayFrequencyID))

                .Parameters.AddWithValue("I_WorkDaysPerYear", If(I_WorkDaysPerYear = Nothing, 0, Val(I_WorkDaysPerYear)))

                .Parameters.AddWithValue("I_RDOCode", I_RDOCode.ToString)

                .Parameters.AddWithValue("I_ZIPCode", I_ZIPCode.ToString)

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error I_OrganizationUpdate Stored Procedure")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function SP_OrganizationWithImage(ByVal Name As String,
                                 ByVal PrimaryAddressID As Integer,
                                 ByVal PrimaryContactID As Integer,
                                 ByVal MainPhone As String,
                                 ByVal FaxNumber As String,
                                 ByVal EmailAddress As String,
                                 ByVal AltEmailAddress As String,
                                 ByVal AltPhone As String,
                                 ByVal URL As String,
                                 ByVal Created As DateTime,
                                 ByVal CreatedBy As Integer,
                                 ByVal LastUpd As DateTime,
                                 ByVal LastUpdBy As Integer,
                                 ByVal TINNumber As String,
                                 ByVal Tradename As String,
                                 ByVal orgType As String,
                                 ByVal image As Object,
                                 Optional I_VacationLeaveDays As Object = Nothing,
                                 Optional I_SickLeaveDays As Object = Nothing,
                                 Optional I_MaternityLeaveDays As Object = Nothing,
                                 Optional I_OthersLeaveDays As Object = Nothing,
                                     Optional I_NightDifferentialTimeFrom As Object = Nothing,
                                     Optional I_NightDifferentialTimeTo As Object = Nothing,
                                     Optional I_NightShiftTimeFrom As Object = Nothing,
                                     Optional I_NightShiftTimeTo As Object = Nothing,
                                 Optional I_PayFrequencyID As Object = Nothing,
                                     Optional I_PhilhealthDeductionSchedule As Object = Nothing,
                                     Optional I_SSSDeductionSchedule As Object = Nothing,
                                     Optional I_PagIbigDeductionSchedule As Object = Nothing,
                                     Optional I_WorkDaysPerYear As Object = Nothing,
                                     Optional I_RDOCode As Object = Nothing,
                                     Optional I_ZIPCode As Object = Nothing,
                                     Optional WithholdingDeductionSchedule As Object = Nothing) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("I_OrgWithImage", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("I_CreatedBy", CreatedBy)
                .Parameters.AddWithValue("I_LastUpdBy", LastUpdBy)
                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_LastUpd", LastUpd)
                .Parameters.AddWithValue("I_Name", Name)
                .Parameters.AddWithValue("I_Tradename", Tradename)
                .Parameters.AddWithValue("I_PrimaryAddressID", If(PrimaryAddressID = Nothing, DBNull.Value, PrimaryAddressID))
                .Parameters.AddWithValue("I_PrimaryContactID", If(PrimaryContactID = Nothing, DBNull.Value, PrimaryContactID))
                .Parameters.AddWithValue("I_MainPhone", MainPhone)
                .Parameters.AddWithValue("I_FaxNumber", FaxNumber)
                .Parameters.AddWithValue("I_EmailAddress", EmailAddress)
                .Parameters.AddWithValue("I_AltEmailAddress", AltEmailAddress)
                .Parameters.AddWithValue("I_AltPhone", AltPhone)
                .Parameters.AddWithValue("I_URL", URL)
                .Parameters.AddWithValue("I_TINNo", TINNumber) 'OrganizationType
                .Parameters.AddWithValue("I_OrganizationType", orgType) 'OrganizationType
                .Parameters.AddWithValue("I_Image", image) 'OrganizationType

                .Parameters.AddWithValue("I_VacationLeaveDays", If(I_VacationLeaveDays = Nothing, DBNull.Value, I_VacationLeaveDays))
                .Parameters.AddWithValue("I_SickLeaveDays", If(I_SickLeaveDays = Nothing, DBNull.Value, I_SickLeaveDays))
                .Parameters.AddWithValue("I_MaternityLeaveDays", If(I_MaternityLeaveDays = Nothing, DBNull.Value, I_MaternityLeaveDays))
                .Parameters.AddWithValue("I_OthersLeaveDays", If(I_OthersLeaveDays = Nothing, DBNull.Value, I_OthersLeaveDays))

                .Parameters.AddWithValue("I_NightDifferentialTimeFrom", If(I_NightDifferentialTimeFrom = Nothing, DBNull.Value, I_NightDifferentialTimeFrom))
                .Parameters.AddWithValue("I_NightDifferentialTimeTo", If(I_NightDifferentialTimeTo = Nothing, DBNull.Value, I_NightDifferentialTimeTo))
                .Parameters.AddWithValue("I_NightShiftTimeFrom", If(I_NightShiftTimeFrom = Nothing, DBNull.Value, I_NightShiftTimeFrom))
                .Parameters.AddWithValue("I_NightShiftTimeTo", If(I_NightShiftTimeTo = Nothing, DBNull.Value, I_NightShiftTimeTo))

                .Parameters.AddWithValue("I_PhilhealthDeductionSchedule", If(I_PhilhealthDeductionSchedule = Nothing, DBNull.Value, I_PhilhealthDeductionSchedule))
                .Parameters.AddWithValue("I_SSSDeductionSchedule", If(I_SSSDeductionSchedule = Nothing, DBNull.Value, I_SSSDeductionSchedule))
                .Parameters.AddWithValue("I_PagIbigDeductionSchedule", If(I_PagIbigDeductionSchedule = Nothing, DBNull.Value, I_PagIbigDeductionSchedule))
                .Parameters.AddWithValue("I_WithholdingDeductionSchedule", If(WithholdingDeductionSchedule = Nothing, DBNull.Value, WithholdingDeductionSchedule))

                .Parameters.AddWithValue("I_PayFrequencyID", If(I_PayFrequencyID = Nothing, DBNull.Value, I_PayFrequencyID))

                .Parameters.AddWithValue("I_WorkDaysPerYear", If(I_WorkDaysPerYear = Nothing, 0, Val(I_WorkDaysPerYear)))

                .Parameters.AddWithValue("I_RDOCode", I_RDOCode.ToString)

                .Parameters.AddWithValue("I_ZIPCode", I_ZIPCode.ToString)

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error I_OrgWithImage Stored Procedure")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function SP_OrganizationWithImageUpdate(ByVal Name As String,
                                ByVal PrimaryAddressID As Integer,
                                ByVal PrimaryContactID As Object,
                                ByVal MainPhone As String,
                                ByVal FaxNumber As String,
                                ByVal EmailAddress As String,
                                ByVal AltEmailAddress As String,
                                ByVal AltPhone As String,
                                ByVal URL As String,
                                ByVal LastUpd As DateTime,
                                ByVal LastUpdBy As Integer,
                                ByVal TINNumber As String,
                                ByVal Tradename As String,
                                ByVal orgType As String,
                                ByVal image As Object,
                                ByVal RowID As Integer,
                                 Optional I_VacationLeaveDays As Object = Nothing,
                                 Optional I_SickLeaveDays As Object = Nothing,
                                 Optional I_MaternityLeaveDays As Object = Nothing,
                                 Optional I_OthersLeaveDays As Object = Nothing,
                                     Optional I_NightDifferentialTimeFrom As Object = Nothing,
                                     Optional I_NightDifferentialTimeTo As Object = Nothing,
                                     Optional I_NightShiftTimeFrom As Object = Nothing,
                                     Optional I_NightShiftTimeTo As Object = Nothing,
                                 Optional I_PayFrequencyID As Object = Nothing,
                                     Optional I_PhilhealthDeductionSchedule As Object = Nothing,
                                     Optional I_SSSDeductionSchedule As Object = Nothing,
                                     Optional I_PagIbigDeductionSchedule As Object = Nothing,
                                     Optional I_WorkDaysPerYear As Object = Nothing,
                                     Optional I_RDOCode As Object = Nothing,
                                     Optional I_ZIPCode As Object = Nothing,
                                     Optional WithholdingDeductionSchedule As Object = Nothing) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("I_OrgWithImageUpdate", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("I_LastUpdBy", LastUpdBy)
                .Parameters.AddWithValue("I_LastUpd", LastUpd)
                .Parameters.AddWithValue("I_Name", Name)
                .Parameters.AddWithValue("I_Tradename", Tradename)
                .Parameters.AddWithValue("I_PrimaryAddressID", PrimaryAddressID)
                .Parameters.AddWithValue("I_PrimaryContactID", If(PrimaryContactID = Nothing, DBNull.Value, PrimaryContactID))
                .Parameters.AddWithValue("I_MainPhone", MainPhone)
                .Parameters.AddWithValue("I_FaxNumber", FaxNumber)
                .Parameters.AddWithValue("I_EmailAddress", EmailAddress)
                .Parameters.AddWithValue("I_AltEmailAddress", AltEmailAddress)
                .Parameters.AddWithValue("I_AltPhone", AltPhone)
                .Parameters.AddWithValue("I_URL", URL)
                .Parameters.AddWithValue("I_TINNo", TINNumber)
                .Parameters.AddWithValue("I_OrganizationType", orgType)
                .Parameters.AddWithValue("I_Image", image)
                .Parameters.AddWithValue("I_RowID", RowID)

                .Parameters.AddWithValue("I_VacationLeaveDays", If(I_VacationLeaveDays = Nothing, DBNull.Value, I_VacationLeaveDays))
                .Parameters.AddWithValue("I_SickLeaveDays", If(I_SickLeaveDays = Nothing, DBNull.Value, I_SickLeaveDays))
                .Parameters.AddWithValue("I_MaternityLeaveDays", If(I_MaternityLeaveDays = Nothing, DBNull.Value, I_MaternityLeaveDays))
                .Parameters.AddWithValue("I_OthersLeaveDays", If(I_OthersLeaveDays = Nothing, DBNull.Value, I_OthersLeaveDays))

                .Parameters.AddWithValue("I_NightDifferentialTimeFrom", If(I_NightDifferentialTimeFrom = Nothing, DBNull.Value, I_NightDifferentialTimeFrom))
                .Parameters.AddWithValue("I_NightDifferentialTimeTo", If(I_NightDifferentialTimeTo = Nothing, DBNull.Value, I_NightDifferentialTimeTo))
                .Parameters.AddWithValue("I_NightShiftTimeFrom", If(I_NightShiftTimeFrom = Nothing, DBNull.Value, I_NightShiftTimeFrom))
                .Parameters.AddWithValue("I_NightShiftTimeTo", If(I_NightShiftTimeTo = Nothing, DBNull.Value, I_NightShiftTimeTo))

                .Parameters.AddWithValue("I_PhilhealthDeductionSchedule", If(I_PhilhealthDeductionSchedule = Nothing, DBNull.Value, I_PhilhealthDeductionSchedule))
                .Parameters.AddWithValue("I_SSSDeductionSchedule", If(I_SSSDeductionSchedule = Nothing, DBNull.Value, I_SSSDeductionSchedule))
                .Parameters.AddWithValue("I_PagIbigDeductionSchedule", If(I_PagIbigDeductionSchedule = Nothing, DBNull.Value, I_PagIbigDeductionSchedule))
                .Parameters.AddWithValue("I_WithholdingDeductionSchedule", If(WithholdingDeductionSchedule = Nothing, DBNull.Value, WithholdingDeductionSchedule))

                .Parameters.AddWithValue("I_PayFrequencyID", If(I_PayFrequencyID = Nothing, DBNull.Value, I_PayFrequencyID))

                .Parameters.AddWithValue("I_WorkDaysPerYear", If(I_WorkDaysPerYear = Nothing, 0, Val(I_WorkDaysPerYear)))

                .Parameters.AddWithValue("I_RDOCode", I_RDOCode.ToString)

                .Parameters.AddWithValue("I_ZIPCode", I_ZIPCode.ToString)

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error I_OrgWithImageUpdate Stored Procedure")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function I_UsersProc(ByVal lname As String,
                                   ByVal fname As String,
                                   ByVal mname As String,
                                   ByVal userid As Object,
                                   ByVal password As Object,
                                   ByVal orgid As Integer,
                                   ByVal postid As String,
                                   ByVal Created As DateTime,
                                   ByVal lastupdby As Integer,
                                   ByVal CreatedBy As Integer,
                                   ByVal LastUpD As DateTime,
                                   ByVal status As String,
                                   ByVal EmailAddress As String,
                                   Optional deptMngrRowID As Object = Nothing) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("I_Users", connection)
        With SQL_command
            Try
                .Connection.Open()
                .Parameters.AddWithValue("I_LastName", lname)
                .Parameters.AddWithValue("I_Firstname", fname)
                .Parameters.AddWithValue("I_MiddleName", mname)
                .Parameters.AddWithValue("I_UserID", userid)
                .Parameters.AddWithValue("I_Password", password)
                .Parameters.AddWithValue("I_organizationID", orgid)
                .Parameters.AddWithValue("I_PositionID", If(postid = Nothing, DBNull.Value, postid))
                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_lastupd", LastUpD)
                .Parameters.AddWithValue("I_Createdby", CreatedBy)
                .Parameters.AddWithValue("I_lastupdby", lastupdby)
                .Parameters.AddWithValue("I_Status", status)
                .Parameters.AddWithValue("I_EmailAddress", Trim(EmailAddress))
                .Parameters.AddWithValue("I_dept_mngr_rowid", deptMngrRowID)
                'I_EmailAddress
                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function U_UsersProc(ByVal RowID As Integer,
                                 ByVal lname As String,
                                 ByVal fname As String,
                                 ByVal mname As String,
                                 ByVal postid As String,
                                 ByVal Created As DateTime,
                                 ByVal lastupdby As Integer,
                                 ByVal CreatedBy As Integer,
                                 ByVal LastUpD As DateTime,
                                 ByVal status As String,
                                 ByVal EmailAddress As String,
                                 Optional enc_userid_value As Object = Nothing,
                                 Optional enc_pword_value As Object = Nothing,
                                 Optional deptMngrRowID As Object = Nothing) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("U_Users", connection)
        With SQL_command
            Try
                .Connection.Open()
                .Parameters.AddWithValue("I_RowID", RowID)
                .Parameters.AddWithValue("I_LastName", lname)
                .Parameters.AddWithValue("I_Firstname", fname)
                .Parameters.AddWithValue("I_MiddleName", mname)
                .Parameters.AddWithValue("I_PositionID", If(postid = Nothing, DBNull.Value, postid))
                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_Createdby", CreatedBy)
                .Parameters.AddWithValue("I_lastupdby", lastupdby)
                .Parameters.AddWithValue("I_lastupd", LastUpD)
                .Parameters.AddWithValue("I_Status", status)
                .Parameters.AddWithValue("I_EmailAddress", Trim(EmailAddress))

                .Parameters.AddWithValue("enc_userid", enc_userid_value)

                .Parameters.AddWithValue("enc_pword", enc_pword_value)

                .Parameters.AddWithValue("I_dept_mngr_rowid", deptMngrRowID)

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function I_Position(ByVal postname As String,
                                    ByVal Lastupd As DateTime,
                                    ByVal Created As DateTime,
                                    ByVal CreatedBy As Integer,
                                    ByVal OrgID As Integer,
                                    ByVal LastUpdBy As Integer) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("I_Position", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("I_PositionName", postname)
                .Parameters.AddWithValue("I_LastUpd", Lastupd)
                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_CreatedBy", CreatedBy)
                .Parameters.AddWithValue("I_OrganizationID", OrgID)
                .Parameters.AddWithValue("I_LastUpdBy", LastUpdBy)

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function SP_DivisionUpdate(ByVal Name As String,
                                 ByVal MainPhone As String,
                                 ByVal FaxNumber As String,
                                 ByVal EmailAddress As String,
                                 ByVal AltEmailAddress As String,
                                 ByVal AltPhone As String,
                                 ByVal URL As String,
                                 ByVal LastUpd As DateTime,
                                 ByVal LastUpdBy As Integer,
                                 ByVal TINNumber As String,
                                 ByVal Tradename As String,
                                 ByVal DivisionType As String,
                                 ByVal Businessaddr As String,
                                 ByVal Contactname As String,
                                 ByVal RowID As Integer,
    ByVal I_GracePeriod As Object,
    ByVal I_WorkDaysPerYear As Object,
    ByVal I_PhHealthDeductSched As Object,
    ByVal I_HDMFDeductSched As Object,
    ByVal I_SSSDeductSched As Object,
    ByVal I_WTaxDeductSched As Object,
    ByVal I_DefaultVacationLeave As Object,
    ByVal I_DefaultSickLeave As Object,
    ByVal I_DefaultMaternityLeave As Object,
    ByVal I_DefaultPaternityLeave As Object,
    ByVal I_DefaultOtherLeave As Object,
    ByVal I_PayFrequencyID As Object,
    Optional I_PhHealthDeductSchedNoAgent As Object = Nothing,
    Optional I_HDMFDeductSchedNoAgent As Object = Nothing,
    Optional I_SSSDeductSchedNoAgent As Object = Nothing,
    Optional I_WTaxDeductSchedNoAgent As Object = Nothing,
    Optional I_MinimumWageAmount As Object = Nothing,
    Optional auto_ot As Object = Nothing) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("SP_DivisionUpdate", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("I_LastUpdBy", LastUpdBy)
                .Parameters.AddWithValue("I_LastUpd", LastUpd)
                .Parameters.AddWithValue("I_Name", Name)
                .Parameters.AddWithValue("I_Tradename", Tradename)
                .Parameters.AddWithValue("I_MainPhone", MainPhone)
                .Parameters.AddWithValue("I_FaxNumber", FaxNumber)
                .Parameters.AddWithValue("I_EmailAddress", EmailAddress)
                .Parameters.AddWithValue("I_AltEmailAddress", AltEmailAddress)
                .Parameters.AddWithValue("I_AltPhone", AltPhone)
                .Parameters.AddWithValue("I_URL", URL)
                .Parameters.AddWithValue("I_TINNo", TINNumber) 'OrganizationType
                .Parameters.AddWithValue("I_DivisionType", DivisionType) 'OrganizationType
                .Parameters.AddWithValue("I_BusinessAddress", Businessaddr) 'OrganizationType
                .Parameters.AddWithValue("I_ContactName", Contactname) 'OrganizationType
                .Parameters.AddWithValue("I_RowID", RowID)

                .Parameters.AddWithValue("I_GracePeriod", I_GracePeriod)
                .Parameters.AddWithValue("I_WorkDaysPerYear", I_WorkDaysPerYear)
                .Parameters.AddWithValue("I_PhHealthDeductSched", I_PhHealthDeductSched)
                .Parameters.AddWithValue("I_HDMFDeductSched", I_HDMFDeductSched)
                .Parameters.AddWithValue("I_SSSDeductSched", I_SSSDeductSched)
                .Parameters.AddWithValue("I_WTaxDeductSched", I_WTaxDeductSched)
                .Parameters.AddWithValue("I_DefaultVacationLeave", I_DefaultVacationLeave)
                .Parameters.AddWithValue("I_DefaultSickLeave", I_DefaultSickLeave)
                .Parameters.AddWithValue("I_DefaultMaternityLeave", I_DefaultMaternityLeave)
                .Parameters.AddWithValue("I_DefaultPaternityLeave", I_DefaultPaternityLeave)
                .Parameters.AddWithValue("I_DefaultOtherLeave", I_DefaultOtherLeave)
                .Parameters.AddWithValue("I_PayFrequencyID", I_PayFrequencyID)

                .Parameters.AddWithValue("I_PhHealthDeductSchedNoAgent", I_PhHealthDeductSchedNoAgent)
                .Parameters.AddWithValue("I_HDMFDeductSchedNoAgent", I_HDMFDeductSchedNoAgent)
                .Parameters.AddWithValue("I_SSSDeductSchedNoAgent", I_SSSDeductSchedNoAgent)
                .Parameters.AddWithValue("I_WTaxDeductSchedNoAgent", I_WTaxDeductSchedNoAgent)

                .Parameters.AddWithValue("I_MinimumWageAmount", I_MinimumWageAmount)

                .Parameters.AddWithValue("auto_ot", auto_ot)

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error SP_DivisionUpdate Stored Procedure")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function SP_Division(ByVal Name As String,
                                 ByVal MainPhone As String,
                                 ByVal FaxNumber As String,
                                 ByVal EmailAddress As String,
                                 ByVal AltEmailAddress As String,
                                 ByVal AltPhone As String,
                                 ByVal URL As String,
                                 ByVal Created As DateTime,
                                 ByVal CreatedBy As Integer,
                                 ByVal LastUpd As DateTime,
                                 ByVal LastUpdBy As Integer,
                                 ByVal TINNumber As String,
                                 ByVal Tradename As String,
                                 ByVal DivisionType As String,
                                 ByVal Businessaddr As String,
                                 ByVal Contactname As String,
                                 ByVal OrgID As Integer,
    ByVal I_GracePeriod As Object,
    ByVal I_WorkDaysPerYear As Object,
    ByVal I_PhHealthDeductSched As Object,
    ByVal I_HDMFDeductSched As Object,
    ByVal I_SSSDeductSched As Object,
    ByVal I_WTaxDeductSched As Object,
    ByVal I_DefaultVacationLeave As Object,
    ByVal I_DefaultSickLeave As Object,
    ByVal I_DefaultMaternityLeave As Object,
    ByVal I_DefaultPaternityLeave As Object,
    ByVal I_DefaultOtherLeave As Object,
    ByVal I_PayFrequencyID As Object,
    Optional I_PhHealthDeductSchedNoAgent As Object = Nothing,
    Optional I_HDMFDeductSchedNoAgent As Object = Nothing,
    Optional I_SSSDeductSchedNoAgent As Object = Nothing,
    Optional I_WTaxDeductSchedNoAgent As Object = Nothing,
    Optional I_MinimumWageAmount As Object = Nothing,
    Optional auto_ot As Object = Nothing) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("SP_Division", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("I_CreatedBy", CreatedBy)
                .Parameters.AddWithValue("I_LastUpdBy", LastUpdBy)
                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_LastUpd", LastUpd)
                .Parameters.AddWithValue("I_Name", Name)
                .Parameters.AddWithValue("I_Tradename", Tradename)
                .Parameters.AddWithValue("I_MainPhone", MainPhone)
                .Parameters.AddWithValue("I_FaxNumber", FaxNumber)
                .Parameters.AddWithValue("I_EmailAddress", EmailAddress)
                .Parameters.AddWithValue("I_AltEmailAddress", AltEmailAddress)
                .Parameters.AddWithValue("I_AltPhone", AltPhone)
                .Parameters.AddWithValue("I_URL", URL)
                .Parameters.AddWithValue("I_TINNo", TINNumber) 'OrganizationType
                .Parameters.AddWithValue("I_DivisionType", DivisionType) 'OrganizationType
                .Parameters.AddWithValue("I_BusinessAddress", Businessaddr) 'OrganizationType
                .Parameters.AddWithValue("I_ContactName", Contactname) 'OrganizationType
                .Parameters.AddWithValue("I_OrganizationID", OrgID)

                .Parameters.AddWithValue("I_GracePeriod", I_GracePeriod)
                .Parameters.AddWithValue("I_WorkDaysPerYear", I_WorkDaysPerYear)
                .Parameters.AddWithValue("I_PhHealthDeductSched", I_PhHealthDeductSched)
                .Parameters.AddWithValue("I_HDMFDeductSched", I_HDMFDeductSched)
                .Parameters.AddWithValue("I_SSSDeductSched", I_SSSDeductSched)
                .Parameters.AddWithValue("I_WTaxDeductSched", I_WTaxDeductSched)
                .Parameters.AddWithValue("I_DefaultVacationLeave", I_DefaultVacationLeave)
                .Parameters.AddWithValue("I_DefaultSickLeave", I_DefaultSickLeave)
                .Parameters.AddWithValue("I_DefaultMaternityLeave", I_DefaultMaternityLeave)
                .Parameters.AddWithValue("I_DefaultPaternityLeave", I_DefaultPaternityLeave)
                .Parameters.AddWithValue("I_DefaultOtherLeave", I_DefaultOtherLeave)
                .Parameters.AddWithValue("I_PayFrequencyID", I_PayFrequencyID)

                .Parameters.AddWithValue("I_PhHealthDeductSchedNoAgent", I_PhHealthDeductSchedNoAgent)
                .Parameters.AddWithValue("I_HDMFDeductSchedNoAgent", I_HDMFDeductSchedNoAgent)
                .Parameters.AddWithValue("I_SSSDeductSchedNoAgent", I_SSSDeductSchedNoAgent)
                .Parameters.AddWithValue("I_WTaxDeductSchedNoAgent", I_WTaxDeductSchedNoAgent)

                .Parameters.AddWithValue("I_MinimumWageAmount", I_MinimumWageAmount)

                .Parameters.AddWithValue("auto_ot", auto_ot)

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error SP_Division Stored Procedure")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function I_contact(ByVal Status As String,
          ByVal Created As DateTime,
          ByVal OrganizationID As Integer,
          ByVal MainPhone As String,
          ByVal LastName As String,
          ByVal FirstName As String,
          ByVal MiddleName As String,
          ByVal MobilePhone As String,
          ByVal WorkPhone As String,
          ByVal Gender As String,
          ByVal JobTitle As String,
          ByVal EmailAddress As String,
          ByVal AlternatePhone As String,
          ByVal FaxNumber As String,
          ByVal LastUpd As DateTime,
          ByVal CreatedBy As Integer,
          ByVal LastUpdBy As Integer,
          ByVal personaltitle As String,
          ByVal type As String,
          ByVal suffix As String,
          ByVal addrID As Integer,
          ByVal tinno As String) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("I_contact", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("I_Status", Status)
                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_OrganizationID", OrganizationID)
                .Parameters.AddWithValue("I_MainPhone", MainPhone)
                .Parameters.AddWithValue("I_LastName", LastName)
                .Parameters.AddWithValue("I_FirstName", FirstName)
                .Parameters.AddWithValue("I_MiddleName", MiddleName)
                .Parameters.AddWithValue("I_MobilePhone", MobilePhone)
                .Parameters.AddWithValue("I_WorkPhone", WorkPhone)
                .Parameters.AddWithValue("I_Gender", Gender)
                .Parameters.AddWithValue("I_JobTitle", JobTitle)
                .Parameters.AddWithValue("I_EmailAddress", EmailAddress)
                .Parameters.AddWithValue("I_AlternatePhone", AlternatePhone)
                .Parameters.AddWithValue("I_FaxNumber", FaxNumber)
                .Parameters.AddWithValue("I_LastUpd", LastUpd)
                .Parameters.AddWithValue("I_CreatedBy", CreatedBy)
                .Parameters.AddWithValue("I_LastUpdBy", LastUpdBy)
                .Parameters.AddWithValue("I_PersonalTitle", personaltitle)
                .Parameters.AddWithValue("I_Type", type)
                .Parameters.AddWithValue("I_Suffix", type)
                .Parameters.AddWithValue("I_AddressID", If(addrID = Nothing, DBNull.Value, addrID)) 'I_TINNumber
                .Parameters.AddWithValue("I_TINNumber", tinno) 'I_TINNumber
                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function I_contactUpdate(ByVal Status As String,
      ByVal MainPhone As String,
      ByVal LastName As String,
      ByVal FirstName As String,
      ByVal MiddleName As String,
      ByVal MobilePhone As String,
      ByVal WorkPhone As String,
      ByVal Gender As String,
      ByVal JobTitle As String,
      ByVal EmailAddress As String,
      ByVal AlternatePhone As String,
      ByVal FaxNumber As String,
      ByVal LastUpd As DateTime,
      ByVal LastUpdBy As Integer,
      ByVal personaltitle As String,
      ByVal type As String,
      ByVal suffix As String,
      ByVal addrID As Integer,
      ByVal tinno As String,
      ByVal RowID As Integer) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("I_contactUpdate", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("I_Status", Status)
                .Parameters.AddWithValue("I_MainPhone", MainPhone)
                .Parameters.AddWithValue("I_LastName", LastName)
                .Parameters.AddWithValue("I_FirstName", FirstName)
                .Parameters.AddWithValue("I_MiddleName", MiddleName)
                .Parameters.AddWithValue("I_MobilePhone", MobilePhone)
                .Parameters.AddWithValue("I_WorkPhone", WorkPhone)
                .Parameters.AddWithValue("I_Gender", Gender)
                .Parameters.AddWithValue("I_JobTitle", JobTitle)
                .Parameters.AddWithValue("I_EmailAddress", EmailAddress)
                .Parameters.AddWithValue("I_AlternatePhone", AlternatePhone)
                .Parameters.AddWithValue("I_FaxNumber", FaxNumber)
                .Parameters.AddWithValue("I_LastUpd", LastUpd)
                .Parameters.AddWithValue("I_LastUpdBy", LastUpdBy)
                .Parameters.AddWithValue("I_PersonalTitle", personaltitle)
                .Parameters.AddWithValue("I_Type", type)
                .Parameters.AddWithValue("I_Suffix", type)
                .Parameters.AddWithValue("I_AddressID", addrID) 'I_TINNumber
                .Parameters.AddWithValue("I_TINNumber", tinno) 'I_TINNumber
                .Parameters.AddWithValue("I_RowID", If(RowID = Nothing, DBNull.Value, RowID)) 'I_TINNumber
                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function SP_employeepreviousemployer(ByVal Name As String,
      ByVal Tradename As String,
      ByVal OrganizationID As Integer,
      ByVal MainPhone As String,
      ByVal faxno As String,
      ByVal jobtitle As String,
      ByVal ExperienceFromTo As String,
      ByVal BusinessAddress As String,
      ByVal ContactName As String,
      ByVal EmailAddress As String,
      ByVal AltEmailAddress As String,
      ByVal AltPhone As String,
      ByVal URL As String,
      ByVal TINNo As String,
      ByVal JobFunction As String,
      ByVal Created As DateTime,
      ByVal CreatedBy As Integer,
      ByVal LastUpd As DateTime,
      ByVal LastUpdBy As Integer,
      ByVal OrganizationType As String,
      ByVal empid As Integer) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("SP_EmployeePreviousEmployer", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("I_Name", Name)
                .Parameters.AddWithValue("I_TradeName", Tradename)
                .Parameters.AddWithValue("I_OrganizationID", OrganizationID)
                .Parameters.AddWithValue("I_MainPhone", MainPhone)
                .Parameters.AddWithValue("I_FaxNumber", faxno)
                .Parameters.AddWithValue("I_JobTitle", jobtitle)
                .Parameters.AddWithValue("I_ExperienceFromTo", ExperienceFromTo)
                .Parameters.AddWithValue("I_BusinessAddress", BusinessAddress)
                .Parameters.AddWithValue("I_ContactName", ContactName)
                .Parameters.AddWithValue("I_EmailAddress", EmailAddress)
                .Parameters.AddWithValue("I_AltEmailAddress", AltEmailAddress)
                .Parameters.AddWithValue("I_AltPhone", AltPhone)
                .Parameters.AddWithValue("I_URL", URL)
                .Parameters.AddWithValue("I_TINNo", TINNo)
                .Parameters.AddWithValue("I_JobFunction", JobFunction)
                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_CreatedBy", CreatedBy)
                .Parameters.AddWithValue("I_LastUpd", LastUpd)
                .Parameters.AddWithValue("I_LastUpdby", LastUpdBy)
                .Parameters.AddWithValue("I_OrganizationType", OrganizationType)
                .Parameters.AddWithValue("I_EmployeeID", empid)

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function SP_EmployeePreviousEmployerUpdate(ByVal Name As String,
     ByVal Tradename As String,
     ByVal MainPhone As String,
     ByVal faxno As String,
     ByVal jobtitle As String,
     ByVal ExperienceFromTo As String,
     ByVal BusinessAddress As String,
     ByVal ContactName As String,
     ByVal EmailAddress As String,
     ByVal AltEmailAddress As String,
     ByVal AltPhone As String,
     ByVal URL As String,
     ByVal TINNo As String,
     ByVal JobFunction As String,
     ByVal OrganizationType As String,
     ByVal rowID As Integer) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("SP_EmployeePreviousEmployerUpdate", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("I_Name", Name)
                .Parameters.AddWithValue("I_TradeName", Tradename)
                .Parameters.AddWithValue("I_MainPhone", MainPhone)
                .Parameters.AddWithValue("I_FaxNumber", faxno)
                .Parameters.AddWithValue("I_JobTitle", jobtitle)
                .Parameters.AddWithValue("I_ExperienceFromTo", ExperienceFromTo)
                .Parameters.AddWithValue("I_BusinessAddress", BusinessAddress)
                .Parameters.AddWithValue("I_ContactName", ContactName)
                .Parameters.AddWithValue("I_EmailAddress", EmailAddress)
                .Parameters.AddWithValue("I_AltEmailAddress", AltEmailAddress)
                .Parameters.AddWithValue("I_AltPhone", AltPhone)
                .Parameters.AddWithValue("I_URL", URL)
                .Parameters.AddWithValue("I_TINNo", TINNo)
                .Parameters.AddWithValue("I_JobFunction", JobFunction)
                .Parameters.AddWithValue("I_OrganizationType", OrganizationType)
                .Parameters.AddWithValue("I_RowID", rowID)

                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function I_ListOfVal(ByVal Created As DateTime,
                            ByVal CreatedBy As Integer,
                            ByVal LastUpd As DateTime,
                            ByVal LastUpdby As Integer,
                            ByVal DisplayValue As String,
                            ByVal LIC As String,
                            ByVal Type As String,
                            ByVal ParentLIC As String,
                            ByVal Status As String,
                            ByVal Description As String,
                            ByVal SystemAccountFlg As Char,
                            ByVal DisplayAccountFlg As Char,
                            ByVal OrderBy As Object) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("I_listofvalue", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("I_Created", Created)
                .Parameters.AddWithValue("I_Createdby", CreatedBy)
                .Parameters.AddWithValue("I_LastUpd", LastUpd)
                .Parameters.AddWithValue("I_LastUpdby", LastUpdby)
                .Parameters.AddWithValue("I_DisplayValue", DisplayValue)
                .Parameters.AddWithValue("I_LIC", LIC)
                .Parameters.AddWithValue("I_Type", Type)
                .Parameters.AddWithValue("I_ParentLIC", ParentLIC)
                .Parameters.AddWithValue("I_Status", Status)
                .Parameters.AddWithValue("I_Description", Description)
                .Parameters.AddWithValue("I_SystemAccountFlg", SystemAccountFlg)
                .Parameters.AddWithValue("I_DisplayAccountFlg", DisplayAccountFlg)
                .Parameters.AddWithValue("I_OrderBy", OrderBy)
                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

    Public Function U_ListOfVal(ByVal RowID As Integer,
                              ByVal LastUpd As DateTime,
                              ByVal LastUpdby As Integer,
                              ByVal DisplayValue As String,
                              ByVal LIC As String,
                              ByVal Type As String,
                              ByVal ParentLIC As String,
                              ByVal Status As String,
                              ByVal Description As String,
                              ByVal SystemAccountFlg As Char,
                              ByVal DisplayAccountFlg As Char,
                              ByVal OrderBy As Object) As Boolean

        Dim F_return As Boolean = False
        Dim SQL_command As MySqlCommand =
                  New MySqlCommand("U_listofvalues", connection)
        With SQL_command
            Try

                .Connection.Open()
                .Parameters.AddWithValue("U_RowID", RowID)
                .Parameters.AddWithValue("U_LastUpd", LastUpd)
                .Parameters.AddWithValue("U_LastUpdby", LastUpdby)
                .Parameters.AddWithValue("U_DisplayValue", DisplayValue)
                .Parameters.AddWithValue("U_LIC", LIC)
                .Parameters.AddWithValue("U_Type", Type)
                .Parameters.AddWithValue("U_ParentLIC", ParentLIC)
                .Parameters.AddWithValue("U_Status", Status)
                .Parameters.AddWithValue("U_Description", Description)
                .Parameters.AddWithValue("U_SystemAccountFlg", SystemAccountFlg)
                .Parameters.AddWithValue("U_DisplayAccountFlg", DisplayAccountFlg)
                .Parameters.AddWithValue("U_OrderBy", OrderBy)
                .CommandType = CommandType.StoredProcedure
                F_return = (.ExecuteNonQuery > 0)
            Catch ex As Exception
                MsgBox(ex.Message, MsgBoxStyle.Critical, "Error")
            Finally
                connection.Close()
            End Try
        End With
        Return F_return
    End Function

End Module