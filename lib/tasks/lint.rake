# frozen_string_literal: true

begin
  require 'rubocop/rake_task'
  require 'haml_lint/rake_task'

  namespace :lint do
    desc 'Run security lint checks with Brakeman'
    task :security do
      require 'brakeman'
      Brakeman.run(app_path: Rails.root)
    end

    # Run Ruby code style lint checks
    RuboCop::RakeTask.new :ruby

    # Run Haml code style lint checks
    HamlLint::RakeTask.new :haml

    desc 'Run ESLint JavaScript lint checks'
    task :js do
      sh 'yarn exec eslint app/javascript'
    end

    desc 'Run Stylelint CSS lint checks'
    task :css do
      sh 'yarn exec stylelint app/assets/stylesheets'
    end
  end

  desc 'Run lint checks on all source code'
  task lint: %i[
    lint:security
    lint:ruby
    lint:haml
    lint:js
    lint:css
  ]
rescue LoadError => error
  task :lint do
    puts "Skipping lint checks: #{error.message}"
  end
end
