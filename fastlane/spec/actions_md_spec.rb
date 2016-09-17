describe "Actions.md" do
  before do
    @actions_md = File.read("docs/Actions.md")
    local_actions = ["rubocop"]
    discontinued = ["update_project_code_signing"]
    others = ["default_platform", "gradle", "build_and_upload_to_appetize", "appetize_viewing_url_generator"]
    @exceptions = local_actions + discontinued + others
  end

  Fastlane::ActionsList.all_actions do |action, name|
    it "Actions.md contains the action '#{name}'" do
      next if @exceptions.include?(name)
      unless @actions_md.include?(name)
        UI.user_error!("#{name} needs to be added to docs/Actions.md")
      end
    end
  end
end
