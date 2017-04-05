# Bamboo Notes

The following notes may be of use if you are using bamboo with fastlane.


## Repository setup

In bamboo under **Linked Repositories** (where you configure your git repo) under **Advanced Settings** is an option called **Exclude changesets**

This dialog will allow you to enter a regular expression that if a commit matches, a build will not be triggered.  

For example, if your `Fastfile` is configured to make a commit message in the style of 

```
Build Version bump by fastlane to Version [0.3] Build [8]
```
Then you could use the following regex to ignore these commits

```
^.*Build Version bump by fastlane.*$
```


## Setting repository remote
By default bamboo will do an anonymous shallow clone of the repo.  This will not preserve the  `git remote` information nor the list of tags.  If you are using bamboo to create commits you may want to use a code block similar to the following:


```ruby
# In prep for eventually committing a version/build bump - set the git params
sh('git config user.name "<COMMITTER USERNAME>"')
sh('git config user.email <COMITTER EMAIL>')   

# Bamboo does an anonymous checkout so in order to update the build versions must set the git repo URL
git_remote_cmd = 'git remote set-url origin ' + ENV['bamboo_repository_git_repositoryUrl']
sh(git_remote_cmd) 
```


## Speeding up build times with carthage

Carthage is a wonderful dependency manager but once you are start using a large number of frameworks, things can start to slow down, especially if your CI server has to run `carthage` EVERY time you check in a small line of code.

One way to make build times faster is to break your work up into two separate build plans (*this can get even more funky if you start having multiple branches*)

The general idea is to make a build plan: **Project - Artifacts** that builds the `Carthage` directory and stores it as a shared artifact.  Then you create a second build plan **Project - Fastlane** that pulls down the `Carthage` directory and runs `fastlane`.  


### Artifact Plan

Use a very simple setup to create this build plan.  First off you want to make sure this plan is manually triggered only - because you only need to run it whenever the `Cartfile` changes as opposed to after ever single commit.  It could also be on a nightly build perhaps if you desire.

#### Stages / Jobs / Tasks
This plan consists of 1 Job, 1 Stage and 2 Tasks

* Task 1: **Source Code Checkout**
* Task 2: **Script** (`carthage update`)

#### Artifact definitions

Create a shared artifact with the following info:

* **Name:** CarthageFolder
* **Location:** (leave blank) 
* **Copy Pattern:** Carthage/Build/**	

*Optional*: You may want to automatically make the **Fastlane Plan** trigger whenever this plan is built

###Fastlane Plan

When configuring fastlane to run in this setup you need to make sure that you are not calling either:

```ruby
reset_git_repo(force: true)
```
or

```ruby
ensure_git_status_clean
```

as these calls will either fail the build or delete the `Carthage` directory.  Additionally you want to remove any `carthage` tasks from inside your `Fastfile` as `carthage` is now happening externally to the build.

#### Build plan setup

What this build plan does is it checks out the source code, then it downloads the entire `Carthage/Build/` directory into your local project - which is exactly what would be created from `carthage bootstrap` and then it runs `fastlane`

* Task 1: **Source Code Checkout**
* Task 2: **Artifact Download**
* Task 3: **Fastlane**

