require 'sinatra'
require 'json'
require 'git'
require 'jekyll'

post '/' do

  dir = './jekyll'
  name = "JekyllBot"
  email = ""
  username = ENV['GH_USER'] || ''
  password = ENV['GH_PASS'] || ''
  
  FileUtils.rm_rf dir
  
  push = JSON.parse(params[:payload])
  if push["commits"].first["author"]["name"] == name
    puts "This is just the callback from JekyllBot's last commit... aborting."
    return
  end

  url = push["repository"]["url"] + ".git"
#  url["https://"] = "https://" + username + ":" + password + "@"
  
  puts "cloning into " + url
  g = Git.clone(url, dir)
   
  options = {}
  options["server"] = false
  options["auto"] = false 
  options["safe"] = false 
  options["source"] = dir
  options["destination"] = File.join( dir, '_site')
  options["plugins"] = File.join( dir, '_plugins')
  options = Jekyll.configuration(options)
  site = Jekyll::Site.new(options)
  
  puts "starting to build in " + dir
  begin
    site.process
  rescue Jekyll::FatalException => e
    puts e.message
    FileUtils.rm_rf dir
    exit(1)
  end
  
  puts "succesfully built; commiting..."
  begin
#    g.config('user.name', name)
#    g.config('user.email', email)  
#    puts g.commit_all( "[JekyllBot] auto-generated changes from previous commit")
  rescue Git::GitExecuteError => e
#    puts e.message
  else
    puts "pushing"
#    puts g.push
    puts "pushed"
  end
  
  puts "cleaning up."
  FileUtils.rm_rf dir
  
  puts "done"
  
end