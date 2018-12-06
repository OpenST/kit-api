class DbMigrationConnection < ActiveRecord::Migration[5.2]

  def run_migration_for_db(model_klass, &block)

    #raise "Reverse the following condition when we launch 'MAIN' sub environment" if GlobalConstant::Base.sub_environment_name == 'main'
    # NOTE: Reverse the following condition when we launch main sub environment
    return unless model_klass.applicable_sub_environments.include?(GlobalConstant::Base.sub_environment_name)

    config_key = model_klass.config_key

    template = ERB.new File.new("#{Rails.root}/config/database.yml").read
    config = (YAML.load(template.result(binding)))[config_key]
    db_name = config["database"]
    config.except!("database")
    puts config
    @connection = ApplicationRecord.establish_connection(config).connection
    execute "CREATE DATABASE IF NOT EXISTS " + db_name + " DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    execute "USE " + db_name
    yield if block.present?
    @connection = ApplicationRecord.establish_connection(Rails.env.to_sym).connection

  end

end