class User
  attr_accessor :username, :email, :display_name, :department, :title

  def self.valid?(entry)
    entry.present? && User.person?(entry)
  end

  def self.person?(entry)
    entry[LDAP_CONFIG['person_key'].to_sym].to_s.match(/CN=Person/i)
  end

  def initialize(entry)
    @username     = entry[LDAP_CONFIG['account_key'].to_sym].first
    @email        = entry[LDAP_CONFIG['email_key'].to_sym].first
    @display_name = entry[LDAP_CONFIG['name_key'].to_sym].first
    @department   = entry[LDAP_CONFIG['department_key'].to_sym]
    @title        = entry[LDAP_CONFIG['title_key'].to_sym]
  end
end
