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
