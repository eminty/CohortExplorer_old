databaseId <- 'optum_extended_dod'

cdmSource <- cdmSources %>%
  dplyr::filter(database == databaseId) %>%
  dplyr::filter(sequence == 1)

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = cdmSource$dbms,
  user = keyring::key_get("OHDSI_USER"),
  password = keyring::key_get("OHDSI_PASSWORD"),
  server = cdmSource$server,
  port = cdmSource$port
)

shinySettings <- c()

shinySettings$cohortDefinitionId <- "9537"
shinySettings$sampleSize <- 1

shinySettings$cohortTable <- "cohort"
shinySettings$cohortDatabaseSchema <-
  cdmSource$resultsDatabaseSchema
shinySettings$cdmDatabaseSchema <- cdmSource$cdmDatabaseSchema


if (is.null(shinySettings$vocabularyDatabaseSchema)) {
  shinySettings$vocabularyDatabaseSchema <-
    shinySettings$cdmDatabaseSchema
}

if (is.null(shinySettings$tempEmulationSchema)) {
  shinySettings$tempEmulationSchema <- NULL
}

if (is.null(shinySettings$subjectIds)) {
  shinySettings$subjectIds <- NULL
}


