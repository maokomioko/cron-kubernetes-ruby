# frozen_string_literal: true

require "cron_kubernetes/configurable"
require "cron_kubernetes/context/kubectl"
require "cron_kubernetes/context/well_known"
require "cron_kubernetes/cron_job"
require "cron_kubernetes/cron_tab"
require "cron_kubernetes/kubeclient_context"
require "cron_kubernetes/kubernetes_client"
require "cron_kubernetes/scheduler"
require "cron_kubernetes/version"

# Configure and deploy Kubernetes CronJobs from ruby
module CronKubernetes
  extend Configurable

  # Provide a CronJob manifest as a Hash
  define_setting :manifest

  # Provide shell output redirection (e.g. "2>&1" or ">> log")
  define_setting :output

  # For RVM support, and to load PATH and such, jobs are run through a bash shell.
  # You can alter this with your own template, add `:job` where the job should go.
  # Note that the job will be treated as a single shell argument or command.
  define_setting :job_template, %w[/bin/bash -l -c :job]

  # Provide an identifier for this schedule (e.g. your application name)
  define_setting :identifier

  # A `kubeclient` for connection context, default attempts to read from cluster or `~/.kube/config`
  define_setting :kubeclient, nil

  class << self
    def schedule(&)
      CronKubernetes::Scheduler.instance.instance_eval(&)
    end
  end
end
