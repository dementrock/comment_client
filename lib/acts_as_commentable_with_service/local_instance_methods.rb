require 'rest_client'
require 'yajl'
require File.join(File.expand_path(File.dirname(__FILE__)), 'comment')

module Acts
  module CommentableWithService
    module LocalInstanceMethods
      def json_comments
        url = "http://#{self.class.service_host}/api/v1/commentables/#{self.class.commentable_type}/#{self.id}/comments"
        response = RestClient.get(url)
        Yajl::Parser.parse(response.body)
      end

      def comments
        json_comments.map do |json_comment|
          Acts::CommentableWithService::Comment.from_json(json_comment)
        end
      end

      def add_comment(comment, parent_id=nil)

      end
    end
  end
end
