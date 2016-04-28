
curl -i http://10.211.55.6:5000/v3/auth/tokens -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"auth" : {"identity" : {"methods" : ["password"], "password" : { "user" : { "name" : "admin","domain": {"name": "Default"},"password" : "password" } } }, "scope": {"project": {"name": "demo","domain": {"name": "Default"} } } } }'


curl -i http://10.211.55.6:5000/v3/auth/tokens -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"auth" : {"identity" : {"methods" : ["password"], "password" : { "user" : { "name" : "demo","domain": {"name": "Default"},"password" : "password" } } }, "scope": {"project": {"name": "demo","domain": {"name": "Default"} } } } }'



curl -i "http://10.211.55.6:8774/" -X GET -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json"


###necessary to retrieve basic info for flavor and image
curl -i "http://10.211.55.6:9292/v2/images" -X GET -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json"

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/flavors" -X GET -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "X-Subject-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json"

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers" -X GET -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Content-Type: application/json" -H "Accept: application/json"

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers" -X POST -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Content-Type: application/json" -H "Accept: application/json" -d '{"server":{"name": "TestBrunoCurl","imageRef":"6f2dd83e-0640-4274-a42b-7e9be85a62d9","flavorRef":"1","security_groups":[{"name":"default"}]}}'



curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/5c6bb51d-eb3d-4e64-af48-3989b99dfdeb/os-instance-actions" -X GET -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Content-Type: application/json" -H "X-Subject-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json"



curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/7f008d27-261c-473d-9027-2dc6aaa59148" -X GET -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "X-Subject-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json"


curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/os-floating-ips" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"pool": "public"}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"addFloatingIp": {"address": "192.168.15.11"}}'


curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"reboot": {"type": "HARD"}}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"reboot": {"type": "SOFT"}}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"os-start": null}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"os-stop": null}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"resume": null}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"rebuild": {"imageRef": "1f66e987-0406-4d64-b8d4-60dba71cc3a5","name": "foobar","adminPass": "seekr3t"}}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"rescue": {"adminPass": "MySecretPass"}}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"unrescue": null}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"pause": null}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"unpause": null}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"lock": null}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"unlock": null}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"shelve": null}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"unshelve": null}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"addSecurityGroup": {"name": "default"}}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"removeSecurityGroup": {"name": "default"}}'


curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"attach": {"volume_id": "c8168b8f-3ffc-4500-9c6f-f8e550c9409d"}}'


curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"os-getVNCConsole": {"type": "novnc"}}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"os-getConsoleOutput": {"length": 50}}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"os-getRDPConsole": {"type": "rdp-html5"}}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/action" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"os-getSerialConsole": {"type": "serial"}}'

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/os-keypairs" -X POST -H "Content-Type: application/json" -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json" -d '{"keypair": {"name": "testkeypair"}}'


curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/consoles" -X GET -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json"

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/os-server-password" -X GET -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json"

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/os-instance-actions" -X GET -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json"

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/ips" -X GET -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json"

curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/servers/466f302d-5e34-418d-b51b-c6dd8161c42e/diagnostics" -X GET -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json"


curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/ips" -X GET -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json"


curl -i "http://10.211.55.6:8774/v2.1/91e3ee7ebf9e4719a930d5d2d295f98d/os-security-groups/e7d6d925-0b16-4e73-8a60-d1bec03b1e44" -X DELETE -H "X-Auth-Token: bf2bcb90e5d44a89944950f21f9a4c6d" -H "Accept: application/json"



