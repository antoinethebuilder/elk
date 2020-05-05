# Winlogbeat

Typically you need the create the following separate roles:

- Setup role for setting up index templates and other dependencies
- Monitoring role for sending monitoring information
- Writer role for publishing events collected by Winlogbeat
- Reader role for Kibana users who need to view and create visualizations that access Winlogbeat data

## Setup role
1. Create a setup role, called something like _winlogbeat_setup_, that has the following privileges:

```json
POST /_xpack/security/role/winlogbeat_setup
{
  "cluster": ["monitor", "manage_ilm"],
  "indices": [
    {
      "names": [ "winlogbeat-*" ],
      "privileges": ["manage"]
    }
  ]
}
```

2. Assign the setup role, along with the following built-in roles, to users who need to set up Winlogbeat:

| Role  | Purpose  |
|---|---|
| winlogbeat_setup | The role we just created to be able to setup winlogbeat|
| kibana_user | Load dependencies, such as example dashboards, if available, into Kibana | 
| ingest_admin | Set up index templates and, if available, ingest pipelines |

Source: [Grant privileges and roles needed for setup](https://www.elastic.co/guide/en/beats/winlogbeat/current/feature-roles.html#privileges-to-setup-beats)

## Monitoring role for sending monitoring information

If you’re using [internal collection](https://www.elastic.co/guide/en/beats/winlogbeat/current/monitoring-internal-collection.html) to collect metrics about Winlogbeat, X-Pack security provides the _beats_system_ built-in user and _beats_system_ built-in role to send monitoring information. 

You can use the built-in user, if it’s available in your environment, or create a user who has the privileges needed to send monitoring information.

If you don’t use the beats_system user:

1. Create a monitoring role, called something like _winlogbeat_monitoring_, that has the following privileges:

```json
POST /_xpack/security/role/winlogbeat_monitoring
{
  "cluster": ["monitor"],
  "indices": [
    {
      "names": [ ".monitoring-beats-*" ],
      "privileges": ["create_index", "create_doc"]
    }
  ]
}
```

2. Assign the monitoring role, along with the following built-in roles, to users who need to monitor Winlogbeat:

| Role  | Purpose  |
|---|---|
| kibana_user | Load dependencies, such as example dashboards, if available, into Kibana | 
| monitoring_user | Use **Stack Monitoring** in Kibana to monitor Winlogbeat |

If you’re using Metricbeat to collect metrics about Winlogbeat, X-Pack security provides the remote_monitoring_user built-in user, and the remote_monitoring_collector and remote_monitoring_agent built-in roles for collecting and sending monitoring information. 

If you use the remote_monitoring_user user, make sure you set the password.

Source: [Grant privileges and roles needed for monitoring](https://www.elastic.co/guide/en/beats/winlogbeat/current/feature-roles.html#privileges-to-publish-monitoring)


## Writer role for publishing events collected by Winlogbeat
1. Create a writer role, called something like *winlogbeat_writer*, that has the following privileges:

```json
POST /_xpack/security/role/winlogbeat_writer
{
  "cluster": ["monitor", "read_ilm"],
  "indices": [
    {
      "names": [ "winlogbeat-*" ],
      "privileges": ["view_index_metadata", "create_index", "create_doc"]
    }
  ]
}
```
2. Assign the writer role to users who will index events into Elasticsearch. 

Source: [Grant privileges and roles needed for publishing](https://www.elastic.co/guide/en/beats/winlogbeat/current/feature-roles.html#privileges-to-publish-events)

## Reader role for Kibana users who need to view and create visualizations that access Winlogbeat data

1. Create a reader role, called something like _winlogbeat_reader_, that has the following privilege:

```json
POST /_xpack/security/role/winlogbeat_reader
{
  "indices": [
    {
      "names": [ "winlogbeat-*" ],
      "privileges": ["read"]
    }
  ]
}
```

2. Assign the reader role, along with the following built-in roles, to users who need to read Winlogbeat data:

| Role  | Purpose  |
|---|---|
| kibana_user or kibana_dashboard_only_user| Use Kibana. kibana_dashboard_only_user grants read-only access to dashboards. |

Source: [Grant privileges and roles needed to read Winlogbeat data](https://www.elastic.co/guide/en/beats/winlogbeat/current/feature-roles.html#kibana-user-privileges)

