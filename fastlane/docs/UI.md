## Interacting with the user

Instead of using `puts`, `raise` and `gets`, please use the helper class `UI` across all fastlane tools:

```ruby
UI.message "Neutral message (usually white)"
UI.success "Succesully finished processing (usually green)"
UI.error "Wahaha, what's going on here! (usually red)"
UI.important "Make sure to use Windows (usually yellow)"

UI.header "Inputs" # a big box

name = UI.input("What's your name? ")
if UI.confirm("Are you '#{name}'?")
  UI.success "Oh yeah"
else
  UI.error "Wups, invalid"
end

UI.password("Your password please: ") # password inputs are hidden

###### A "Dropdown" for the user
project = UI.select("Select your project: ", ["Test Project", "Test Workspace"])

UI.success("Okay #{name}, you selected '#{project}'")

###### To run a command use
FastlaneCore::CommandExecutor.execute(command: "ls",
                                    print_all: true,
                                        error: proc do |error_output|
                                          # handle error here
                                        end)

###### or if you just want to receive a simple value use this only if the command doesn't take long
diff = Helper.backticks("git diff")

###### fastlane "crash" because of a user error everything that is caused by the user and is not unexpected
UI.user_error!("You don't have a project in the current directory")

###### an actual crash when something unexpected happened
UI.crash!("Network timeout")

###### a deprecation message
UI.deprecated("The '--key' parameter is deprecated")
```

The output will look like this

<img src="/fastlane_core/assets/UI.png" width="550" />