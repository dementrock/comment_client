require 'active_record'
require 'rest_client'
require 'yajl'
require File.join(File.expand_path(File.dirname(__FILE__)), 'acts_as_commentable_with_service/singleton_methods')
require File.join(File.expand_path(File.dirname(__FILE__)), 'acts_as_commentable_with_service/local_instance_methods')
require File.join(File.expand_path(File.dirname(__FILE__)), 'acts_as_commentable_with_service/exceptions')

module Acts
  module CommentableWithService

    extend ActiveSupport::Concern
    extend ActiveSupport::Inflector

    module ClassMethods
      def acts_as_commentable(options={})
        raise TypeError.new("Options for acts_as_commentable must be in a hash.") unless options.is_a? Hash
        options.each do |key, value|
          unless [:service_host].include? key
            raise ArgumentError.new("Unknown option for acts_as_commentable: #{key.inspect} => #{value.inspect}")
          end
        end

        cattr_accessor :service_host
        self.service_host = options[:service_addr] || 'localhost:4567'

        cattr_accessor :commentable_type
        self.commentable_type = self.to_s.underscore.pluralize

        include Acts::CommentableWithService::LocalInstanceMethods
        extend Acts::CommentableWithService::SingletonMethods
      end
    end
  end
end

ActiveRecord::Base.send(:include, Acts::CommentableWithService)
