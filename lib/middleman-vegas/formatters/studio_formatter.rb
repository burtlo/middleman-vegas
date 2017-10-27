require 'middleman-vegas/formatters/terminal_formatter'

module Middleman
  module Vegas
    class StudioFormatter < TerminalFormatter

      def studio_title
        "Hab Studio"
      end

      def render(lexed_code, highlighter_options)
        prompt_content = promptize(lexed_code)
        terminal_window prompt_content, studio_title
      end

      def habitat_prompt_regex
        /\[(?<command_count>\d+)\]\[(?<studio_type>[^:]+):(?<cwd>[^:]+):(?<return_code>\d+)\]#?/
      end

      def habitat_debugger_regex
        /\[(?<command_count>\d+)\]\s(?<pkg_name>[^\(]+)\((?<break_point>[^\)]+)\)&gt;/
      end

      def default_studio_metadata
        { 'type' => 'prompt', 'command_count' => '1', 'studio_type' => 'default', 'cwd' => '/src', 'return_code' => 0 }
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
          if line.length > 1 && line.start_with?('# ') && matches = line.gsub(/^#+\s*/,"").strip.match(habitat_prompt_regex)
            set_next_prompt(matches)
          elsif matches = line.strip.match(habitat_prompt_regex)
            set_next_prompt(matches)
            gutters.push create_prompt
            lines_of_code.push line_of_code(line.gsub(habitat_prompt_regex,'').strip, true, false)
            in_command = is_continuation?(line)
          elsif line.length > 1 && line.start_with?('$ ')
            gutters.push create_prompt
            line = line.length > 2 ? line[2..-1] : ""
            lines_of_code.push line_of_code(line, true, false)
            in_command = is_continuation?(line)
          elsif matches = line.match(habitat_debugger_regex)
            gutters.push({ 'type' => 'debugger', 'command_count' => matches['command_count'], 'pkg_name' => matches['pkg_name'], 'break_point' => matches['break_point'] })
            line = line.gsub(habitat_debugger_regex,'').strip
            lines_of_code.push line_of_code(line, true, false)
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
        @command_count = data['command_count']
        @studio_type = data['studio_type']
        @cwd = data['cwd']
        @return_code = data['return_code']
      end

      attr_reader :command_count, :studio_type, :cwd, :return_code

      def create_prompt
        { 'type' => 'prompt', 'command_count' => @command_count, 'studio_type' => @studio_type, 'cwd' => @cwd, 'return_code' => @return_code }
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
          elsif gutter['type'] == 'debugger'
            table += render_debugger_table_cell(gutter)
            table += "<td class='code'><pre><code>#{lines_of_code[index]}</code></pre></td>"
          else
            table += "<td colspan='2' class='code'><pre><code>#{lines_of_code[index]}</code></pre></td>"
          end
          table += "</tr>"
        end
        table += "</table>"
      end

      def render_prompt_table_cell(data)
        "<td class='gutter'><pre class='line-number'><span>[</span>#{render_gutter('command_count',data['command_count'])}<span>][</span>#{render_gutter('studio_type',data['studio_type'])}<span>:</span>#{render_gutter('cwd',data['cwd'])}<span>:</span>#{render_gutter('return_code',data['return_code'])}<span>]#</span></pre></td>"
      end

      def render_debugger_table_cell(data)
        "<td class='gutter'><pre class='line-number'><span>[</span>#{render_gutter('command_count',data['command_count'])}<span>] </span>#{render_gutter('pkg_name',data['pkg_name'])}<span>(</span>#{render_gutter('break_point',data['break_point'])}<span>)&gt;</span></pre></td>"
      end
    end
  end
end
