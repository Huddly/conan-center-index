#!groovy
@Library('huddlygo_shared_libraries@master') _

pipeline {
    
    agent none
    environment {
        ARTIFACTORY_ACCESS_TOKEN=credentials('artifactory-access-token')
        ARTIFACTORY_USER="jenkins"
        TEST_REMOTE="conan-staging-local"
        CONANCENTER_REMOTE="conan-center-local"
    }
    stages {
        stage ('Upload recipes'){
            agent { label 'build2' }
            steps {
                set_git_pr_status("PENDING", "Running pipeline")
                echo "Running on $NODE_NAME"
                script {
                    args = ""
                    if (env.BRANCH_NAME != 'huddly_conan'){
                        // Don't upload anything if we are not running from huddly_conan
                        args = "--dry-run"
                    }
                    sh script: "./docker/run_in_docker.sh 'python3 export_recipes.py ${args}'"
                }
            }
            post {
                always {
                    cleanWs()
                }
            }
        }
    }
    post {
        failure {
            set_git_pr_status("ERROR", "pipeline failed")
        }
        aborted {
            set_git_pr_status("ERROR", "pipeline aborted")
        }
        success {
            set_git_pr_status("SUCCESS", "pipeline succeeded")
        }
    }
}

def set_git_pr_status(String pr_state, String desc) {
    def JOB_NAMES = env.JOB_NAME.tokenize('/') as String[];
    def COMMIT_SHA = env.GIT_COMMIT
    def String ctx = JOB_NAMES[0];
    def String repo = 'conan-center-index'
    githubPRStatus([
        status: pr_state,
        description: desc,
        context: ctx,
        sha: COMMIT_SHA,
        repo: repo
    ])
}
