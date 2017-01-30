# Set the working application directory
# working_directory "/path/to/your/app"
working_directory "/home/app.merchcast.com/app.merchcast.com/public"

# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
pid "/home/app.merchcast.com/cache/unicorn.pid"

# Path to logs
# stderr_path "/path/to/log/unicorn.log"
# stdout_path "/path/to/log/unicorn.log"
stderr_path "/home/app.merchcast.com/logs/unicorn.log"
stdout_path "/home/app.merchcast.com/logs/unicorn.log"

# Unicorn socket
listen "/tmp/unicorn.app.merchcast.com.sock"

# Number of processes
# worker_processes 4
worker_processes 2

# Time-out
timeout 30
