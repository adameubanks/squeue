require 'open3'

class Command
  def to_s
    "/opt/slurm/current/bin/squeue"
  end

  AppProcess = Struct.new(:nothing, :jobid, :partition, :name, :user, :st, :time, :nodes, :nodelist)


  # For the last column, nodelist
  def remove_spaces_inside_parentheses(text)
    text.gsub(/\((.*?)\)/) do |match|
      inside_parentheses = match[1..-2].gsub(/\s+/, '')
      "(#{inside_parentheses})"
    end
  end


  def parse(output)
    lines = output.strip.split("\n")
    # Skip header line
    lines = lines.drop(1)
    
    lines.map do |line|
      #remove spaces inside of the parentheses, should there be any
      line = remove_spaces_inside_parentheses(line)
      # Split the line by whitespace
      all_fields = line.split(/\s+/)
      
      first_three = all_fields[0, 3]
      last_five = all_fields[-5, 5]
      
      name = all_fields[3..-6].join(' ')
      fields = first_three + [name] + last_five
      
      AppProcess.new(*fields)
    end
  end

  def exec
    processes, error = [], nil

    stdout, stderr, status = Open3.capture3(to_s)
    output = stdout + stderr

    processes = parse(output) if status.success?

    [processes, error]
  end
end
