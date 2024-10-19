# SheetZoukas::Lambda

AWS Lambda wrapper for [sheet_zoukas](https://github.com/eebbesen/sheet_zoukas).

[sheet_zoukas](https://github.com/eebbesen/sheet_zoukas) converts Google Sheets to JSON. [sheet_zoukas-lambda](https://github.com/eebbesen/sheet_zoukas-lambda) serves [sheet_zoukas](https://github.com/eebbesen/sheet_zoukas) via AWS Lambda.

Reference implementation TBD.

## Installation

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

* Runtime Settings -> Edit
* Set Handler to `lib/sheet_zoukas/lambda.SheetZoukas::Lambda.lambda_handler`

### Create environment variables in AWS

* Configuration -> Environment Variables -> Edit -> Add environment variables
* Set vars required by [sheet_zoukas](https://github.com/eebbesen/sheet_zoukas) uses environment variables to authenticate a Google service account. See [the sheet_zoukas README](https://github.com/eebbesen/sheet_zoukas?tab=readme-ov-file#requirements) for more info. The logs/console will tell you which environment variables aren't set.

### Package code

For CI/CD use

    $ rake package:package

For local development you'll want bundler reset to include test and development

    $ rake package:package_dev

### Deploy code

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eebbesen/sheet_zoukas-lambda.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
