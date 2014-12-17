require 'net/ldap'

class Ldap
  attr_accessor :username, :password, :connection, :user

  def initialize(username, password)
    @user       = nil
    @username   = username
    @password   = password
    @connection = Net::LDAP.new(:host => LDAP_CONFIG['host'],
    :port => LDAP_CONFIG['port'],
    :auth => {
      :method => LDAP_CONFIG['auth']['method'].to_sym,
      :username => "#{@username}#{LDAP_CONFIG['ad_suffix']}",
      :password => @password
    })
  end

  def connect
    @connection.bind ? @connection : false
  end

  def store_search_cache
    Rails.cache.fetch(self.user.username) do
      self.search("*")
    end
  end

  def authenticate
    if @connection = self.connect
      if self.user = self.search(@username).first
        self.store_search_cache
      end
    end
    self.user.presence
  end

  def search(username)
    self.retrieve(username)
  end

  def retrieve(username)
    filter      = Net::LDAP::Filter.eq(LDAP_CONFIG['account_key'], username)
    treebase    = LDAP_CONFIG['treebase']
    search_attr = LDAP_CONFIG['search_keys']
    user_array  = []

    @connection.search(:base => treebase, :filter => filter,  :attributes => search_attr).each do |entry|
      user_array << User.new(entry) if User.valid?(entry)
    end
    user_array
  end

  def get_connection_message
    @connection.get_operation_result.to_s.split(', ').last.sub('message="', '').sub('">', '') if @connection.present?
  end

end
