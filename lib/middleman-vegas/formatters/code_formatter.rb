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

      def render(lexed_code, highlighter_options, style_options = {})

        # When its a really small amount of code do not show the line numbers
        # Remember that if you use the first comment for the title it counts

        if line_count(lexed_code) > min_line_threshold_for_line_numbers
          highlighter_options.merge!(:line_numbers => true)
        else
          highlighter_options[:css_class] += " no-lineno"
        end

        # The first comment within the code block will be used as a comment

        lexed_code, title = extract_title_from_first_comment(lexed_code)

        # Generate an HTML table with line numbers and then wrap it so
        # pygments will be able to properly apply its style.

        formatter = Rouge::Formatters::HTMLLegacy.new(highlighter_options)

        inner_content = pygments_wrap formatter.format(lexed_code).strip, highlighter_options[:css_class]

        # Place the code into HTML that will look like a code window.
        source_window inner_content, title, style_options[:window_style]
      end

      def line_count(lexed_code)
        lexed_code.find_all { |tk,val| val.include?("\n") }.count
      end

      # Examine the lexed code and determine if the first line is comment.
      # The first comment should be treated as a title.
      def extract_title_from_first_comment(lexed_code)
        token_type, token_content = lexed_code.first

        if comment_token?(token_type)
          [ remove_first_comment(lexed_code), strip_comment_content(token_content) ]
        else
          [ lexed_code, default_title ]
        end
      end

      # Sometimes the token type is Token.Comment.Single or Token.Comment
      def comment_token?(token)
        token.name == :Comment || token.parent.name == :Comment
      end

      def remove_first_comment(lexed_code)
        commentless_lexed_code = lexed_code.to_a[1..-1]

        # After removing the title/filepath defined in the comment
        # a text token remains. If it has a newline within it
        # then we want to remove it but preserve any whitespace
        # that follows it.
        token_type, token_value = commentless_lexed_code.first
        if token_type.name == :Text && token_value =~ /^\n/
          [ [token_type, token_value.gsub(/^\n/,'')] ] + commentless_lexed_code[1..-1]
        else
          commentless_lexed_code
        end
      end

      # This method is going to clean up the comment provided and remove the
      # any comment characters at the beginning of the line and at the end.
      #
      #     # path/to/filename.rb
      #     <!-- path/to/filename.erb -->
      #     -- path/to/filename.sql
      #     // path/to/filename.php
      #     ; path/to/filename.ini
      #
      def strip_comment_content(content)
        content.gsub(/^\s*(?:#|;|<!--|--|\/\/)\s*/,"").gsub(/\s*-->\s*$/,"")
      end


      def pygments_wrap(content, css_class)
        "<div class='#{css_class}'><pre class='code_wrapper'>#{content}</pre></div>"
      end

      # Wrap the content with HTML that will be styled in CSS.
      #
      # @note an empty title string will render an empty h1 which makes no title
      #   to display. This is the intended behavior for all the reference windows
      #   we have on the site.
      def source_window(content, title, window_style)
<<-EOH
<div class="window #{window_style}">
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
