require 'open3'

class Command
  def to_s
    "squeue"
  end

  AppProcess = Struct.new(:jobid, :partition, :name, :user, :st, :time, :nodes, :nodelist)

  def parse(output)
    lines = output.strip.split("\n")
    # Skip header lines
    lines = lines.drop(1)
    lines.map do |line|
      fields = line.split(/\s{2,}/) # Split based on two or more spaces
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
