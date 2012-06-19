plugin_test_dir = File.dirname(__FILE__)

$LOAD_PATH.unshift(File.join(plugin_test_dir, '..', 'lib'))
$LOAD_PATH.unshift(plugin_test_dir)
require 'rspec'
require 'acts_as_commentable_with_service'
require 'active_record'
require 'rest_client'
require 'yajl'

require 'logger'

ActiveRecord::Base.logger = Logger.new(File.join(plugin_test_dir, "debug.log"))

ActiveRecord::Base.configurations = YAML::load_file(File.join(plugin_test_dir, "db", "database.yml"))
ActiveRecord::Base.establish_connection(ENV["DB"] || "sqlite3")
ActiveRecord::Migration.verbose = false

load(File.join(plugin_test_dir, "db", "schema.rb"))
# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

ActiveRecord::Base.send(:include, Acts::CommentableWithService)

class Question < ActiveRecord::Base
  acts_as_commentable
end
