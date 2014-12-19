namespace :curl do
  desc "Curl Jarvis with the auth web service"
  task :auth, [:username, :password, :token] do |t, args|
    if args[:username].nil? || args[:password].nil? || args[:token].nil?
      puts "usage:"
      puts "  rake curl:auth[username,password,token]"
      puts ""
    else
      puts `curl -s http://0.0.0.0:3000/ldap/auth -d "[ldap][username]=#{args[:username]}" -d "[ldap][password]=#{args[:password]}" -H "AUTH-TOKEN: #{args[:token]}"`
    end
  end

  desc "Curl Jarvis with the search web service"
  task :search, [:username, :token, :q] do |t, args|
    if args[:username].nil? || args[:token].nil? || args[:q].nil?
      puts "usage:"
      puts "  rake curl:search[username,token,q]"
      puts ""
    else
      puts `curl -s http://0.0.0.0:3000/ldap/search -d "[ldap][username]=#{args[:username]}" -d "[ldap][password]=#{args[:password]}" -d "[ldap][q]=#{args[:q]}" -H "AUTH-TOKEN: #{args[:token]}"`
    end
  end
end
