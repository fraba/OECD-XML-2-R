#!/usr/bin/Rscript

library(XML)

# OECD URL to XML
url <- "http://stats.oecd.org/restsdmx/sdmx.ashx/GetData/SNA_TABLE1/NOR+CAN+FRA+DEU+GBR+USA+ITA+JAP.B1_GA+B1G_P119+B1G+B1GVA+B1GVB_E+B1GVC+B1GVF+B1GVG_I+B1GVJ+B1GVK+B1GVL+B1GVM_N+B1GVO_Q+B1GVR_U+D21_D31+D21S1+D31S1+DB1_GA.CXC/all?startTime=1950&endTime=2013"
xml <- xmlParse(url)

ns<-xmlNamespaceDefinitions(xml, simplify=T)
names(ns)[1] <- "def"   #assign name "def"

df <- data.frame()

for (i in 1:length(xpathSApply(xml, "//message:MessageGroup/def:DataSet/def:Series", namespaces=ns))) {
  location <- xpathSApply(xml, paste0("//message:MessageGroup/def:DataSet/def:Series[",i,"]/def:SeriesKey/def:Value[@concept='LOCATION']/@value"), namespaces=ns)
  transact <- xpathSApply(xml, paste0("//message:MessageGroup/def:DataSet/def:Series[",i,"]/def:SeriesKey/def:Value[@concept='TRANSACT']/@value"), namespaces=ns)
  measure <- xpathSApply(xml, paste0("//message:MessageGroup/def:DataSet/def:Series[",i,"]/def:SeriesKey/def:Value[@concept='MEASURE']/@value"), namespaces=ns)
  
  time <- xpathSApply(xml, paste0("//message:MessageGroup/def:DataSet/def:Series[",i,"]/def:Obs/def:Time"), xmlValue, 
                      namespaces=ns)
  value <- xpathSApply(xml, paste0("//message:MessageGroup/def:DataSet/def:Series[",i,"]/def:Obs/def:ObsValue/@value"), 
                       namespaces=ns)
  
  tmp <- data.frame(location=rep(location, length(time)),
                    transact=rep(transact, length(time)),
                    measure=rep(measure, length(time)),
                    time=time,
                    value=value)
  
  df <- rbind(df, tmp)
}

