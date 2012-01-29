class YATF::CommentTestInput
  def initialize
  end

  def matches? name
    name =~ /_comment_test\.sh$/ && File.exist?(name)
  end

  def load file_name
    lines = []
    File.readlines(file_name).each{|line|
      # remove human comments
      line.sub!(/##.*$/,'')
      # reject empty lines
      next if line =~ /^$/
      # extract command and tests
      cmd, tests = line.split("#")
      cmd.strip!
      tests = tests.split(";").map(&:strip)
      if cmd.blank?
        lines.last[1] += tests unless lines.last.nil?
      else
        lines << [cmd, tests]
      end
    }
    name = file_name.gsub(/^.*\//,'').sub(/_comment_test\.sh$/,'')
    [ name, Hash[lines] ]
  end
end
