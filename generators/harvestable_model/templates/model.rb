class <%= class_name %> < ActiveRecord::Base
  cache_harvestable
<% attributes.select(&:reference?).each do |attribute| -%>
  belongs_to :<%= attribute.name %>
<% end -%>
end