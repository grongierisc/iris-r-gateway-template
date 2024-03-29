/// Description
Class Demo.RGateway
{

Parameter JGWHOST = "jgw";

Parameter JGWPORT = 55554;

Parameter RHOST = "r";

Parameter RPORT = 6311;

ClassMethod RunEval() As %Status
{
	// Get a gateway instance
    set gateway = ##class(%Net.Remote.Gateway).%New()
    set tSC = gateway.%Connect(..#JGWHOST, ..#JGWPORT)
	if $$$ISERR(tSC) quit
	
	// Bind the gateway to the Rserve
	set c = ##class(%Net.Remote.Object).%ClassMethod(.gateway,"com.intersystems.rgateway.Helper","createRConnection", ..#RHOST, ..#RPORT)

	// Run a random R command
    zw c.eval("R.version$version.string").asString()

    do:c'="" c.close()
	do:gateway'="" gateway.%Disconnect()
	quit
}

ClassMethod FromSQLOnIris()
{
    set gateway = ##class(%Net.Remote.Gateway).%New()
    set tSC = gateway.%Connect(..#JGWHOST, ..#JGWPORT)
	if $$$ISERR(tSC) quit
		
	set c = ##class(%Net.Remote.Object).%ClassMethod(.gateway,"com.intersystems.rgateway.Helper","createRConnection", ..#RHOST, ..#RPORT)
	
	// SQL Query
	set q = "select length from Test.Data"
	set resultSet = ##class(%SQL.Statement).%ExecDirect( , .q)

	// Prepare R vector
 	do c.eval("l = c()")
 	while resultSet.%Next() {
		 // Append resultSet to the R vector
 		do c.assign("x", ##class(%Net.Remote.Object).%New(gateway, "org.rosuda.REngine.REXPDouble", resultSet.Length))
 		do c.eval("l = append(l, c(x))")
 	}
 	
	// Produce mean from R
	zw "mean = " _c.eval("mean(l)").asString()

	// Produce median from R
	zw "median = "_c.eval("median(l)").asString()

	do:c'="" c.close()
	do:gateway'="" gateway.%Disconnect()
	quit
}

ClassMethod FromCSVOnRServe()
{
    set gateway = ##class(%Net.Remote.Gateway).%New()
    set tSC = gateway.%Connect(..#JGWHOST, ..#JGWPORT)
	if $$$ISERR(tSC) quit
		
	set c = ##class(%Net.Remote.Object).%ClassMethod(.gateway,"com.intersystems.rgateway.Helper","createRConnection", ..#RHOST, ..#RPORT)
	
	// Read a file from R
	// assign an R variable for the data file 
	set filename = "/tmp/data/abalone.csv"
	do c.assign("filename", filename)
	// Read the file from the R server
	do c.eval("data = read.csv(filename)")

	zw "mean = "_c.eval("mean(data$Length)").asString()
	zw "median = "_c.eval("median(data$Length)").asString()
 		
	// Call function from R script
	// assign an R variable for the script file 
	do c.assign("rFile", "/tmp/r/src/test.R")
	do c.eval("source(rFile)") 
 		
	zw "mode = "_c.eval("getMode(data$Length)").asString()
	

	// Plot graphs
	// assign a directory to save files
	do c.assign("dir", "/tmp/data")
	// produce plot PNG
	do c.eval("createHistPNG(data$Rings, dir, ""Rings"")")
	zw "plot produced in /tmp/data/hist.png"
	// produce plot JPG
	do c.eval("createHistJPG(data$Rings, dir, ""Rings"")")
	zw "plot produced in /tmp/data/hist.jpeg"
	// produce plot PDF
	do c.eval("createHistPDF(data$Rings, dir, ""Rings"")")
	zw "plot produced in /tmp/data/hist.pdf"
	
	do:c'="" c.close()
	do:gateway'="" gateway.%Disconnect()
	quit
}

ClassMethod RunScript() As %Status
{
	// Get a gateway instance
    set gateway = ##class(%Net.Remote.Gateway).%New()
    set tSC = gateway.%Connect(..#JGWHOST, ..#JGWPORT)
	if $$$ISERR(tSC) quit
	
	// Bind the gateway to the Rserve
	set c = ##class(%Net.Remote.Object).%ClassMethod(.gateway,"com.intersystems.rgateway.Helper","createRConnection", ..#RHOST, ..#RPORT)
	
	// create a list
	set l = ##class(%Net.Remote.Object).%New(gateway, "org.rosuda.REngine.RList")
	// add an element to the list
	do l.put("a",##class(%Net.Remote.Object).%New(gateway, "org.rosuda.REngine.REXPInteger", ##class(%Net.Remote.Object).%New(gateway, "int[]", 0,1,2,3)))
	// add a second element
	do l.put("b",##class(%Net.Remote.Object).%New(gateway, "org.rosuda.REngine.REXPDouble", ##class(%Net.Remote.Object).%New(gateway, "double[]", 0.5,1.2,2.3,3.0)))
	// assign the list to an R variable
	do c.assign("x", ##class(%Net.Remote.Object).%New(gateway, "org.rosuda.REngine.REXPList", l))
	
	// assign an R variable for the script file 
    do c.assign("rFile", "/tmp/r/src/test.R")
	// bind file to R
    do c.eval("source(rFile)")
	// use function from file /tmp/r/scr/test.R
    zw "getLength = "_c.eval("getLength(x)").asString()

	do:c'="" c.close()
	do:gateway'="" gateway.%Disconnect()
	quit
}

}
