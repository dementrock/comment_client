require 'active_record'
require 'rest_client'
require 'yajl'

module CommentClient

  @@service_host = 'localhost:4567'

  class << self

    def service_host=(host)
      @@service_host = host
    end

    def comments_for(commentable)
      response = RestClient.get(url_top_level_comments(commentable))
      if response.code == 200
        parse(response.body)
      else
        {"error" => "unexpected error"}
      end
    end

    def delete_thread(commentable)
      response = RestClient.delete(url_for_commentable(commentable))
      process_error(response)
    end

    def add_comment(commentable, comment_hash)
      response = RestClient.post(url_top_level_comments(commentable), comment_hash)
      process_error(response)
    end
    
    def reply_to(comment_id, comment_hash)
      response = RestClient.post(url_for_comment(comment_id), comment_hash)
      process_error(response)
    end

    def update_comment(comment_id, comment_hash)
      response = RestClient.put(url_for_comment(comment_id), comment_hash)
      process_error(response)
    end

    def delete_comment(comment_id)
      response = RestClient.delete(url_for_comment(comment_id))
      process_error(response)  
    end

    def vote_comment(comment_id, user_id, vote)
      response = RestClient.put(url_for_vote(comment_id, user_id, ), vote)
      process_error(response)
    end

    def unvote_comment(comment_id, user_id)
      response = RestClient.delete(url_for_vote(comment_id, user_id))
      process_error(response)
    end

  private

    def process_error(response)
      if response.code == 400
        parse(response.body)
      elsif response.code != 200
        {"error" => "unexpected error"}
      else
        nil
      end
    end

    def url_prefix
      "http://#{@@service_host}/api/v1"
    end

    def url_for_commentable(commentable)
      "#{url_prefix}/commentables/#{commentable.class.to_s.underscore.pluralize}/#{commentable.id}"
    end

    def url_top_level_comments(commentable)
      "#{url_for_commentable(commentable)}/comments"
    end

    def url_for_comment(comment_id)
      "#{url_prefix}/comments/#{comment_id}" 
    end

    def url_for_vote(comment_id, user_id)
      "#{url_prefix}/votes/comments/#{comment_id}/users/#{user_id}"
    end

    def parse(json)
      Yajl::Parser.parse(json)
    end
  end
end
