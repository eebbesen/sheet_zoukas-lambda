# SheetZoukas::Lambda

AWS Lambda wrapper for [sheet_zoukas](https://github.com/eebbesen/sheet_zoukas).

[sheet_zoukas](https://github.com/eebbesen/sheet_zoukas) converts Google Sheets to JSON. [sheet_zoukas-lambda](https://github.com/eebbesen/sheet_zoukas-lambda) serves [sheet_zoukas](https://github.com/eebbesen/sheet_zoukas) via AWS Lambda.

Reference implementation TBD.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

## Usage


## Development

Run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Release sheet_zoukas-lambda to RubyGems

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

To experiment with the code, run `bin/console` for an interactive prompt.

## Deploy to AWS

### Create AWS role

* create
* configure

### Create Lambda in AWS

### Create environment variables in AWS
[sheet_zoukas](https://github.com/eebbesen/sheet_zoukas) uses environment variables to authenticate a Google service account. See [the sheet_zoukas README](https://github.com/eebbesen/sheet_zoukas?tab=readme-ov-file#requirements) for more info.

### Package code

### Deploy code

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eebbesen/sheet_zoukas-lambda.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
