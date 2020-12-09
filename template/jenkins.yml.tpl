jenkins:
  systemMessage: "\n\nHi. This Jenkins is configured automatically by Jenkins Configuration as Code plugin.\n To create a new job or a pipeline, please push the Jenkinsfile as a separate remote branch to https://github.com/janpreet/Jenkins-Job-DSL.\n\n"

  numExecutors: 3
  mode: NORMAL
  scmCheckoutRetryCount: 5
  labelString: "master"  

  securityRealm:
    local:
      allowsSignup: false
      users:
      - id: ${j_admin_user}
        password: ${j_admin_password}

  clouds:
    - docker:
        dockerApi:
          dockerHost:
            uri: "unix://var/run/docker.sock"
        name: "docker"
        templates:
        - connector: attach
          dockerTemplateBase:
            cpuPeriod: 0
            cpuQuota: 0
            image: "janpreet/jenkins-slave"
          labelString: "all-in-one"
          name: "docker-slave"
          pullStrategy: PULL_ALWAYS          
          remoteFs: "/home/jenkins"                    

  crumbIssuer:
    standard:
      excludeClientIPFromCrumb: false

  disableRememberMe: true  
  
  authorizationStrategy:
    globalMatrix:
      permissions:
        - "View/Read:authenticated"
        - "Job/Read:authenticated"
        - "Job/Build:authenticated"        
        - "Job/Discover:authenticated"
        - "Job/Workspace:authenticated"
        - "Job/Cancel:authenticated"
        - "Run/Replay:authenticated"
        - "Run/Update:authenticated"
        - "Overall/Read:authenticated"  
        - "Overall/Administer:${j_admin_user}"        

  remotingSecurity:
    enabled: true    

tool:
  git:
    installations:
      - name: git
        home: /usr/bin/git
  dockerTool:
    installations:
    - name: docker
      properties:
      - installSource:
          installers:
          - fromDocker:
              version: "latest"        

credentials:
  system:
    domainCredentials:
      - credentials:
        - usernamePassword:
            scope: "GLOBAL"
            id: "github-user"
            description: github username/password            
            username: ${gh_admin_user}
            password: ${gh_admin_password}
        - usernamePassword:
            scope: "GLOBAL"
            id: "dockerHub-user"
            description: "Docker Hub User Credentials"
            username: $${dh_admin_user}
            password: ${dh_admin_password}
        - usernamePassword:
            scope: "GLOBAL"
            id: "jenkins-admin"
            description: "Jenkins Admin Credentials"
            username: $${j_admin_user}
            password: ${j_admin_password}              
        - file:
            description: "K8s Kubeconfig"
            fileName: "kubeconfig"
            id: "kubeconfig"
            scope: GLOBAL
            secretBytes: ${secretBytes}     

jobs:
  - script: >
      multibranchPipelineJob('Jenkins-Job-DSL') {
          branchSources {
              git {
                  id = 'Jenkins-Job-DSL'
                  remote('https://github.com/janpreet/Jenkins-Job-DSL.git')
              }
          }
      }

unclassified:
  location:
    url: "${j_url}"
    adminAddress: janpreetsinghgill@gmail.com             