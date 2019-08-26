#!/bin/bash

# This will create a secret, approle, and generate the code to use in your orchestrator. 
# It's a CLI, complete with arguments and a help flags break and contribute!
# Sometimes you'll want to use a configuration management database, this takes a json and stores it in vault 
# Give it a shot

cleanup () {
    rm -f "$tmpfile"
    rm -f "$tmp_policy"
    rm -rf "$tmpdir"
    rm -rf "$token_payload"
}

TMPDIR=$(mktemp -d)
tmpfile=$(mktemp)
tmp_policy=$(mktemp)
token_payload=$(mktemp)

trap cleanup EXIT
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -a|--vault-address)
    VAULT_ADDR="$2"
    shift # past argument
    shift # past value
    ;;
    -m|--auth-method)
    AUTH_METHOD="$2"
    shift # past argument
    shift # past value
    ;;
    -f|--filename)
    SECFILE="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--secret-name)
    SECRET_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    -r|--role-name)
    ROLE_NAME="$2"
    AUTH_METHOD=approle
    shift # past argument
    shift # past value
    ;;
    -t|--vault-token)
    VAULT_TOKEN="$2"
    shift # past argument
    shift # past value
    ;;
    -h|--help)
    echo -e """
      \r-a|--vault-address
      \rEXAMPLE: -a https://localhost:8200

      \r-f|--filename
      \rFull or local path
      \rEXAMPLE: -f /user/michone/.docker/config.json

      \r-r|--role-name
      \r Name of approle that will be generated
      \rEXAMPLE: -s myrole

      \r-s|--secret-name
      \rEXAMPLE: -s docker-dtr-dev

      \r-m|--auth-method
      \r options are 
      approle ldap ldap-group
      \rEXAMPLE: -m ldap-group 

      \r-t|--vault-token
      \rMust be given as full path
      \rEXAMPLE: -t s.0S4KqZ2q80O8YcANTz7Na1XH
    """
    exit
    ;;
    --default)
    DEFAULT=YES
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    echo "$key is not a recognized argument"
    exit
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 "$1"
fi



if curl -sk $VAULT_ADDR/v1/sys/health -o /dev/null --show-error; then
  echo "Vault accessible over network"
else
  if [ -z "$VAULT_ADDR" ]
  then
        echo "\$VAULT_ADDR is empty, where can vault be reached?"
        echo "Be sure to specify port, and http/https, normally 8200. eg" 
        #echo "https://stnamcvdl759.us164.corpintra.net:8200"
        echo "http://localhost:8200"
        read -p "Vault Address:" VAULT_ADDR
  else
        echo "Vault found, testing connection"
        if curl -sk "$VAULT_ADDR/v1/sys/health -0 /dev/null" --show-error; then
            echo 'Vault found setting environment var'
            export VAULT_ADDR=$VAULT_ADDR
        else
            echo "Vault not reachable at $VAULT_ADDR"
            exit
        fi 
  fi
fi

if [ -z "$VAULT_TOKEN" ]; then
    if cat ~/.vault-token; then
      echo 'Vault login found'
      VAULT_TOKEN="$(cat ~/.vault-token)"
    else
      echo 'Please login to vault or set the VAULT_TOKEN env variable'
      exit
    fi
fi


until test -f "$SECFILE"; do
    LSECFILE="$PWD/$SECFILE"
    if test -f "$LSECFILE"; then
      break
    fi
    echo -e """
   \r#######################################
    \rPresent Working Directory is ${PWD}
    \rFiles Available here are
    \r#######################################
    """
    ls
    echo '#######################################'
    echo "$SECFILE or $LSECFILE not found, try again"
    read -e -p "File to convert:" SECFILE
done

# Get path where the secret should be saved only support kv for now
while [ -z $SECRET_NAME ]; do
  echo "What is the secret's name?"
  echo 'e.g my-db-secret'
  read SECRET_NAME
done

while [ -z $ROLE_NAME ]; do
  echo "What is the application's name?"
  echo 'e.g americas-spring-login'
  read ROLE_NAME
done

dump="$(cat $SECFILE | jq -c '.' | sed 's/"/\\"/g')"; echo "{\"data\":{ \"config\": \"$dump\" }}" > $tmpfile

curl -s \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data @$tmpfile \
    $VAULT_ADDR/v1/secret/data/$SECRET_NAME -o /dev/null --show-error

  #"rules": "path \"secret/data/approles/okbob\" {\n  capabilities =  [\"read\"]}",
