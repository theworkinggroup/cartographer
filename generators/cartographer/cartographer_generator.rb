class CartographerGenerator < Rails::Generator::NamedBase
  def initialize(args, options = {})
    super
    @class = args[0]
  end
 
  def manifest
    @migration_name = file_name.camelize
    record do |m|
      
      if Dir.glob("db/migrate/[0-9]*_*.rb").grep(/[0-9]+_create_cartographer_basic_tables.rb$/).empty?
        m.migration_template 'migrations/create_cartographer_basic_tables.rb', File.join('db', 'migrate'), :migration_file_name => 'create_cartographer_basic_tables'
      else
        puts "WARNING: Migration 'create_cartographer_basic_tables' already exists. You don't need it twice."
      end
      
      m.migration_template "migrations/cartographer_migration.rb.erb", File.join('db', 'migrate'), :migration_file_name => file_name
      
      m.directory 'public/javascripts/cartographer'
      %w(cartographer.js).each do |f|
        m.file "javascripts/#{f}", "public/javascripts/cartographer/#{f}", :collision => :ask
      end
      
      m.directory 'config/initializers'
      %w(cartographer.rb).each do |f|
        m.file "config/initializers/#{f}", "config/initializers/#{f}", :collision => :ask
      end
      
    end
  end
  
  def migration_name
    @migration_name
  end
  
  def file_name
    "add_cartographer_to_#{@class.underscore}"
  end
end
