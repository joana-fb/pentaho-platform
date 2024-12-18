--Begin--
-- note: this script assumes pg_hba.conf is configured correctly
--

\connect postgres postgres
--Create pentaho_user if it does not exist
DO
$do$
BEGIN
    IF EXISTS (
        SELECT FROM pg_catalog.pg_roles
        WHERE  rolname = 'pentaho_user') THEN

      RAISE NOTICE 'Role "pentaho_user" already exists. Skipping.';
    ELSE
      CREATE ROLE pentaho_user LOGIN PASSWORD 'password';
    END IF;
END
$do$;

-- create quartz database if it does not exist
SELECT 'CREATE DATABASE quartz WITH OWNER = pentaho_user ENCODING = ''UTF8'' TABLESPACE = pg_default;'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'quartz')\gexec
GRANT ALL ON DATABASE quartz to pentaho_user;
-- Next psql line will prompt for quartz password.  There is no way to specify it without knowing the hostname

--End--
--Begin Connect--
\connect quartz pentaho_user
-- We are now logged into the quartz database as pentaho_user
begin;

DROP TABLE IF EXISTS QRTZ6_FIRED_TRIGGERS;
DROP TABLE IF EXISTS QRTZ6_PAUSED_TRIGGER_GRPS;
DROP TABLE IF EXISTS QRTZ6_SCHEDULER_STATE;
DROP TABLE IF EXISTS QRTZ6_LOCKS;
DROP TABLE IF EXISTS QRTZ6_SIMPLE_TRIGGERS;
DROP TABLE IF EXISTS QRTZ6_CRON_TRIGGERS;
DROP TABLE IF EXISTS QRTZ6_SIMPROP_TRIGGERS;
DROP TABLE IF EXISTS QRTZ6_BLOB_TRIGGERS;
DROP TABLE IF EXISTS QRTZ6_TRIGGERS;
DROP TABLE IF EXISTS QRTZ6_JOB_DETAILS;
DROP TABLE IF EXISTS QRTZ6_CALENDARS;

CREATE TABLE QRTZ6_JOB_DETAILS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    JOB_NAME VARCHAR(200) NOT NULL,
    JOB_GROUP VARCHAR(200) NOT NULL,
    DESCRIPTION VARCHAR(250) NULL,
    JOB_CLASS_NAME VARCHAR(250) NOT NULL,
    IS_DURABLE BOOLEAN NOT NULL,
    IS_NONCONCURRENT BOOLEAN NOT NULL,
    IS_UPDATE_DATA BOOLEAN NOT NULL,
    REQUESTS_RECOVERY BOOLEAN NOT NULL,
    JOB_DATA BYTEA NULL,
    PRIMARY KEY (SCHED_NAME, JOB_NAME, JOB_GROUP)
);

CREATE TABLE QRTZ6_TRIGGERS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    JOB_NAME VARCHAR(200) NOT NULL,
    JOB_GROUP VARCHAR(200) NOT NULL,
    DESCRIPTION VARCHAR(250) NULL,
    NEXT_FIRE_TIME BIGINT NULL,
    PREV_FIRE_TIME BIGINT NULL,
    PRIORITY INTEGER NULL,
    TRIGGER_STATE VARCHAR(16) NOT NULL,
    TRIGGER_TYPE VARCHAR(8) NOT NULL,
    START_TIME BIGINT NOT NULL,
    END_TIME BIGINT NULL,
    CALENDAR_NAME VARCHAR(200) NULL,
    MISFIRE_INSTR SMALLINT NULL,
    JOB_DATA BYTEA NULL,
    PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP),
    FOREIGN KEY (SCHED_NAME, JOB_NAME, JOB_GROUP)
        REFERENCES QRTZ6_JOB_DETAILS (SCHED_NAME, JOB_NAME, JOB_GROUP)
);

CREATE TABLE QRTZ6_SIMPLE_TRIGGERS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    REPEAT_COUNT BIGINT NOT NULL,
    REPEAT_INTERVAL BIGINT NOT NULL,
    TIMES_TRIGGERED BIGINT NOT NULL,
    PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP),
    FOREIGN KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP)
        REFERENCES QRTZ6_TRIGGERS (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP)
);

