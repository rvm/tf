## https://github.com/mpapis/mpapis_test/blob/master/variables_list.sh

## Examples BASH:
#~ USER=vagrant
#~ _=
#~ array2=([0]="four" [1]="five" [2]="six" [10]="ten")
#~ variable1='play'\''me'
#~ variable2=$'play\n with\n me\n now'

## Examples ZSH:
#~ FIGNORE=''
#~ USER=vagrant
#~ array2=(four five six '' '' '' '' '' '' ten)
#~ variable1='play'\''me'
#~ variable2='play
#~  with
#~  me
#~  now'
require 'shellwords'

class TF::Environment
  HANDLER=<<EOF.gsub(/\n/,'')
set | awk -F= '
  BEGIN{v=0;}
  /^[a-zA-Z_][a-zA-Z0-9_]*=/{v=1;}
  v==1&&$2~/^['\\''\\$]/{v=2;}
  v==1&&$2~/^\\(/{v=3;}
  v==2&&/'\\''$/&&!/'\\'\\''$/{v=1;}
  v==3&&/\\)$/{v=1;}
  v{print;}
  v==1{v=0;}
'
EOF
  class << self
    def show_env_command
      TF::Environment::HANDLER
    end
    def parse_env output
      env = []
      holder=nil
      terminator=nil
      output.each do |line|
        line.chomp!
        if holder.nil?
          if line =~ /^[^=]+=([\('\$]?)/
            holder = line
            if $1 && !$1.empty?
              terminator = $1.sub(/\$/,"'").sub(/\(/,")")
            end
          elsif line =~ /^[^=]*=/
            holder = line
            terminator=nil
          else
            $stderr.puts "Unknown environment token: #{line}." if ENV["TF_DEBUG"]
          end
        else
          holder += line
        end
        if terminator && line.chars.to_a.last == terminator
          terminator=nil
        end
        if holder && terminator.nil?
          env << parse_var( holder.strip )
          holder=nil
        end
      end
      Hash[ env ]
    end
    def parse_var definition
      definition =~ /\A([^=]*)=([$]?[\(']?)(.*?)([\)']?)\z/m
      name  = $1
      type1 = $2
      value = $3
      type2 = $4
      case type2
      when ')'
        parse_array( name, value.shellsplit.map{|v|v.gsub(/'\''/,'\'')} )
      else
        [ name, value.gsub(/'\''/,'\'') ]
      end
    end
    def parse_array name, value
      if value[0] && value[0].chars.to_a.first == '['
        value = value.map do |string|
          string =~ /\[([^\]]+)\]=(.*)/m
          [ $1, $2 ]
        end
      else
        value = value.to_enum.with_index.map{|v,i|[(i+1).to_s,v]}.to_a
        # TODO: zsh -c 'typeset -A arr; arr[ala]=1; arr[kot]=2; set | grep -a ^arr=' => arr=(ala 1 kot 2 ) - space on the end
      end
      [ name, Hash[ value ] ]
    end
  end
end
