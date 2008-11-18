require 'rubygems'
#require 'rwriteboard'
require 'stringio'


class RemoteFeature
  attr_accessor :result,
                :writeboard,
                :name,
                :output_separator
  
  @@remote_features ||= []
  
  def @@remote_features.find(hash)
    memo = self
    hash.each do |k,v|
      memo = [memo.detect {|rf| !rf.nil? && rf.respond_to?(k.to_sym) && rf.send(k.to_sym) == v}]
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

    feature_string = wb_body.cut_runner_output(self.output_separator).gsub(%r(\\n),"\n")
    raise "Writeboard is empty" if feature_string.empty?
    cucumber_obj.instance_eval do
      # TODO user chooses language
      Cucumber.load_language('en')
      ::Term::ANSIColor.coloring = false
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
      wb.body = feature_string + "\n \n #{self.output_separator} \n" + runner_output
      wb.post_without_revision
    end
    self.result = runner_output.compact
  end
  
  def self.run(cucumber_obj, hash)
    raise "inadequate writeboard parameters" unless hash[:name] && hash[:path] && hash[:password]
    wb_parameters = {:name => hash[:name], :path => hash[:path], :password => hash[:password]}
    unless wb = Writeboard.writeboards.find(wb_parameters)
      Writeboard.create(wb_parameters)
      wb = Writeboard.writeboards.find(wb_parameters)
    end
    raise "I wasn't able to create a reference to the Writeboard #{hash}" unless wb
    rf = self.new(wb)
    rf.output_separator = hash[:output_separator] || "RUNNER OUTPUT"
    rf.run(cucumber_obj)
  end
  
  def self.find(hash)
    remote_features.find(hash)
  end
  
  def self.remote_features
    @@remote_features
  end
end