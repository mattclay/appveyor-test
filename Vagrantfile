Vagrant.configure(2) do |config|
  user = ENV['WIN_USER']
  password = ENV['WIN_PASSWORD']
  config.vm.box = "ubuntu/xenial32"
  config.vm.box_url = "https://dl.dropboxusercontent.com/s/c2tsphy6c52w1ck/xenial-server-cloudimg-i386-vagrant.box"
  config.vm.provision :shell, :path => 'bootstrap.sh', :args => [user, password]
  # config.vm.synced_folder ENV['APPVEYOR_BUILD_FOLDER'], "/home/ubuntu/ansible"
  config.vm.box_check_update = false

  config.vm.provider "virtualbox" do |vb|
     vb.gui = false
     vb.memory = 512
	 vb.cpus = 1
   end
end
