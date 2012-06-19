require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "CommentClient" do
  before :each do
    api_base_url = "http://localhost:4567/api/v1"
    Question.delete_all
    question = Question.create!
    RestClient.get "#{api_base_url}/clean" # Helper api to clean the database. Only valid in development mode
    comment1 = RestClient.post "#{api_base_url}/commentables/questions/#{question.id}/comments", :body => "top comment", :title => "top 0", :user_id => 1, :course_id => 1
    comment1 = Yajl::Parser.parse(comment1.body)["comment"]
    comment2 = RestClient.post "#{api_base_url}/commentables/questions/#{question.id}/comments", :body => "top comment", :title => "top 1", :user_id => 1, :course_id => 1
    comment2 = Yajl::Parser.parse(comment2.body)["comment"]
    sub_comment1 = RestClient.post "#{api_base_url}/comments/#{comment1["id"]}", :body => "comment body", :title => "comment title 0", :user_id => 1, :course_id => 1
    sub_comment2 = RestClient.post "#{api_base_url}/comments/#{comment2["id"]}", :body => "comment body", :title => "comment title 1", :user_id => 1, :course_id => 1
  end

  describe "#comments_for(commentable)" do
    it "should get all comments associated with the commentable object" do
      question = Question.first
      comments = CommentClient.comments_for(question)
      comments.length.should == 2
      comment1, comment2 = comments
      comment1["body"].should == "top comment"
      comment1["title"].should == "top 0"
      comment2["title"].should == "top 1"
      comment1["children"].length.should == 1
      comment2["children"].length.should == 1
      comment2["children"].first["title"].should == "comment title 1"
    end
  end

  describe "#delete_thread(commentable)" do
    it "should remove all comments associated with the commentable object" do
      question = Question.first
      errors = CommentClient.delete_thread(question)
      errors.should be_nil
      CommentClient.comments_for(question).length.should == 0
    end
  end

  describe "#add_comment(commentable, comment_hash)" do
    it "adds a top-level comment" do
      question = Question.first
      errors = CommentClient.add_comment(question, :body => "top comment", :title => "top 2", :user_id => 1, :course_id => 1)
      errors.should be_nil
      CommentClient.comments_for(question).length.should == 3
    end
    it "adds a sub-comment to the comment" do
      question = Question.first
      comments = CommentClient.comments_for(question)
      errors = CommentClient.reply_to(comments[0]["id"], :body => "comment body", :title => "comment title 2", :user_id => 1, :course_id => 1)
      errors ||= CommentClient.reply_to(comments[1]["id"], :body => "comment body", :title => "comment title 3", :user_id => 1, :course_id => 1)
      errors.should be_nil
      CommentClient.comments_for(question).first["children"].length.should == 2
    end
  end

  describe "#update_comment(comment_id, comment_hash)" do
    it "updates the comment" do
      question = Question.first
      comment = CommentClient.comments_for(question).first
      errors = CommentClient.update_comment(comment["id"], :body => "updated")
      errors.should be_nil
      CommentClient.comments_for(question).collect{|c| c["body"]}.include?("updated").should be_true
    end
    it "does not update invalid attributes" do
      question = Question.first
      comment = CommentClient.comments_for(question).first
      errors = CommentClient.update_comment(comment["id"], :id => "100")
      CommentClient.comments_for(question).collect{|c| c["id"].to_s}.include?("100").should be_false
    end
  end

  describe "#delete_comment(comment_id)" do
    it "deletes the comment with id comment_id together with its sub-comments" do
      question = Question.first
      comment = CommentClient.comments_for(question).first
      errors = CommentClient.delete_comment(comment["id"])
      errors.should be_nil
      CommentClient.comments_for(question).length == 1
    end
  end

  describe "#vote_comment(vote, comment_id)" do
    it "votes on the comment" do
    end
  end

  describe "#unvote_comment(comment_id)" do
    it "unvotes on the comment" do
    end
  end

end
