class User < ApplicationRecord
  has_secure_password
  # attribute :reset_token, :string

  validates_presence_of :email
  validates_uniqueness_of :username, :allow_blank => true
  validates_uniqueness_of :email, :case_sensitive => false

  validates_format_of :username, :with => /[-\w\._@]+/i, :allow_blank => true, :message => "should only contain letters, numbers, or .-_@"
  serialize :roles, Array
  before_save :downcase_login

  def downcase_login
   self.email.downcase!
   self.username.downcase!
  end

  def to_label
   self.full_name.present? ? self.full_name : self.email
  end

  # Role checker, from low of guest to high of super
  def is_super?
    return has_role?('super')
  end

  def is_trustee?
  return has_role?(%w(trustee super admin manager))
  end

  def is_admin?
  return has_role?(%w(super admin manager))
  end

  def is_guest?
    return has_role?('guest')
  end
    
  def has_role?(role)
    return false if self.roles.nil?
    if role.class != Array
      if self.roles.class == Array
        return self.roles.include?(role.to_s.downcase)
      else
        return self.roles == (role.to_s.downcase)
      end
    else
      ok = false
      role.each do |r|
        if self.roles.class == Array
          ok = true if self.roles.include?(r.to_s.downcase)
        else
          ok = true if self.roles == (r.to_s.downcase)
        end
      end
    end
    return ok
  end

end
