pipeline {
  agent any

  parameters {
        string(name: 'environment', defaultValue: 'dev', description: 'Workspace/environment file to use for deployment')
        string(name: 'version', defaultValue: '', description: 'Version variable to pass to Terraform')
        string(name: 'RepoURL', defaultValue: '', description: 'Repo to use for Infra Provisioning')
        string(name: 'StateBucket', defaultValue: '', description: 'Bucket to use to store tfstate')
        string(name: 'StateLock', defaultValue: '', description: 'DynamoDB table to use to lock tfstate')
        string(name: 'Project', defaultValue: '', description: 'Project Name')
        booleanParam(name: 'StaticAnalysis', defaultValue: false, description: 'Automatically run static code analysis?')
  }

  // environment {
  //     AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
  //     AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
  //     TF_IN_AUTOMATION      = '1'
  //     FOR_SEQUENTIAL        = '1'
  // }

  // try{
  stages {
      stage('1. Get Infrastructure repository') {
        steps {
          cleanWs()
          checkout scm
          // sh "echo 'export OLDPATH="$PATH"' >> ~/.bash_profile"
        }
      }
      stage('2. Setup Terraform') {
        steps {
          sh """  
            rm -rf ~/.tfenv/
            sudo rm -rf /usr/local/bin/terraform
            sudo rm -rf /usr/local/bin/tfenv
            git clone https://github.com/tfutils/tfenv.git ~/.tfenv
            sudo ln -s ~/.tfenv/bin/terraform /usr/local/bin
            sudo ln -s ~/.tfenv/bin/tfenv /usr/local/bin
            tfenv install min-required
            tfenv use min-required
            terraform workspace select dev || terraform workspace new dev
          """
        }
      }
      stage('3. Setup Workspace') {
        steps {
          sh 'echo $PATH'
          sh 'terraform workspace select dev || terraform workspace new dev'
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
  // }
  // catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException flowError) {
  //   currentBuild.result = 'ABORTED'
  // }
  // catch (err) {
  //   currentBuild.result = 'FAILURE'
  //   throw err
  // }
  // finally {
  //   if (currentBuild.result == 'SUCCESS') {
  //     currentBuild.result = 'SUCCESS'
  //   }
  // }
}