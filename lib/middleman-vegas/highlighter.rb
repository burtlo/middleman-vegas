require 'rouge'
require 'middleman-vegas/formatters/code_formatter'
require 'middleman-vegas/formatters/default_formatter'
require 'middleman-vegas/formatters/studio_formatter'
require 'middleman-vegas/formatters/terminal_formatter'
require 'middleman-vegas/formatters/windows_studio_formatter'

module Middleman
  module Vegas
    module Highlighter
      mattr_accessor :options

      # The highlight method is called when code fences are used in RedCarpet
      # and when the code helper is used.
      #
      # @param code [String] the content found within the code block
      # @param options [Hash] contains any additional rendering options provided
      #    to the code helper methods, as code fences don't have a way to
      #    provide additional parameters.
      #
      # @return the HTML that will be rendered to the page
      def self.highlight(code, metadata={})
        return no_html if code_block_is_empty?(code.strip)
        language = metadata[:lang]
        formatter(language).render(code, metadata)
      end

      def self.code_block_is_empty?(code)
        code == "" || code == "</div>"
      end

      def self.no_html
        ""
      end

      def self.formatter(language)
        Array(formatters.find { |formatter, languages| formatter if languages.include?(language) }).first || default_formatter
      end

      def self.formatters
        @formatters ||= begin
          [
            [ TerminalFormatter.new, %w[ cmd console powershell shell studio ] ],
            [ CodeFormatter.new, %w[ bash conf diff handlebars html json js ps1 ruby sql toml yaml ] ]
          ]
        end
      end

      def self.default_formatter
        @default_formatter ||= CodeFormatter.new
      end

    end
  end
end
