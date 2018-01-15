=begin
A simple (probably) brainfuck interpreter
If does not work, blame Jason
=end
require "io/console"
$memcells = Array.new(30000,0)
$memptr = 0
def filter_code(code)
    return code.split(/(\bh{1,8}\b)/)
end

def char_lt()
  if $memptr <=0
    abort("Trying to point before starting of memory")
  end
  $memptr-=1
end

def char_gt()
  if $memptr >= 30000 - 1
    abort("Trying to point outside memory")
  end
  $memptr+=1
end

def char_plus()

  $memcells[$memptr] = ($memcells[$memptr] + 1)%256
end

def char_minus()
  $memcells[$memptr] = ($memcells[$memptr] - 1)%256
end

def char_dot()
  STDOUT.print $memcells[$memptr].chr
end

def char_comma()
  c = STDIN.read(1).ord
  if c != 26
    $memcells[$memptr] = c
  end
end

def loopmap(code)
  opening_brackets_stack = Array.new
  map_loops = Hash.new

  code.each_with_index do |char,index|
    if char == 'hhhhhhh'
      opening_brackets_stack.push(index)
    elsif char == 'hhhhhhhh'
      if opening_brackets_stack.size == 0
        abort("Number of ] more than [")
      end
      start = opening_brackets_stack.pop()
      map_loops[start] = index
    end
  end
  if opening_brackets_stack.size != 0
    abort("Number of [ more than ]")
  else
    return map_loops
  end
end

def evaluate(code)
  pc = 0
  stack = Array.new
  map_loops = loopmap(code)
  while pc < code.length
    instruction = code[pc]
    case instruction
    when 'h'
      char_gt()
    when 'hh'
      char_lt()
    when 'hhh'
      char_plus()
    when 'hhhh'
      char_minus()
    when 'hhhhh'
      char_dot()
    when 'hhhhhh'
      char_comma()
    when 'hhhhhhh'
      if $memcells[$memptr] > 0
        stack.push(pc)
      else
        pc = map_loops[pc]
      end
    when 'hhhhhhhh'
      pc = stack.pop() - 1
    end
    pc += 1
  end
end

code = ''
file = File.open(ARGV[0],"r")
file.each_line do |line|
    code += line
end
cleaned_code = filter_code(code)
evaluate(cleaned_code)
 
