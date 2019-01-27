#!/bin/bash
terraform output -json | grep -v sens | grep -v type | sed 's/value/hosts/g' | sed 's/app_external_ip/app/' | sed 's/db_external_ip/db/'  > ~/otus/crzlol_infra/ansible/inventory.json
