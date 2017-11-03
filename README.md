# Middleman::Vegas

This brings the great styles and metadata support found in the Octopress Code Highlighter to Middleman. This has some additional features beyond that to support the work being done for Habitat.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'middleman-vegas'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install middleman-vegas

## Usage

Activate it to the Middleman `config.rb`:

```ruby
activate :vegas
```

## Syntax

You can define code fences as you would normally. These code fences have support for the languages defined in [rouge](https://github.com/jneen/rouge/wiki/List-of-supported-languages-and-lexers).

Define a code fence with a language.

    ```lang
    [code]
    ```

Define a code fence for a language with the addition of a title.

    ```lang title
    [code]
    ```

Define a code fence for a language with additional metadata

    ```lang [metadata]
    [code]
    ```

The additional metadata that can be specified:

| Metadata     | Example                    | Description                                                           |
|:-------------|:---------------------------|:----------------------------------------------------------------------|
|`lang`        | `ruby`                     | Used by the syntax highlighter. Passing 'plain' disables highlighting.|
|`title`       | `title:"Figure 1.A"`       | Add a figcaption title to your code block. |
|`url`         | `url:"https://github.com"` | No default value |
|`link_text`   | `link_text:"Download"`     | Text for the link, default: `"link"` |
|`linenos`     | `linenos:true`             | Enables line numbering |
|`start`       | `start:5`                  | Start the line numbering at the given value. |
|`mark`        | `mark:1-4,8`               | Highlight lines of code. This example marks lines 1,2,3,4 and 8 |
|`class`       | `class:"css example"`      | Add CSS class names to the code `<figure>` element |

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/burtlo/middleman-vegas. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Middleman::Octopress::Code::Highlighter project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/burtlo/middleman-vegas/blob/master/CODE_OF_CONDUCT.md).
