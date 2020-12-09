sudo mkdir /var/jenkins_home
sudo chmod -R 777 /var/jenkins_home
sudo echo "export KUBECONFIG=/var/jenkins_home/kubeconfig" >> /etc/bash/bashrc
sudo usermod -a -G root $USER
sudo chmod 777 /var/run/docker.sock
JENKINS_IMAGE="janpreet/jenkins-with-docker"
sudo docker pull $JENKINS_IMAGE
sleep 30
sudo mv ${jenkins_upload}/jenkins.yml /var/jenkins_home/jenkins.yml
sudo mv ${jenkins_upload}/kubeconfig /var/jenkins_home/kubeconfig
sleep 30
sudo docker run -d -p 8080:8080 -p 50000:50000 -v /var/jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/kubectl:/usr/bin/kubectl --env JAVA_OPTS="-Djenkins.install.runSetupWizard=false" --env CASC_JENKINS_CONFIG="/var/jenkins_home/jenkins.yml" --name master $JENKINS_IMAGE
sudo source /etc/bash/bashrc