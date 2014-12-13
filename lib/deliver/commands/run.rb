

command :run do |c|
  c.syntax = 'deliver'
  c.description = 'Run a deploy process using the Deliverfile in the current folder'
  c.option '--force', 'Runs a deployment without verifying any information (PDF file). This can be used for build servers.'
  c.option '--beta', 'Runs a deployment to beta build on iTunes Connect'
  c.option '--skip-deploy', 'Skips deployment on iTunes Connect'
  c.action do |args, options|
    Deliver::DependencyChecker.check_dependencies

    if File.exists?(deliver_path)
      # Everything looks alright, use the given Deliverfile
      options.default :beta => false, :skip_deploy => false
      Deliver::Deliverer.new(deliver_path, force: options.force, is_beta_ipa: options.beta, skip_deploy: options.skip_deploy)
    else
      Deliver::Helper.log.warn("No Deliverfile found at path '#{deliver_path}'.")
      if agree("Do you want to create a new Deliverfile at the current directory? (y/n)", true)
        Deliver::DeliverfileCreator.create(enclosed_directory)
      end
    end
  end
end
