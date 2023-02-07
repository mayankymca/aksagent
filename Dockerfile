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
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Homebrew/brew need to be installed for kubelogin installation
RUN apt update -y
RUN apt-get install build-essential -y
RUN apt install git -y
#RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" # as per Azure Pipeline
#RUN "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" # As per Git hub
#RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" # Need to be fixed
RUN echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /root/.profile
#RUN brew install gcc # Need to be fixed

# Install Kubelogin 
#RUN brew install Azure/kubelogin/kubelogin # Need to be fixed

# To Uninstall Brew (if required)
#RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)" # No changes
# Install azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install azure devops extentions
RUN az config set extension.use_dynamic_install=yes_without_prompt
RUN az extension add --name azure-devops

# Install Terraform 

RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
RUN apt update && sudo apt install terraform -y

# Install Helm 

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh


# Install ARGOCD 
RUN curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
RUN install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
RUN rm argocd-linux-amd64

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#RUN curl -LO https://dl.k8s.io/release/v1.25.2/bin/linux/amd64/kubectl
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl


# Login to Azure 
RUN az login --service-principal -u ${{ secrets.SP_USERNAME }} -p ${{ secrets.SP_PASSWORD }} --tenant ${{ secrets.SP_TENANT_ID }}
RUN az account set --subscription ${{ secrets.SUB }}

# Login to AKS
#RUN az aks get-credentials --resource-group MyResourceGroup --name mayank --format exec
#/root/.kube/config

# To create USER , once user is added then all rest commands would be executed from new user's context
# https://stackoverflow.com/questions/27701930/how-to-add-users-to-docker-container
# Option 1
#RUN useradd -rm -d /home/mayank -s /bin/bash -g root -G sudo -u 1001 mayank
# Switch to 'mayank'
#USER mayank
#SHELL ["/bin/bash", "-o", "pipefail", "-c"]
#RUN echo 'mayank:mayank' | chpasswd
#WORKDIR /home/mayank
# Option 2
#RUN useradd -ms /bin/bash mayank
#USER mayank
#WORKDIR /home/mayank



# This need to be used
#RUN useradd -m  -s /bin/bash mayank
#RUN usermod -aG sudo mayank && echo "mayank ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/mayank
#RUN chmod 0440 /etc/sudoers.d/mayank          # should be 0440
# Switch to 'mayank'
#USER mayank:mayank
#WORKDIR /home/mayank

#https://stackoverflow.com/questions/27701930/how-to-add-users-to-docker-container

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64



WORKDIR /azp
#WORKDIR /root

COPY ./start.sh .

#RUN chmod +x start.sh
RUN chmod +x ./start.sh

ENTRYPOINT [ "./start.sh" ]
