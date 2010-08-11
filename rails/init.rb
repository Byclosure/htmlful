puts "Please run rake htmlful:update:javascript, with an appropriate FRAMEWORK env variable" unless File.exist?("#{Rails.root}/public/javascripts/dynamic-fields.js")

require "htmlful/url"
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send(:include, Htmlful::Url)
end