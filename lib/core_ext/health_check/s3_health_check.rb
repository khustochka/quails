# frozen_string_literal: true

# Patch to fix S3 health check, until https://github.com/Purple-Devs/health_check/pull/112 is merged and released.
module HealthCheck
  class S3HealthCheck
    class << self
      private

      def W(bucket) # rubocop:disable Naming/MethodName
        app_name = ::Rails.application.class.module_parent_name

        aws_s3_client.put_object(bucket: bucket,
          key: "healthcheck_#{app_name}",
          body: Time.zone.now.to_s)
      end

      def D(bucket) # rubocop:disable Naming/MethodName
        app_name = ::Rails.application.class.module_parent_name

        aws_s3_client.delete_object(bucket: bucket,
          key: "healthcheck_#{app_name}")
      end
    end
  end
end
