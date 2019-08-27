# Fastlane Env

An action for adding a comment to include `fastlane env` in an issue description.

# Usage

See [action.yml](action.yml)

```yaml
steps:
- uses: ./.github/actions/add-fastlane-env-comment
  with:
    repo-token: ${{ secrets.GITHUB_TOKEN }}
```

# License

The scripts and documentation in this project are released under the [MIT License](LICENSE)
