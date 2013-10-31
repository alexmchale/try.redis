# encoding: utf-8

task :default => :test

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.options = "-v"
  t.test_files = FileList["test/test_*.rb"]
end
