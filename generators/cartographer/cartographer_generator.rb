class CartographerGenerator < Rails::Generator::NamedBase
  def initialize(args, options = {})
    super
    @class = args[0]
  end
 
  def manifest
    @migration_name = file_name.camelize
    record do |m|
      
      if Dir.glob("db/migrate/[0-9]*_*.rb").grep(/[0-9]+_create_cartographer_basic_tables.rb$/).empty?
        m.migration_template 'create_cartographer_basic_tables.rb', 'db/migrate', :migration_file_name => 'create_cartographer_basic_tables'
      else
        puts "WARNING: Migration 'create_cartographer_basic_tables' already exists. You don't need it twice."
      end
      
      m.migration_template "cartographer_migration.rb.erb", File.join('db', 'migrate'), :migration_file_name => file_name
      
    end
  end
  
  def file_name
    "add_cartographer_to_#{@class.underscore}"
  end
end
