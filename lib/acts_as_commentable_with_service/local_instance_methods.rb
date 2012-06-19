require 'rest_client'
require 'yajl'
require File.join(File.expand_path(File.dirname(__FILE__)), 'comment')

module Acts
  module CommentableWithService
    module LocalInstanceMethods

      def commentable_type
        self.class.commentable_type
      end

      def commentable_id
        self.id
      end

      def json_comments
        RestClient.get(url_top_level_comments).body
      end

      def comments
        parse(json_comments).map {|hash_comment| Comment.from_hash(hash_comment)}
      end

      def delete_thread
        response = RestClient.delete(url_commentable)
        if response.code == 400
          raise RequestException, parse(response.body)["errors"]
        elsif response.code != 200
          raise ServerException, "Unexpected error"
        end
      end

      def add_comment(comment_hash, parent_id=nil)
        comment = Comment.from_hash(comment_hash)
        if comment.valid?
          if parent_id.nil?
            response = RestClient.post(url_top_level_comments, comment_hash)
          else
            response = RestClient.post(url_for_comment(parent_id), comment_hash)
          end
          if response.code == 400
            comment.errors.add(:server, parse(response.body)["errors"])
          elsif response.code != 200
            comment.errors.add(:server, "Unexpected error")
          end
        end
        comment
      end

      def update_comment(comment_hash, comment_id)
        comment_hash = Comment.valid_attrs(comment_hash)
        response = RestClient.put(url_for_comment(comment_id), comment_hash)
      end

      def delete_comment(comment_id)
        response = RestClient.delete(url_for_comment(comment_id))
        if response.code == 400
          comment.errors.add(:server, parse(response.body)["errors"])
        elsif response.code != 200
          comment.errors.add(:server, "Unexpected error")
        end
      end

      def vote_comment(vote, comment_id)
        response = RestClient.put(url_for_comment_vote(comment_id), vote)
      end

      def unvote_comment(comment_id)
        response = RestClient.delete(url_for_comment_vote(comment_id))
      end

      
      
    private
      def url_prefix
        "http://#{self.class.service_host}/api/v1"
      end

      def url_commentable
        "#{url_prefix}/commentables/#{commentable_type}/#{commentable_id}"
      end

      def url_top_level_comments
        "#{url_commentable}/comments"
      end

      def parse(json)
        Yajl::Parser.parse(json)
      end
        
    end
  end
end
