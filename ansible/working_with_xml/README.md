# This folder has a playbook with info on how to work with XML in Ansible

This is the pretty version of the XML that will be used in the playbook files
```<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
    <soapenv:Body>
        <ns:listUserResponse xmlns:ns="http://www.cisco.com/AXL/API/12.5">
            <return>
                <user uuid="{F5653A7D-1D91-F407-631F-01B29DC25EAA}">
                    <firstName>Joe</firstName>
                    <middleName/>
                    <lastName>Test</lastName>
                    <emMaxLoginTime/>
                    <userid>joetest</userid>
                </user>
                <user uuid="{083C72B4-EA4C-D7F5-84DD-751C9EBC1562}">
                    <firstName/>
                    <middleName/>
                    <lastName>test2</lastName>
                    <emMaxLoginTime/>
                    <userid>joetest2</userid>
                </user>
            </return>
        </ns:listUserResponse>
    </soapenv:Body>
</soapenv:Envelope>
```


The `xml.yml` has some code on how to work with XML in Ansible

The `cucm.yml` and `listUser.xml` files are used to show how to send requests to a CUCM Server.
