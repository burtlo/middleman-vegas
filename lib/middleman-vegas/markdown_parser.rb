require 'middleman-vegas/options_parser'

module Middleman
  module Vegas
    module MarkdownParser
      # Evaluate the entire document and look code blocks:
      #
      #     ```LANGUAGE METADATA
      #     CODE
      #     ```
      def self.parse_document(full_document)
        full_document.gsub /^\s{0,4}`{3}.+?`{3}/m do |code_block|
          parse_code_block code_block
        end
      end

      # Extract from the code block the metadata and the code and highlight it.
      #
      #     ```LANGUAGE METADATA
      #     CODE
      #     ```
      #
      def self.parse_code_block(code_block)
        code_block.gsub /(\s{0,4})`{3}([^\n]+)?\n(.+?)`{3}\Z/m do
          spacing = Regexp.last_match(1)
          spacing = (spacing == "\n" ? "" : spacing)
          metadata = get_metadata(Regexp.last_match(2).to_s)
          code = Regexp.last_match(3).to_s
          trimmed_code = code.gsub("\n#{spacing}","\n")[spacing.length..-1]
          "#{spacing}#{::Middleman::Vegas::Highlighter.highlight(trimmed_code, metadata)}"
        end
      end

      AllOptions = /([^\s]+)\s+(.+?)\s+(https?:\/\/\S+|\/\S+)\s*(.+)?/i
      LangCaption = /([^\s]+)\s*(.+)?/i

      # Extract the metadata from the code block. There are two simple formats:
      #
      #     ```LANGUAGE TITLE
      #
      #     ```LANGUAGE TITLE URL LINK_TEXT
      #
      #
      def self.get_metadata(markup)
        defaults = { escape: true }
        clean_markup = OptionsParser.new(markup).clean_markup

        if clean_markup =~ AllOptions
          defaults = {
            lang: $1,
            title: $2,
            url: $3,
            link_text: $4,
          }
        elsif clean_markup =~ LangCaption
          defaults = {
            lang: $1,
            title: $2
          }
        end
        OptionsParser.new(markup).parse_markup(defaults)
      end
    end
  end
end
