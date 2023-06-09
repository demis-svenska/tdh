<!--THIS FILE IS AUTOGENERATED: DO NOT EDIT-->
<!--See https://github.com/dimagi/commcare-cloud/blob/master/changelog/README.md for instructions-->
# 51. historical-auditcare-data-migration

**Date:** 2022-08-11

**Optional per env:** _only required on some environments_


## CommCare Version Dependency
The following version of CommCare must be deployed before rolling out this change:
[f0445cf7](https://github.com/dimagi/commcare-hq/commit/f0445cf724e3e2ba3b1b149705a62f4e66ad75b4)


## Change Context
Instructions regarding Migrating Historical Auditcare data to SQL.

## Details
From March 2021, we have started saving audit events to Postgres. The historical data was still in CouchDB. We have added migration utilities which will help you to migrate historical auditcare data. If you do not use auditcare you can safely ignore it.

## Steps to update
### Steps to migrate
It is advised to start a tmux session to run the migrations, you can use `django-manage` machine to start the tmux session. 
  
```
$ cchq <env> ssh django-manage:0
$ tmux new -s auditcare
$ sudo -iu cchq
$ cd /home/cchq/www/<env>/current
$ git checkout f0445cf724e3e2ba3b1b149705a62f4e66ad75b4
$ source python_env/bin/activate
$ python manage.py copy_events_to_sql --batch_size=10000 --workers=5
```
Replace <env> with your correct environment

We are checking out `f0445cf724e3e2ba3b1b149705a62f4e66ad75b4` to ensure that we have the migration commands available to us.

The migration utility creates batches and runs them parellely.
--workers defines the parallelization level
--batch_size defines the number of events that will be processed by one batch.

You should set these parameters based on the resources that you have.

The migrations are resumable, you can stop them and start them again.
