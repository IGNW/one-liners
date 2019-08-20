# Branch name accessible via: ${data.external.git-branch.result.branch}

data "external" "git-branch" {
    program = ["/bin/bash", "-c", "jq -n --arg branch `git rev-parse --abbrev-ref HEAD` '{\"branch\":$branch}'"]
}