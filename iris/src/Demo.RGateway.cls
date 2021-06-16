/// Description
Class Demo.RGateway
{

/// Description
ClassMethod RunEval() As %Status
{
    set gateway = ##class(%Net.Remote.Gateway).%New()
    set tSC = gateway.%Connect("r",55554)
	if $$$ISERR(tSC) quit
		
	set c = ##class(%Net.Remote.Object).%ClassMethod(.gateway,"com.intersystems.rgateway.Helper","createRConnection")
	
    zw c.eval("R.version$version.string").asString()

    Return tSC
}

ClassMethod RunScript() As %Status
{
    set gateway = ##class(%Net.Remote.Gateway).%New()
    set tSC = gateway.%Connect("r",55554)
	if $$$ISERR(tSC) quit
		
	set c = ##class(%Net.Remote.Object).%ClassMethod(.gateway,"com.intersystems.rgateway.Helper","createRConnection")
	

    do c.assign("rFile", "/r/src/test.R")
    do c.eval("source(rFile)")
    zw c.eval("getMode(data$Length)").asString()

    Return tSC
}

ClassMethod FromSQL()
{
    set gateway = ##class(%Net.Remote.Gateway).%New()
    set tSC = gateway.%Connect("r",55554)
	if $$$ISERR(tSC) quit
		
	set c = ##class(%Net.Remote.Object).%ClassMethod(.gateway,"com.intersystems.rgateway.Helper","createRConnection")
	
	set q = "select length from RTest.abalone"
	set resultSet = ##class(%SQL.Statement).%ExecDirect( , .q)

 	do c.eval("l = c()")
 	while resultSet.%Next() {
 		do c.assign("x", ##class(%Net.Remote.Object).%New(gateway, "org.rosuda.REngine.REXPDouble", resultSet.Length))
 		do c.eval("l = append(l, c(x))")
 	}
 	
	zw "mean = " _c.eval("mean(l)").asString()
	
	zw "median = "_c.eval("median(l)").asString()
}

}
