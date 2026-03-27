pipeline {
  agent {
    kubernetes {
      yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins-agent: kaniko
spec:
  serviceAccountName: jenkins
  restartPolicy: Never
  volumes:
    - name: kaniko-docker-config
      secret:
        secretName: harbor-docker-config
        items:
          - key: config.json
            path: config.json
  containers:
    - name: maven
      image: maven:3.9.9-eclipse-temurin-17
      command: ['cat']
      tty: true
    - name: kaniko
      image: gcr.io/kaniko-project/executor:latest
      command: ['/busybox/cat']
      tty: true
      volumeMounts:
        - name: kaniko-docker-config
          mountPath: /kaniko/.docker
'''
    }
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Jar') {
      steps {
        container('maven') {
          sh 'mvn clean package -DskipTests'
        }
      }
    }

    stage('Kaniko Build') {
      steps {
        container('kaniko') {
          sh '/kaniko/executor --context "$WORKSPACE" --dockerfile Dockerfile --destination harbor.example.com/test/demo-java-service:demo'
        }
      }
    }
  }
}
