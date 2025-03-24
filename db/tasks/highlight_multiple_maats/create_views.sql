CREATE VIEW tmp_defendants AS
  SELECT jsonb_array_elements(body->'defendantSummary') AS defendant,
        body->'prosecutionCaseId' AS prosecution_case_id,
        body->'prosecutionCaseReference' AS urn,
        body->'caseStatus' AS case_status
    FROM prosecution_cases;

CREATE VIEW tmp_offences AS
  SELECT jsonb_array_elements(defendant->'offenceSummary') AS offence,
        urn AS urn,
        prosecution_case_id AS prosecution_case_id,
        case_status AS case_status,
        defendant->>'defendantId' as defendant_id,
        defendant->>'defendantASN' as asn
    FROM tmp_defendants;

CREATE VIEW tmp_defendants_with_maats AS
  SELECT offence->'laaApplnReference'->>'applicationReference' AS maat_id,
         offence->'laaApplnReference'->>'statusDescription' AS laa_status,
         urn AS urn,
         prosecution_case_id AS prosecution_case_id,
         case_status AS case_status,
         defendant_id AS defendant_id,
         asn AS asn
    FROM tmp_offences;
