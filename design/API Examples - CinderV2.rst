curl -i http://10.211.55.8:5000/v3/auth/tokens -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"auth" : {"identity" : {"methods" : ["password"], "password" : { "user" : { "name" : "admin","domain": {"name": "Default"},"password" : "password" } } }, "scope": {"project": {"name": "demo","domain": {"name": "Default"} } } } }'



curl -i "http://10.211.55.8:8776/v2/a0d9431339274dff979c9bf095d72439/volumes/eedbd665-4533-46ca-a26d-47a9c91a8119" -X GET -H "X-Auth-Token: 7cd25a31f38541b6a344d12b44b6e672" -H "Accept: application/json"

curl -i "http://10.211.55.8:8776/v2/a0d9431339274dff979c9bf095d72439/volumes/eedbd665-4533-46ca-a26d-47a9c91a8119/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: 7cd25a31f38541b6a344d12b44b6e672" -H "Accept: application/json" -d '{ "os-extend": { "new_size": 2 } }'

curl -i "http://10.211.55.8:8776/v2/a0d9431339274dff979c9bf095d72439/volumes/eedbd665-4533-46ca-a26d-47a9c91a8119/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: 7cd25a31f38541b6a344d12b44b6e672" -H "Accept: application/json" -d '{ "os-reset_status": { "status": "available" } }'

curl -i "http://10.211.55.8:8776/v2/a0d9431339274dff979c9bf095d72439/volumes/eedbd665-4533-46ca-a26d-47a9c91a8119" -X GET -H "X-Auth-Token: 7cd25a31f38541b6a344d12b44b6e672" -H "Accept: application/json"

curl -i "http://10.211.55.8:8776/v2/a0d9431339274dff979c9bf095d72439/volumes/eedbd665-4533-46ca-a26d-47a9c91a8119/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: 7cd25a31f38541b6a344d12b44b6e672" -H "Accept: application/json" -d '{ "os-set_image_metadata": { "metadata": {"metadata1": "blabla", "metadata2": "blublu" } } }'


curl -i "http://10.211.55.8:8776/v2/a0d9431339274dff979c9bf095d72439/backups" -X GET -H "X-Auth-Token: 7cd25a31f38541b6a344d12b44b6e672" -H "Accept: application/json"

curl -i "http://10.211.55.8:8776/v2/a0d9431339274dff979c9bf095d72439/backups"  -X POST -H "Content-Type: application/json" -H "X-Auth-Token: 7cd25a31f38541b6a344d12b44b6e672" -H "Accept: application/json" -d '{ "backup": { "name": "backup001","volume_id": "49890d24-c5c9-4c40-8cdc-c28ac422f879" } }'


