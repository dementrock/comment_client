require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "A class that is commentable" do
  before :each do
    api_base_url = "http://localhost:4567/api/v1"
    Question.delete_all
    question = Question.create!
    RestClient.get "#{api_base_url}/clean" # Helper api to clean the database
    comment1 = RestClient.post "#{api_base_url}/commentables/questions/#{question.id}/comments", :body => "top comment", :title => "top 0", :user_id => 1, :course_id => 1
    comment1 = Yajl::Parser.parse(comment1.body)["comment"]
    comment2 = RestClient.post "#{api_base_url}/commentables/questions/#{question.id}/comments", :body => "top comment", :title => "top 1", :user_id => 1, :course_id => 1
    comment2 = Yajl::Parser.parse(comment2.body)["comment"]
    sub_comment1 = RestClient.post "#{api_base_url}/comments/#{comment1["id"]}", :body => "comment body", :title => "comment title 0", :user_id => 1, :course_id => 1
    sub_comment2 = RestClient.post "#{api_base_url}/comments/#{comment2["id"]}", :body => "comment body", :title => "comment title 1", :user_id => 1, :course_id => 1
  end

  describe "#comments" do
    it "should get all comments associated with the commentable object" do
      question = Question.first
      comments = question.comments
      comments.length.should == 2
      comment1, comment2 = comments
      comment1.body.should == "top comment"
      comment1.title.should == "top 0"
      comment2.title.should == "top 1"
      comment1.children.length.should == 1
      comment2.children.length.should == 1
      comment2.children.first.title.should == "comment title 1"
    end
  end

  describe "#delete_thread" do
    it "should remove all comments associated with the commentable object" do
      question = Question.first
      question.delete_thread
      question.comments.length.should == 0
    end
  end

  describe "#add_comment(comment, parent_id)" do
    it "adds a top-level comment" do
      question = Question.first
      comment = question.add_comment :body => "top comment", :title => "top 2", :user_id => 1, :course_id => 1
      comment.valid?.should be_true
      question.comments.length.should == 3
    end
    it "does not add an invalid comment" do
      question = Question.first
      comment = question.add_comment :body => "title", :title => "title", :user_id => nil, :course_id => nil
      comment.valid?.should be_false
      question.comments.length.should == 2
    end
    it "adds a sub-comment to the comment" do
      question = Question.first
      comment = question.comments.first
      sub_comment = question.add_comment(:body => "comment body", :title => "comment title 2", :user_id => 1, :course_id => 1, comment.id)
      sub_comment.errors.should be_nil
      question.comments.first.children.length.should == 2
    end
  end

  describe "#update_comment(comment, comment_id)" do
    it "updates the comment" do
      question = Question.first
      comment = question.comments.first
      question.update_comment(comment.id, :body => "updated")
      question.comments.collect {|c| c.body}.include?("updated").should be_true
    end
    it "raises error when called with invalid attributes" do
      question = Question.first
      comment = question.comments.first
      expect {question.update_comment(comment.id, :id => 100)}.should raise_error
    end
  end

  describe "#delete_comment(comment_id)" do
    it "deletes the comment with id comment_id together with its sub-comments" do
      question = Question.first
      comment = question.comments.first
      question.delete_comment(comment.id)
      question.comments.length.should == 1
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
