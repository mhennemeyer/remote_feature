dir = File.dirname(__FILE__)
require dir + "/../lib/remote_feature.rb"
require 'rubygems'
#require 'rwriteboard'
require "/Users/macbook/Projekte/rwriteboard/lib/rwriteboard.rb"
require 'cucumber'
require 'stringio'

$io ||= StringIO.new

$cucumber_obj = Object.new

$cucumber_obj.instance_eval do
  require 'rubygems'
  require 'cucumber'
  require 'cucumber/treetop_parser/feature_en.rb'
  require 'cucumber/broadcaster.rb'
  @step_mother = Cucumber::StepMother.new
  @executor = Cucumber::Executor.new(@step_mother)
  @formatters = Cucumber::Broadcaster.new [Cucumber::Formatters::ProgressFormatter.new($io)]
  @executor.formatters = @formatters
  @parser = Cucumber::TreetopParser::FeatureParser.new
  @features = Cucumber::Tree::Features.new
  @step_mother.register_step_proc(/100 Euro/){ false }
  $cucumber_context = binding()
end

  