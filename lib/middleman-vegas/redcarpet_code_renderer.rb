require 'middleman-vegas/markdown_parser'

module Middleman
  module Vegas
    # A mixin for the Redcarpet Markdown renderer that will assist in finding
    # codeblocks and replacing them with rendered HTML.
    module RedcarpetCodeRenderer
      #
      # Traditionally you would enable code fences in RedCarpet and then
      # process it with #block_code function. But code blocks parsed that way
      # will not allow you to define metadata. So the entire document needs to
      # be examined.
      #
      # @see Middleman::Vegas::MarkdownParser
      def preprocess(full_document)
        MarkdownParser.parse_document full_document
      end
    end
  end
end