cat >$tmp_policy <<EOL
{
  "name": "${SECRET_NAME}",
  "rules": "path \"secret/data/${SECRET_NAME}\" {\n  capabilities = [\"read\"]\n}\n",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data": {
    "name": "${SECRET_NAME}",
    "rules": "path \"secret/data/${SECRET_NAME}\" {\n  capabilities = [\"read\"]\n}\n"
  },
  "wrap_info": null,
  "warnings": null,
  "auth": null
}
EOL

curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data @$tmp_policy \
  $VAULT_ADDR/v1/sys/policy/approles/$SECRET_NAME -o /dev/null

policies="$(curl -s --header "X-Vault-Token: $VAULT_TOKEN" \
  $VAULT_ADDR/v1/auth/approle/role/$ROLE_NAME | jq --arg b "approles/$SECRET_NAME" '.data.policies + [ $b ]')"

curl -s --header "X-Vault-Token: $VAULT_TOKEN" \
  --request POST \
  --data "{\"policies\": $policies }" \
  $VAULT_ADDR/v1/auth/approle/role/$ROLE_NAME 

#while [ -z $AUTH_METHOD_FINAL ]; do
#    echo $AUTH_METHOD_FINAL
#    echo $AUTH_METHOD
#    if [ -z $AUTH_METHOD ]; then 
#      echo 'Select an auth method. approle or ldap'
#      read -p "Auth Method:" $AUTH_METHOD
#    fi 
#    echo $AUTH_METHOD
#    case $AUTH_METHOD in 
#      approle)
#        echo 'Case worked'
#        AUTH_METHOD_FINAL='approle'
#
#        policies="$(curl --header "X-Vault-Token: $VAULT_TOKEN" \
#          $VAULT_ADDR/v1/auth/approle/role/$ROLE_NAME | jq --arg b "approles/$SECRET_NAME" '.data.policies + [ $b ]')"
#
#        curl --header "X-Vault-Token: $VAULT_TOKEN" \
#          --request POST \
#          --data "{\"policies\": $policies }" \
#          $VAULT_ADDR/v1/auth/approle/role/$ROLE_NAME
#        AUTH_METHOD_FINAL='notempty'
#        ;;
#      me)
#      echo 'Creating access policy for self'
#      ;;
#    esac
#done

echo 

if curl -s --header "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/secret/data/$SECRET_NAME -s | jq -r '.data.data.config' > /dev/null; then
  echo "Secret successfully stored"
else
  echo "Secret Inaccessible"
fi

cat > $tmpfile << 'EOF'
#####################################
Access your secret in one of the following ways

##### FROM Orchestrator
roleid="$(curl --header "X-Vault-TOKEN: \$VAULT_TOKEN" ${VAULT_ADDR}/v1/auth/approle/role/${ROLE_NAME}/role-id)" \
secretid="$(curl --header "X-Vault-Token: \$VAULT_TOKEN" --request POST $VAULT_ADDR}/v1/auth/approle/role/$ROLE_NAME}/secret-id)" \
token="$(curl --request POST --data "{"role_id":"$roleid","secret_id":"$secretid"}" ${VAULT_ADDR}/v1/auth/approle/login)"
curl --header "X-Vault-Token: $token" ${VAULT_ADDR}/v1/secret/data/${SECRET_NAME} | jq -r '.data.data.config'


### As a priveleged user with vault cli
vault read secret/data/${SECRET_NAME}
EOF
cat $tmpfile
#roleid="$(curl -s --header "X-Vault-TOKEN: $VAULT_TOKEN" $VAULT_ADDR/v1/auth/approle/role/$ROLE_NAME/role-id | jq -r '.data.role_id')"
#secretid="$(curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request POST $VAULT_ADDR/v1/auth/approle/role/$ROLE_NAME/secret-id | jq -r '.data.secret_id')"
#token="$(curl -s --request POST --data "{\"role_id\": \"$roleid\", \"secret_id\": \"$secretid\"}" $VAULT_ADDR/v1/auth/approle/login | jq '.auth.client_token' -r)"
#echo $roleid
#echo $secretid
#echo $token
#echo $SECRET_NAME
#curl --header "X-Vault-TOKEN: $token" $VAULT_ADDR/v1/secret/data/$SECRET_NAME 
