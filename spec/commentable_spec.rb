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

  it "should get all comments associated with the question" do
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

