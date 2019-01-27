# crzlol_infra
crzlol Infra repository

Самостоятельно задание:
ssh -A -J 35.233.12.253 10.132.0.3

Дополнительное задание:
в hosts на рабочей станции добавить имя Jump-хоста (бастиона),
в hosts на бастионе добавить имя someinternalhost,
в ~/.ssh/config добавить
Host someinternalhost
   ProxyJump bastion
в результате сможем на него ходить
ssh someinternalhost

bastion_IP = 35.233.12.253
someinternalhost_IP = 10.132.0.3

Создание виртуальной машины и автодеплой приложения:
gcloud compute instances create reddit-app-3  --boot-disk-size=10GB   --image-family ubuntu-1604-lts   --image-project=ubuntu-os-cloud   --machine-type=g1-small   --tags puma-server   --restart-on-failure --scopes storage-ro --metadata startup-script-url=https://gist.githubusercontent.com/crzlol/2e6a59aebbed514d80ddae03fec7a9ec/raw/4be1532e6c6a6d8f2a2df3435d65c6967f3805cb/startup.sh

Создание правила в firewall:
gcloud compute firewall-rules create default-puma-server-cli --allow tcp:9292 --direction INGRESS --target-tags puma-server
[![Build Status](https://travis-ci.com/Otus-DevOps-2018-09/crzlol_infra.svg?branch=master)](https://travis-ci.com/Otus-DevOps-2018-09/crzlol_infra)
testapp_IP = 35.228.253.93
testapp_port = 9292

В ветке packer-base был создан шаблон для образа reddit-base из ubuntu-1604 и двух скриптов.
После этого был создан шаблон для образа reddit-full из reddit-base, приложения и systemd-сервиса.
Создан скрипт для создания ВМ из образа reddit-full.

Если добавить SSH-ключ через веб-интерфейс, при этом Terraform не будет про него знать, то, при накатывании шаблона Terraform удалит этот ключ.
В Terraform* я вижу проблему в такой конфигурации приложения в том, что не синхронизируются данные между приложениями.

В Terraform-2 при одновременном применении конфигурации видим сообщение о блокировке. При желании ее можно отключить, но это не рекомендуется.
В задании со * пришлось добавить команд для переконфига монги и настройки сервиса приложения.

В ansible-1 для начала пришлось довыполнить задание из Terraform-2, потому что я не выполнил задачу по построению зависимости для Provisioner,
из-за чего в Stage-окружении приложение было установлено. После доработки Stage-окружение пришло в ожидаемое состояние.
Разница между результатами выполнения команд ansible в параметре changed.
inventory.json предполагает наличие DNS-записей или записей в hosts для обращения к хостам по именам.

В ansible-2 были созданы плейбуки для развертывания базы и приложения на двух разных хостах. Написаны плэйбуки для запекания их в образ через packer. Генерацию dynamic-inventory через утилиты пока не осилил, генерю этот файл через terraform вот этим быдлокодом: terraform output -json | grep -v sens | grep -v type | sed 's/value/hosts/g' | sed 's/app_external_ip/app/' | sed 's/db_external_ip/db/'
Удалось немного сравнить два способа генерации dynamic-inventory из GCP - gcp_compute и gce.py. Gce.py заработал из коробки так, как ожидалось. Для корректной работы gcp_compute пришлось много гуглить, на мой взгляд он сложнее для запуска, но имеет более гибкие возможности для группировки хостов и возвращает больше информации о ВМ, чем gce.py. Ho gce.py, на мой взгляд более user-friendly. В итоге сделал задание со * через gcp_compute.
