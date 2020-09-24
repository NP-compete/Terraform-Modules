pipeline {
  agent any

  parameters {
        string(name: 'environment', defaultValue: 'dev', description: 'Workspace/environment file to use for deployment')
        string(name: 'StateBucket', defaultValue: '', description: 'Bucket to use to store tfstate')
        string(name: 'StateLock', defaultValue: '', description: 'DynamoDB table to use to lock tfstate')
        string(name: 'Project', defaultValue: '', description: 'Project Name')
        string(name: 'Region', defaultValue: 'us-east-1', description: 'The AWS Region')
        booleanParam(name: 'StaticAnalysis', defaultValue: false, description: 'Run static code analysis?')
  }

  environment {
      AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
      AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
      TF_IN_AUTOMATION      = '1'
      FOR_SEQUENTIAL        = '1'
  }

  stages {
      stage('1. Get Infrastructure repository') {
        steps {
          cleanWs()
          sh 'rm -rf ~/.tfenv'
          checkout scm
        }
      }
      stage('2. Setup Terraform') {
        steps {
          sh """
            git clone https://github.com/tfutils/tfenv.git ~/.tfenv
            sudo ln -s ~/.tfenv/bin/terraform /usr/local/bin
            sudo ln -s ~/.tfenv/bin/tfenv /usr/local/bin
            tfenv install min-required
            tfenv use min-required
          """
        }
      }
      stage('3. Setup Workspace') {
        steps {
          sh 'terraform workspace select ${environment} || terraform workspace new ${environment}'
        }
      }
      stage('4. Terraform init') {
        steps {
          sh 'terraform init -backend-config="bucket=${StateBucket}" -backend-config="key=${Project}/${environment}.tfstate" -backend-config="lock_table=${StateLock}"  -backend-config="region=us-east-1" -backend=true -force-copy -get=true -input=false'
        }
      }
      stage('Clean up'){
        steps {
          sh """  
            tfenv uninstall latest
            rm -rf ~/.tfenv/
            sudo rm -rf /usr/local/bin/terraform
            sudo rm -rf /usr/local/bin/tfenv
          """
        }
      }
  }
}