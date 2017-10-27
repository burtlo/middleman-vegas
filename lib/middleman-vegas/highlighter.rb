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

      # The highlight method is called when using:
      #
      #    * markdown code fences
      #    * kramdown code fences
      #    * erb 'code' helper method
      #
      #       <% code('ruby', :line_numbers => true, :start_line => 7) do %>
      #         my code
      #       <% end %>
      #
      #    * slim 'code' helper method
      #
      #       = code(:yaml) do
      #         |
      #          version: '3'
      #          services:
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

        lexer = lexer_for_language(fence_name_to_language(language.to_s), code)

        metadata[:class] = [ metadata[:class].to_s, lexer.tag ].join(' ')
        # formatter_options = { css_class: [ metadata[:class].to_s, lexer.tag ].join(' ') }
        # TODO this probably needs to be read from the MIDDLEMAN extension settings
        lexer_options = {}
        # lexer_options = formatter_options.delete(:lexer_options)
        lexed_code = lexer.lex(code, lexer_options)

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
        formatters[language]
      end

      # @return [Hash<#render>] a look-up table of all the types of renderers
      def self.formatters
        @formatters ||= begin
          hash = {}
          #   "bash" => CodeFormatter.new,
          #   "conf" => CodeFormatter.new,
          #   "console" => TerminalFormatter.new,
          #   "cmd" => TerminalFormatter.new({:prompt => ">", :window_style => "Win32" }),
          #   "diff" => CodeFormatter.new,
          #   "handlebars" => CodeFormatter.new,
          #   "html" => CodeFormatter.new,
          #   "json" => CodeFormatter.new,
          #   "js" => CodeFormatter.new,
          #   "plaintext" => DefaultFormatter.new,
          #   "powershell" => TerminalFormatter.new({:prompt => "PS >", :window_style => "Win32" }),
          #   "ps" => CodeFormatter.new,
          #   "ps1" => CodeFormatter.new,
          #   "ruby" => CodeFormatter.new,
          #   "sh" => TerminalFormatter.new,
          #   "shell" => TerminalFormatter.new,
          #   "studio" => StudioFormatter.new({:prompt => "[1][default:/src:0]#", :window_style => "hab-studio" }),
          #   "studio-win" => WindowsStudioFormatter.new({:prompt => "[HAB-STUDIO] Habitat:\\src>", :window_style => "hab-studio" }),
          #   "sql" => CodeFormatter.new,
          #   "toml" => CodeFormatter.new,
          #   "yaml" => CodeFormatter.new
          # }

          hash.default = CodeFormatter.new
          hash
        end
      end

    end
  end
end
