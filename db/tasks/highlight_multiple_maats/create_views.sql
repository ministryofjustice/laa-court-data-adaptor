CREATE VIEW tmp_acd_621_defendants AS
  SELECT jsonb_array_elements(body->'defendantSummary') AS defendant,
         body->'prosecutionCaseReference' AS urn
    FROM prosecution_cases;

CREATE VIEW tmp_acd_621_offences AS
  SELECT jsonb_array_elements(defendant->'offenceSummary') AS offence,
         urn AS urn,
         defendant->>'defendantId' as defendant_id
    FROM tmp_acd_621_defendants;

CREATE VIEW tmp_acd_621_defendants_with_maats AS
  SELECT (CASE WHEN offence->'laaApplnReference'->>'applicationReference' IS NULL
          THEN '<none>'
          ELSE offence->'laaApplnReference'->>'applicationReference' END) AS returned_maat_ids,
         urn AS urn,
         defendant_id AS defendant_id
    FROM tmp_acd_621_offences;

CREATE VIEW tmp_acd_621_defendants_with_multiple_maats AS
  SELECT urn,
         tmp_acd_621_defendants_with_maats.defendant_id,
         laa_references.maat_reference AS actual_maat_id,
         string_agg(returned_maat_ids, ',') AS returned_ids
    FROM tmp_acd_621_defendants_with_maats
    LEFT JOIN laa_references
      ON (laa_references.defendant_id)::text = tmp_acd_621_defendants_with_maats.defendant_id
      AND linked = true
    GROUP BY urn, tmp_acd_621_defendants_with_maats.defendant_id, actual_maat_id
    HAVING COUNT(distinct returned_maat_ids) > 1;
