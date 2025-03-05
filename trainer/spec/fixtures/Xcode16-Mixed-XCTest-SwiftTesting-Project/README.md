This Xcode project is not directly used by the `trainer` specs suite as a fixture (i.e. the specs suite don't reference that fixture directly), but it is the Xcode project that was used to generate the `Xcode16-Mixed-XCTest-SwiftTesting-Project.xcresult` file.

## Why is this Xcode project committed to the repo?

The only reason it is committed to the repo is to:

 - Provide a reference to what tests were used to generate the `Xcode16-Mixed-XCTest-SwiftTesting-Project.xcresult` file.
 - Make it easy to add more tests if we want to expand `trainer`'s test suite to cover more cases.

## How to add more tests to the `.xcresult` fixture?

To add more tests to be then reported in the `.xcresult` fixture so that the `trainer` specs suite can test more cases:

 - Add your tests to the Xcode project like you'd do normally.
 - Run the tests in Xcode.
 - When the tests are done running, locate the `.xcresult` file that Xcode created. It'll typically be in the `~/Library/Developer/Xcode/DerivedData/{project-name}-{project-uuid}/Logs/Test/` directory.
 - Copy the new `.xcresult` file and paste it in the `spec/fixtures` directory, giving it the name `Xcode16-Mixed-XCTest-SwiftTesting-Project.xcresult`.
 - Delete the `database.sqlite3` file in the `.xcresult` bundle you just copied, as it is not used by the `trainer` specs suite and would be a waste of disk space.

    ```
    $ rm -r trainer/spec/fixtures/Xcode16-Mixed-XCTest-SwiftTesting.xcresult
    $ cp -R ~/Library/Developer/Xcode/DerivedData/FastlaneTrainerExample-{uuid}/Logs/Test/Test-FastlaneTrainerExample-{timestamp}.xcresult trainer/spec/fixtures/Xcode16-Mixed-XCTest-SwiftTesting.xcresult
    $ rm -r trainer/spec/fixtures/Xcode16-Mixed-XCTest-SwiftTesting.xcresult/Data/database.sqlite3
    ```

You can then run the `trainer` specs suite, which will use the new `.xcresult` fixture, and adjust the rspec tests accordingly to cover the added cases.
