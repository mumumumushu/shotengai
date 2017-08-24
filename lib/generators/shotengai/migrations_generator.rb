  require 'rails/generators/migration'

  module Shotengai
    module Generators
      class MigrationsGenerator < Rails::Generators::Base
        include Rails::Generators::Migration

        desc 'Copy shotengai migrations to your application.'

        def self.next_migration_number(dir)
          Time.now.utc.strftime("%Y%m%d%H%M%S")
        end

        source_root File.expand_path("../../../../db/migrate", __FILE__)

        def copy_migrations
          # Use sort() to order the migrations by seq 
          # Use [2..-1] to delete the seq
          Dir[ File.join(self.class.source_root, '*.rb') ].sort.each { |f| 
            copy_migration File.basename(f, '.rb')[2..-1]
          }
        end

      protected
        def copy_migration(filename)
          if self.class.migration_exists?("db/migrate", "#{filename}")
            say_status("skipped", "Migration #{filename} already exists")
          else
            migration_template "#{filename}.rb", "db/migrate/#{filename}.rb"
          end
        end
      end
    end
  end
