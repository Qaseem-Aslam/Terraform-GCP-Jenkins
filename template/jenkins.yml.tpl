jenkins:
  systemMessage: "\n\nHi. This Jenkins is controlled by a config file.\n\n"

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

  authorizationStrategy:
    globalMatrix:
      permissions:
        - "Overall/Administer:admin"
        - "Overall/Read:authenticated"

  remotingSecurity:
    enabled: true    

  credentials:
    system:
      domainCredentials:
        - credentials:
          - usernamePassword:
              scope:    GLOBAL
              id:       github-user
              username: ${gh_admin_user}
              password: ${gh_admin_password}
              description: github username/password  

  jobs:
    - script: >
        job('Job_DSL_Seed') {
          scm {
            git {
              remote {
                url 'https://github.com/janpreet/Jenkins-Job-DSL.git'
              }
            }
          }
          steps {
            jobDsl {
              targets 'jobs/**/*.groovy'
            }
          }
        }          