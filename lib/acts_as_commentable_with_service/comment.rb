require 'active_model'

module Acts
  module CommentableWithService
    class Comment

      include ActiveModel::Validations

      @@accessible_attrs = [:user_id, :course_id, :body, :title, :id, :comment_thread_id, :children, :created_at, :updated_at]

      attr_accessor *@@accessible_attrs

      validates_presence_of :user_id, :course_id, :body, :title

      def initialize(attributes={})
        self.attributes = attributes
        if attributes[:children]
          self.children = (attributes[:children] || []).map {|child| self.class.from_hash(child)}
        end
      end

      def attributes=(attrs)
        attrs.each_pair {|k, v| send("#{k}=", v)}
      end

      def self.from_hash(hash)
        symbol_hash = hash.inject({}){|h, (k, v)| h[k.intern] = v; h}.select{|k, v| @@accessible_attrs.include?(k)}
        new(symbol_hash)
      end
    end
  end
end
