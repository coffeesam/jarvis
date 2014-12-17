class User
  attr_accessor :username, :email

  def self.valid?(entry)
    entry.present? && entry[:objectcategory].to_s.match(/CN=Person/i)
  end

  def initialize(entry)
    @username = entry[:sAMAccountName].first
    @email    = entry[:mail].first
  end
end
