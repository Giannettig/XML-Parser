#Install the libraries
install.packages("purrr")
library(httr)
library(data.table)
library(dplyr)
library(xml2)
library(purrr)

#=======API CALL========#


query1<-"https://www.slevoteka.cz/pro-agregatory/xml/ppc-hit.xml"
query2<-"https://www.slevoteka.cz/pro-agregatory/xml/muj-skrz.xml"

parseXML<-function(endpoint,args=NULL){
  r <- RETRY("GET",endpoint, times=3, query=args)
  
  
  results<-if(r$status_code==200) {
    res<-xml2::as_list(content(r,"parsed",encoding = "UTF-8")) 
    
    listNames<-unique(unlist(map(res,names)))
    
    a<-NULL
    
    for(name in listNames){
      
      a<-cbind(a,map(map(res,name),unlist))
    }
    
    res<-as.data.frame(a)
    names(res)<-listNames
    res
    
  }else {
    stop(paste("API Call n.",call,"failed. status:",content(r)$status, sep=" "),call.=TRUE)}
}

data1<-parseXML(query1)%>% mutate_all( function(x){x<-as.character(x)})
data2<-parseXML(query2)%>% mutate_all( function(x){x<-as.character(x)})

data1<-data1[!duplicated(data1$ID),]
data2<-data2[!duplicated(data2$ID),]

#Providers<-data.table::rbindlist(data2$PROVIDER,fill = TRUE)

###Export the data

write.csv(as.matrix(data1),"out/tables/ppc-hit.csv", row.names=FALSE)
write.csv(as.matrix(data2),"out/tables/muj-skrz.csv", row.names=FALSE)
