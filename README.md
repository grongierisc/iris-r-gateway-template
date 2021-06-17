# iris-r-gateway-template

This repository is a template of how to use the new R gateway for IRIS 2021.1.

The achitecture of this template is as follow :

![architecture](https://raw.githubusercontent.com/grongierisc/iris-r-gateway-template/master/misc/architecture.png)

There is two container :

- one for IRIS
- one for R and is Server

Both container share the same datas : abalone.csv

This file is loaded as a table in IRIS : Test.Data.

The R container have an script for demonstration purpose.

 - test.R

```R
getMode <- function(x) {
  l <- unique(x)
  l[which.max(tabulate(match(x, l)))]
}

getLength <- function(x) {
  length(x)
}

createHistJPG <- function(data, dir, label) {
  dir2 = paste(dir, "/hist.jpeg", sep="")
  jpeg(file = dir2)
  hist(data, xlab=label)
  dev.off()
}

createHistPNG <- function(data, dir, label) {
  dir2 = paste(dir, "/hist.png", sep="")
  png(file = dir2)
  hist(data, xlab=label)
  dev.off()
}

createHistPDF <- function(data, dir, label) {
  dir2 = paste(dir, "/hist.pdf", sep="")
  pdf(file = dir2)
  hist(data, xlab=label)
  dev.off()
}
```

## Run this template 

```sh
git clone https://github.com/grongierisc/iris-r-gateway-template
```

then :

```sh
docker compose up
```

## Play with this template

Run the following ObjectScript commands

### Run random R expression

```objectscript
do ##class(Demo.RGateway).RunEval()
```

output :

```
"R version 3.4.4 (2018-03-15)"
```

code : 

```objectscript
ClassMethod RunEval() As %Status
{
	// Get a gateway instance
    set gateway = ##class(%Net.Remote.Gateway).%New()
    set tSC = gateway.%Connect("r",55554)
	if $$$ISERR(tSC) quit
	
	// Bind the gateway to the Rserve
	set c = ##class(%Net.Remote.Object).%ClassMethod(.gateway,"com.intersystems.rgateway.Helper","createRConnection")

	// Run a random R command
    zw c.eval("R.version$version.string").asString()

    Return tSC
}
```

### Run R expression from IRIS SQL

```objectscript
do ##class(Demo.RGateway).FromSQLOnIris()
```

output :

```
"mean = 0.5239920995930093"
"median = 0.545"
```

code : 

```objectscript
ClassMethod FromSQLOnIris()
{
    set gateway = ##class(%Net.Remote.Gateway).%New()
    set tSC = gateway.%Connect("r",55554)
	if $$$ISERR(tSC) quit
		
	set c = ##class(%Net.Remote.Object).%ClassMethod(.gateway,"com.intersystems.rgateway.Helper","createRConnection")
	
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
```

### Run R Script and produce plot

```objectscript
do ##class(Demo.RGateway).FromCSVOnRServe()
```

output :

```
"mean = 0.5239920995930093"
"median = 0.545"
"mode = 0.55"
"plot produced in /tmp/data/hist.png"
"plot produced in /tmp/data/hist.jpeg"
"plot produced in /tmp/data/hist.pdf"
```

code : 

```objectscript
ClassMethod FromCSVOnRServe()
{
    set gateway = ##class(%Net.Remote.Gateway).%New()
    set tSC = gateway.%Connect("r",55554)
	if $$$ISERR(tSC) quit
		
	set c = ##class(%Net.Remote.Object).%ClassMethod(.gateway,"com.intersystems.rgateway.Helper","createRConnection")
	
	set filename = "/tmp/data/abalone.csv"
	// assign an R variable for the script file 
	do c.assign("filename", filename)
	// Read the file from the R server
	do c.eval("data = read.csv(filename)")

	zw "mean = "_c.eval("mean(data$Length)").asString()
 		
	zw "median = "_c.eval("median(data$Length)").asString()
 		
	// call function from r script
	do c.assign("rFile", "/tmp/r/src/test.R")
	do c.eval("source(rFile)") 
 		
	zw "mode = "_c.eval("getMode(data$Length)").asString()
	
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
```

