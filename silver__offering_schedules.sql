INSERT INTO silver.OfferingSchedules (
    offering_id,
    day,
    start_time,
    end_time
)
WITH classes AS (
    SELECT
        cl.id as raw_class_id,
        co.id AS course_id,
        class_dates AS dates,
        row_number() over () AS class_sequence
    FROM bronze.Classes cl
    JOIN silver.Courses co
      ON cl.course_id = co.raw_course_id
),
expanded_dates_array AS (
    SELECT
        class_sequence,
        value,
        row_number() over () AS dates_sequence
    FROM classes
    JOIN json_each(classes.dates)
),
expanded_dates AS (
    SELECT
        class_sequence,
        dates_sequence,
        key,
        j.value
    FROM expanded_dates_array ar
    JOIN json_each(ar.value) j
),
days AS (
    SELECT
        class_sequence,
        dates_sequence,
        key AS day
    FROM expanded_dates
    WHERE key IN ('mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun')
    AND value = 1
),
start_times AS (
    SELECT
        dates_sequence,
        value AS start_time
    FROM expanded_dates
    WHERE key = 'start_time'
),
end_times AS (
    SELECT
        dates_sequence,
        value AS end_time
    FROM expanded_dates
    WHERE key = 'end_time'
),
time_blocks AS (
    SELECT
        day,
        start_time,
        end_time,
        d.class_sequence AS class_sequence
    FROM days d
    JOIN start_times s
      ON d.dates_sequence = s.dates_sequence
    JOIN end_times e
      ON d.dates_sequence = e.dates_sequence
),
time_blocks_by_course AS (
    SELECT
        c.course_id AS course_id,
        day,
        start_time,
        end_time,
        raw_class_id
    FROM classes c
    JOIN time_blocks t
      ON c.class_sequence = t.class_sequence
),
final AS (
    SELECT
        o.id AS offering_id,
        day,
        start_time,
        end_time
    FROM time_blocks_by_course t
    JOIN silver.Offerings o
      ON t.raw_class_id = o.raw_class_id
)
SELECT
*
FROM final
