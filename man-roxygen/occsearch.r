#' @param taxonKey A taxon key from the GBIF backbone. All included and synonym taxa 
#'    are included in the search, so a search for aves with taxononKey=212 
#'    (i.e. /occurrence/search?taxonKey=212) will match all birds, no matter which 
#'    species. You can pass many keys by passing occ_search in a call to an 
#'    lapply-family function (see last example below).
#' @param scientificName A scientific name from the GBIF backbone. All included and synonym 
#' 	  taxa are included in the search.
#' @param datasetKey The occurrence dataset key (a uuid)
#' @param catalogNumber An identifier of any form assigned by the source within a 
#'    physical collection or digital dataset for the record which may not unique, 
#'    but should be fairly unique in combination with the institution and collection code.
#' @param collectorName The person who recorded the occurrence. 
#' @param collectionCode An identifier of any form assigned by the source to identify 
#'    the physical collection or digital dataset uniquely within the text of an institution.
#' @param institutionCode An identifier of any form assigned by the source to identify 
#'    the institution the record belongs to. Not guaranteed to be que.
#' @param country The 2-letter country code (as per ISO-3166-1) of the country in 
#'    which the occurrence was recorded. See here
#'    \url{http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2}
#' @param basisOfRecord Basis of record, as defined in our BasisOfRecord enum here
#'    \url{http://bit.ly/19kBGhG}. Acceptable values are:
#'    \itemize{
#'      \item FOSSIL_SPECIMEN An occurrence record describing a fossilized specimen.
#'      \item HUMAN_OBSERVATION An occurrence record describing an observation made by 
#'      one or more people.
#'      \item LITERATURE An occurrence record based on literature alone.
#'      \item LIVING_SPECIMEN An occurrence record describing a living specimen, e.g.
#'      \item MACHINE_OBSERVATION An occurrence record describing an observation made 
#'      by a machine.
#'      \item OBSERVATION An occurrence record describing an observation.
#'      \item PRESERVED_SPECIMEN An occurrence record describing a preserved specimen.
#'      \item UNKNOWN Unknown basis for the record.
#'    }
#' @param date Occurrence date in ISO 8601 format: yyyy, yyyy-MM, yyyy-MM-dd, or 
#'    MM-dd.
#' @param year The 4 digit year. A year of 98 will be interpreted as AD 98.
#' @param month The month of the year, starting with 1 for January.
#' @param search Query terms. The value for this parameter can be a simple word or a phrase.
#' @param decimallatitude Latitude in decimals between -90 and 90 based on WGS 84. 
#'    Supports range queries.
#' @param decimalLongitude Longitude in decimals between -180 and 180 based on WGS 84.  
#'    Supports range queries.
#' @param publishingCountry The 2-letter country code (as per ISO-3166-1) of the 
#'    country in which the occurrence was recorded.
#' @param altitude Altitude/elevation in meters above sea level.
#' @param depth Depth in meters relative to altitude. For example 10 meters below a 
#'    lake surface with given altitude.
#' @param geometry Searches for occurrences inside a polygon described in Well Known 
#'    Text (WKT) format. A WKT shape written as either POINT, LINESTRING, LINEARRING 
#'    or POLYGON. Example of a polygon: ((30.1 10.1, 20, 20 40, 40 40, 30.1 10.1))
#'     would be queried as \url{http://bit.ly/HwUSif}.
#' @param spatialIssues Includes/excludes occurrence records which contain spatial 
#'    issues (as determined in our record interpretation), i.e. spatialIssues=TRUE 
#'    returns only those records with spatial issues while spatialIssues=FALSE includes 
#'    only records without spatial issues. The absence of this parameter returns any 
#'    record with or without spatial issues.
#' @param hasCoordinate Return only occurence records with lat/long data (TRUE) or
#'    all records (FALSE, default).
#' @param typeStatus Type status of the specimen. One of many options. See ?typestatus
#' @param recordedNumber Number recorded by collector of the data, different from GBIF record
#'    number. See \url{http://rs.tdwg.org/dwc/terms/#recordNumber} for more info
#' @param lastInterpreted Date the record was last modified in GBIF, in ISO 8601 format: 
#'    yyyy, yyyy-MM, yyyy-MM-dd, or MM-dd. Supports range queries.
#' @param continent Continent. One of 'AFRICA', 'ANTARCTICA', 'ASIA', 'EUROPE' 'NORTH_AMERICA' 
#'    (North America includes the Caribbean and reachies down and includes Panama), 'OCEANIA', 
#'    or 'SOUTH_AMERICA'
#' @param fields (character) Default ('minimal') will return just taxon name, key, latitude, and 
#'    longitute. 'all' returns all fields. Or specify each field you want returned by name, e.g.
#'    fields = c('name','latitude','altitude').
#' @param return One of data, hier, meta, or all. If data, a data.frame with the 
#'    data. hier returns the classifications in a list for each record. meta 
#'    returns the metadata for the entire call. all gives all data back in a list. 
#' @return A data.frame or list
#' @description
#' Note that you can pass in a vector to one of taxonkey, datasetKey, and 
#' catalogNumber parameters in a function call, but not a vector >1 of the three 
#' parameters at the same time
#' 
#' \bold{Hierarchies:} hierarchies are returned wih each occurrence object. There is no
#' option no to return them from the API. However, within the \code{occ_search}
#' function you can select whether to return just hierarchies, just data, all of 
#' data and hiearchies and metadata, or just metadata. If all hierarchies are the 
#' same we just return one for you. 
#' 
#' \bold{Data:} By default only three data fields are returned: name (the species name),
#' decimallatitude, and decimallongitude. Set parameter minimal=FALSE if you want more data.
#' 
#' \bold{Nerds:} You can pass parameters not defined in this function into the call to 
#' the GBIF API to control things about the call itself using the \code{callopts} 
#' function. See an example below that passes in the \code{verbose} function to 
#' get details on the http call.
#' 
#' \bold{Scientific names vs. taxon keys:} In the previous GBIF API and the version of rgbif that wrapped 
#' that API, you could search the equivalent of this function with a species name, which was 
#' convenient. However, names are messy right. So it sorta makes sense to sort out the species 
#' key numbers you want exactly, and then get your occurrence data with this function. GBIF has 
#' added a parameter scientificName to allow searches by scientific names in this function - which 
#' includes synonym taxa.
#' 
#' \bold{WKT:} Examples of valid WKT objects:
#' \itemize{
#'  \item 'POLYGON((30.1 10.1, 10 20, 20 60, 60 60, 30.1 10.1))'
#'  \item 'POINT(30.1 10.1)'
#'  \item 'LINESTRING(3 4,10 50,20 25)'
#'  \item 'LINEARRING' ???' - Not sure how to specify this. Anyone?
#' }
#' 
#' \bold{Range queries:} A range query is as it sounds - you query on a range of values defined by
#' a lower and upper limit. Do a range query by specifying the lower and upper limit in a vector 
#' like \code{depth='50,100'}. It would be more R like to specify the range in a vector like 
#' \code{c(50,100)}, but that sort of syntax allows you to do many searches, one for each element in 
#' the vector - thus range queries have to differ. The following parameters support range queries.
#' \itemize{
#'  \item decimalLatitude
#'  \item decimalLongitude
#'  \item depth
#'  \item elevation
#'  \item eventDate
#'  \item lastInterpreted
#'  \item month
#'  \item year
#' }