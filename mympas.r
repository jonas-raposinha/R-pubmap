#Creates coordinates from Place info in pub.doi to make a Google Mymap of publication entries

library(RISmed)

pub.doi <- read.table("2018DOI.txt", header = FALSE, sep = "|", stringsAsFactors=F, col.names = "DOI")

nrecs <- nrow(pub.doi)
country.list <- vector("character", nrow(pub.doi))
aff.list <- vector("character", nrow(pub.doi))

for(k in 1:nrecs){ 
  test <- try(EUtilsSummary(pub.doi$DOI[k], type='esearch', db='pubmed')) #Gets record from pubmed database by DOI
  while(class(test) == "try-error"){
    test <- try(EUtilsSummary(pub.doi$DOI[k], type='esearch', db='pubmed')) # Protects loop against Error in file(con, "r") : cannot open the connection
    print("Connection error. Retrying.")
  }
  pubmed.res <- test
  recs <- EUtilsGet(pubmed.res) #Extracts info from record by field
  if(length(ArticleTitle(recs))>0){
    title.list[k] <- ArticleTitle(recs)
  }
}

countries <- read.table("countries.csv", header=F, dec=".", sep=";", quote="\"")

doi <- c()
long <- c()
lat <- c()

for(k in 1:nrow(countries)){
  c.count <- grep(countries$name[k], pub.doi$title, ignore.case = T) #Finds the country
  if(length(c.count) > 0){
    doi <- c(doi, as.character(pub.doi$DOI[c.count]))
    long <- c(long, rep(countries$longitude[k], length(c.count)))
    lat <- c(lat, rep(countries$latitude[k], length(c.count)))
    print(as.character(countries$name[k]))
  }
}

mymaps.frame <- data.frame(matrix(ncol=3))
colnames(mymaps.frame) = c("DOI", "long", "lat")

for(k in 1:length(doi)){
  mymaps.frame$DOI[k] <- sprintf("http://dx.doi.org/%s", doi[k])
  mymaps.frame$long[k] <- long[k] + runif(1, -0.5, 0.5) #Creates preudolocation by adding random scatter
  mymaps.frame$lat[k] <- lat[k] + runif(1, -0.15, 0.15) #Creates preudolocation by adding random scatter
}
write.csv(mymaps.frame, "mymaps.csv", row.names = F)
