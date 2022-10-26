
writeLines("Getting cohort table.")
cohort <-
  DatabaseConnector::renderTranslateQuerySql(
    connection = connection,
    sql = "SELECT subject_id,
          	cohort_start_date,
          	cohort_end_date
          FROM @cohort_database_schema.@cohort_table
          WHERE cohort_definition_id = @cohort_definition_id
          	AND subject_id IN (@subject_ids)
          ORDER BY subject_id, cohort_start_date;",
    cohort_database_schema = shinySettings$cohortDatabaseSchema,
    cohort_table = shinySettings$cohortTable,
    cohort_definition_id = shinySettings$cohortDefinitionId,
    subject_ids = shinySettings$subjectIds,
    snakeCaseToCamelCase = TRUE
  ) %>%
  dplyr::tibble() %>%
  dplyr::arrange(subjectId, cohortStartDate)

shinySettings$subjectIdsFound <- unique(cohort$subjectId)

if (nrow(cohort) == 0) {
  stop("Cohort does not have the selected subject ids")
}

writeLines("Getting person table.")
person <- DatabaseConnector::renderTranslateQuerySql(
  connection = connection,
  sql = "SELECT person_id,
                gender_concept_id,
                year_of_birth
        FROM @cdm_database_schema.person
        WHERE person_id IN (@subject_ids)
        ORDER BY person_id;",
  cdm_database_schema = shinySettings$cdmDatabaseSchema,
  subject_ids = shinySettings$subjectIds,
  snakeCaseToCamelCase = TRUE
) %>%
  dplyr::tibble()

writeLines("Getting observation period table.")
observationPeriod <- DatabaseConnector::renderTranslateQuerySql(
  connection = connection,
  sql = "SELECT person_id, observation_period_start_date, observation_period_end_date, period_type_concept_id
        FROM @cdm_database_schema.observation_period
        WHERE person_id IN (@subject_ids)
        ORDER BY person_id,
                observation_period_start_date,
                observation_period_end_date;",
  cdm_database_schema = shinySettings$cdmDatabaseSchema,
  subject_ids = shinySettings$subjectIds,
  snakeCaseToCamelCase = TRUE
) %>%
  dplyr::tibble()

writeLines("Getting visit occurrence table.")
visitOccurrence <-  DatabaseConnector::renderTranslateQuerySql(
  connection = connection,
  sql = "SELECT person_id,
              visit_start_date AS start_date,
              visit_end_date AS end_date,
              visit_concept_id AS concept_id,
          	  visit_type_concept_id AS type_concept_id,
          	  count(*) records
        FROM @cdm_database_schema.visit_occurrence
        WHERE person_id IN (@subject_ids)
        GROUP BY person_id,
                  visit_start_date,
                  visit_end_date,
                  visit_concept_id,
                  visit_type_concept_id
        ORDER BY person_id,
                visit_start_date,
                visit_end_date;",
  cdm_database_schema = shinySettings$cdmDatabaseSchema,
  subject_ids = shinySettings$subjectIds,
  snakeCaseToCamelCase = TRUE
) %>%
  dplyr::tibble()

writeLines("Getting condition occurrence table.")
conditionOccurrence <-  DatabaseConnector::renderTranslateQuerySql(
  connection = connection,
  sql = "SELECT person_id,
              condition_start_date AS start_date,
              condition_end_date AS end_date,
              condition_concept_id AS concept_id,
          	  condition_type_concept_id AS type_concept_id,
          	  count(*) records
        FROM @cdm_database_schema.condition_occurrence
        WHERE person_id IN (@subject_ids)
        GROUP BY person_id,
                  condition_start_date,
                  condition_end_date,
                  condition_concept_id,
                  condition_type_concept_id
        ORDER BY person_id,
                condition_start_date,
                condition_end_date;",
  cdm_database_schema = shinySettings$cdmDatabaseSchema,
  subject_ids = shinySettings$subjectIds,
  snakeCaseToCamelCase = TRUE
) %>%
  dplyr::tibble()

