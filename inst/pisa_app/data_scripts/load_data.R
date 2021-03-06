library(jsonlite)
library(httr)

## id the years based on current date
year_current <- as.numeric(format(Sys.Date(), "%Y"))
year_prev <- year_current - 1
year_prev_2 <- year_current -2

## load credentials from environment
cred <- readRDS("./data_scripts/token.RDS")
username <- cred$username
password <- cred$password

# username <- 'preview'#cred$username
# password <- 'preview' #cred$password

## call web service for current year
call <- paste0("http://apps.who.int/gho/athena/flumart/MEASURE/IMPACT,IMPACT_CL,IMPACT_COM,TRANSMISSION,TRANSMISSION_CL,TRANSMISSION_COM,SERIOUSNESS,SERIOUSNESS_CL,SERIOUSNESS_COM?filter=PISA/YEAR:",
               year_current,
               "&format=json&profile=pisa")

get_data <- GET(call, authenticate(username, password, type = "basic"))

get_text <- content(get_data, "text")

get_json <- fromJSON(get_text)

df <- get_json

## call web service for previous year
call <- paste0("http://apps.who.int/gho/athena/flumart/MEASURE/IMPACT,IMPACT_CL,IMPACT_COM,TRANSMISSION,TRANSMISSION_CL,TRANSMISSION_COM,SERIOUSNESS,SERIOUSNESS_CL,SERIOUSNESS_COM?filter=PISA/YEAR:",
               year_prev,
               "&format=json&profile=pisa")
get_data <- GET(call, authenticate(username, password, type = "basic"))

get_text <- content(get_data, "text")

get_json <- fromJSON(get_text)

df <- rbind(df, get_json)

## call web service for two years prior
# call <- paste0("http://apps.who.int/gho/athena/flumart/MEASURE/IMPACT,IMPACT_CL,IMPACT_COM,TRANSMISSION,TRANSMISSION_CL,TRANSMISSION_COM,SERIOUSNESS,SERIOUSNESS_CL,SERIOUSNESS_COM?filter=PISA/YEAR:",
#                year_prev_2,
#                "&format=json&profile=pisa")
# get_data <- GET(call, authenticate(username, password, type = "basic"))
#
# get_text <- content(get_data, "text")
#
# get_json <- fromJSON(get_text)
#
# df <- rbind(df, get_json)

# remove text from dates
df$ISOYW <- gsub("Week ", "", df$ISOYW)
df$ISO_YW <- gsub("Week ", "", df$ISO_YW)

## shorten US and UK names in data
df$COUNTRY_TITLE <- gsub("^((\\w+\\W+){1}\\w+).*$","\\1", df$COUNTRY_TITLE)

##impute iso2 code for United Kingdom
df$ISO2 <- ifelse(df$COUNTRY_TITLE == "United Kingdom", "GB", df$ISO2)

## impute Not Reported for all measures
df$TRANSMISSION[nchar(df$TRANSMISSION) == 0] <- "Not Available"
df$TRANSMISSION_CL[nchar(df$TRANSMISSION_CL) == 0] <- "Not Available"
df$TRANSMISSION_COM[nchar(df$TRANSMISSION_COM) == 0] <- "Not Available"
########Changes into the sentence cases############
df$TRANSMISSION=gsub("([[:alpha:]])([[:alpha:]]+)", "\\U\\1\\L\\2", df$TRANSMISSION, perl=TRUE)
df$TRANSMISSION_CL=gsub("([[:alpha:]])([[:alpha:]]+)", "\\U\\1\\L\\2", df$TRANSMISSION_CL, perl=TRUE)
##########

df$SERIOUSNESS[nchar(df$SERIOUSNESS) == 0] <- "Not Available"
df$SERIOUSNESS_CL[nchar(df$SERIOUSNESS_CL) == 0] <- "Not Available"
df$SERIOUSNESS_COM[nchar(df$SERIOUSNESS_COM) == 0] <- "Not Available"
########Changes into the sentence cases############
df$SERIOUSNESS=gsub("([[:alpha:]])([[:alpha:]]+)", "\\U\\1\\L\\2", df$SERIOUSNESS, perl=TRUE)
df$SERIOUSNESS_CL=gsub("([[:alpha:]])([[:alpha:]]+)", "\\U\\1\\L\\2", df$SERIOUSNESS_CL, perl=TRUE)
##########

df$IMPACT[nchar(df$IMPACT) == 0] <- "Not Available"
df$IMPACT_CL[nchar(df$IMPACT_CL) == 0] <- "Not Available"
df$IMPACT_COM[nchar(df$IMPACT_COM) == 0] <- "Not Available"
########Changes into the sentence cases############
df$IMPACT=gsub("([[:alpha:]])([[:alpha:]]+)", "\\U\\1\\L\\2", df$IMPACT, perl=TRUE)
df$IMPACT_CL=gsub("([[:alpha:]])([[:alpha:]]+)", "\\U\\1\\L\\2", df$IMPACT_CL, perl=TRUE)
##########

## create UI data
year_ui <- sort(unique(df$ISO_YEAR[nchar(df$ISO_YEAR) == 4])) #Incorrect Year in data

levels_ui <- c("Below Seasonal Threshold", "Low", "Moderate", "High", "Extra-ordinary", "Not Available", "No Impact") #inconsistent spellings in data

confidence_ui <- c("Low", "Medium", "High", "Not Available") # insconsistent spellings in data

who_region_ui <- c("Region of the Americas"="AMR",
                   "European Region" = "EUR",
                   "Western Pacific Region" = "WPR",
                   "African Region"= "AFR",
                   "Eastern Mediterranean Region" = "EMR",
                   "South-East Asia Region" = "SEAR")
who_region_ui <- sort(who_region_ui)
