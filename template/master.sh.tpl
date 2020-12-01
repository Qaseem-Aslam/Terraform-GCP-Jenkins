sudo usermod -a -G root $USER
sudo chmod 777 /var/run/docker.sock
sudo mkdir -p /mnt/disks/${mnt_drive_name}
sudo chmod a+w /mnt/disks/${mnt_drive_name}
sudo mount -o discard,defaults ${mnt_drive_id} /mnt/disks/${mnt_drive_name}
sudo cp /etc/fstab /etc/fstab.backup
echo UUID=`sudo blkid -s ${js_uuid} -o value ${mnt_drive_id}` /mnt/disks/${mnt_drive_name} ext4 discard,defaults,NOFAIL_OPTION 0 2 | sudo tee -a /etc/fstab
sudo docker pull janpreet/jenkins
sudo rm -f /mnt/disks/${mnt_drive_name}/kubeconfig /mnt/disks/${mnt_drive_name}/jenkins.yml
sudo rm -rf /mnt/disks/${mnt_drive_name}/jobs /mnt/disks/${mnt_drive_name}/workspace
sudo rm -f /mnt/disks/${mnt_drive_name}/kubeconfig
sudo mv /tmp/jenkins.yml /mnt/disks/${mnt_drive_name}/jenkins.yml
sudo mv /tmp/kubeconfig /mnt/disks/${mnt_drive_name}/kubeconfig
sudo docker run -d -p 8080:8080 -p 50000:50000 -v /mnt/disks/${mnt_drive_name}:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock --env JAVA_OPTS="-Djenkins.install.runSetupWizard=false" --env CASC_JENKINS_CONFIG="/var/jenkins_home/jenkins.yml" --name master janpreet/jenkins
JENKINS_URL=${j_url}
JENKINS_USERNAME=${j_admin_user}
JENKINS_PASSWORD=${j_admin_password}
#j_token=$(curl -u $JENKINS_USERNAME:$JENKINS_PASSWORD 'localhost:8080//crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)')
sudo echo "export KUBECONFIG=/mnt/disks/${mnt_drive_name}/kubeconfig" >> /etc/bash/bashrc
sudo echo "export JENKINS_URL=http://${j_url}:8080" >> /etc/bash/bashrc
sudo echo "export JENKINS_USERNAME=${j_admin_user}" >> /etc/bash/bashrc
sudo echo "export JENKINS_PASSWORD=${j_admin_password}" >> /etc/bash/bashrc
#sleep 30
#sudo echo "export J_TOKEN=$(curl -u $JENKINS_USERNAME:$JENKINS_PASSWORD 'localhost:8080//crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)')" >> /etc/bash/bashrc
