class LdapController < ApplicationController
  before_action :check_token, except: [:welcome]

  def welcome
    render text: ''
  end

  def auth
    ldap = Ldap.new(ldap_params[:username], ldap_params[:password])
    if user = ldap.authenticate
      render json: user
    else
      render json: { status: 'error', message: ldap.get_connection_message }
    end
  end

  def search
    if Rails.cache.exist?(ldap_params[:username])
      ldap = Ldap.new(ldap_params[:username])
      render json: ldap.match(/#{ldap_params[:q]}/i)
    else
      render json: { status: 'error', message: 'Please authenticate before performing search.' }
    end
  end

  private

  def ldap_params
    params.require(:ldap).permit(:username, :password, :q)
  end

  def check_token
    unless valid_ip? && exists_config_and_header? && valid_token?
      render :json => {status: 'Bad auth token or invalid IP address'}, :layout => nil, :format => [:text], :status => 401
    end
  end

  def valid_ip?
    ip_address = request.env['HTTP_X_REAL_IP'] || request.remote_ip
    LDAP_CONFIG['valid_ips'].include?(ip_address)
  end

  def exists_config_and_header?
    LDAP_CONFIG['auth_token'].present? && request.headers['AUTH-TOKEN'].present?
  end

  def valid_token?
    request.headers['AUTH-TOKEN'] == LDAP_CONFIG['auth_token']
  end

end
