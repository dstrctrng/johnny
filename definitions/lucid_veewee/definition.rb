Veewee::Session.declare({
  :cpu_count => '1', :memory_size=> '512',
  :disk_size => '10140', :disk_format => 'VDI', :hostiocache => 'off',
  :os_type_id => 'Ubuntu', :iso_file => "ubuntu-10.04.3-server-i386.iso",
  :iso_src => "http://releases.ubuntu.com/10.04.3/ubuntu-10.04.3-server-i386.iso",
  :boot_wait => "0", :boot_cmd_sequence => [ ],
  :ssh_login_timeout => "10000", :ssh_user => "root", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "bash '%f'",
  :shutdown_cmd => "shutdown -P now",
  :postinstall_files => [ "postinstall.sh" ], :postinstall_timeout => "10000"
})
