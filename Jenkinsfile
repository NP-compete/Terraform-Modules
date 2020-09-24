pipeline {
  agent any

  parameters {
        choice(name: 'environment', choices: ['dev', 'sys', 'prod'], description: 'Workspace/environment file to use for deployment')
        string(name: 'StateBucket', defaultValue: '', description: 'Bucket to use to store tfstate')
        string(name: 'StateLock', defaultValue: '', description: 'DynamoDB table to use to lock tfstate')
        string(name: 'Project', defaultValue: '', description: 'Project Name')
        choice(name: 'Region', choices: ['us-east-1', 'us-east-2', 'us-west-1', 'us-west-2'], description: 'The AWS Region')
        choice(name: 'Backend', choices: ['local', 's3'], description: 'The backend to use with terraform')
        booleanParam(name: 'StaticAnalysis', defaultValue: false, description: 'Run static code analysis?')
  }

  environment {
      // AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
      // AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
      TF_IN_AUTOMATION      = '1'
      FOR_SEQUENTIAL        = '1'
  }

  stages {
      stage('PRE Clean up'){
        steps {
          sh """
            rm -rf ~/.tfenv/
            sudo rm -rf /usr/local/bin/terraform
            sudo rm -rf /usr/local/bin/tfenv
          """
        }
      }
      stage('1. Get Infrastructure repository') {
        steps {
          cleanWs()
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
      stage('4.1 Terraform init - s3') {
        when {
          environment name: 'Backend', value: 's3'
        }
        steps {
          withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWS Creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
            sh 'terraform init -backend-config="bucket=${StateBucket}" -backend-config="key=${Project}/${environment}.tfstate" -backend-config="lock_table=${StateLock}"  -backend-config="region=us-east-1" -backend=true -force-copy -get=true -input=false'
          }
        }
      }
      stage('4.2 Terraform init - local') {
        when {
          environment name: 'Backend', value: 'local'
        }
        steps {
          sh 'terraform init -input=false'
        }
      }
      // stage('5. Validate Terraform code') {
      //   steps {
          
      //     sh 'terraform validate'
      //   }
      // }
      // stage('6. Perform static Analysis') {
        // when {
        //   environment name: 'StaticAnalysis', value: true
        // }
      //   steps {
      //     sh 'go get -u github.com/liamg/tfsec/cmd/tfsec'
      //     sh 'tfsec . --tfvars-file env/${environment}.tfvars'
      //   }
      // }
      // stage('7. Terraform lint') {
      //   steps {
      //     sh 'curl -L "$(curl -Ls https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" -o tflint.zip && unzip tflint.zip'
      //     tflint
      //   }
      // }
      // stage('8. Terraform plan') {
      //   steps {
      //     sh 'go get -u github.com/dmlittle/scenery'
      //     sh 'curl -L "$(curl -Ls https://api.github.com/repos/cloudposse/tfmask/releases/latest | grep -o -E "https://.+?_linux_amd64")" -o tfmask.zip && unzip tfmask.zip && rm tfmask.zip'
      //     sh 'terraform plan --var-file env/${environment}.tfvars | scenery | tfmask'
      //   }
      // }
      // stage('9. Terraform Cost Estimate') {
      //   steps {
      //     sh 'curl -sLO https://raw.githubusercontent.com/antonbabenko/terraform-cost-estimation/master/terraform.jq'
      //     sh 'terraform plan -out=plan.tfplan > /dev/null && terraform show -json plan.tfplan | jq -cf terraform.jq | curl -s -X POST -H "Content-Type: application/json" -d @- https://cost.modules.tf/'
      //   }
      // }
      // stage('10. Terraform apply') {
      //   steps {
      //     sh 'curl -L "$(curl -Ls https://api.github.com/repos/cloudposse/tfmask/releases/latest | grep -o -E "https://.+?_linux_amd64")" -o tfmask.zip && unzip tfmask.zip && rm tfmask.zip'
      //     sh 'terraform apply --var-file env/${environment}.tfvars --auto-approve | tfmask'
      //   }
      // }
      stage('POST Clean up'){
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