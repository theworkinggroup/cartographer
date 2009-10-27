class CartographerGenerator < Rails::Generator::NamedBase
   
  def manifest
    record do |m|
      # moving javascript
      m.directory 'public/javascripts/cartographer'
      %w(cartographer.js).each do |f|
        m.file "javascripts/#{f}", "public/javascripts/cartographer/#{f}", :collision => :force
      end
      
      # moving config file
      m.directory 'config'
      %w(cartographer.yml).each do |f|
        m.file "config/#{f}", "config/#{f}", :collision => :skip
      end
    end
  end
  
end
