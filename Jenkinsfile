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
        sh 'cd src'
        sh 'fastlane test'
      }
    }
    stage('Archive') {
      steps {
        archiveArtifacts(artifacts: 'reports/, dist/', allowEmptyArchive: true)
      }
    }
  }
}