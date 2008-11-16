require 'stringio'

class RemoteFeature
  attr_accessor :result,
                :writeboard
  
  @@remote_features ||= []
  
  def initialize(writeboard)
    self.writeboard = writeboard
    remote_features << self
  end
  
  def run()
    wb_body = ""
    self.writeboard.logged_in do |wb|
      wb_body = wb.get.body
    end
    io = StringIO.new

    feature_string = wb_body.cut_runner_output
    formatters = Cucumber::Broadcaster.new [Cucumber::Formatters::ProgressFormatter.new(io)]
    parser = Cucumber::TreetopParser::FeatureParser.new
    feature = parser.parse(string).compile
    features = Cucumber::Tree::Features.new
    features << feature
    original_formatters = @executor.formatters
    @executor.formatters = formatters
    @executor.visit_features(features)
    @executor.formatters = original_formatters
    runner_output = io.string
    Writeboard.by_name "Feature1" do |wb|
      wb.post_without_revision(string + "<br /> ### RUNNER OUTPUT ### \n" + runner_output)
    end
    
  end
  
  def self.run(cucumber_obj, hash)
    unless wb = Writeboard.writeboards.find(hash)
      Writeboard.create(hash)
      wb = Writeboard.writeboards.find(hash)
    end
    rf = self.new(wb)
    rf.run(cucumber_obj)
  end
  
  def self.find(hash)
    
  end
  
  def self.remote_features
    @@remote_features
  end
end