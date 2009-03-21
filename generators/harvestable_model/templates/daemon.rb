#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__)) + '/../../config/boot'
rails_root = File.expand_path RAILS_ROOT

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

Dir.chdir(rails_root)
require "config/environment"

$running = true
Signal.trap("TERM") do 
  $running = false
end

#Preload models that might be in the cache
<%= class_name %>

while($running) do
  ActiveRecord::Base.logger.info "Running <%= class_name %> Cache Recorder"
  <%= class_name %>.save_from_cache

  # Add anything else you may need to do here after the items have been harvested
  
  if Rails.cache.read(<%= class_name %>.index_max, :raw => true).to_i > 100000000
    <%= class_name %>.reset_indexes
  end
  
  # Defaults to 2 minutes between harvests.   Increase or decrease as necessesary.   
  sleep 120
end