require 'active_record'

namespace :db do
  task make_dirs: :environment do
    environment = Rails.env
    dir = "db/dumps/#{environment}"
    unless File.exist?(dir)
      puts "Directory created please rerun task."
      exec "mkdir -p #{dir}"
    end
  end

  desc "Delete dumpfile except latest"
  task dump_clean: :environment do
    environment = Rails.env
    days = []
    Dir.glob("db/dumps/#{environment}/*").each do |file|
      days << Date.parse(File.basename(file, '.dump'))
    end
    latest_file = "#{days.max}.dump"
    Dir.glob("db/dumps/#{environment}/*").each do |file|
      File.delete(file) unless File.basename(file) == latest_file
    end
  end

  desc "Dumps the database by date"
  task dump_all: [:environment,:load_config] do
    if Rails.env.development?
      Rake::Task["db:mysql:dump_all"].invoke
    else
      Rake::Task["db:postgres:dump_all"].invoke
    end
  end

  desc "Imort from dumpfile"
  task :import_all, ['name'] => [:environment,:load_config] do |task, args|
    args = args[:name]
    if Rails.env.development?
      if args.nil?
        Rake::Task["db:mysql:import_all"].invoke
      else
        Rake::Task["db:mysql:import_all"].invoke(args)
      end
    else
      if args[:name].nil?
        Rake::Task["db:postgres:import_all"].invoke
      else
        Rake::Task["db:postgres:import_all"].invoke(args)
      end
    end
  end

  namespace :mysql do
    desc "Dumps the database by date"
    task dump_all: [:environment,:load_config] do
      environment = Rails.env
      configuration = ActiveRecord::Base.configurations[environment]
      dump_file = "db/dumps/#{environment}/#{Date.today.strftime("%Y-%m-%d")}.dump"
      cmd = "mysqldump -h#{configuration['host']} -u #{configuration['username']} -p#{configuration['password']} #{configuration['database']} > #{dump_file}"
      puts cmd
      exec cmd
    end

    desc "Imort from dumpfile"
    task :import_all, ['name'] => [:environment,:load_config] do |task, args|
      environment = Rails.env
      configuration = ActiveRecord::Base.configurations[environment]

      if args[:name].nil?
        days = []
        Dir.glob("db/dumps/#{environment}/*").each do |file|
          days << Date.parse(File.basename(file, '.dump'))
        end
        import_file = "#{days.max}.dump"
      else
        import_file = "#{args[:name]}.dump"
      end

      dump_file = "db/dumps/#{environment}/#{import_file}"
      cmd = "mysql -h#{configuration['host']} -u #{configuration['username']} -p#{configuration['password']} #{configuration['database']} < #{dump_file}"
      puts cmd
      exec cmd
    end
    task dump_all: :make_dirs
  end

  namespace :postgres do
    desc "Dumps the database by date"
    task dump_all: [:environment,:load_config] do
      environment = Rails.env
      configuration = ActiveRecord::Base.configurations[environment]
      dump_file = "db/dumps/#{environment}/#{Date.today.strftime("%Y-%m-%d")}.dump"
      cmd = "PGPASSWORD=#{configuration['password']} pg_dump -h #{configuration['host']} -U #{configuration['username']} #{configuration['database']} > #{dump_file}"
      puts cmd
      exec cmd
    end

    desc "Imort from dumpfile"
    task :import_all, ['name'] => [:environment,:load_config] do |task, args|
      environment = Rails.env
      configuration = ActiveRecord::Base.configurations[environment]

      if args[:name].nil?
        days = []
        Dir.glob("db/dumps/#{environment}/*").each do |file|
          days << Date.parse(File.basename(file, '.dump'))
        end
        import_file = "#{days.max}.dump"
      else
        import_file = "#{args[:name]}.dump"
      end

      dump_file = "db/dumps/#{environment}/#{import_file}"
      cmd = "PGPASSWORD=#{configuration['password']} psql -h #{configuration['host']} -U #{configuration['username']} #{configuration['database']} < #{dump_file}"
      puts cmd
      exec cmd
    end
    task dump_all: :make_dirs
  end
end
