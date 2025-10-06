-- Create database
CREATE DATABASE medicare_analysis;

-- Connect to the database
\c medicare_analysis;

-- Create table
CREATE TABLE medicare_data (
    type_of_entitlement VARCHAR(100),
    calendar_year INT,
    total_original_medicare_part_a_enrollees BIGINT,
    total_persons_with_utilization BIGINT,
    total_discharges BIGINT,
    discharges_per_1000_original_medicare_part_a_enrollees DECIMAL(10,2),
    discharges_per_1000_persons_with_utilization DECIMAL(10,2),
    total_days_of_care BIGINT,
    total_days_of_care_per_1000_original_medicare_part_a_enrollees DECIMAL(10,2),
    total_days_of_care_per_person_with_utilization DECIMAL(10,2),
    total_days_of_care_per_discharge DECIMAL(10,2),
    covered_days_of_care BIGINT,
    covered_days_of_care_per_1000_original_medicare_part_a_enrollees DECIMAL(10,2),
    covered_days_of_care_per_person_with_utilization DECIMAL(10,2),
    covered_days_of_care_per_discharge DECIMAL(10,2),
    total_program_payments DECIMAL(18,2),
    program_payments_per_original_medicare_part_a_enrollee DECIMAL(18,2),
    program_payments_per_person_with_utilization DECIMAL(18,2),
    program_payments_per_discharge DECIMAL(18,2),
    program_payments_per_covered_day DECIMAL(18,2),
    persons_with_coinsurance BIGINT,
    total_coinsurance_days BIGINT,
    coinsurance_days_per_person_with_coinsurance DECIMAL(10,2),
    total_coinsurance_payments DECIMAL(18,2),
    coinsurance_payments_per_person_with_coinsurance DECIMAL(18,2),
    total_deductible_payments DECIMAL(18,2),
    total_lifetime_reserve_days BIGINT,
    persons_with_lifetime_reserve_days BIGINT,
    discharged_dead BIGINT
);

-- Load data (assuming CSV format)
-- Adjust path to your CSV file
COPY medicare_data
FROM '/path/to/your/medicare_data.csv'
DELIMITER ','
CSV HEADER;

-- Quick data inspection
SELECT * FROM medicare_data LIMIT 10;

-- Analytical queries

-- Total enrollees and utilization
SELECT 
    calendar_year,
    SUM(total_original_medicare_part_a_enrollees) AS total_enrollees,
    SUM(total_persons_with_utilization) AS total_utilized,
    ROUND(SUM(total_persons_with_utilization)::DECIMAL / SUM(total_original_medicare_part_a_enrollees) * 100,2) AS utilization_percentage
FROM medicare_data
GROUP BY calendar_year
ORDER BY calendar_year;

-- Discharges analysis
SELECT 
    calendar_year,
    SUM(total_discharges) AS total_discharges,
    ROUND(SUM(total_discharges)::DECIMAL / SUM(total_persons_with_utilization) * 1000,2) AS discharges_per_1000_utilized,
    ROUND(SUM(total_discharges)::DECIMAL / SUM(total_original_medicare_part_a_enrollees) * 1000,2) AS discharges_per_1000_enrollees
FROM medicare_data
GROUP BY calendar_year
ORDER BY calendar_year;

-- Days of care summary
SELECT 
    calendar_year,
    SUM(total_days_of_care) AS total_days_of_care,
    ROUND(SUM(total_days_of_care)::DECIMAL / SUM(total_persons_with_utilization),2) AS avg_days_per_person,
    ROUND(SUM(total_days_of_care)::DECIMAL / SUM(total_discharges),2) AS avg_days_per_discharge,
    SUM(covered_days_of_care) AS total_covered_days,
    ROUND(SUM(covered_days_of_care)::DECIMAL / SUM(total_discharges),2) AS avg_covered_days_per_discharge
FROM medicare_data
GROUP BY calendar_year
ORDER BY calendar_year;

-- Payments analysis
SELECT
    calendar_year,
    SUM(total_program_payments) AS total_program_payments,
    ROUND(SUM(total_program_payments)::DECIMAL / SUM(total_original_medicare_part_a_enrollees),2) AS payments_per_enrollee,
    ROUND(SUM(total_program_payments)::DECIMAL / SUM(total_persons_with_utilization),2) AS payments_per_utilized_person,
    ROUND(SUM(total_program_payments)::DECIMAL / SUM(total_discharges),2) AS payments_per_discharge,
    ROUND(SUM(total_program_payments)::DECIMAL / SUM(covered_days_of_care),2) AS payments_per_covered_day
FROM medicare_data
GROUP BY calendar_year
ORDER BY calendar_year;

-- Coinsurance & deductibles
SELECT
    calendar_year,
    SUM(persons_with_coinsurance) AS total_persons_with_coinsurance,
    SUM(total_coinsurance_days) AS total_coinsurance_days,
    ROUND(SUM(total_coinsurance_days)::DECIMAL / NULLIF(SUM(persons_with_coinsurance),0),2) AS avg_coinsurance_days_per_person,
    SUM(total_coinsurance_payments) AS total_coinsurance_payments,
    ROUND(SUM(total_coinsurance_payments)::DECIMAL / NULLIF(SUM(persons_with_coinsurance),0),2) AS coinsurance_payment_per_person,
    SUM(total_deductible_payments) AS total_deductible_payments
FROM medicare_data
GROUP BY calendar_year
ORDER BY calendar_year;

-- Lifetime reserve and mortality
SELECT
    calendar_year,
    SUM(total_lifetime_reserve_days) AS total_lifetime_reserve_days,
    SUM(persons_with_lifetime_reserve_days) AS total_persons_with_lifetime_reserve_days,
    SUM(discharged_dead) AS total_discharged_dead
FROM medicare_data
GROUP BY calendar_year
ORDER BY calendar_year;

