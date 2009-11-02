#Cartographer configuration definitions

Cartographer.config do |c|
  c.default_provider = :google
  c.country_bias = 'CA'
  c.api_keys = { 
    :google => {
      :test => 'thisismyfakegoogletestingkey',
      :development => 'thisismyfakegoogledevelopmentkey',
      :staging => 'thisismyfakegooglestagingkey',
      :production => 'thisismyfakegoogleproductionkey'
    }, 
    :yahoo => {
      :test => 'thisismyfakeyahootestingkey',
      :development => 'thisismyfakeyahoodevelopmentkey',
      :staging => 'thisismyfakeyahoostagingkey',
      :production => 'thisismyfakeyahooproductionkey'
    }
  }
end
