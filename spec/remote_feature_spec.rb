require File.dirname(__FILE__) + '/spec_helper'

describe RemoteFeature do
  describe ".run" do
    it "should run the feature defined in the writeboard" do
      feature = 'Feature: FeaturesTitle\nHeader\nScenario: ScenarioTitle\n Given pending step'
      Writeboard.create({
        :name => "Feature One",
        :path => "/ef4c90d8796ee361e",
        :password => "123456"
      }) do |wb|
        wb.post_without_revision(:title => "First Feature", :body => feature)
      end
      RemoteFeature.run({
        :name => "Feature One",
        :path => "/ef4c90d8796ee361e",
        :password => "123456"
      })
      rf = RemoteFeature.find(:name => "Feature One")
      Writeboard.find(:name => "Feature One") do |wb|
        wb.get
        wb.body.split("### RUNNER OUTPUT ###").last.should eql(rf.result)
      end
    end
  end
  
  describe ".find(hash)" do
    it "should return a remote feature" do
      RemoteFeature.find(:name => "Feature One").should be_an_instance_of(RemoteFeature)
    end
  end
  
  describe "#result" do
    it "should return the runner output" do
      writeboard = mock("Writeboard", :body => "dumdidum ### RUNNER OUTPUT ### this is the result")
      Writeboard.should_receive(:find).and_return(writeboard)
      RemoteFeature.find(:name => "Name").result.should eql("this is the result")
    end
  end
end