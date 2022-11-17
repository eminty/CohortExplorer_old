# # install.packages("tidyverse")
library(tidyverse)
library(dplyr)
library(Hades)
library(keyring)
library(usethis)

#usethis::edit_r_profile()

#cdmSources$database



databaseId <- "truven_mdcd"  

baseUrl = Sys.getenv("baseUrl")

cdmSource <- cdmSources %>%
  dplyr::filter(database == databaseId) %>%
  dplyr::filter(sequence == 1)

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = cdmSource$dbms,
  user = keyring::key_get("OHDSI_USER"),
  password = keyring::key_get("OHDSI_PASSWORD"),
  server = cdmSource$server,
  port = cdmSource$port,
  pathToDriver = pathToDriver
)

#source("connectionDetails.R")
# connectionDetails = connectionDetailsMDCD

shinySettings <- c()

shinySettings$cohortDefinitionId <- 10212
shinySettings$sampleSize <- 20

shinySettings$originDate <- as.Date('2020-01-01')

shinySettings$cohortTable <- "cohort"
shinySettings$cohortDatabaseSchema <-"results_truven_mdcd_v2128"
shinySettings$cdmDatabaseSchema <- "cdm_truven_mdcd_v2128"

shinySettings$conceptSetIds <- c()# inpatient or ER visit


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

baseUrl <- Sys.getenv("BaseUrl")
# #temporary, while rprofile method being fixed:
# baseUrl <- "https://epi.jnj.com:8443/WebAPI"


if (length(shinySettings$conceptSetIds) > 0) {
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


cohortName <- c()


ROhdsiWebApi::authorizeWebApi(baseUrl = baseUrl, authMethod = "windows")

#check for webAPI
#ROhdsiWebApi::getWebApiVersion(baseUrl = baseUrl)

shinySettings$cohortName <-
  ROhdsiWebApi::getCohortDefinition(
    cohortId = shinySettings$cohortDefinitionId %>% as.integer(),
    baseUrl = baseUrl
  )

shinySettings$cohortName <-
  shinySettings$cohortName$name
