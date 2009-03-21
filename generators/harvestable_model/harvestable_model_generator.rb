class HarvestableModelGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.directory "lib/daemons"
      m.file "daemons_extension.rb", "lib/daemons_extension.rb"
      m.file "daemons", "script/daemons", :chmod => 0755
      m.template "daemon.rb", "lib/daemons/#{file_name}.rb", :chmod => 0755
      m.template "daemon_ctl", "lib/daemons/#{file_name}_ctl", :chmod => 0755
      m.file "daemons.yml", "config/daemons.yml"
      
      m.template "model.rb",  File.join('app/models', class_path, "#{file_name}.rb")
      
      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
         :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
       }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
     end
    end
  end
end
