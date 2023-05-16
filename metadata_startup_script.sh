metadata_startup_script = <<-EOF
  #!/bin/bash
  apt-get update
  apt-get install -y openjdk-11-jdk
  wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
  sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
  apt-get update
  apt-get install -y jenkins
  EOF
