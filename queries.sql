-- queries blocking other queries
CREATE OR REPLACE VIEW public.locks
 AS
 SELECT activity.pid,
    activity.usename,
    activity.query,
    blocking.pid AS blocking_id,
    blocking.query AS blocking_query
 FROM pg_stat_activity activity
   JOIN pg_stat_activity blocking ON blocking.pid = ANY (pg_blocking_pids(activity.pid));


-- queries blocking other queries with even more details
CREATE OR REPLACE VIEW public.locks2
 AS
 SELECT COALESCE(blockingl.relation::regclass::text, blockingl.locktype) AS locked_item,
    now() - blockeda.query_start AS waiting_duration,
    blockeda.pid AS blocked_pid,
    blockeda.query AS blocked_query,
    blockedl.mode AS blocked_mode,
    blockinga.pid AS blocking_pid,
    blockinga.query AS blocking_query,
    blockingl.mode AS blocking_mode
   FROM pg_locks blockedl
     JOIN pg_stat_activity blockeda ON blockedl.pid = blockeda.pid
     JOIN pg_locks blockingl ON (blockingl.transactionid = blockedl.transactionid OR blockingl.relation = blockedl.relation AND blockingl.locktype = blockedl.locktype) AND blockedl.pid <> blockingl.pid
     JOIN pg_stat_activity blockinga ON blockingl.pid = blockinga.pid AND blockinga.datid = blockeda.datid
  WHERE NOT blockedl.granted AND blockinga.datname = current_database();


-- active queries sorted by the duration of execution
CREATE OR REPLACE VIEW public.long_queries
 AS
 SELECT pg_stat_activity.pid,
    age(clock_timestamp(), pg_stat_activity.query_start) AS age,
    pg_stat_activity.usename,
    pg_stat_activity.query
   FROM pg_stat_activity
  WHERE pg_stat_activity.state <> 'idle'::text AND pg_stat_activity.query !~~* '%pg_stat_activity%'::text
  ORDER BY pg_stat_activity.query_start;


-- queries running longer than 5 minutes
CREATE OR REPLACE VIEW public.long_queries2
 AS
 SELECT pg_stat_activity.pid,
    now() - pg_stat_activity.query_start AS duration,
    pg_stat_activity.query,
    pg_stat_activity.state
   FROM pg_stat_activity
 WHERE (now() - pg_stat_activity.query_start) > '00:05:00'::interval;



-- HOW TO USE:
select * from locks;
select * from locks2;
select * from long_queries;
select * from long_queries2;
