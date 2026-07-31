def branch_checkout_commands(git_branch)
  [
    # Check if branch exists.
    "git --no-pager branch --list origin/#{git_branch} --no-color -r",
    # Checkout branch.
    "git checkout --orphan #{git_branch}",
    # Reset all changes in the working branch copy.
    "git reset --hard"
  ]
end

def expect_command_execution(commands)
  [commands].flatten.each do |command|
    expect(FastlaneCore::CommandExecutor).to receive(:execute).once.with({
      command: command,
      print_all: nil,
      print_command: nil
    }).and_return("")
  end
end
