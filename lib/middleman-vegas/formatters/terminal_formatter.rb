require 'cgi'

module Middleman
  module Vegas
    class TerminalFormatter
      def initialize(options = {:prompt => "$", :window_style => "" })
        @prompt = options[:prompt]
        @window_style = options[:window_style]
        @default_title = ""
      end

      attr_reader :default_title

      def render(lexed_code, highlighter_options)
        lexed_code, title = extract_title_from_first_comment(lexed_code)
        prompt_content = promptize(lexed_code)
        terminal_window prompt_content, title
      end

      # Examine the lexed code and determine if the first line is comment.
      # The first comment should be treated as a title.
      def extract_title_from_first_comment(lexed_code)
        token_type, token_content = lexed_code.first

        if comment_token?(token_type) && ! is_shebang?(token_content)
          [ remove_first_comment(lexed_code), strip_comment_content(token_content) ]
        else
          [ lexed_code, default_title ]
        end
      end

      # Sometimes the token type is Token.Comment.Single or Token.Comment
      def comment_token?(token)
        token.name == :Comment || token.parent.name == :Comment
      end

      def is_shebang?(content)
        content =~ /^#!/
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

      def promptize(content)

        gutters = []
        lines_of_code = []

        # unroll the content into a single text buffer
        buffer = content.map { |token,text| text }.join

        # process escape characters & split into lines
        lines = CGI.escapeHTML(buffer.strip).split("\n")
        # process each line
        in_command = false
        lines.each do |line|
          if line.length > 1 && line.start_with?('$ ')
            # begins with prompt, so push prompt character onto gutter and add the remaining
            # line to the lines of code

            # TODO Special case for InSpec shell commands. We may want to generalize/refactor this.
            if line.start_with?(inspec_prompt)
              gutters.push gutter(inspec_prompt)
              len = inspec_prompt.length + 1
              line = line.length > len ? line[len..-1] : ""
            else
              gutters.push gutter(@prompt)
              line = line.length > 2 ? line[2..-1] : ""
            end

            lines_of_code.push line_of_code(line, true, false)
            in_command = is_continuation?(line)
          else
            # no gutter, so just push a space onto gutter and add the entire
            # line to the lines of code
            gutters.push gutter("&nbsp;")
            line = "&nbsp;" if line == "" # html requires that a blank space
            lines_of_code.push line_of_code(line, in_command, !in_command && line == "[...]")
            in_command = in_command && is_continuation?(line)
          end
        end

        render_table(gutters,lines_of_code)
      end

      def render_table(gutters, lines_of_code)
        table = "<table><tr>"
        table += "<td class='gutter'><pre class='line-numbers'>#{gutters.join("")}</pre></td>"
        table += "<td class='code'><pre><code>#{lines_of_code.join("")}</code></pre></td>"
        table += "</tr></table>"
      end

      def is_continuation?(line)
        # \ is Linux; ` is Windows PowerShell
        line = line.strip
        line.end_with?('\\') || line.end_with?('`')
      end

      def command_character
        @prompt
      end

      def inspec_prompt
        '$ inspec&gt;'
      end

      def gutter(line)
        if line.start_with?(inspec_prompt)
          gutter_value = inspec_prompt
        elsif line.start_with?(command_character)
          gutter_value = command_character
        else
          gutter_value = "&nbsp;"
        end
        "<span class='line-number'>#{gutter_value}</span>"
      end

      def line_of_code(line,command,is_truncation)
        if command
          line_class = "command"
        elsif is_truncation
          line_class = "output truncated-output"
        else
          line_class = "output"
        end
        if line
          # TODO: A bit of a hack, but I want to be able to highlight commands from SSH connections.
          # Can come back and rethink this more fully later.
          if m = line.match(/(\[?.+@.+\s?~\]?\$\s?)(.*)/)
            "<span style='display: inline;' class='line-number'>#{m[1]}</span><span style='display: inline;' class='line command'>#{m[2]}</span><br>"
          # Powershell. Example:
          # C:\dev\packer-templates [master]>
          elsif m = line.match(/(\w:\\.*\s+\[.+?\]&gt;)(\s+.*)/)
            "<span style='display: inline;' class='line-number'>#{m[1]}</span><span style='display: inline;' class='line command'>#{m[2]}</span><span class='line #{line_class}'></span>"
          # TODO: A variation of the above (example: root@079f902cf103:/home/test_user $)
          elsif m = line.match(/(\[?.+@.+:.+\s?\$\s?)(.*)/)
            "<span style='display: inline;' class='line-number'>#{m[1]}</span><span style='display: inline;' class='line command'>#{m[2]}</span><br>"
          # TODO: Perhaps another hack. The intention here is to highlight Git prompts (for example, "users git:(master) $").
          elsif m = line.match(/(.+\sgit:\(.+\)\s\$\s)(.*)/)
            "<span style='display: inline;' class='line-number'>#{m[1]}</span><span style='display: inline;' class='line command'>#{m[2]}</span><span class='line #{line_class}'></span>"
          else
            "<span class='line #{line_class}'>#{line}</span>"
          end
        else
          ""
        end
      end

      def terminal_window(content,filepath)
<<-EOH
<div class="window #{@window_style}">
<h1 class="app-title">#{filepath}</h1>
  <div class="contents">
    <div class="terminal">
      #{content}
      </div>
    </div>
</div>
EOH
      end
    end


  end
end
