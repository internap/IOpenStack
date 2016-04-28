
curl -i http://10.211.55.8:5000/v3/auth/tokens -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"auth" : {"identity" : {"methods" : ["password"], "password" : { "user" : { "name" : "admin","domain": {"name": "Default"},"password" : "password" } } }, "scope": {"project": {"name": "demo","domain": {"name": "Default"} } } } }'



curl -i "http://10.211.55.6:9292/v2/images" -X GET -H "X-Auth-Token: 20359c6e175e405084e24d5f2d25a4cb" -H "X-Subject-Token: 20359c6e175e405084e24d5f2d25a4cb" -H "Accept: application/json"