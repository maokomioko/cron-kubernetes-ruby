# frozen_string_literal: true

require "singleton"

module CronKubernetes
  # A singleton that creates and holds the scheduled commands.
  class Scheduler
    include Singleton
    attr_reader :schedule

    def initialize
      @schedule   = []
      @identifier = CronKubernetes.identifier
    end

    def rake(task, schedule:, name: nil, cron_job_settings: {})
      rake_command = "bundle exec rake #{task} --silent"
      rake_command = "RAILS_ENV=#{rails_env} #{rake_command}" if rails_env
      @schedule << new_cron_job(schedule, rake_command, name, cron_job_settings)
    end

    def runner(ruby_command, schedule:, name: nil, cron_job_settings: {})
      env = nil
      env = "-e #{rails_env} " if rails_env
      runner_command = "bin/rails runner #{env}'#{ruby_command}'"
      @schedule << new_cron_job(schedule, runner_command, name, cron_job_settings)
    end

    def command(command, schedule:, name: nil, cron_job_settings: {})
      @schedule << new_cron_job(schedule, command, name, cron_job_settings)
    end

    private

    def make_command(command)
      CronKubernetes.job_template.map do |arg|
        if arg == ":job"
          "cd #{root} && #{command} #{CronKubernetes.output}"
        else
          arg
        end
      end
    end

    def new_cron_job(schedule, command, name, cron_job_settings)
      CronJob.new(
        command: make_command(command),
        schedule:,
        job_manifest: CronKubernetes.manifest,
        cron_job_settings:,
        name:,
        identifier: @identifier
      )
    end

    def rails_env
      ENV.fetch("RAILS_ENV", nil)
    end

    def root
      return Rails.root if defined? Rails

      Dir.pwd
    end
  end
end
