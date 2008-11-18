require File.dirname(__FILE__) + '/spec_helper'

def cucumber_object
  eval("$cucumber_obj", $cucumber_context)
end

describe RemoteFeature do
  describe ".run" do
    it "should run the feature defined in the writeboard" do
      feature = "Feature: FeaturesTitle\nHeader\nScenario: ScenarioTitle\n Given pending step"
      sep_patt = "->Output"
      Writeboard.create({
        :name => "Feature One",
        :path => "/ef4c90d8796ee361e",
        :password => "Ql5L47DZs9SPhYj"
      }) do |wb|
        wb.post_without_revision(:title => "First Feature", :body => feature)
      end
      RemoteFeature.run(cucumber_object, {
        :name => "Feature One",
        :path => "/ef4c90d8796ee361e",
        :password => "Ql5L47DZs9SPhYj",
        :output_separator => sep_patt,
        :language => "en"
      })
      rf = RemoteFeature.find(:name => "Feature One")
      Writeboard.find(:name => "Feature One") do |wb|
        wb.get
        wb.body.split(sep_patt).last.gsub(%r(\A([^P])*),"").should eql(rf.result)
      end
    end
  end
  
  describe "remote_features.find(hash)" do
    describe "returns the first remote_feature that matches all conditions defined by name value pairs in the arg hash" do
      describe "@@remote_features empty" do
        it "should return nil if @@remote_features is empty" do
          RemoteFeature.remote_features.find(:name => "value").should be_nil
        end
      end
      describe "@@remote_features contains a remote_feature" do
        before(:each) do
          @writeboard = mock("Writeboard", :name => "value")
          @rf = RemoteFeature.new(@writeboard)
        end
        
        it "should return existing remote_feature with name value" do
          RemoteFeature.remote_features.find(:name => "value").should eql(@rf)
        end
        
        it "should return nil if hash contains value that doesn't match remote_feature" do
          RemoteFeature.remote_features.find(:name => "nonexistant").should be_nil
        end
        
        it "should return nil if hash contains name pair that doesn't match remote_feature" do
          RemoteFeature.remote_features.find(:nonexistant => "nonexistant").should be_nil
        end
      end
    end
  end
  
  describe ".find(hash)" do
    it "should return a remote feature" do
      RemoteFeature.find(:name => "Feature One").should be_an_instance_of(RemoteFeature)
    end
  end
  
  # describe "#result" do
  #   it "should return the runner output" do
  #     writeboard = mock("Writeboard", :body => "dumdidum ### RUNNER OUTPUT ### this is the result")
  #     Writeboard.should_receive(:find).and_return(writeboard)
  #     RemoteFeature.find(:name => "Name").result.should eql("this is the result")
  #   end
  # end
end