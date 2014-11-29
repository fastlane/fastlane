

command :run do |c|
  c.syntax = 'deliver'
  c.description = 'Run a deploy process using the Deliverfile in the current folder'
  c.option '--force', 'Runs a deployment without verifying any information (PDF file). This can be used for build servers.'
  c.option '--beta', 'Runs a deployment to beta build on iTunes Connect'
  c.optin '--skip-deploy'
  c.action do |args, options|
    Deliver::DependencyChecker.check_dependencies

    if File.exists?(deliver_path)
      # Everything looks alright, use the given Deliverfile
      upload_strategy = Deliver::IPA_UPLOAD_STRATEGY_APP_STORE
      if options.beta
        upload_strategy = Deliver::IPA_UPLOAD_STRATEGY_BETA_BUILD
      elsif options.skip-deploy
        upload_strategy = Deliver::IPA_UPLOAD_STRATEGY_JUST_UPLOAD
      end

      Deliver::Deliverer.new(deliver_path, force: options.force, upload_strategy: upload_strategy)
    else
      Deliver::Helper.log.warn("No Deliverfile found at path '#{deliver_path}'.")
      if agree("Do you want to create a new Deliverfile at the current directory? (y/n)", true)
        Deliver::DeliverfileCreator.create(enclosed_directory)
      end
    end
  end
end
