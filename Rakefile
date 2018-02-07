# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

load 'etude_for_ops/tasks/ops.rake' if Rails.env.development?

Rails.application.load_tasks