CREATE TABLE QRTZ6_CRON_TRIGGERS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    CRON_EXPRESSION VARCHAR(120) NOT NULL,
    TIME_ZONE_ID VARCHAR(80),
    PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP),
    FOREIGN KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP)
        REFERENCES QRTZ6_TRIGGERS (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP)
);

CREATE TABLE QRTZ6_SIMPROP_TRIGGERS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    STR_PROP_1 VARCHAR(512) NULL,
    STR_PROP_2 VARCHAR(512) NULL,
    STR_PROP_3 VARCHAR(512) NULL,
    INT_PROP_1 INTEGER NULL,
    INT_PROP_2 INTEGER NULL,
    LONG_PROP_1 BIGINT NULL,
    LONG_PROP_2 BIGINT NULL,
    DEC_PROP_1 NUMERIC(13,4) NULL,
    DEC_PROP_2 NUMERIC(13,4) NULL,
    BOOL_PROP_1 BOOLEAN NULL,
    BOOL_PROP_2 BOOLEAN NULL,
    PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP),
    FOREIGN KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP)
        REFERENCES QRTZ6_TRIGGERS (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP)
);

CREATE TABLE QRTZ6_BLOB_TRIGGERS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    BLOB_DATA BYTEA NULL,
    PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP),
    FOREIGN KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP)
        REFERENCES QRTZ6_TRIGGERS (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP)
);

CREATE TABLE QRTZ6_CALENDARS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    CALENDAR_NAME VARCHAR(200) NOT NULL,
    CALENDAR BYTEA NOT NULL,
    PRIMARY KEY (SCHED_NAME, CALENDAR_NAME)
);

CREATE TABLE QRTZ6_PAUSED_TRIGGER_GRPS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    PRIMARY KEY (SCHED_NAME, TRIGGER_GROUP)
);

CREATE TABLE QRTZ6_FIRED_TRIGGERS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    ENTRY_ID VARCHAR(95) NOT NULL,
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    INSTANCE_NAME VARCHAR(200) NOT NULL,
    FIRED_TIME BIGINT NOT NULL,
    SCHED_TIME BIGINT NOT NULL,
    PRIORITY INTEGER NOT NULL,
    STATE VARCHAR(16) NOT NULL,
    JOB_NAME VARCHAR(200) NULL,
    JOB_GROUP VARCHAR(200) NULL,
    IS_NONCONCURRENT BOOLEAN NULL,
    REQUESTS_RECOVERY BOOLEAN NULL,
    PRIMARY KEY (SCHED_NAME, ENTRY_ID)
);

CREATE TABLE QRTZ6_SCHEDULER_STATE
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    INSTANCE_NAME VARCHAR(200) NOT NULL,
    LAST_CHECKIN_TIME BIGINT NOT NULL,
    CHECKIN_INTERVAL BIGINT NOT NULL,
    PRIMARY KEY (SCHED_NAME, INSTANCE_NAME)
);

CREATE TABLE QRTZ6_LOCKS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    LOCK_NAME VARCHAR(40) NOT NULL,
    PRIMARY KEY (SCHED_NAME, LOCK_NAME)
);

INSERT INTO QRTZ6_LOCKS values('PentahoQuartzScheduler','TRIGGER_ACCESS');
INSERT INTO QRTZ6_LOCKS values('PentahoQuartzScheduler','JOB_ACCESS');
INSERT INTO QRTZ6_LOCKS values('PentahoQuartzScheduler','CALENDAR_ACCESS');
INSERT INTO QRTZ6_LOCKS values('PentahoQuartzScheduler','STATE_ACCESS');
INSERT INTO QRTZ6_LOCKS values('PentahoQuartzScheduler','MISFIRE_ACCESS');

CREATE INDEX IDX_QRTZ6_J_REQ_RECOVERY
    ON QRTZ6_JOB_DETAILS (SCHED_NAME, REQUESTS_RECOVERY);
CREATE INDEX IDX_QRTZ6_J_GRP
    ON QRTZ6_JOB_DETAILS (SCHED_NAME, JOB_GROUP);

CREATE INDEX IDX_QRTZ6_T_J
    ON QRTZ6_TRIGGERS (SCHED_NAME, JOB_NAME, JOB_GROUP);
