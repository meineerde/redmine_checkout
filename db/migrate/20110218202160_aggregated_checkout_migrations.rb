require Rails.root.join("db","migrate","migration_utils","migration_squasher").to_s
require 'open_project/plugins/migration_mapping'
# This migration aggregates the migrations detailed in MIGRATION_FILES
class AggregatedCheckoutMigrations < ActiveRecord::Migration

  MIGRATION_FILES = <<-MIGRATIONS
    20091208210439_add_checkout_url_info.rb
    20091220173312_add_display_login.rb
    20100118174556_add_render_link.rb
    20100118235845_remove_defaults.rb
    20100118235909_add_overwrite_option.rb
    20100203202320_update_settings.rb
    20100426154202_rename_render_link_to_render_type.rb
    20100512135418_consolidate_repository_options.rb
    20100609153630_apply_setting_changes.rb
    20100808185600_change_protocol_storage_from_hash_to_array.rb
    20101110133453_add_username_to_protocol_urls.rb
    20110218202110_more_display_options.rb
  MIGRATIONS

  OLD_PLUGIN_NAME = "redmine_checkout"

  def up
    migration_names = OpenProject::Plugins::MigrationMapping.migration_files_to_migration_names(MIGRATION_FILES, OLD_PLUGIN_NAME)
    Migration::MigrationSquasher.squash(migration_names) do
    end
  end

  def down
  end
end



