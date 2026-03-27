pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
    ansiColor('xterm')
  }

  parameters {
    string(name: 'GIT_REF', defaultValue: 'main', description: 'Git branch/tag/commit')
  }

  environment {
    SERVICE_NAME = ''
    BUILD_PATH = '.'
    DOCKERFILE_PATH = './Dockerfile'
    IMAGE_REPO = ''
    IMAGE_TAG = ''
    IMAGE_TAG_STRATEGY = 'git-build-number'
    GITOPS_REPO = ''
    GITOPS_BRANCH = 'main'
    GITOPS_MANIFEST = ''
    HARBOR_CONFIG_JSON_CREDENTIALS_ID = 'harbor-docker-config'
    GITOPS_GIT_CREDENTIALS_ID = 'gitops-git'
    ARGOCD_APP = ''
  }

  stages {
    stage('Checkout Source') {
      steps {
        checkout scm
        sh 'git checkout ${GIT_REF}'
      }
    }

    stage('Load Config') {
      steps {
        script {
          def cfg = readYaml file: 'ci/release-config.yaml'
          env.SERVICE_NAME = cfg.service_name
          env.BUILD_PATH = cfg.build_path ?: '.'
          env.DOCKERFILE_PATH = cfg.dockerfile_path ?: './Dockerfile'
          env.IMAGE_REPO = cfg.image_repo ?: ''
          env.GITOPS_REPO = cfg.gitops_repo ?: ''
          env.GITOPS_BRANCH = cfg.gitops_branch ?: 'main'
          env.GITOPS_MANIFEST = cfg.gitops_manifest ?: ''
          env.ARGOCD_APP = cfg.argocd_app ?: ''
          env.IMAGE_TAG_STRATEGY = cfg.image_tag_strategy ?: 'git-build-number'
          env.HARBOR_CONFIG_JSON_CREDENTIALS_ID = cfg.harbor_config_json_credentials_id ?: 'harbor-docker-config'
          env.GITOPS_GIT_CREDENTIALS_ID = cfg.gitops_git_credentials_id ?: 'gitops-git'

          def shortSha = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
          if (env.IMAGE_TAG_STRATEGY == 'git-sha') {
            env.IMAGE_TAG = "git-${shortSha}"
          } else if (env.IMAGE_TAG_STRATEGY == 'git-build-number') {
            env.IMAGE_TAG = "git-${shortSha}-${env.BUILD_NUMBER}"
          } else {
            env.IMAGE_TAG = "build-${env.BUILD_NUMBER}"
          }
        }
      }
    }

    stage('Build Jar') {
      steps {
        sh 'mvn -f ${BUILD_PATH}/pom.xml clean package -DskipTests'
      }
    }

    stage('Kaniko Build & Push') {
      steps {
        withCredentials([file(credentialsId: env.HARBOR_CONFIG_JSON_CREDENTIALS_ID, variable: 'DOCKERCFG')]) {
          sh '''
            mkdir -p /kaniko/.docker
            cp "$DOCKERCFG" /kaniko/.docker/config.json
            /kaniko/executor \
              --context "${WORKSPACE}" \
              --dockerfile "${DOCKERFILE_PATH}" \
              --destination "${IMAGE_REPO}:${IMAGE_TAG}"
          '''
        }
      }
    }

    stage('Update GitOps Repo') {
      steps {
        withCredentials([usernamePassword(credentialsId: env.GITOPS_GIT_CREDENTIALS_ID, usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
          sh '''
            rm -rf gitops-repo
            git clone -b "${GITOPS_BRANCH}" "${GITOPS_REPO}" gitops-repo
            cd gitops-repo
            sed -i "s|__IMAGE__|${IMAGE_REPO}:${IMAGE_TAG}|g" "${GITOPS_MANIFEST}"
            git config user.name "jenkins"
            git config user.email "jenkins@example.local"
            git add "${GITOPS_MANIFEST}"
            git commit -m "Update ${SERVICE_NAME} image to ${IMAGE_TAG}" || true
            git push
          '''
        }
      }
    }

    stage('Wait for Argo CD Sync') {
      steps {
        sh '''
          if command -v argocd >/dev/null 2>&1 && [ -n "$ARGOCD_APP" ]; then
            argocd app wait "$ARGOCD_APP" --health --sync --timeout 300 || argocd app get "$ARGOCD_APP"
          else
            echo "argocd CLI unavailable or app not set; skip direct Argo CD wait"
          fi
        '''
      }
    }
  }
}
