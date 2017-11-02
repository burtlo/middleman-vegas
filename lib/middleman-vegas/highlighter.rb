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

        # From the language on the codefence find the formatter and
        # let the formatter perform the lexing (it will need to maintain language aliases)

        # The studio lexer would be deconstruct the studio prompt through a lexer
        # it could also find and tag particular elements of commands and put special
        # classes on them that could be something we could link from or provide
        # additional support.
        #
        # @see https://github.com/jneen/rouge/blob/master/lib/rouge/lexers/shell.rb


        # The windows lexer I want to support the "$ -> PS >" and support PS >
        #

        lexer = lexer_for_language(fence_name_to_language(language.to_s), code)

        metadata[:class] = [ metadata[:class].to_s, lexer.tag ].join(' ')

        lexed_code = lexer.lex(code, {})

        formatter = formatter_for_language(language.to_s)
        formatter.render(lexed_code, metadata)
      end

      def self.code_block_is_empty?(code)
        code == "" || code == "</div>"
      end

      def self.no_html
        ""
      end

      # Convert the code fences specified into their languages. This allows
      # a user to use convert a code fence like `console` or `terminal` as the
      # language `bash`.
      def self.fence_name_to_language(fence_name)
        case fence_name
        when 'console', 'shell', 'studio', 'terminal'
          'bash'
        when 'cmd', 'ps', 'ps1'
          'powershell'
        else
          fence_name
        end
      end

      # @return [Rouge::Lexer] that matches the provided language and code or
      #   default to processing this as plain text.
      def self.lexer_for_language(language, code)
        Rouge::Lexer.find_fancy(language, code) || Rouge::Lexers::PlainText
      end

      # @return [#render] based on the code fenced language return the type of
      #   renderer. @see Highlighter.formatters
      def self.formatter_for_language(language)
        formatters[language].new
      end

      # @return [Hash<#render>] a look-up table of all the types of renderers
      def self.formatters
        @formatters ||= begin
          hash = {
            "bash" => CodeFormatter,
            "conf" => CodeFormatter,
            "console" => TerminalFormatter,
            # "cmd" => TerminalFormatter({:prompt => ">", :window_style => "Win32" }),
            "diff" => CodeFormatter,
            "handlebars" => CodeFormatter,
            "html" => CodeFormatter,
            "json" => CodeFormatter,
            "js" => CodeFormatter,
          #   "plaintext" => DefaultFormatter,
            "powershell" => TerminalFormatter,
            "ps" => CodeFormatter,
            "ps1" => CodeFormatter,
            "ruby" => CodeFormatter,
          #   "sh" => TerminalFormatter,
            "shell" => TerminalFormatter,
          #   "studio" => StudioFormatter({:prompt => "[1][default:/src:0]#", :window_style => "hab-studio" }),
          #   "studio-win" => WindowsStudioFormatter({:prompt => "[HAB-STUDIO] Habitat:\\src>", :window_style => "hab-studio" }),
            "sql" => CodeFormatter,
            "toml" => CodeFormatter,
            "yaml" => CodeFormatter
          }

          hash.default = CodeFormatter
          hash
        end
      end

    end
  end
end
