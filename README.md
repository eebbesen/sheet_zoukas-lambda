# SheetZoukas::Lambda

Deploy to AWS Lambda to expose Google Sheets as JSON via HTTPS. AWS Lambda wrapper for [sheet_zoukas](https://github.com/eebbesen/sheet_zoukas).

![Tests](https://github.com/eebbesen/sheet_zoukas-lambda/actions/workflows/test.yml/badge.svg)

[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)

[sheet_zoukas](https://github.com/eebbesen/sheet_zoukas) converts Google Sheets to JSON. [sheet_zoukas-lambda](https://github.com/eebbesen/sheet_zoukas-lambda) serves [sheet_zoukas](https://github.com/eebbesen/sheet_zoukas) via AWS Lambda.

Reference implementation TBD.

## Installation

## Usage

Deploy to AWS Lambda to expose Google Sheets as JSON.

Use with a request body (URL differs for each Lambda)

    $ curl -v 'https://a1aaa1aaaaaaaaaaaaaa1zzzzz1zzzzz.lambda-url.us-east-1.on.aws' \
      -H 'content-type: application/json' \
      -d '{ "sheet_id": "<GOOGLE_SHEET_ID>", "tab_name": "<TAB_NAME>" }'

Use with query string parameters

    $ curl -v 'https://a1aaa1aaaaaaaaaaaaaa1zzzzz1zzzzz.lambda-url.us-east-1.on.aws?sheet_id=<GOOGLE_SHEET_ID>&tab_name=<TAB_NAME>'

Use with environment variables in AWS Lambda as default values.

    $ curl -v 'https://a1aaa1aaaaaaaaaaaaaa1zzzzz1zzzzz.lambda-url.us-east-1.on.aws/defaults'

You can use defaults and still pass in values to override the environment variables. For example, with `SHEET_ID` and `TAB_NAME` set as an environment variable in Lambda the following will use the SHEET_ID but override the TAB_NAME:

    $ curl -v 'https://a1aaa1aaaaaaaaaaaaaa1zzzzz1zzzzz.lambda-url.us-east-1.on.aws/defaults' \
      -H 'content-type: application/json' \
      -d '{ "tab_name": "<TAB_NAME>" }'

    $ curl -v 'https://a1aaa1aaaaaaaaaaaaaa1zzzzz1zzzzz.lambda-url.us-east-1.on.aws/defaults?tab_name=<TAB_NAME>'

## Development

    $ bundle install
    $ rake spec

## Deploy to AWS

### Create AWS role

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

Upload the zip file to the Lambda.

### Test code

Modify spec/fixtures/lambda_tests to have valid values and execute the tests in the Lambda console.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eebbesen/sheet_zoukas-lambda.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
