require 'rouge'
require 'middleman-vegas/formatters/table_formatter'

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
        metadata[:lang] = with_lang_aliases_considered(metadata[:lang])
        TableFormatter.new.render(code, metadata)
      end

      def self.code_block_is_empty?(code)
        code == "" || code == "</div>"
      end

      def self.no_html
        ""
      end

      # When languages are provided they could be aliases for other languages
      # or the way that they are presented. With a few languages we want to
      # make sure that they are presented within the context of a console.
      def self.with_lang_aliases_considered(lang)
        case lang
        when 'cmd'
          'console?lang=powershell'
        when 'posh', 'powershell', 'shell', 'studio'
          "console?lang=#{lang}"
        when 'ps1'
          'powershell'
        else
          lang
        end
      end

    end
  end
end
