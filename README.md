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

## Play the demo

Run the following ObjectScript commands :

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
