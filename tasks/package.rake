# frozen_string_literal: true

namespace :package do
  desc 'package from development machine'
  task package_dev: %i[package cleanup]

  desc 'setup for packaging'
  task :setup do
    sh 'bundle install'
    sh 'bundle exec rake spec'
    sh "bundle config set --local path 'vendor/bundle'"
    sh "bundle config set --local without ['test' 'development']"
    sh 'mkdir -p pkg'
  end

  desc 'package for deployment to AWS Lambda'
  task package: :setup do
    slug = %x(git rev-parse HEAD) # rubocop:disable Style/CommandLiteral
    sh "zip -r pkg/sheet_zoukas-lambda-#{slug.strip}.zip lib/sheet_zoukas vendor"
  end

  desc 'reset for development after packaing'
  task :cleanup do
    sh 'rm -rf vendor'
    sh 'bundle config unset --local path'
    sh 'bundle config unset --local without'
    sh "bundle config set --local with ['development' 'test']"
    sh 'bundle install '
  end
end
