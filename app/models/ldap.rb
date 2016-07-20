require 'net/ldap'

class Ldap
  attr_accessor :username, :password, :connection, :user

  def initialize(username=nil, password=nil, search_mode=false)
    @user       = nil
    @username   = username
    @password   = password
    if (username.present? && password.present?) || (username.present? && search_mode)
      @connection = Net::LDAP.new(:host => LDAP_CONFIG['host'],
      :port => LDAP_CONFIG['port'],
      :auth => {
        :method => LDAP_CONFIG['auth']['method'].to_sym,
        :username => "#{@username}#{LDAP_CONFIG['ad_suffix']}",
        :password => @password
      })
    else
      raise 'Empty username or password'
    end
  end

  def connect
    @connection.bind ? @connection : false
  end

  def fetch_search_cache
    Rails.cache.fetch(@username) do
      self.search("*")
    end
  end

  def authenticate
    if @connection = self.connect
      if self.user = self.retrieve_by_id(@username)
      end
    end
    self.user.presence
  end

  def retrieve_by_id(username)
    users = self.fetch_search_cache
    users.detect do |user|
      username.downcase == user.username.downcase
    end
  end

  def match(pattern)
    users = self.fetch_search_cache
    users_array = []
    users.each do |user|
      users_array << user if user.display_name.match(pattern)
    end
    users_array
  end

  def search(username)
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
