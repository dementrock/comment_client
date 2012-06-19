module Acts
  module CommentableWithService
    class Comment
      attr_accessor :user_id, :course_id, :body, :title, :id, :comment_thread_id, :children

      def initialize(attributes={})
        self.attributes = attributes
      end

      def attributes=(attrs)
        attrs.each_pair {|k, v| send("#{k}=", v)}
      end

      def self.from_json(json)
        comment = self.new(
          :user_id => json["user_id"], :course_id => json["course_id"], :body => json["body"],
          :id => json["id"], :comment_thread_id => json["comment_thread_id"], :title => json["title"])
        comment.children = json["children"].map {|child| from_json(child)}
        comment
      end
    end
  end
end
