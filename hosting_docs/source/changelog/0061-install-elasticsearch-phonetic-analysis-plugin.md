<!--THIS FILE IS AUTOGENERATED: DO NOT EDIT-->
<!--See https://github.com/dimagi/commcare-cloud/blob/master/changelog/README.md for instructions-->
# 61. Install Elasticsearch Phonetic Analysis Plugin

**Date:** 2022-11-08

**Optional per env:** _required on all environments_


## CommCare Version Dependency
The following version of CommCare must be deployed before rolling out this change:
[cdd8da84](https://github.com/dimagi/commcare-hq/commit/cdd8da8425a06eefc5257f7720fb6f332000e01c)


## Change Context
The Elasticsearch 'case search' index now requires the [phonetic analysis][plugin docs] plugin
to be install in Elasticsearch.

[plugin docs]: https://www.elastic.co/guide/en/elasticsearch/plugins/2.4/analysis-phonetic.html

## Details
A new feature has been added to CommCare which allows searching for cases using phonetic matching.
This features adds a new field and analyzer to the `case_search` index in Elasticsearch. In order
to roll out the changes a new Elasticsearch plugin must be installed and the index must be
re-created.

## Steps to update
This process will require some downtime.

### Preparation

Before starting this process ensure that the version of CommCare which is deployed contains the
necessary changes.

Run this command on any of the webworkers, pillowtop or celery machines:
```shell
$ grep phonetic /home/cchq/www/<env>/current/corehq/pillows/mappings/case_search_mapping.py
```

You should expect to see a few lines of output. If you do not see any output you will need
to deploy the latest version of CommCare.

### Start the downtime

```shell
$ commcare-cloud <env> downtime start
```

### Install the plugin and restart Elasticsearch

```shell
$ commcare-cloud <env> ap deploy_db.yml --tags elasticsearch
$ commcare-cloud <env> service elasticsearch-classic restart
```

Note: If your cluster has replica shards you will need to ensure that cluster routing is enabled:
```shell
$ curl 'http://<es host>/_cluster/settings/' -X PUT --data '{
  "transient": {"cluster.routing.allocation.enable": "all"}
}'
```

### Reindex the case search index

1. Update the name of the index in settings

    Edit your `<env>/public.yml` to add / edit the following setting:

    ```yaml
    localsettings:
      ES_CASE_SEARCH_INDEX_NAME: case_search_2022-11-03
    ```
2. Update settings

    ```shell
    $ commcare-cloud <env> update-config
    ```

3. Populate the new index

    Get the name of the current case search index:

    ```shell
    $ curl "<elasticsearch host>:9200/_cat/aliases" | grep case_search
    case_search   case_search_2018-05-29    <---- this is the name of the index
    ```

    Populate the new index based on the current index:

    ```shell
    $ commcare-cloud <env> django-manage --tmux reindex_es_native <current index name> case_search
    ```

4. Update the new index settings

    ```shell
    commcare-cloud <env> django-manage initialize_es_indices --index case_search --set-for-usage
    commcare-cloud <env> django-manage update_es_settings
    ```

### End downtime

```shell
$ commcare-cloud <env> downtime end
```
