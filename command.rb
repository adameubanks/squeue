require 'open3'

class Command
  def to_s
    "/opt/slurm/current/bin/squeue"
  end

  AppProcess = Struct.new(:nothing, :jobid, :partition, :name, :user, :st, :time, :nodes, :nodelist)

  def parse(output)
    lines = output.strip.split("\n")
    # Skip header lines
    lines = lines.drop(1)
    lines.map do |line|
      fields = line.split(/\s{1,}/) # Split based on one or more spaces
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
