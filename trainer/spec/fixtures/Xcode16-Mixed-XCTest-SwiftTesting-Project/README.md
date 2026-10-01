This Xcode project is not directly used by the _trainer_ specs suite as a fixture (i.e. the specs suite don't reference that fixture directly), but it is the Xcode project that was used to generate the `Xcode16-Mixed-XCTest-SwiftTesting-Project.xcresult` file.

## Why is this Xcode project committed to the repo?

The only reason it is committed to the repo is to:

 - Provide a reference to what tests were used to generate the `Xcode16-Mixed-XCTest-SwiftTesting-Project.xcresult` file.
 - Make it easy to add more tests if we want to expand _trainer_'s test suite to cover more cases.

## How to add more tests to the `.xcresult` fixture?

To add more tests to be then reported in the `.xcresult` fixture so that the _trainer_ specs suite can test more cases:

 - Add your tests to the Xcode project like you'd do normally, then run the tests in Xcode (⌘U).
 - Locate the `~/Library/Developer/Xcode/DerivedData/{project-name}-{project-uuid}/Logs/Test/*.xcresult` file that Xcode created.
   - Let's call that path `$XCRESULT_PATH`.
 - Run `xcrun xcresulttool get test-results tests --path "$XCRESULT_PATH"`
   - In addition to printing the JSON of the test results, this call will also have the side effect of generating the `$XCRESULT_PATH/database.sqlite3` database file in the `.xcresult` bundle.
 - Copy the `$XCRESULT_PATH/{Info.plist,database.sqlite3}` files in the `spec/fixtures/Xcode16-Mixed-XCTest-SwiftTesting-Project.xcresult` directory.
   - Since the `database.sqlite3` file represents the same data as what's serialized in `$XCRESULT_PATH/Data/*`, but takes way less disk space (since the database can optimize storage), the idea is to only commit that database file instead of the `Data/` directory to save disk space and make the git logs/diffs easier to work with.
 
    ```bash
    $ XCRESULT_PATH="$HOME/Library/Developer/Xcode/DerivedData/FastlaneTrainerExample-{uuid}/Logs/Test/Test-FastlaneTrainerExample-{timestamp}.xcresult"
    # cp "$XCRESULT_PATH"/{Info.plist,database.sqlite3} trainer/spec/fixtures/Xcode16-Mixed-XCTest-SwiftTesting.xcresult
    ```

You can then run the _trainer_ specs suite, which will use the new `.xcresult` fixture, and adjust the rspec tests accordingly to cover the added cases.
