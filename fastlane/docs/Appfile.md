# Appfile

The `Appfile` stores useful information that are used across all `fastlane` tools like your *Apple ID* or the application *Bundle Identifier*, to deploy your lanes faster and tailored on your project needs. 

By default an Appfile looks like:

```ruby
app_identifier "net.sunapps.1" # The bundle identifier of your app
apple_id "felix@krausefx.com"  # Your Apple email address

# You can uncomment the lines below and add your own 
# team selection in case you're in multiple teams
# team_name "Felix Krause"
# team_id "Q2CBPJ58CA"

# To select a team for iTunes Connect use
# itc_team_name "Company Name"
# itc_team_id "18742801"
```

If you have different credentials for iTunes Connect and the Apple Developer Portal use the following code:

```ruby
app_identifier "tools.fastlane.app"       # The bundle identifier of your app

apple_dev_portal_id "portal@company.com"  # Apple Developer Account
itunes_connect_id "tunes@company.com"     # iTunes Connect Account

team_id "Q2CBPJ58CA" # Developer Portal Team ID
itc_team_id "18742801" # iTunes Connect Team ID
```

If your project has different bundle identifiers per environment (i.e. beta, app store), you can define that by using `for_platform` and/or `for_lane` block declaration. 

```ruby
app_identifier "net.sunapps.1"
apple_id "felix@krausefx.com"
team_id "Q2CBPJ58CC"

for_platform :ios do
  team_id '123' # for all iOS related things
  for_lane :test do
    app_identifier 'com.app.test'
  end
end
```

You only have to use `for_platform` if you're using `platform [platform_name] do` in your `Fastfile`.

`fastlane` will always use the lane specific value if given, otherwise fall back to the value on the top of the file. Therefore, while driving the `:beta` lane, this configuration is loaded:

```ruby
app_identifier "net.sunapps.1.beta"
apple_id "felix@krausefx.com"
team_id "Q2CBPJ58CC"
```

### Accessing from fastlane

If you want to access those values from within your `Fastfile` use

```ruby
identifier = CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
team_id = CredentialsManager::AppfileConfig.try_fetch_value(:team_id)
```

### Multiple users configuration

#### Using environment vairables

In big teams instead of specifying one email for `apple_id`, you can get `apple_id` from environment variable instead. 
Doing this will allow different developers to specify their own apple ids, and won't affect others
In case if this enviroment variable won't be setup - then it will be asked by fastlane on any command that requires apple_id

```ruby
# Appfile
# without default fallback user will be asked to input apple_id
apple_id ENV["MY_APP_NAME_APPLE_ID"] 

# In case if environment variable isn't set up, fallback email will be used
apple_id ENV["MY_APP_NAME_APPLE_ID"] || "default@email.com"
```

```bash
# ~/.bashrc of some user
export MY_APP_NAME_APPLE_ID="some_user@gmail.com"

# ~/.bashrc of some another user
export MY_APP_NAME_APPLE_ID="another_user@gmail.com"
```

#### Using file check and .gitignore

As an another option, you can use use file checking and .gitignore combination:
```ruby
# Appfile
if File.exist?("apple_id.txt")
  apple_id File.read("apple_id.txt").strip
else
  apple_id "default@email.com"
end
```

```sh
# .gitignore
apple_id.txt
```
