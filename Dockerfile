FROM ubuntu:20.04
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    git \
    iputils-ping \
    jq \
    lsb-release \
    software-properties-common

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    bash \
    curl \
    file \
    grep \
    maven \
    mount \
    sudo \
    tar \
    util-linux

RUN apt-get -y install libgtk2.0-0 libxtst6 xvfb curl libswt-gtk-4-java libswt-gtk-4-jni jq \
    vim \
    maven \
    git \
    zip \
    unzip

# Install PWSH
# Update the list of packages
RUN apt-get update
# Install pre-requisite packages.
RUN apt-get install -y wget apt-transport-https software-properties-common
# Download the Microsoft repository GPG keys
RUN wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
# Register the Microsoft repository GPG keys
RUN dpkg -i packages-microsoft-prod.deb
# Update the list of packages after we added packages.microsoft.com
RUN apt-get update
# Install PowerShell
RUN apt-get install -y powershell
# Start PowerShell
#pwsh

# Install az copy
RUN wget https://aka.ms/downloadazcopy-v10-linux
 
#Expand Archive
RUN tar -xvf downloadazcopy-v10-linux
 
#(Optional) Remove existing AzCopy version
#RUN rm /usr/bin/azcopy
 
#Move AzCopy to the destination you want to store it
RUN cp ./azcopy_linux_amd64_*/azcopy /usr/bin/

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    git \
    iputils-ping \
    netcat \
    lsb-release \
    software-properties-common

# Install Kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#RUN curl -LO https://dl.k8s.io/release/v1.25.2/bin/linux/amd64/kubectl
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install azure devops extentions
RUN az config set extension.use_dynamic_install=yes_without_prompt
RUN az extension add --name azure-devops

# Install Docker 
RUN apt-get update
RUN apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
RUN chmod a+r /etc/apt/keyrings/docker.gpg
RUN apt-get update -y


RUN apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64

WORKDIR /azp


COPY ./start.sh .

RUN chmod +x start.sh
RUN chmod +x ./start.sh

ENTRYPOINT [ "./start.sh" ]
