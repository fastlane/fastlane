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

