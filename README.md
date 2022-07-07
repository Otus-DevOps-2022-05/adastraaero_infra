
# Lesson 7(Packer)

## **Задачи**

1. Создать новую ветку.
2. Установить Packer.
3. Создание сервисного аккаунта для Packer в YC.
4. Подготовка, сборка образа через Packer.
5. Развертывание VM из образа, установка и запуск приложения.
6. Построение bake-образа *.
7. Автоматизация создания ВМ *.

## Решение
<details>
  <summary>Решение</summary>

### 1. Создание новой ветки

Создаем новую ветку в репозитории и переносим в директорию config-scripts все скрипты из предыдущего задания:

```
git checkout -b packer-base

git mv *.sh config-scripts/ 
```
### 2. Установка Packer 
```
sudo apt install packer
```
Проверяем:
```
packer -v
1.8.1
```
### 3. Создание сервисного аккаунта в yandex.
Посмотрим и выберем нужный folder-id и проверим, что он активирован.
```
yc resource-manager folder list 
```
Задаем переменные и создаем сервисный аккаунт
  
```
$ SVC_ACCT="<придумайте имя>"
$ FOLDER_ID="<замените на собственный>"
$ yc iam service-account create --name $SVC_ACCT --folder-id $FOLDER_ID 
```
Через Web в YandexCloud - нужный каталог - проверяем, что сервисный аккаунт создался.
  
Назначаем аккаунту права editor через yc cli:
```
ACCT_ID=$(yc iam service-account get $SVC_ACCT | grep ^id | awk '{print $2}')

yc resource-manager folder add-access-binding --id $FOLDER_ID --role editor --service-account-id $ACCT_ID
```
Через Web в YandexCloud - нужный каталог - проверяем, что у аккаунта в разделе "Роли в каталоге" стоит значение editor.
  
Создаём IAM key за пределами репозитория:
``` 
 yc iam key create --service-account-id $ACCT_ID --output /my_secret/path/key.json 
```
  
### 4. Подготовка, сборка образа через Packer.

Создаем директорию `packer` и внутри файл `ubuntu16.json`, при этом использумем раздел Packer "File Provisioner" https://www.packer.io/docs/provisioners/file ,
т.к. нужно создать и залить в образ unit файл для автозапуска mongodb, всвязи с ограничением доступа к новым версиям  mongodb. 

Соответсвенно файл mongodb.service:   

```  
[Unit]
Description=High-performance, schema-free document-oriented database
After=network.target

[Service]
User=mongodb
ExecStart=/usr/bin/mongod --quiet --config /etc/mongodb.conf

[Install]
WantedBy=multi-user.target  
```   

Соотвественно файл ubuntu16.json для packer:

``` 
{
    "builders": [
        {
            "type": "yandex",
            "service_account_key_file": "/home/mity/Documents/OtusDevops/key.json",
            "folder_id": "b1gl9g5f46b3fv1g4ac1",
            "source_image_family": "ubuntu-1604-lts",
            "image_name": "reddit-base-{{timestamp}}",
            "image_family": "reddit-base",
            "ssh_username": "ubuntu",
            "platform_id": "standard-v1",
            "use_ipv4_nat": "true"
        }
    ],
    "provisioners": [
         {
            "type": "file",
            "source": "/home/mity/Documents/OtusDevops/adastraaero_infra/packer/scripts/mongodb.service",
            "destination": "/tmp/mongodb.service"
        },
        {
            "type": "shell",
            "script": "scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        }
    ]
}  
 
``` 
Перед копированием скриптов в папку scrips, внесём изменения в install_mongodb.sh , для перещения unit файла в /etc/systemd/system/ :

``` 
#!/bin/bash
sudo cp /tmp/mongodb.service /etc/systemd/system/
apt-get update
chown 777 /etc/systemd/system/mongodb.service
apt install -y mongodb
systemctl start mongodb
systemctl enable mongodb
```   

Сделаем проверку правильности файла ubuntu16.json:

```
packer validate ./ubuntu16.json
```
  
### 5.Развертывание VM из образа, установка и запуск приложения. 

Создаем ВМ на основе нашего образа и ставим reddit:

```
sudo apt-get update
sudo apt-get install -y git
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d
```
**Параметризирование шаблона**

Создаем `variables.json`, `.gitignore` файлы и для коммита в репозиторий `variables.json.examples`. В gitignore включаем variables.json.

```
$ cat variables.json.examples

{
  "key": "key.json",
  "folder_id": "folder-id_from_config",
  "image": "ubuntu-1604-lts"
}
```
  
# Lesson 8 (Terraform - 1)
## **Задачи**

1. Установка Terraform.
2. Cоздание новой ветки в репозитории и внутренней файловой структуры.
3. Создание VM через Terraform и настраиваем переменные.



## Решение
<details>
  <summary>Решение</summary>
  
  
### 1. Установка Terraform.
  
Скачивание и распаковка нужной версии.  
```
sudo unzip terraform_0.12.8_linux_amd64.zip -d /usr/local/bin
```
 
