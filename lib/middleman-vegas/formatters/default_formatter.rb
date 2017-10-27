module Middleman
  module Vegas
    class DefaultFormatter
      def render(lexed_code, highlighter_options)
        formatter = Rouge::Formatters::HTMLLegacy.new(highlighter_options)
        pygments_wrap formatter.format(lexed_code), highlighter_options[:css_class]
      end

      def pygments_wrap(content,css_class)
        "<div class='#{css_class}'>
          <pre><code>#{content}</code></pre>
        </div>"
      end
    end
  end
end
