Imports NUnit.Framework

<TestFixture()>
Public Class PayrollResourcesTest

    <Test()>
    Public Sub TestMethod1()
        Dim payrollResource As New PayrollResources(222, New Date(2019, 3, 1), New Date(2019, 3, 15))
        Dim resourcesTask = payrollResource.Load()
        resourcesTask.Wait()
        'payrollResource.LoadProducts().Wait()

        Assert.Pass()
    End Sub

End Class
