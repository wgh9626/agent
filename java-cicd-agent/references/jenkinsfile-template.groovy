pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
    ansiColor('xterm')
  }

  parameters {
    string(name: 'GIT_REPO', defaultValue: '', description: 'Git repository URL')
    string(name: 'GIT_REF', defaultValue: 'main', description: 'Git branch/tag/commit')
    string(name: 'SERVICE_NAME', defaultValue: '', description: 'Service name / deployment name')
    string(name: 'BUILD_PATH', defaultValue: '.', description: 'Java project path')
    string(name: 'DOCKERFILE_PATH', defaultValue: './Dockerfile', description: 'Dockerfile path')
    string(name: 'IMAGE_REPO', defaultValue: 'harbor.example.com/project/app', description: 'Harbor repository without tag')
    string(name: 'MANIFEST_PATH', defaultValue: './k8s/test', description: 'Manifest file or directory')
    string(name: 'NAMESPACE', defaultValue: 'test', description: 'Kubernetes namespace')
    string(name: 'DEPLOYMENT_NAME', defaultValue: '', description: 'Kubernetes deployment name')
    string(name: 'LABEL_SELECTOR', defaultValue: '', description: 'Label selector, e.g. app=my-service')
    string(name: 'HEALTHCHECK_URL', defaultValue: '-', description: 'Health check URL or - to skip HTTP check')
    booleanParam(name: 'ROLLBACK_ON_FAIL', defaultValue: true, description: 'Rollback deployment on verify failure')
  }

  environment {
    IMAGE_TAG = "git-${env.BUILD_NUMBER}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout([$class: 'GitSCM', branches: [[name: params.GIT_REF]], userRemoteConfigs: [[url: params.GIT_REPO]]])
      }
    }

    stage('Build Jar') {
      steps {
        sh "${WORKSPACE}/skills/java-cicd-agent/scripts/build_java.sh ${params.BUILD_PATH}"
      }
    }

    stage('Build Image') {
      steps {
        sh "${WORKSPACE}/skills/java-cicd-agent/scripts/build_image.sh ${WORKSPACE} ${params.DOCKERFILE_PATH} ${params.IMAGE_REPO} ${env.IMAGE_TAG}"
      }
    }

    stage('Push Image') {
      steps {
        sh "${WORKSPACE}/skills/java-cicd-agent/scripts/push_image.sh ${params.IMAGE_REPO} ${env.IMAGE_TAG}"
      }
    }

    stage('Render Manifest') {
      steps {
        sh "${WORKSPACE}/skills/java-cicd-agent/scripts/render_manifest.sh ${params.MANIFEST_PATH} ${params.IMAGE_REPO} ${env.IMAGE_TAG}"
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh "${WORKSPACE}/skills/java-cicd-agent/scripts/deploy_k8s.sh ${params.MANIFEST_PATH} ${params.NAMESPACE} ${params.DEPLOYMENT_NAME}"
      }
    }

    stage('Verify Deploy') {
      steps {
        sh "${WORKSPACE}/skills/java-cicd-agent/scripts/verify_deploy.sh ${params.NAMESPACE} ${params.DEPLOYMENT_NAME} ${params.LABEL_SELECTOR} ${params.HEALTHCHECK_URL}"
      }
    }

    stage('Argo CD Status') {
      when {
        expression { return fileExists('argocd-app.txt') }
      }
      steps {
        sh "${WORKSPACE}/skills/java-cicd-agent/scripts/check_argocd.sh $(cat argocd-app.txt) ${params.NAMESPACE}"
      }
    }
  }

  post {
    success {
      echo "Release succeeded: ${params.SERVICE_NAME} -> ${params.IMAGE_REPO}:${env.IMAGE_TAG}"
    }
    failure {
      script {
        if (params.ROLLBACK_ON_FAIL?.toString() == 'true' && params.DEPLOYMENT_NAME?.trim()) {
          sh "${WORKSPACE}/skills/java-cicd-agent/scripts/rollback.sh ${params.NAMESPACE} ${params.DEPLOYMENT_NAME} || true"
        }
      }
      echo 'Release failed'
    }
    always {
      archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true
    }
  }
}
