pipeline {
    agent any
    tools {
        maven 'MVN-3.86'
        jdk 'JDK17'
    }
    stages {
        stage('Preparation'){
            steps{
                sh 'mvn clean validate initialize'
            }
        }
        stage('Build') {
            steps {
                sh 'mvn compile test -Dmaven.test.failure.ignore=true'
            }
            post {
                always {
                    junit(testResults: '**/surefire-reports/*.xml', allowEmptyResults: true)
                }
            }
        }
        stage('Deploy') {
            when {
                branch 'master'
            }
            steps {
                sh 'mvn package'
            }
        }
    }

    // Send out notifications on unsuccessful builds.
    post {
        // If this build failed, send an email to the list.
        failure {
            script {
                if(env.BRANCH_NAME == "master") {
                    def state = (currentBuild.previousBuild != null) && (currentBuild.previousBuild.result == 'FAILURE') ? "Still failing" : "Failure"
                    emailext(
                            subject: "[Lang] Change on branch \"${env.BRANCH_NAME}\": ${env.JOB_NAME} - Build # ${env.BUILD_NUMBER} - $state",
                            body: """The Apache Jenkins build system has built ${env.JOB_NAME} (build #${env.BUILD_NUMBER})
Status: ${currentBuild.result}
Check console output at <a href="${env.BUILD_URL}">${env.BUILD_URL}</a> to view the results.
""",
                            to: "notifications@commons.apache.org",
                            recipientProviders: [[$class: 'DevelopersRecipientProvider']]
                    )
                }
            }
        }

        // If this build didn't fail, but there were failing tests, send an email to the list.
        unstable {
            script {
                if(env.BRANCH_NAME == "master") {
                    def state = (currentBuild.previousBuild != null) && (currentBuild.previousBuild.result == 'UNSTABLE') ? "Still unstable" : "Unstable"
                    emailext(
                            subject: "[Lang] Change on branch \"${env.BRANCH_NAME}\": ${env.JOB_NAME} - Build # ${env.BUILD_NUMBER} - $state",
                            body: """The Apache Jenkins build system has built ${env.JOB_NAME} (build #${env.BUILD_NUMBER})
Status: ${currentBuild.result}
Check console output at <a href="${env.BUILD_URL}">${env.BUILD_URL}</a> to view the results.
""",
                            to: "notifications@commons.apache.org",
                            recipientProviders: [[$class: 'DevelopersRecipientProvider']]
                    )
                }
            }
        }

        // Send an email, if the last build was not successful and this one is.
        success {
            script {
                if ((env.BRANCH_NAME == "master") && (currentBuild.previousBuild != null) && (currentBuild.previousBuild.result != 'SUCCESS')) {
                    emailext (
                            subject: "[Lang] Change on branch \"${env.BRANCH_NAME}\": ${env.JOB_NAME} - Build # ${env.BUILD_NUMBER} - Back to normal",
                            body: """The Apache Jenkins build system has built ${env.JOB_NAME} (build #${env.BUILD_NUMBER})
Status: ${currentBuild.result}
Check console output at <a href="${env.BUILD_URL}">${env.BUILD_URL}</a> to view the results.
""",
                            to: "notifications@commons.apache.org",
                            recipientProviders: [[$class: 'DevelopersRecipientProvider']]
                    )
                }
            }
        }
    }
}
