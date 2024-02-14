{{
    config(
        materialized='incremental',
        unique_key = ['metric_name', 'building_code', 'floor_code', 'space_code', 'timestamp', 'data_source'],
        merge_update_columns = ['in_count', 'out_count', 'created_date']
    )
}}

   SELECT
        CAST(metric AS string) AS metric_name,
        CAST(building AS string) AS building_code,
        CAST(level AS string) AS floor_code,
        CAST(area AS string) AS space_code,
        -- CAST(REGEXP_REPLACE(datetime, r'(\d+)-(\d+)-(\d+) (\d+):(\d+)', r'\3-\2-\1 \4:\5:00') AS timestamp) AS timestamp,
        CAST(date(datetime) AS timestamp) AS timestamp,
        CAST(in_count AS int64) AS in_count,
        CAST(out_count AS int64) AS out_count,
         _airbyte_extracted_at AS created_date,
        'nexpa' AS data_source
    FROM `transformed_events.carpark_area_utilisation`

    {% if is_incremental() %}

    -- this filter will only be applied on an incremental run
    -- (uses > to include records whose timestamp occurred since the last run of this model)
    WHERE _airbyte_extracted_at > (SELECT max(created_date) FROM {{ this }})

    {% endif %}
