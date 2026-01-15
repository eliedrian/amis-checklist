INSERT INTO silver.Enlistments (
    student_number,
    offering_id
)
SELECT
    json_extract(e.student_enlistment, '$.student_id') AS student_number,
    o.id AS offering_id
FROM bronze.Enlistments e
JOIN silver.Offerings o
ON o.raw_class_id = e.class_id
