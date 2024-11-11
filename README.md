# MongoSync Deployment

This project sets up a MongoSync deployment using Docker and Kubernetes.

## Prerequisites

- Docker
- Kubernetes cluster
- kubectl configured to interact with your cluster

## Dockerfile

The Dockerfile is based on Ubuntu and installs MongoSync. It exposes port 27182 and sets up the MongoSync command with the necessary arguments.

```dockerfile
FROM ubuntu:latest
WORKDIR /tmp

ARG VERSION=1.6.1
ARG SRC_URI
ARG DST_URI
EXPOSE 27182

RUN apt-get update && apt-get install -y curl
RUN curl https://fastdl.mongodb.org/tools/mongosync/mongosync-ubuntu2004-x86_64-${VERSION}.tgz -o mongosync-ubuntu2004-x86_64-${VERSION}.tgz
RUN tar -xvzf mongosync-ubuntu2004-x86_64-${VERSION}.tgz
RUN cp mongosync-ubuntu2004-x86_64-${VERSION}/bin/mongosync /usr/local/bin/
RUN mongosync -v

CMD mongosync --cluster0 ${SRC_URI} --cluster1 ${DST_URI}
```

## Deployment
The Kubernetes deployment is defined in deployment.yml. It creates a single replica of the MongoSync container, exposing port 27182 and setting environment variables for the source and destination URIs.

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongosync
  namespace: development
  labels:
    app: mongosync
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongosync
  template:
    metadata:
      namespace: development
      labels:
        app: mongosync
    spec:
      containers:
        - name: mongosync
          image: guillevalin/mongosync:1.6.1
          ports:
            - containerPort: 27182
              protocol: TCP
          env:
            - name: SRC_URI
              value: 'mongodb://localhost:27017'
            - name: DST_URI
              value: 'mongodb://localhost:27018'
          resources:
            requests:
              cpu: 200m
              memory: 512Mi
            limits:
              cpu: 1
              memory: 4Gi
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
```

## Building the Docker Image
To build the Docker image, run the following command:
```
docker build -t yourusername/mongosync:1.6.1 .
```

## Deploying to Kubernetes
To deploy the application to your Kubernetes cluster, run:
```
kubectl apply -f deployment.yml
```

## Environment Variables
- `SRC_URI`: The URI of the source MongoDB cluster.
- `DST_URI`: The URI of the destination MongoDB cluster.

## Exposed Ports
- `27182`: The port on which MongoSync listens.

## Resources
- CPU Requests: 200m
- Memory Requests: 512Mi
- CPU Limits: 1
- Memory Limits: 4Gi

## License
This project is licensed under the MIT License.