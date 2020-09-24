// pipeline {
//   agent any

  // parameters {
  //       string(name: 'environment', defaultValue: 'dev', description: 'Workspace/environment file to use for deployment')
  //       string(name: 'version', defaultValue: '', description: 'Version variable to pass to Terraform')
  //       string(name: 'RepoURL', defaultValue: '', description: 'Repo to use for Infra Provisioning')
  //       string(name: 'StateBucket', defaultValue: '', description: 'Bucket to use to store tfstate')
  //       string(name: 'StateLock', defaultValue: '', description: 'DynamoDB table to use to lock tfstate')
  //       string(name: 'Project', defaultValue: '', description: 'Project Name')
  //       booleanParam(name: 'StaticAnalysis', defaultValue: false, description: 'Automatically run static code analysis?')
  // }

  // environment {
  //     AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
  //     AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
  //     TF_IN_AUTOMATION      = '1'
  //     FOR_SEQUENTIAL        = '1'
  // }

  // try{
node {
      stage('1. Get Infrastructure repository') {
        node {
          cleanWs()
          checkout scm
        }
      }
      stage('2. Setup Terraform') {
        sh """  
          rm -rf tfenv/
          rm -rf $HOME/.local/bin/
          git clone https://github.com/tfutils/tfenv.git tfenv
          export PATH="$(pwd)/tfenv/bin:$PATH"
          tfenv install min-required
          tfenv use min-required
        """
      }
      stage('3. Setup Workspace') {
        steps {
          // sh 'terraform workspace select ${environment} || terraform workspace new ${environment}'
        }
      }
      stage('Clean up'){
          sh 'rm -rf tfenv/'
          sh './tfenv/bin/tfenv uninstall latest'
          sh 'rm -rf $HOME/.local/bin/'
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
// }