module Middleman
  module Vegas

    # When you want to render code in what looks like an editor this is your
    # formatter to use.
    class CodeFormatter

      def initialize
        @min_line_threshold_for_line_numbers = 2
        @default_title = ""
      end

      attr_reader :min_line_threshold_for_line_numbers, :default_title

      def render(lexed_code, metadata)

        # convert the metadata to rouge compatible keys
        # class to css_class
        # linenos to line_numbers

        formatter_options = {
          css_class: metadata[:class].to_s,
          line_numbers: metadata[:linenos],
          start_line: metadata[:start] || 1
        }

        # When its a really small amount of code do not show the line numbers
        # Remember that if you use the first comment for the title it counts

        if line_count(lexed_code) > min_line_threshold_for_line_numbers
          formatter_options[:line_numbers] = true
        else
          formatter_options[:css_class] += " no-lineno"
        end

        # Generate an HTML table with line numbers and then wrap it so
        # pygments will be able to properly apply its style.



        # formatter = Rouge::Formatters::HTMLLegacy.new(formatter_options)
        formatter = Rouge::Formatters::HTMLTable.new(Rouge::Formatters::HTML.new,formatter_options)

        inner_content = pygments_wrap formatter.format(lexed_code).strip, formatter_options[:css_class]

        # Place the code into HTML that will look like a code window.
        source_window inner_content, metadata[:title]
      end

      def line_count(lexed_code)
        lexed_code.find_all { |tk,val| val.include?("\n") }.count
      end

      def pygments_wrap(content, css_class)
        "<div class='#{css_class}'><pre class='code_wrapper'>#{content}</pre></div>"
      end

      # Wrap the content with HTML that will be styled in CSS.
      #
      # @note an empty title string will render an empty h1 which makes no title
      #   to display. This is the intended behavior for all the reference windows
      #   we have on the site.
      def source_window(content, title)
<<-EOH
<div class="window">
<h1 class="app-title">#{title}</h1>
<div class="contents">
  <div class="editor">
    #{content}
  </div>
</div>
</div>
EOH
      end
    end

  end
end
