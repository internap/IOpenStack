
curl -i http://10.211.55.8:5000/v3/auth/tokens -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"auth" : {"identity" : {"methods" : ["password"], "password" : { "user" : { "name" : "demo","domain": {"name": "Default"},"password" : "password" } } }, "scope": {"project": {"name": "demo","domain": {"name": "Default"} } } } }'


curl -i http://10.211.55.8:8080/v1/AUTH_a0d9431339274dff979c9bf095d72439 -X GET -H "Content-Type: application/json" -H "X-Auth-Token: 03f05b84a43e4afc81025a3722c35e4f" -H "X-Subject-Token: 03f05b84a43e4afc81025a3722c35e4f" -H "Accept: application/json"


curl -i http://10.211.55.8:8080/v1/AUTH_a0d9431339274dff979c9bf095d72439/testbruno -X PUT -H "Content-Type: application/json" -H "X-Auth-Token: 6c279de5739e42f9ba4099f13f5cd790" -H "Accept: application/json" -H "X-Container-Meta-Book: TomSawyer"


curl -i http://10.211.55.8:8080/v1/AUTH_a0d9431339274dff979c9bf095d72439/testbruno/testbruno.txt -X PUT -H "Content-Type: application/json" -H "X-Auth-Token: 6c279de5739e42f9ba4099f13f5cd790" -H "Accept: application/json" -H "X-Container-Meta-Book: TomSawyer" -d "testbrunotext"


curl -i http://10.211.55.8:8080/v1/AUTH_a0d9431339274dff979c9bf095d72439/testbruno/testbruno.txt -X GET -H "Content-Type: application/json" -H "X-Auth-Token: 6c279de5739e42f9ba4099f13f5cd790"

http://10.211.55.8:8080/v1/AUTH_a0d9431339274dff979c9bf095d72439/testcontainer-8B47F350-4F26-4590-8D61-1CC9C352E9E4