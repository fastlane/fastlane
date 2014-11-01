

command :init do |c|
  c.syntax = 'deliver init'
  c.description = "Creates a new Deliverfile in the current directory"

  c.action do |args, options|
    Deliver::DependencyChecker.check_dependencies

    Deliver::DeliverfileCreator.create(enclosed_directory)
  end
end