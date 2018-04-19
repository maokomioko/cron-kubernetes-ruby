# CronKubernetes

Configue and deploy Kubernetes [CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) 
from ruby. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem "cron-kubernetes"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cron_kubernetes

## Configuration

You can configure global settings for your cron jobs. Add a file to your source as following. 
If you are using Rails, you can add this to something like `config/initializers/cron_kuberentes.rb`.

You _must_ configure the `manifest` setting. The other settings are optional and default values
are shown below.

```ruby
CronKubernetes.configure do |config|
  config.manifest     = YAML.read(File.join(Rails.root, "deploy", "kubernetes-job.yml"))
  config.output       = ""
  config.job_template = %w[/bin/bash -l -c :job]
end
```

### `manifest`

This is a Kubernetes Job manifest used as the job template within the Kubernetes 
CronJob. That is, this is the job that's started at the specified schedule. For 
example:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: scheduled-job
spec:
  template:
    metadata:
      name: scheduled-job
    spec:
      containers:
      - name: my-shell
        image: busybox
      restartPolicy: OnFailure
```

In the example above we show the manifest loading a file, just to make it
simple. But you could also read use a HEREDOC, parse a template and insert
values, or anything else you want to do in the method, as long as you return
a valid Kubernetes Job manifest as a `Hash`.

When the job is run, the default command in the Docker instance is replaced with
the command specified in the cron schedule (see below). The command is run on the 
first container in the pod.

### `output`

By default no redirection is done; cron behaves as normal. If you would like you 
can specify an option here to redirect as you would on a shell command. For example,
`"2>&1` to collect STDERR in STDOUT or `>> /var/log/task.log` to append to a log file.

### `job_template`

This is a template that we use to execute your rake, rails runner, or shell command
in the container. The default template executes it in a login shell so that environment
variables (and profile) are loaded. 

You can modify this. The value should be an array of arguments. The first element of the
array will be the Kubernetes pod `command`. The remainder will be the `args`. See
[Define a Command and Arguments for a Container](https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/)
for a discussion of how `command` and `args` works in Kubernetes.

## Usage

Add a file to your source that defines the scheduled tasks. If you are using Rails, you could 
put this in `config/initializers/cron_kuberentes.rb`. Or, if you want to make it work like the
`whenever` gem you could add these lines to `config/schedule.rb` and then `require` that from your
initializer.

```ruby
CronKubernetes.schedule do
  command "ls -l", schedule: "0 0 1 1 *"
  rake "audit:state", schedule: "0 20 1 * *", name: "audit-state"
  runner "CleanSweeper.run", schedule: "30 3 * * *"
end
```

For all jobs the command with change directories to either `Rails.root` if Rails is installed
or the current working directory. These are evaluated when the scheduled tasks are loaded.

For all jobs you may provide a `name` to name the CronJob.

### Shell Commands

A `command` runs any arbitrary shell command on a schedule. The first argument is the command to run.


### Rake Tasks

A `rake` call runs a `rake` task on the schedule. Rake and Bundler must be installed and on the path 
in the container The command it executes is `bundle exec rake ...`. 

### Runners

A `runner` runs arbitrary ruby code under rails. Rails must be installed at `bin/rails` from the 
working folder. The command it executes is `bin/rails runner '...'`.

## To Do
- In place of `schedule`, support `every`/`at` syntax:
  ```
  every: :minute, :hour, :day, :month, :year
         3.minutes, 1.hour, 1.day, 1.week, 1.month, 1.year
  at: "[H]H:mm[am|pm]"
  ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. 

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

To release a new version, update the version number in `lib/cron_kubernets/version.rb` and the `CHANGELOG.md`, 
and then run `bundle exec rake release`, which will create a git tag for the version, 
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/keylimetoolbox/cron-kubernetes.

## Acknowledgments

We have used the [`whenever` gem](https://github.com/javan/whenever) for years and we love it. 
Much of the ideas for scheduling here were inspired by the great work that @javan and team 
have put into that gem.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
