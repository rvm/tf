class DTF::CommentTestInput
  def initialize
  end

  def matches? name
    name =~ /_comment_test\.sh$/ && File.exist?(name)
  end

  def load file_name
    lines = []
    File.readlines(file_name).each{|line|
      # Fix jruby-1.6.6-d19 bug with empty strings from files
      line = "#{line}"
      # remove human comments
      line.sub!(/##.*$/,'')
      # reject empty lines
      line.strip!
      next if line =~ /^$/
      # extract command and tests
      cmd, tests = line.split("#")
      cmd.strip!
      tests = if tests.blank?
        []
      else
        tests.split(";").map(&:strip)
      end
      if cmd.blank?
        lines.last[:tests] += tests unless lines.last.nil?
      else
        lines << { :cmd => cmd, :tests => tests }
      end
    }
    name = file_name.gsub(/^.*\//,'').sub(/_comment_test\.sh$/,'')
    { :name => name, :commands => lines }
  end
end
