namespace :htmlful do
  namespace :update do
    desc "Update htmlful javascript from the gem source. Use FRAMEWORK=prototype for prototype version"
    task :javascript do
      if ENV["FRAMEWORK"] == "prototype"
        `cp #{File.basedir(__FILE__)}/../javascripts/dynamic-fields.prototype.js #{Rails.root}/public/javascripts/dynamic-fields.js`
      else
        `cp #{File.basedir(__FILE__)}/../javascripts/dynamic-fields.js #{Rails.root}/public/javascripts`
      end
    end
  end
end