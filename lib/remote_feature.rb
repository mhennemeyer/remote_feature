require 'rubygems'
require 'rwriteboard'
require 'stringio'


class RemoteFeature
  attr_accessor :result,
                :writeboard,
                :name
  
  @@remote_features ||= []
  
  def @@remote_features.find(hash)
    memo = self
    hash.each do |k,v|
      memo = [memo.detect {|wb| wb.respond_to?(k.to_sym) && wb.send(k.to_sym) == v}]
    end
    memo.first
  end
  
  def initialize(writeboard)
    self.writeboard = writeboard
    self.name = writeboard.name
    @@remote_features << self
  end
  
  def run(cucumber_obj)
    wb_body = ""

    self.writeboard.logged_in do |wb|
      wb_body = wb.get.body
    end
    io = StringIO.new

    feature_string = wb_body.cut_runner_output
    
    cucumber_obj.instance_eval do
      require 'rubygems'
      require 'cucumber'
      require 'cucumber/treetop_parser/feature_en.rb'
      require 'cucumber/broadcaster.rb'

      Cucumber.load_language('en')
      # coloring stuff??
      formatters = Cucumber::Broadcaster.new [Cucumber::Formatters::ProgressFormatter.new(io)]
      parser = Cucumber::TreetopParser::FeatureParser.new
      feature = parser.parse(feature_string).compile
      features = Cucumber::Tree::Features.new
      features << feature
      original_formatters = @executor.formatters
      @executor.formatters = formatters
      @executor.visit_features(features)
      @executor.formatters = original_formatters
    end
    
    runner_output = io.string
    self.writeboard.logged_in do |wb|
      wb.body = feature_string + "<br /> <br /> ### RUNNER OUTPUT ### \n" + runner_output
      wb.post_without_revision
    end
    self.result = runner_output.compact
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
    remote_features.find(hash)
  end
  
  def self.remote_features
    @@remote_features
  end
end