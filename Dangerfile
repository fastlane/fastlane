if (pr_body + pr_title).include?("WIP")
  warn("Pull Request is Work in Progress")
end

if files_modified.any? { |a| a.include?("spec/") }
  message("Tests were updated / added")
else
  warn("Tests were not updated")
end

if pr_body.length < 5
  fail "Please provide a changelog summary in the Pull Request description @#{pr_author}"
end

if files_added.count > 0 and !files_modified.any? { |a| a.include?("spec") }
  fail "Added a new file, but no new tests"
end
