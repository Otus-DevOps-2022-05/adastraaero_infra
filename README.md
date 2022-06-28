
# Lesson 7(Packer)

## **Задачи**

1. Создать новую ветку.
2. Установить Packer.
3. Создание сервисного аккаунта для Packer в YC.
4. Подготовка, сборка образа через Packer.
5. Развертывание VM и образа, установка и запуск приложения.
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

Создаем директорию `packer` и внутри файл `ubuntu16.json`, при этом использумем раздел Packer "File Provisioner"

  
  
  
  
