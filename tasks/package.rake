# rubocop:disable Metrics/BlockLength
# frozen_string_literal: true

# tasks to packaging for AWS Lambda
namespace :package do
  desc 'package from development machine'
  task package_dev: %i[package cleanup]

  desc 'test before packaging'
  task :test do
    sh 'bundle config unset --local path'
    sh 'bundle install'
    sh 'bundle exec rake spec'
  end

  desc 'package for deployment to AWS Lambda'
  task package: :test do
    sh 'mkdir -p pkg'
    sh 'bundle config unset --local with'
    sh 'bundle config set --local without development:test'
    sh 'bundle config set --local path vendor/bundle'
    sh 'bundle install'
    slug = %x(git rev-parse HEAD).strip # rubocop:disable Style/CommandLiteral
    sh "zip -r pkg/sheet_zoukas-lambda-#{slug}.zip lib/sheet_zoukas vendor"
  end

  desc 'reset for development after packaing'
  task :cleanup do
    sh 'rm -rf vendor'
    sh 'bundle config unset --local path'
    sh 'bundle config unset --local without'
    sh 'bundle config set --local with development:test'
    sh 'bundle install'
  end
end

# rubocop:enable Metrics/BlockLength
