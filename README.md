# BitBucket Pipelines Pipe: conventional-changelog-release

A BitBucket Pipe for implementing ConventionalCommit Releases in a Mono Repo

## YAML Definition

Add the following snippet to the script section of your `bitbucket-pipelines.yml` file:

```yaml
script:
  - pipe: docker://quay.io/devops_consultants/conventional-changelog-release:latest
    variables:
      TF_MODULE_PATH: "<string>"
      TAG_PREFIX: mytag-
      COMMITTER_EMAIL: noreply@myorg.com
      # DEBUG: "<boolean>" # Optional
```

## Variables

| Variable            | Usage                                                  |
| ------------------- | ------------------------------------------------------ |
| TF_MODULE_PATH (\*) | The path to the module                                 |
| TAG_PREFIX (\*)     | The prefix used when adding git tag. Default: `v`.     |
| DEBUG               | Turn on extra debug information. Default: `false`.     |
| COMMITTER_NAME      | Git Username. Default: `Conventional Commits Release`. |
| COMMITTER_EMAIL     | Git user email. Default: `noreply@example.com`.        |
| CONFIG              | Override config.cjs path. Default: `/config.cjs`       |

_(\*) = required variable._

## Prerequisites

## Examples

Basic example:

```yaml
script:
  - pipe: docker://quay.io/devops_consultants/terraform-checks:latest
    variables:
      TF_MODULE_PATH: "modules/foobar"
```

Advanced example:

```yaml
script:
  - pipe: docker://quay.io/devops_consultants/terraform-checks:latest
    variables:
      TF_MODULE_PATH: "modules/foobar"
      DEBUG: "true"
```
