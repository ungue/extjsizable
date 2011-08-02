$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'active_record'
require 'active_support'
require 'rspec'
require 'extjsizable'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => ":memory:"
)

ActiveRecord::Schema.define(:version => 1) do
  create_table "products", :force => true do |t|
    t.integer "category_id"
    t.string  "name"
  end
  
  create_table "categories", :force => true do |t|
    t.string "name"
  end
end

# Testing models
class Category < ActiveRecord::Base
  has_many :products

  validates_presence_of :name

  def my_method
    return 'the result of my method'
  end
end

class Product < ActiveRecord::Base
  belongs_to :category

  validates_presence_of :name
end

RSpec.configure do |config|
  
end
