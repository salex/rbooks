module Vfw
  class Audit
    attr_accessor :audit_yaml, :audit_config

    def get_audit_config
      @audit_yaml = AuditConfig.first.yaml
      @audit_config = YAML.load(@audit_yaml)
    end

    def put_audit_config(audit_config)
      ac = AuditConfig.first
      ac.yaml = audit_config
      ac.save
    end

  end
end