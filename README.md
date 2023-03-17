# psql-queries
PostgreSQL locks, long running / hanging queries, etc.

# HOW TO USE:
execute queries.sql to create views, then:

```
select * from locks;
select * from locks2;
select * from long_queries;
select * from long_queries2;
```

Tested on PostgreSQL 15
