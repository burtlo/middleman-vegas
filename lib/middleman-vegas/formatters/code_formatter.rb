module Middleman
  module Vegas

    # When you want to render code in what looks like an editor this is your
    # formatter to use.
    class CodeFormatter
      def render(lexed_code, metadata)
        formatter = Rouge::Formatters::HTML.new(wrap: false)
        rendered_code = formatter.format(lexed_code)
        rendered_code = tableize_code(rendered_code, metadata)

        classnames = [ 'code-highlight-figure', metadata[:class].to_s ].join(' ')

        "<figure class='#{classnames}'>#{caption(metadata)}#{rendered_code}</figure>"
      end

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
