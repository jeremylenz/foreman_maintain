module Scenarios::Satellite_6_4
  class Abstract < ForemanMaintain::Scenario
    def self.upgrade_metadata(&block)
      metadata do
        tags :upgrade_scenario
        confine do
          feature(:satellite) &&
            (feature(:satellite).current_minor_version == '6.3' || \
            ForemanMaintain.upgrade_in_progress == '6.4')
        end
        instance_eval(&block)
      end
    end

    def target_version
      '6.4'
    end
  end

  class PreUpgradeCheck < Abstract
    upgrade_metadata do
      description 'Checks before upgrading to Satellite 6.4'
      tags :pre_upgrade_checks
      run_strategy :fail_slow
    end

    def compose
      add_steps(find_checks(:default))
      add_steps(find_checks(:pre_upgrade))
      add_step(Checks::Puppet::ProvideUpgradeGuide.new)
      add_step(Checks::Repositories::Validate.new(:version => '6.4'))
    end
  end

  class PreMigrations < Abstract
    upgrade_metadata do
      description 'Procedures before migrating to Satellite 6.4'
      tags :pre_migrations
    end

    def compose
      add_steps(find_procedures(:pre_migrations))
      add_step(Procedures::Service::Stop.new)
    end
  end

  class Migrations < Abstract
    upgrade_metadata do
      description 'Migration scripts to Satellite 6.4'
      tags :migrations
    end

    def compose
      add_step(Procedures::Repositories::Setup.new(:version => '6.4'))
      add_step(Procedures::Packages::UnlockVersions.new)
      add_step(Procedures::Packages::Update.new(:assumeyes => true))
      add_step(Procedures::Installer::Upgrade.new)
    end
  end

  class PostMigrations < Abstract
    upgrade_metadata do
      description 'Procedures after migrating to Satellite 6.4'
      tags :post_migrations
    end

    def compose
      add_step(Procedures::Service::Start.new)
      add_steps(find_procedures(:post_migrations))
    end
  end

  class PostUpgradeChecks < Abstract
    upgrade_metadata do
      description 'Checks after upgrading to Satellite 6.4'
      tags :post_upgrade_checks
      run_strategy :fail_slow
    end

    def compose
      add_steps(find_checks(:default))
      add_steps(find_checks(:post_upgrade))
    end
  end
end
