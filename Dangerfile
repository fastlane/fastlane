warn("Big PR") if lines_of_code > 500

if (pr_body.to_s + pr_title.to_s).include?("WIP")
  warn("Pull Request is Work in Progress")
end

if pr_body.length < 5
  warn "Please provide a changelog summary in the Pull Request description @#{pr_author}"
end
