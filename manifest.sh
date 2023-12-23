====================Steps for Static storage====================
apiVersion: v1
kind: PersistentVolume
metadata:
  name: myebsvol
spec:
  capacity:
    storage: 4Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  awsElasticBlockStore:
    volumeID: vol-011fadfdef7b54563          # take the volume id and add here
    fsType: ext4
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-mysql-pv-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 4Gi

========================================
#Install EBS Driver:
#Add IAM role to workernode policy

# Using helm:
wget https://get.helm.sh/helm-v3.12.3-linux-amd64.tar.gz
tar -xzf helm-v3.12.3-linux-amd64.tar.gz
sudo mv ./linux-amd64/helm /usr/local/bin/
helm
# Add the aws-ebs-csi-driver Helm repository.
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update
# Install the latest release of the driver.
helm upgrade --install aws-ebs-csi-driver \
    --namespace kube-system \
    aws-ebs-csi-driver/aws-ebs-csi-driver

## Create a Storage Class:

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata: 
  name: ebs-sc
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
# WaitForFirstConsumer: mode will delay the volume binding and provisioning of a PersistentVolume until a Pod using the PersistentVolumeClaim is created.
---
## Create a persistence volume claim

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-mysql-pv-claim
spec: 
  accessModes:
    - ReadWriteOnce
  storageClassName: ebs-sc
  resources: 
    requests:
      storage: 5Gi

## storageClassName is ebs-sc, which is same as StorageClass metadata name from StorageClass manifest
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: usermanagement-dbcreation-script
data: 
  mysql_usermgmt.sql: |-
    DROP DATABASE IF EXISTS usermgmt;
    CREATE DATABASE usermgmt; 
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec: 
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  strategy:
    type: Recreate 
  template: 
    metadata: 
      labels: 
        app: mysql
    spec: 
      containers:
        - name: mysql
          image: mysql:5.6
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: India@123
          ports:
            - containerPort: 3306
              name: mysql    
          volumeMounts:
            - name: mysql-persistent-storage
              mountPath: /var/lib/mysql    
            - name: usermanagement-dbcreation-script
              mountPath: /docker-entrypoint-initdb.d #https://hub.docker.com/_/mysql Refer Initializing a fresh instance                                            
      volumes: 
        - name: mysql-persistent-storage
          persistentVolumeClaim:
            claimName: ebs-mysql-pv-claim
        - name: usermanagement-dbcreation-script
          configMap:
            name: usermanagement-dbcreation-script
---
#05-mysql-clusterip-service.yml
apiVersion: v1
kind: Service
metadata: 
  name: mysql
spec:
  selector:
    app: mysql 
  ports: 
    - port: 3306  
  clusterIP: None # This means we are going to use Pod IP
---
apiVersion: apps/v1
kind: Deployment 
metadata:
  name: usermgmt-microservice
  labels:
    app: usermgmt-restapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: usermgmt-restapp
  template:  
    metadata:
      labels: 
        app: usermgmt-restapp
    spec:
      containers:
        - name: usermgmt-restapp
          image: amiyaranjansahoo/dockerapp:v1 
          ports: 
            - containerPort: 8095           
          env:
            - name: DB_HOSTNAME
              value: "mysql"            
            - name: DB_PORT
              value: "3306"            
            - name: DB_NAME
              value: "usermgmt"            
            - name: DB_USERNAME
              value: "root"            
            - name: DB_PASSWORD
              value: "dbpassword11"
---
#07-UserManagement-Service.yml
apiVersion: v1
kind: Service
metadata:
  name: usermgmt-restapp-service
  labels: 
    app: usermgmt-restapp
spec:
  type: NodePort
  selector:
    app: usermgmt-restapp
  ports: 
    - port: 8095
      targetPort: 8095
      nodePort: 31231		 
			  
    


###
# Connect to MYSQL Database
kubectl run -it --rm --image=mysql:5.6 --restart=Never mysql-client -- mysql -h mysql -pIndia@123

# Verify usermgmt schema got created which we provided in ConfigMap
mysql> show schemas;
use usermgmt;
show tables;
select * from users;



http://publicip:31231