Проверка  
``` 
$ terraform -v
Terraform v0.12.8
```

### 2. Создание новой ветки в репозитории и внутренней файловой структуры.

```   
git checkout -b terraform-1
``` 
редактируем .gitignore:

```   
*.tfstate
*.tfstate.*.backup
*.tfstate.backup
*.tfvars
.terraform/
```
Создаём сервисный аккаунт " terraformacc" и назначаем ему права.

```
yc config list

SVC_ACCT="terraformac"
$ FOLDER_ID="my_folder_id"
$ yc iam service-account create --name $SVC_ACCT --folder-id $FOLDER_ID
  
$ ACCT_ID=$(yc iam service-account get $SVC_ACCT | \
grep ^id | \
awk '{print $2}')
$ yc resource-manager folder add-access-binding --id $FOLDER_ID \
--role editor \
--service-account-id $ACCT_ID
```
  
Создаём профиль для выполнения операций от имени сервисного аккаунта, указываем ключ, создаём токен.
  
```
yc config profile create my-terraform-profile
yc config set service-account-key key.json
yc iam create-token
```  
  
### 3. Создание VM через Terraform и настраиваем переменные.  
Создаём main.tf, вносим данные из ДЗ и правки для работы:

```   
provider "yandex" {
  version                  = 0.35
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

resource "yandex_compute_instance" "app" {
  name  = "reddit-app-${count.index}"
  count = var.instance_count

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      # Указать id образа созданного в предыдущем домашем задании
      image_id = var.image_id
    }
  }

  network_interface {
    # Указан id подсети default-ru-central1-a
    subnet_id = var.subnet_id
    nat       = true
  }
  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
  connection {
    type  = "ssh"
    host  = self.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }
  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}
``` 

Выполняем terraform plan и terraform apply -auot-approve .
  
Проверяем и подклюячаемся:  
``` 
 $ terraform show | grep nat_ip_address
        nat_ip_address = "51.250.14.183"
$ shh ubuntu@51.250.14.183 
``` 
Проверяем, что сервис доступен http://51.250.14.183:9292

 # Lesson 8 (Terraform - 1)
## **Задачи**

1. Установка Terraform.
2. Cоздание новой ветки в репозитории и внутренней файловой структуры.
3. Создание VM через Terraform и настраиваем переменные.



## Решение
<details>
  <summary>Решение</summary>
  
  
### 1. Установка Terraform.
  
Скачивание и распаковка нужной версии.  
```
sudo unzip terraform_0.12.8_linux_amd64.zip -d /usr/local/bin
```
 
Проверка  
``` 
$ terraform -v
Terraform v0.12.8
```

### 2. Создание новой ветки в репозитории и внутренней файловой структуры.

```   
git checkout -b terraform-1
``` 
редактируем .gitignore:

```   
*.tfstate
*.tfstate.*.backup
*.tfstate.backup
*.tfvars
.terraform/
```
Создаём сервисный аккаунт " terraformacc" и назначаем ему права.

```
yc config list

SVC_ACCT="terraformac"
$ FOLDER_ID="my_folder_id"
$ yc iam service-account create --name $SVC_ACCT --folder-id $FOLDER_ID
  
$ ACCT_ID=$(yc iam service-account get $SVC_ACCT | \
grep ^id | \
awk '{print $2}')
$ yc resource-manager folder add-access-binding --id $FOLDER_ID \
--role editor \
--service-account-id $ACCT_ID
```
  
Создаём профиль для выполнения операций от имени сервисного аккаунта, указываем ключ, создаём токен.
  
```
yc config profile create my-terraform-profile
yc config set service-account-key key.json
yc iam create-token
```  
  
### 3. Создание VM через Terraform и настраиваем переменные.  
Создаём main.tf, вносим данные из ДЗ и правки для работы:

```   
provider "yandex" {
  version                  = 0.35
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

resource "yandex_compute_instance" "app" {
  name  = "reddit-app-${count.index}"
  count = var.instance_count

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      # Указать id образа созданного в предыдущем домашем задании
      image_id = var.image_id
    }
  }

  network_interface {
    # Указан id подсети default-ru-central1-a
    subnet_id = var.subnet_id
    nat       = true
  }
  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
  connection {
    type  = "ssh"
    host  = self.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }
  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}
``` 

Выполняем terraform plan и terraform apply -auot-approve .
  
Проверяем и подклюячаемся:  
``` 
 $ terraform show | grep nat_ip_address
        nat_ip_address = "51.250.14.183"
$ shh ubuntu@51.250.14.183 
``` 
Проверяем, что сервис доступен http://51.250.14.183:9292
 
</details>  

# Lesson 9 (Terraform - 2)
## **Задачи**

1. Подготовка инфраструктуры.
2. Создание 2ух отдельных образов Packer.
3. Разбиение main.tf на части.
4. Создание модульной структуры.
5. Перенос конфигурации в stage и prod.
6. Cоздание S3.
 
  
  
