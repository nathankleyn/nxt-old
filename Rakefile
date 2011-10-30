require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rdoc/task'
require 'rspec/core/rake_task'

RDoc::Task.new do |rdoc|
  files =['README.markdown', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.markdown" # page to start on
  rdoc.title = "ruby_events Docs"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

RSpec::Core::RakeTask.new(:spec)

desc "NXT related tasks"
namespace :nxt do
  desc "Detect a connected NXT brick within /dev."
  task :detect do
    unless $DEV ||= ENV['NXT'] || ENV['DEV']
      begin
        devices = Dir["/dev/*NXT*"]
        if devices.size > 0
          $DEV = devices[0]
          puts "Detected a NXT brick at '#{$DEV}'."
        else
          puts "Could not detect any connected NXT bricks."
        end
      rescue
        # the /dev directory probably doesn't exist... maybe we're on Win32?
      end
    end
  end
end
