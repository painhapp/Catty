pipeline {
  agent any
  stages {
    stage('Carthage') {
      steps {
        sh 'make init'
      }
    }
    stage('Fastlane Test') {
      steps {
        sh 'cd src && fastlane tests'
      }
    }
    stage('Archive') {
      steps {
        archiveArtifacts(artifacts: 'test_output/', allowEmptyArchive: true)
      }
    }
  }
}