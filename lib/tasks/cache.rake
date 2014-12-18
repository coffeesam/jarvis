namespace :cache do
  desc "Curl Jarvis with the auth web service"
  task :clear => :environment do
    puts "Memcache cleared. All keys flushed.\n\n" if Rails.cache.clear
  end
end
