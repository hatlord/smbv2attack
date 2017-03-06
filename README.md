## smbv2attack is a tool for performing password attacks against SMBv2/3. 
It is intended to be a stop-gap until the bigger tools (Hydra/Medusa/Metasploit) publish an SMBv2+ compatible too.
You will need Ruby and a couple of gems, which can be installed with 'bundle install' from within the tools directory.

Usage is straight forward:

./smbv2attack.rb --help  
smbv2attack 0.1b  
Options:  
  -H, --hosts=\<s>        Choose hosts to attack  
  -h, --host=\<s>         Choose host to attack  
  -u, --user=\<s>         Username  
  -U, --users=\<s>        Username List  
  -P, --passwords=\<s>    Password list  
  -p, --password=\<s>     Password list  
  -d, --domain=\<s>       Domain to attack (default: WORKGROUP)  
  -v, --version          Print version and exit  
  -e, --help             Show this message
  
  Attacking a single host:
  ./smbv2attack.rb --host 10.10.10.1 --user administrator --password Password1 --domain TEST.CORP
  
  Attacking multiple hosts:
  ./smbv2attack.rb --hosts hosts.txt --users users.txt --passwords passwords.txt

I may not have caught all of the SMB feedback messages, but any that aren't understood are still output to screen for you to parse. Any successful username and password pairs are written to a file.

Account lockouts are RED in the console.
Please note that specifying a domain against a domain control won't change anything, the domain users will always be attacked. This setting is targeted at workstations, so that you don't lock out domain accounts.