CREATE INDEX IDX_QRTZ6_T_JG
    ON QRTZ6_TRIGGERS (SCHED_NAME, JOB_GROUP);
CREATE INDEX IDX_QRTZ6_T_C
    ON QRTZ6_TRIGGERS (SCHED_NAME, CALENDAR_NAME);
CREATE INDEX IDX_QRTZ6_T_G
    ON QRTZ6_TRIGGERS (SCHED_NAME, TRIGGER_GROUP);
CREATE INDEX IDX_QRTZ6_T_STATE
    ON QRTZ6_TRIGGERS (SCHED_NAME, TRIGGER_STATE);
CREATE INDEX IDX_QRTZ6_T_N_STATE
    ON QRTZ6_TRIGGERS (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP, TRIGGER_STATE);
CREATE INDEX IDX_QRTZ6_T_N_G_STATE
    ON QRTZ6_TRIGGERS (SCHED_NAME, TRIGGER_GROUP, TRIGGER_STATE);
CREATE INDEX IDX_QRTZ6_T_NEXT_FIRE_TIME
    ON QRTZ6_TRIGGERS (SCHED_NAME, NEXT_FIRE_TIME);
CREATE INDEX IDX_QRTZ6_T_NFT_ST
    ON QRTZ6_TRIGGERS (SCHED_NAME, TRIGGER_STATE, NEXT_FIRE_TIME);


CREATE INDEX IDX_QRTZ6_T_NFT_MISFIRE
    ON QRTZ6_TRIGGERS (SCHED_NAME, MISFIRE_INSTR, NEXT_FIRE_TIME);
CREATE INDEX IDX_QRTZ6_T_NFT_ST_MISFIRE
    ON QRTZ6_TRIGGERS (SCHED_NAME, MISFIRE_INSTR, NEXT_FIRE_TIME, TRIGGER_STATE);
CREATE INDEX IDX_QRTZ6_T_NFT_ST_MISFIRE_GRP
    ON QRTZ6_TRIGGERS (SCHED_NAME, MISFIRE_INSTR, NEXT_FIRE_TIME, TRIGGER_GROUP, TRIGGER_STATE);

CREATE INDEX IDX_QRTZ6_FT_TRIG_INST_NAME
    ON QRTZ6_FIRED_TRIGGERS (SCHED_NAME, INSTANCE_NAME);
CREATE INDEX IDX_QRTZ6_FT_INST_JOB_REQ_RCVRY
    ON QRTZ6_FIRED_TRIGGERS (SCHED_NAME, INSTANCE_NAME, REQUESTS_RECOVERY);
CREATE INDEX IDX_QRTZ6_FT_J_G
    ON QRTZ6_FIRED_TRIGGERS (SCHED_NAME, JOB_NAME, JOB_GROUP);
CREATE INDEX IDX_QRTZ6_FT_JG
    ON QRTZ6_FIRED_TRIGGERS (SCHED_NAME, JOB_GROUP);
CREATE INDEX IDX_QRTZ6_FT_T_G
    ON QRTZ6_FIRED_TRIGGERS (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);
CREATE INDEX IDX_QRTZ6_FT_TG
    ON QRTZ6_FIRED_TRIGGERS (SCHED_NAME, TRIGGER_GROUP);

ALTER TABLE qrtz6_fired_triggers OWNER TO pentaho_user;
ALTER TABLE qrtz6_paused_trigger_grps OWNER TO pentaho_user;
ALTER TABLE qrtz6_scheduler_state OWNER TO pentaho_user;
ALTER TABLE qrtz6_locks OWNER TO pentaho_user;
ALTER TABLE qrtz6_simple_triggers OWNER TO pentaho_user;
ALTER TABLE qrtz6_cron_triggers OWNER TO pentaho_user;
ALTER TABLE qrtz6_blob_triggers OWNER TO pentaho_user;
ALTER TABLE qrtz6_simprop_triggers OWNER TO pentaho_user;
ALTER TABLE qrtz6_triggers OWNER TO pentaho_user;
ALTER TABLE qrtz6_job_details OWNER TO pentaho_user;
ALTER TABLE qrtz6_calendars OWNER TO pentaho_user;

commit;
--End Connect--