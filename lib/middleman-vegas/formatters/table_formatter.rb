module Middleman
  module Vegas

    # When you want to render code with a title, a link, line numbers and highlights
    # in a table style.
    class TableFormatter
      def render(code, metadata)
        lexer = Rouge::Lexer.find_fancy(metadata[:lang], code) || Rouge::Lexers::PlainText
        lexed_code = expand_tokens_with_newlines(lexer.lex(code, {}))

        formatter = Rouge::Formatters::HTML.new(wrap: false)
        rendered_code = formatter.format(lexed_code)
        rendered_code = tableize_code(rendered_code, metadata)

        classnames = [ 'code-highlight-figure', metadata[:class].to_s ].join(' ')

        "<figure class='#{classnames}'>#{caption(metadata)}#{rendered_code}</figure>"
      end

      # The lexed code generates an enumerator of tokens with their values.
      # Before they are rendered to HTML all of the non-text tokens with newlines
      # should be split into several tokens of the same type. This ensures
      # that when they are tableized later the surrounding spans are not broken.
      def expand_tokens_with_newlines(lexed_code)
        full_lex = []
        lexed_code.each do |token, value|
          if token.qualname == "Text"
            full_lex << [ token, value ]
          else
            lines = value.split("\n")
            lines.each_with_index do |line, index|
              # if not the last line or the last line had a newline at the end
              suffix = if index < (lines.length - 1) || (index == (lines.length - 1) && value.end_with?("\n"))
                "\n"
              else
                ""
              end

              full_lex << [ token, "#{line}#{suffix}" ]
            end
          end
        end
        full_lex
      end

      # Given the rendered code it is time to present the information in a table.
      def tableize_code(code, options)
        start = options[:start] || 1
        lines = options[:linenos] || false
        marks = options[:marks]

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
          line = line.strip.empty? ? ' ' : line
          table += "<div data-line='#{index + start}' class='#{classes}'><div class='code-highlight-line'>#{line}</div></div>"
        end
        table +="</pre></div>"
      end

      # Generates a caption above the code area when there is a title / url
      def caption(options)
        if options[:title]
          figcaption  = "<figcaption class='code-highlight-caption'><span class='code-highlight-caption-title'>#{options[:title]}</span>"
          figcaption += "<a class='code-highlight-caption-link' href='#{options[:url]}'>#{(options[:link_text] || 'link').strip}</a>" if options[:url]
          figcaption += "</figcaption>"
        else
          ''
        end
      end

    end
  end
end
