import http.server
import socketserver
import json
import os
import requests
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
verify=False


data = '{"password": "abc123"}'
response = requests.post('https://localhost:8200/v1/auth/ldap/login/pytestapp', data=data, verify=False)
vault_token = json.loads(response.content)['auth']['client_token']

headers = {
    'X-Vault-Token': vault_token,
}

DBPASS = json.loads(response.content)['data']['password']
print(DBPASS)

