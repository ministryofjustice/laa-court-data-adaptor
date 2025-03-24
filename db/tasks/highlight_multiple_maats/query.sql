SELECT string_agg(maat_id, ', '),
       urn,
       prosecution_case_id,
       case_status,
       defendant_id,
       asn,
       laa_status
FROM tmp_defendants_with_maats
GROUP BY urn, prosecution_case_id, case_status, defendant_id, asn, laa_status
HAVING COUNT(distinct maat_id) > 1;
