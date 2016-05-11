curl -i http://10.211.55.6:5000/v2.0/tokens -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"auth": {"tenantName": "inap-17142","passwordCredentials":{"username": "api-562aa318b095e","password":"2c8b3d9f6cb50ede0ce6c1a7c6bf1338"}}}'

curl -i http://10.211.55.8:5000/v2.0/tokens -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"auth": {"tenantName": "demo","passwordCredentials":{"username": "demo","password":"password"}}}'

curl -i http://10.211.55.6:5000/v2.0/tenants -X GET -H "X-Auth-Token: 2c6f300b45bb4c6e843f2d55c28ebf45" -H "Accept: application/json"



curl -i http://10.211.55.6:5000/v3/auth/tokens -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"auth" : {"identity" : {"methods" : ["password"], "password" : { "user" : { "name" : "admin","domain": {"name": "Default"},"password" : "password" } } }, "scope": "unscoped" } }'

curl -i http://10.211.55.6:5000/v3/auth/tokens -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"auth" : {"identity" : {"methods" : ["password"], "password" : { "user" : { "name" : "admin","domain": {"name": "Default"},"password" : "password" } } }, "scope": {"project": {"name": "demo","domain": {"name": "Default"} } } } }'


curl -i http://10.211.55.6:5000/v3/auth/tokens -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"auth" : {"identity" : {"methods" : ["password"], "password" : { "user" : { "name" : "admin","domain": {"name": "Default"},"password" : "password" } } }, "scope": {"project": {"name": "demo","domain": {"name": "Default"} } } } }'


curl -i http://10.211.55.6:5000/v3/auth/tokens -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"auth" : {"identity" : {"methods" : ["token"], "token" : { "id" : "e7d562db1bc6442fb44b06f59c5da6fb" } }, "scope": {"project": {"name": "demo","domain": {"name": "Default"} } } } }'

curl -i http://10.211.55.6:5000/v3/auth/tokens -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"auth" : {"identity" : {"methods" : ["token"], "token" : { "id" : "62737999ed144a7aaf99c0bacefe9bfb" } }, "scope": "unscoped"  } }'



curl -i http://10.211.55.10:5000/v3/auth/tokens -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"auth" : {"identity" : {"methods" : ["password"], "password" : { "user" : { "name" : "admin","domain": {"name": "Default"},"password" : "password" } } }, "scope": "unscoped" } }'



curl -i http://10.211.55.6:5000/v3/auth/tokens -X GET -H "X-Auth-Token: 6b815d79945c4aecba6200e5c90be301" -H "X-Subject-Token: 6b815d79945c4aecba6200e5c90be301" -H "Accept: application/json"


curl -i http://10.211.55.6:5000/v3/services/7c4fb417fe89428fb6dbd932ebbaf2d5 -X GET -H "X-Auth-Token: b61ebed96f9a4611bdeb5fcf86f805b0" -H "Accept: application/json"

curl -i "http://10.211.55.6:5000/v3/endpoints?service_id=7c4fb417fe89428fb6dbd932ebbaf2d5&interface=public" -X GET -H "X-Auth-Token: 5316f1c4366847c8a40f22109b6622fb" -H "Accept: application/json"


curl -i http://10.211.55.10:5000/v3/domains -X GET -H "X-Auth-Token: e67b76cc08f447f2b9ae52984e81e6b6" -H "Accept: application/json"
curl -i http://10.211.55.10:5000/v3/domains/d604f28490c842ac841fa615a47d4009 -X PATCH -H "X-Auth-Token: e67b76cc08f447f2b9ae52984e81e6b6" -H "Accept: application/json" -H "Content-Type: application/json" -d '{ "domain" : { "enabled" : false } }'
curl -i http://10.211.55.10:5000/v3/domains/d604f28490c842ac841fa615a47d4009 -X DELETE -H "X-Auth-Token: e67b76cc08f447f2b9ae52984e81e6b6" -H "Accept: application/json"

curl -i http://10.211.55.6:5000/v3/projects/default -X GET -H "X-Auth-Token: 12896251e0514a928a603e0f8659c5ea" -H "Accept: application/json"

curl -i http://10.211.55.6:5000/v3/regions -X GET -H "X-Auth-Token: c17e598f8ac741558a2a71e2757643f3" -H "Accept: application/json"

curl -i http://10.211.55.6:5000/v3/regions/RegionOne -X GET -H "X-Auth-Token: ed48ed71be4944f198d30a56a2bf2652" -H "Accept: application/json"





curl -i https://identity.api.cloud.iweb.com/v3/auth/tokens -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"auth" : {"identity" : {"methods" : ["password"], "password" : { "user" : { "name" : "api-562aa318b095e","domain": {"name": "Default"},"password" : "2c8b3d9f6cb50ede0ce6c1a7c6bf1338" } } }, "scope": {"project": {"name": "inap-17142","domain": {"name": "Default"} } } } }'