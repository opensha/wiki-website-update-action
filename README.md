# wiki-website-update-action

GitHub action to update a wiki-backed website with wiki contents. The wiki should already contain all configuration files related to GitHub pages (\_config.yml, stylesheets, templates, etc). It is based on [this Action](https://github.com/cpina/github-action-push-to-another-repository).

See an [example implementation here](https://github.com/opensha/wgcep-website), where the wiki is automatically synced to the `gh-pages` branch.

## Inputs

* `wiki-repository`: Name of the source wiki repository: username/repo.wiki or organization/repo.wiki
* `wiki-branch`: (Optional) Wiki repository branch, defaults to "master"
* `user-email`: Email for the git commit
* `user-name`: User name for the git commit.
* `commit-message`: (Optional) commit message for the output repository. ORIGIN_COMMIT is replaced by the URL@commit in the origin repo
* `destination-repository`: (Optional) Name of the destination repository. Defaults to the this repository
* `destination-branch`: (Optional) set target branch name for the destination repository. Defaults to "master" for historical reasons

### `API_TOKEN_GITHUB` (environment)
E.g.:
  `API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}`

Generate your personal token following the steps:
* Go to the Github Settings (on the right hand side on the profile picture)
* On the left hand side pane click on "Developer Settings"
* Click on "Personal Access Tokens" (also available at https://github.com/settings/tokens)
* Generate a new token, choose "Repo". Copy the token.

Then make the token available to the Github Action following the steps:
* Go to the Github page for the repository that you push from, click on "Settings"
* On the left hand side pane click on "Secrets"
* Click on "Add a new secret" and name it "API_TOKEN_GITHUB"

## Example usage
```yaml
name: WGCEP wiki-website update

# Controls when the action will run. 
on:
  # Updates on wiki updates
  gollum:
  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  build:
    # The type of runner that the job will run on
    runs-on: ubuntu-latest

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
      - name: Wiki-Website update
        uses: opensha/wiki-website-update-action@master
        env:
          API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}
        with:
          wiki-repository: 'opensha/wgcep-website.wiki'
          user-email: 'opensha.org@gmail.com'
          user-name: 'opensha-website-robot'
          destination-branch: 'gh-pages'
```
