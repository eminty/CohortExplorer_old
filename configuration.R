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
shinySettings$sampleSize <- 100

shinySettings$originDate <- as.Date('2020-01-01')

shinySettings$cohortTable <- "cohort"
shinySettings$cohortDatabaseSchema <-
  cdmSource$resultsDatabaseSchema
shinySettings$cdmDatabaseSchema <- cdmSource$cdmDatabaseSchema

shinySettings$conceptSetIds <- c()


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

shinySettings$conceptSets <- c()

if (length(shinySettings$conceptSetIds) > 0) {
  baseUrl <- Sys.getenv("BaseUrl")
  for (i in (1:length(shinySettings$conceptSetIds))) {
    ROhdsiWebApi::authorizeWebApi(baseUrl = baseUrl, authMethod = "windows")
    conceptSetExpression <-
      ROhdsiWebApi::getConceptSetDefinition(conceptSetId = shinySettings$conceptSetIds[[i]], baseUrl = baseUrl)
    conceptSetResolved <- ROhdsiWebApi::resolveConceptSet(conceptSetDefinition = conceptSetExpression, baseUrl = baseUrl)
    
    shinySettings$conceptSets$id <- dplyr::bind_rows(
      dplyr::tibble(
        conceptSetId = shinySettings$conceptSetIds[[i]],
        conceptSetName = conceptSetExpression$name
      ) %>% 
        dplyr::mutate(fullName = paste0(conceptSetId, " ", conceptSetName)),
      shinySettings$conceptSets$expression
    ) %>% 
      dplyr::arrange(conceptSetId)
    
    shinySettings$conceptSets$resolved <- dplyr::bind_rows(
      dplyr::tibble(
        conceptSetId = shinySettings$conceptSetIds[[i]],
        conceptId = conceptSetResolved
      ),
      shinySettings$conceptSets$resolved
    )
  }
}