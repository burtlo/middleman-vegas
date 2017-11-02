require 'cgi'
require 'middleman-vegas/lexers/habitat_studio'

module Middleman
  module Vegas
    class TerminalFormatter
      def render(code, metadata)
        rendered_code = tableize_code(code, metadata)

        classnames = [ 'code-highlight-figure', metadata[:class].to_s ].join(' ')

        "<figure class='#{classnames}'>#{caption(metadata)}#{rendered_code}</figure>"
      end

      def with_lang_aliases_considered(lang)
        case lang
        when 'ps', 'ps1', 'cmd'
          'powershell'
        else
          lang
        end
      end

      def tableize_code(code, metadata)
        start = metadata[:start] || 1
        lines = metadata[:linenos] || false
        marks = metadata[:marks]
        language = with_lang_aliases_considered(metadata[:lang])

        table = "<div class='code-highlight'>"
        table += "<pre class='code-highlight-pre'>"
        code.lines.each_with_index do |line,index|

          classes = 'code-highlight-row'
          classes += lines ? ' numbered' : ' unnumbered'
          if marks.include? index + start
            classes += ' marked-line'
            classes += ' start-marked-line' unless marks.include? index - 1 + start
            classes += ' end-marked-line' unless marks.include? index + 1 + start
          end

          rendered_line = line_lexers.find { |lexer| lexer.find(line) }.new(metadata).render(language, line)
          line = line.strip.empty? ? ' ' : line
          classes += ' command' if metadata[:command_line]

          table += "<div data-line='#{index + start}' class='#{classes}'><div class='code-highlight-line'>#{rendered_line}</div></div>"
        end
        table +="</pre></div>"
      end

      def caption(metadata)
        if metadata[:title]
          figcaption  = "<figcaption class='code-highlight-caption'><span class='code-highlight-caption-title'>#{metadata[:title]}</span>"
          figcaption += "<a class='code-highlight-caption-link' href='#{metadata[:url]}'>#{(metadata[:link_text] || 'link').strip}</a>" if metadata[:url]
          figcaption += "</figcaption>"
        else
          ''
        end
      end

      def line_lexers
        [ CommandLineLexer , DefaultLineLexer ]
      end

      class CommandLineLexer
        def initialize(metadata)
          @metadata = metadata
        end

        attr_reader :metadata

        def self.find(line)
          line =~ /^\$\s*[\S]+/
        end

        def render(language, line)
          metadata[:command_line] = true
          metadata[:command_continues] = has_continuation?(line)
          formatter = Rouge::Formatters::HTML.new(wrap: false)
          puts "lex(#{language}) for #{line}"
          lexer = Rouge::Lexer.find_fancy(language, line)
          formatter.format(lexer.lex(line, {}))
        end

        # \ is Linux; ` is Windows PowerShell
        def has_continuation?(line)
          line = line.strip
          line.end_with?('\\') || line.end_with?('`')
        end
      end

      class DefaultLineLexer
        def initialize(metadata)
          @metadata = metadata
        end

        attr_reader :metadata

        def self.find(line)
          true
        end

        def render(language, line)
          if metadata[:command_continues]
            metadata[:command_line] = true
            metadata[:command_continues] = has_continuation?(line)
            CommandLineLexer.new(metadata).render(language, line)
          else
            metadata[:command_line] = false
            line
          end
        end

        # \ is Linux; ` is Windows PowerShell
        def has_continuation?(line)
          line = line.strip
          line.end_with?('\\') || line.end_with?('`')
        end
      end

    end
  end
end