writeLines("Getting condition era table.")
conditionEra <-  DatabaseConnector::renderTranslateQuerySql(
  connection = connection,
  sql = "SELECT person_id,
              condition_era_start_date AS start_date,
              condition_era_end_date AS end_date,
              condition_concept_id AS concept_id,
          	  count(*) records
        FROM @cdm_database_schema.condition_era
        WHERE person_id IN (@subject_ids)
        GROUP BY person_id,
              condition_era_start_date,
              condition_era_end_date,
              condition_concept_id;",
  cdm_database_schema = shinySettings$cdmDatabaseSchema,
  subject_ids = shinySettings$subjectIds,
  snakeCaseToCamelCase = TRUE
) %>%
  dplyr::tibble() %>% 
  dplyr::mutate(typeConceptId = 0, records = 1)

writeLines("Getting observation table.")
observation <-  DatabaseConnector::renderTranslateQuerySql(
  connection = connection,
  sql = "SELECT person_id,
              observation_date AS start_date,
              observation_concept_id AS concept_id,
          	  observation_type_concept_id AS type_concept_id,
          	  count(*) records
        FROM @cdm_database_schema.observation
        WHERE person_id IN (@subject_ids)
        GROUP BY person_id,
                  observation_date,
                  observation_concept_id,
                  observation_type_concept_id
        ORDER BY person_id,
                observation_date,
                observation_concept_id,
                observation_type_concept_id;",
  cdm_database_schema = shinySettings$cdmDatabaseSchema,
  subject_ids = shinySettings$subjectIds,
  snakeCaseToCamelCase = TRUE
) %>%
  dplyr::tibble()

writeLines("Getting procedure occurrence table.")
procedureOccurrence <-  DatabaseConnector::renderTranslateQuerySql(
  connection = connection,
  sql = "SELECT person_id,
              procedure_date AS start_date,
              procedure_concept_id AS concept_id,
              procedure_type_concept_id AS type_concept_id,
          	  count(*) records
        FROM @cdm_database_schema.procedure_occurrence
        WHERE person_id IN (@subject_ids)
        GROUP BY person_id,
                  procedure_date,
                  procedure_concept_id,
                  procedure_type_concept_id
        ORDER BY person_id,
                procedure_date,
                procedure_concept_id,
                procedure_type_concept_id;",
  cdm_database_schema = shinySettings$cdmDatabaseSchema,
  subject_ids = shinySettings$subjectIds,
  snakeCaseToCamelCase = TRUE
) %>%
  dplyr::tibble() %>% 
  dplyr::mutate(endDate = startDate)

writeLines("Getting drug exposure table.")
drugExposure <-  DatabaseConnector::renderTranslateQuerySql(
  connection = connection,
  sql = "SELECT person_id,
              drug_exposure_start_date AS start_date,
              drug_exposure_end_date AS end_date,
              drug_concept_id AS concept_id,
              drug_type_concept_id AS type_concept_id,
          	  count(*) records
        FROM @cdm_database_schema.drug_exposure
        WHERE person_id IN (@subject_ids)
        GROUP BY person_id,
                  drug_exposure_start_date,
                  drug_exposure_end_date,
                  drug_concept_id,
                  drug_type_concept_id
        ORDER BY person_id,
                  drug_exposure_start_date,
                  drug_exposure_end_date,
                  drug_concept_id,
                  drug_type_concept_id;",
  cdm_database_schema = shinySettings$cdmDatabaseSchema,
  subject_ids = shinySettings$subjectIds,
  snakeCaseToCamelCase = TRUE
) %>%
  dplyr::tibble()

writeLines("Getting drug era table.")
drugEra <-  DatabaseConnector::renderTranslateQuerySql(
  connection = connection,
  sql = "SELECT person_id,
              drug_era_start_date AS start_date,
              drug_era_end_date AS end_date,
              drug_concept_id AS concept_id,
          	  count(*) records
        FROM @cdm_database_schema.drug_era
        WHERE person_id IN (@subject_ids)
        GROUP BY person_id,
                  drug_era_start_date,
                  drug_era_end_date,
                  drug_concept_id
        ORDER BY person_id,
                  drug_era_start_date,
                  drug_era_end_date,
                  drug_concept_id;",
  cdm_database_schema = shinySettings$cdmDatabaseSchema,
  subject_ids = shinySettings$subjectIds,
  snakeCaseToCamelCase = TRUE
) %>%
  dplyr::tibble() %>% 
  dplyr::mutate(typeConceptId = 0)

