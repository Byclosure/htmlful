module Htmlful
  module Url
    module Macro
      def url(*fields)
        cattr_accessor :url_fields
        self.url_fields = fields
        include Url::InstanceMethods
      end
    end
  
    module InstanceMethods
      def to_param
        url_str = self.class.url_fields.map {|f| send(f).parameterize }.join("-")
        "#{id}-#{url_str}"
      end
    end
  
    def self.append_features(base)
      base.extend(Url::Macro)
    end
  end
end