# Migration guide to snapshot 1.0

**Removed options**

Removed     | Use instead              | Note
---------|-----------------|------------------------------------------------------------
`js_file` | |
`build_command` | |
`skip_alpha_removal` | |
`project_path` | `project` | 
`setup_for_device_change` | |
`teardown_device` | |
`setup_for_language_change` | |
`teardown_language` | |
`html_title` | |
`screenshots_path` | `output_directory` |

**New options:**

Option     | Note
------------------------|------------------------------------------------------------
`workspace` | Path the workspace file
`sdk` | The SDK that should be used for building the application
`configuration` | The configuration to use when building the app. Defaults to 'Release'
`buildlog_path` | The directory where to store the build log
`stop_after_first_error` | 

How to migrate:

- Update to the new version using `sudo gem update snapshot`
- Delete `snapshot.js`, `SnapshotHelper.js` and `Snapfile` and any other files you were using
- Follow the [Quick Start Guide](https://docs.fastlane.tools/actions/snapshot/#quick-start)