writeLines("Getting measurement table.")
measurement <-  DatabaseConnector::renderTranslateQuerySql(
  connection = connection,
  sql = "SELECT person_id,
              measurement_date AS start_date,
              measurement_concept_id AS concept_id,
              measurement_type_concept_id as type_concept_id,
          	  count(*) records
        FROM @cdm_database_schema.measurement
        WHERE person_id IN (@subject_ids)
        GROUP BY person_id,
                  measurement_date,
                  measurement_concept_id,
                  measurement_type_concept_id
        ORDER BY person_id,
                  measurement_date,
                  measurement_concept_id,
                  measurement_type_concept_id;",
  cdm_database_schema = shinySettings$cdmDatabaseSchema,
  subject_ids = shinySettings$subjectIds,
  snakeCaseToCamelCase = TRUE
) %>%
  dplyr::tibble() %>% 
  dplyr::mutate(endDate = startDate)


writeLines("Getting concept id.")
conceptIds <- DatabaseConnector::renderTranslateQuerySql(
  connection = connection,
  sql = "WITH concepts as
        (
          SELECT DISTINCT gender_concept_id AS CONCEPT_ID
          FROM @cdm_database_schema.person
          WHERE person_id IN (@subject_ids)

          UNION

          SELECT DISTINCT period_type_concept_id AS CONCEPT_ID
          FROM @cdm_database_schema.observation_period
          WHERE person_id IN (@subject_ids)

          UNION

          SELECT DISTINCT observation_concept_id AS CONCEPT_ID
          FROM @cdm_database_schema.observation
          WHERE person_id IN (@subject_ids)

          UNION

          SELECT DISTINCT observation_type_concept_id AS CONCEPT_ID
          FROM @cdm_database_schema.observation
          WHERE person_id IN (@subject_ids)

          UNION

          SELECT DISTINCT drug_concept_id AS concept_id
          FROM @cdm_database_schema.drug_exposure
          WHERE person_id IN (@subject_ids)

          UNION

          SELECT DISTINCT drug_type_concept_id AS concept_id
          FROM @cdm_database_schema.drug_exposure
          WHERE person_id IN (@subject_ids)

          UNION

          SELECT DISTINCT drug_concept_id AS concept_id
          FROM @cdm_database_schema.drug_era
          WHERE person_id IN (@subject_ids)

          UNION

          SELECT DISTINCT visit_concept_id AS concept_id
          FROM @cdm_database_schema.visit_occurrence
          WHERE person_id IN (@subject_ids)

          UNION

          SELECT DISTINCT visit_type_concept_id AS concept_id
          FROM @cdm_database_schema.visit_occurrence
          WHERE person_id IN (@subject_ids)

          UNION

          SELECT DISTINCT procedure_concept_id AS concept_id
          FROM @cdm_database_schema.procedure_occurrence
          WHERE person_id IN (@subject_ids)

          UNION

          SELECT DISTINCT procedure_type_concept_id AS concept_id
          FROM @cdm_database_schema.procedure_occurrence
          WHERE person_id IN (@subject_ids)

          UNION

          SELECT DISTINCT condition_concept_id AS concept_id
          FROM @cdm_database_schema.condition_occurrence
          WHERE person_id IN (@subject_ids)

          UNION

          SELECT DISTINCT condition_type_concept_id AS concept_id
          FROM @cdm_database_schema.condition_occurrence
          WHERE person_id IN (@subject_ids)

          UNION

          SELECT DISTINCT condition_concept_id AS concept_id
          FROM @cdm_database_schema.condition_era
          WHERE person_id IN (@subject_ids)

          UNION

          SELECT DISTINCT measurement_concept_id AS concept_id
          FROM @cdm_database_schema.measurement
          WHERE person_id IN (@subject_ids)

          UNION

          SELECT DISTINCT measurement_type_concept_id AS concept_id
          FROM @cdm_database_schema.measurement
          WHERE person_id IN (@subject_ids)
        )
        SELECT DISTINCT c.concept_id,
                c.domain_id,
                c.concept_name
        FROM @vocabulary_database_schema.concept c
        INNER JOIN
            concepts c2
        ON c.concept_id = c2.concept_id
        ORDER BY c.concept_id;",
  cdm_database_schema = shinySettings$cdmDatabaseSchema,
  vocabulary_database_schema = shinySettings$vocabularyDatabaseSchema,
  subject_ids = shinySettings$subjectIds, 
  snakeCaseToCamelCase = TRUE
) %>%
  dplyr::tibble()
