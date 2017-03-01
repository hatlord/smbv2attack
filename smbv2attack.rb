#!/usr/bin/env ruby
#smbv2 password attack tool

require 'tty'
require 'logger'
require 'colorize'
require 'trollop'

def arg
  opts = Trollop::options do 
    version "smbv2attack 0.1b".light_blue
      opt :hosts, "Choose hosts to enumerate", :type => String
      opt :user, "Username", :type => String
      opt :users, "Username List", :type => String
      opt :passwords, "Password list", :type => String
      opt :domain, "Domain to attack, default 'WORKGROUP'", :type => String, :default => "WORKGROUP"

      if ARGV.empty?
        puts "Need Help? Try ./smbv2attack.rb --help or -h"
        exit
      end
  end
  Trollop::die :hosts, "You must specify a list of hosts to test".red.bold if opts[:hosts].nil?
  Trollop::die :passwords, "You must specify a password list for the attacks".red.bold if opts[:passwords].nil?
  opts
end

def check_smbclient
  @smbclient = TTY::Which.which('smbclient.py')
    if @smbclient.nil?
      install_smbclient
    end
  @smbclient
end

def install_smbclient
  puts "SMBClient Not Installed....Downloading Impacket".light_blue.bold
  `git clone https://github.com/CoreSecurity/impacket.git`
  @smbclient = TTY::Which.which('smbclient.py')
end

def create_hosts(arg)
  @hosts = File.readlines(arg[:hosts]).map(&:chomp &&:strip)
  puts @hosts
end

def smb2_attack
  out, err = @cmd.run!("enum4linux -u #{splitter[0]} -p #{splitter[1]} -S #{host}", timeout: 0.5)
end

arg
check_smbclient
create_hosts(arg)
smb2_attack