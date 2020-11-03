class AuditConfig < Stash
  after_initialize :set_stashable

  def set_stashable
    if self.new_record?
      self.stashable_id = 1
      self.stashable_type = "Stash"
      filepath = Rails.root.join("yaml","audit_config.yaml")
      self.yaml = File.read(filepath)
      self.save
    end
  end
end