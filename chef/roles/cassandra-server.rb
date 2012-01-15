
name "cassandra-server"
description "Cassandra Server Role - Cassandra for the cloud"
run_list(
  "recipe[cassandra]"
)
default_attributes()
override_attributes()

