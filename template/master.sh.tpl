sudo mkdir -p /mnt/disks/${mnt_drive_name}
sudo chmod a+w /mnt/disks/${mnt_drive_name}
sudo mount -o discard,defaults ${mnt_drive_id} /mnt/disks/${mnt_drive_name}
sudo cp /etc/fstab /etc/fstab.backup
echo UUID=`sudo blkid -s ${js_uuid} -o value ${mnt_drive_id}` /mnt/disks/${mnt_drive_name} ext4 discard,defaults,NOFAIL_OPTION 0 2 | sudo tee -a /etc/fstab
sudo cp /tmp/jenkins.yml /mnt/disks/${mnt_drive_name}/jenkins.yml
sudo docker pull janpreet/jenkins
sudo docker run -d -p 8080:8080 -p 50000:50000 -v /mnt/disks/${mnt_drive_name}:/var/jenkins_home --env JAVA_OPTS="-Djenkins.install.runSetupWizard=false" --env CASC_JENKINS_CONFIG="/var/jenkins_home/jenkins.yml" --name master janpreet/jenkins
