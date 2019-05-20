# R-pubmap
Extraction of geographic data from publication records

R is great for creating, manipulating and visualizing databases. One very useful type of database that I often come across is collections of scientific publications. I say “very useful”, since there is a lot of interesting data to be gathered from these collections, although it often takes a bit of work to extract it.
Here I will start with a list of scientific publications on the topic of antimicrobial resistance, collected over 6 months for a biweekly newsletter that I was compiling. The publications are represented here by Digital Object Identifiers (DOI), which are unique identifying codes assigned to each article when published. 

```R
pub.doi <- read.table("2018DOI.txt", header = FALSE, sep = "|", stringsAsFactors=F, col.names = "DOI")
head(pub.doi)
>   DOI
> 1 10.1136/bmjopen-2017-019479
> 2 10.1136/sextrans-2017-053273
> 3 10.1542/peds.2017-3068
> 4 10.1093/jpids/piy018
> 5 10.3201/eid2403.171362
> 6 10.1093/jac/dkx438
```

The DOIs do not contain much info on their own though, so we need to use them to extract what we need from the online records. This is easily done using the package RISmed. Let’s download the first record in the list from the PubMed database and query it to see how the process works. 

```R
library(RISmed)

test.search <- EUtilsSummary(pub.doi$DOI[1], type='esearch', db='pubmed')
test.recs <- EUtilsGet(test.search)
ArticleTitle(test.recs)
> [1] "7-day compared with 10-day antibiotic treatment for febrile urinary tract infections in children: protocol of a randomised controlled trial."
```

Sometimes when my internet connection isn’t very stable, searching the online database fails. If this is not a problem for you, just ignore this section. Connection errors are quite annoying when the call is built into a loop that takes about a tea break to complete for a decently sized list of publications. To protect the loop from this eventuality, we can use the very handy try() call, which allows the call to fail, turning the output into class “try-error”. To implement it, we can do something like this:

```R
test <- try(EUtilsSummary(pub.doi$DOI[k], type='esearch', db='pubmed'))
  while(class(test) == "try-error"){
    test <- try(EUtilsSummary(pub.doi$DOI[k], type='esearch', db='pubmed'))
    print("Connection error. Retrying.")
  }
```

Let’s put the search loop together with the queries to add some interesting data to the original list of DOIs. For the purpose of this exercise, I will try to extract some geographic information from the records. If we, for example, are interested in where the studies are performed, we could identify records that mention a country in the title (or abstract, which would be analogous). We then need to query the records for ArticleTitle.

```R
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
```

To extract country names from the titles we first need a list of countries along with their coordinates, such as this data set from [Google Dev](https://developers.google.com/public-data/docs/canonical/countries_csv). 

```R
countries <- read.table("countries.csv", header=F, dec=".", sep=";", quote="\"")
```

Then we need to search the title column for each country name and save the coordinates for each match. Just for fun I print out the countries found.

```R
doi <- c()
long <- c()
lat <- c()

for(k in 1:nrow(countries)){
  c.count <- grep(countries$name[k], pub.doi$title, ignore.case = T)
  if(length(c.count) > 0){
    doi <- c(doi, as.character(pub.doi$DOI[c.count]))
    long <- c(long, rep(countries$longitude[k], length(c.count)))
    lat <- c(lat, rep(countries$latitude[k], length(c.count)))
    print(as.character(countries$name[k]))
  }
}
```

So then we need to put it all together. Geographic data is often best visualized using maps, but as an alternative to the approaches I showed [here](https://github.com/jonas-raposinha/R-map-plotting) and [here](https://github.com/jonas-raposinha/R-map-api-data), I will just export the location data and make an interactive map using Google MyMaps. A nice thing about DOIs is that they also work as web links to the online version of the publication, via the [International DOI Foundation](http://dx.doi.org/). This allows us to mark the location of each publication with a link to the actual publication. However, if we have more than one data point per country, they will stack on top of each other and not be very easy tell apart. This can be easily fixed with some pseudolocation scattering though.

```R
mymaps.frame <- data.frame(matrix(ncol=3))
colnames(mymaps.frame) = c("DOI", "long", "lat")

for(k in 1:length(doi)){
  mymaps.frame$DOI[k] <- sprintf("http://dx.doi.org/%s", doi[k])
  mymaps.frame$long[k] <- long[k] + runif(1, -0.5, 0.5) #Creates preudolocation by adding random scatter
  mymaps.frame$lat[k] <- lat[k] + runif(1, -0.15, 0.15)
}
write.csv(mymaps.frame, "mymaps.csv", row.names = F)
```

And here is the resulting map:

<a href="https://www.google.com/maps/d/embed?mid=1z0mtNo6B1ZDgp1Gm1UgQEFLWr3LVrrF9" target="_blank"><img src="https://github.com/jonas-raposinha/R-pubmap/blob/master/mapshot.png" alt="IMAGE ALT TEXT HERE" width="648" height="372" border="10" /></a>
