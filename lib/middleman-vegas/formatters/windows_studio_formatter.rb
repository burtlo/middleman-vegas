require 'middleman-vegas/formatters/terminal_formatter'

module Middleman
  module Vegas
    class WindowsStudioFormatter < TerminalFormatter

      def studio_title
        "Hab Studio"
      end

      def render(lexed_code, highlighter_options)
        prompt_content = promptize(lexed_code)
        terminal_window prompt_content, studio_title
      end

      def habitat_prompt_regex
        /\[HAB-STUDIO\] Habitat:\\(?<cwd>[^&]+)&gt;/
      end

      def promptize(content)
        gutters = []
        lines_of_code = []

        buffer = content.map { |token,text| text }.join

        # process escape characters & split into lines
        lines = CGI.escapeHTML(buffer.strip).split("\n")
        in_command = false

        set_next_prompt(default_studio_metadata)

        lines.each do |line|
          # If the line is comment and the content after the comment looks like a habitat
          # prompt we want to set the next use of the $ character to use the prompt defined

          # if the line looks like a habitat prompt then set the prompt and then strip off that prompt from the line
          # also if this line ends with a continuation charater, like  multi-line command
          # then set that to true.

          # if the command starts with a $ then assume that we want to use the previous defined
          # prompt in a comment or the default prompt. This makes it easier to write prompts

          # Otherwise its just a line.

          if line.length > 1 && line.start_with?('# ') && matches = line.gsub(/^#+\s*/,"").strip.match(habitat_prompt_regex)
            set_next_prompt(matches)
          elsif matches = line.strip.match(habitat_prompt_regex)
            set_next_prompt(matches)
            gutters.push create_prompt
            lines_of_code.push line_of_code(line.gsub(habitat_prompt_regex,'').strip, true, false)
            in_command = is_continuation?(line)
          elsif line.length > 1 && line.start_with?('$ ')
            gutters.push create_prompt
            lines_of_code.push line_of_code(line.gsub(/^$\s*/,''), true, false)
            in_command = is_continuation?(line)
          else
            gutters.push({ 'type' => 'no-gutter'})
            line = "&nbsp;" if line == "" # for HTML to render this we need a blank space
            lines_of_code.push line_of_code(line, in_command, !in_command && line == "[...]")
            in_command = in_command && is_continuation?(line)
          end
        end

        render_table(gutters,lines_of_code)
      end

      def set_next_prompt(data)
        @cwd = data['cwd']
      end

      def create_prompt
        { 'type' => 'prompt', 'cwd' => @cwd }
      end

      attr_reader :cwd

      def default_studio_metadata
        { 'type' => 'prompt', 'cwd' => 'src' }
      end

      def render_gutter(key, value)
        "<span class='#{key}'>#{value}</span>"
      end

      def render_table(gutters, lines_of_code)
        table = "<table>"
        gutters.count.times do |index|
          table += "<tr>"
          gutter = gutters[index]
          if gutter['type'] == 'prompt'
            table += render_prompt_table_cell(gutter)
            table += "<td class='code'><pre><code>#{lines_of_code[index]}</code></pre></td>"
          else
            table += "<td colspan='2' class='code'><pre><code>#{lines_of_code[index]}</code></pre></td>"
          end
          table += "</tr>"
        end
        table += "</table>"
      end

      def render_prompt_table_cell(data)
        "<td class='gutter'><pre class='line-number'><span>[</span>HAB-STUDIO<span>]</span> Habitat:<span>\\#{render_gutter('cwd',data['cwd'])}</span><span>&gt;</span></pre></td>"
      end

    end
  end
end
