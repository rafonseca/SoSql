# SoSql

A SQL variation that allows for statements stacking. It is essentially syntax sugar for Common Table Expressions (the WITH clause).

## Why

- SQL is a widely adopted standard. 
- We can only talk to PostgreSQL in SQL.
- I wish there were a few modifications.


## How

- While the SQL committee does not approve my suggestions, we can transpile SoSql to SQL (and SQL to SoSql) using the binary provided here. 

## What

I hope the following examples are self-explanatory. 

### Stacking statements (with implicit FROM clause)

```
so
  select * from auth_users
then
  select name where id=64;
```

### Stacking named statements

```
so
  deleted_users <- delete from auth_users where not is_active returning *
then
  delete from user_profile join deleted_users on (user_profile.user_id = deleted_users.id)
then 
  deleted_stats <- select now(), count(*) from deleted_users
then 
  insert into some_log (select * from deleted_stats)
```

### Implicit SELECT clause
```
so
  from auth_users
```

### Implicit SELECT and FROM clauses
```
so
  from auth_users
then
  where id=64;
```


### Improved Aggregate (FOLD clause)
```
so
  from auth_users
  group by language
  fold [with] count(*);
```
The select clause is inferred from GROUP BY and FOLD clauses.


## Installation instructions

By default, we use stack+nix. If you have both installed, the following command will create a binary called `sosql` in the appropriate path.
```
stack install
```

Installation without Nix should also work since we don't have external dependencies.

Alternatively, you can grab the binary in a zip file as an [artifact of GitHub actions](https://github.com/rafonseca/SoSql/actions/workflows/haskell.yml). Pick the last successful job, scroll down, and find the artifacts section.

## TODO
  * [x] sosql -> sql
  * [ ] sql -> sosql
  * [x] implicit from clause 
  * [x] named statements 
  * [x] unnamed statements
  * [ ] implicit select clause
  * [ ] improved aggregate clause
  * [ ] implicit returning clause
