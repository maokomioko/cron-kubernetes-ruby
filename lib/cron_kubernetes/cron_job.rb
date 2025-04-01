# frozen_string_literal: true

require "digest/sha1"

module CronKubernetes
  # A single job to run on a given schedule.
  class CronJob
    attr_accessor :schedule, :command, :job_manifest, :name, :identifier, :cron_job_settings

    def initialize(options = {})
      @schedule     = options[:schedule]
      @command      = options[:command]
      @job_manifest = options[:job_manifest]
      @name         = options[:name]
      @identifier   = options[:identifier]
      @cron_job_settings = options[:cron_job_settings] || {}
    end

    def cron_job_manifest
      {
          "apiVersion" => "batch/v1",
          "kind" => "CronJob",
          "metadata" => {
              "name" => "#{identifier}-#{cron_job_name}",
              "namespace" => namespace,
              "labels" => {"cron-kubernetes-identifier" => identifier}
          },
          "spec" => build_cron_job_spec
      }
    end

    private

    def namespace
      return job_manifest["metadata"]["namespace"] if job_manifest["metadata"] && job_manifest["metadata"]["namespace"]

      "default"
    end

    def build_cron_job_spec
      default_spec = {
          "schedule" => schedule,
          "concurrencyPolicy" => "Forbid",
          "jobTemplate" => {
              "metadata" => job_metadata,
              "spec" => job_spec
          }
      }

      default_spec.merge(cron_job_settings)
    end

    def job_spec
      spec = job_manifest["spec"].dup
      first_container = spec["template"]["spec"]["containers"][0]
      first_container["command"] = command
      spec
    end

    def job_metadata
      job_manifest["metadata"]
    end

    def cron_job_name
      return name if name
      return job_hash(job_manifest["metadata"]["name"]) if job_manifest["metadata"]

      pod_template_name
    end

    def pod_template_name
      return nil unless job_manifest["spec"] &&
          job_manifest["spec"]["template"] &&
          job_manifest["spec"]["template"]["metadata"]

      job_hash(job_manifest["spec"]["template"]["metadata"]["name"])
    end

    def job_hash(name)
      "#{name}-#{Digest::SHA1.hexdigest(schedule + command.join)[0..7]}"
    end
  end
end
