#!/bin/bash

#########################################################
# Function :kubernetes-utils                            #
# Platform :macos or linux                              #
# Version  :1.1                                         #
# Date     :2021-03-10                                  #
# Author   :potato                                      #
# Contact  :sweetpotatolinjl@gmail.com                  #
#########################################################

# Uasge
help_msg(){
    echo -e "不需要输入脚本参数，我先帮你 \033[31mexit 1\033[0m"
}

log_info() {
    echo -e "\033[34m[$(date +'%Y-%m-%dT%H:%M:%S')]\033[0m $*"
}

log_err() {
    echo -e "\033[34m[$(date +'%Y-%m-%dT%H:%M:%S')] $*\033[0m"
}

# arg judge
if [[ $# -ne 0 ]]
then
    help_msg
    exit 1
fi

# read -p "$(echo -e "请输入需要安装的 kubectl 版本 --- v1.xx.x [default: latest]"):" kubectl_version
echo -n "请输入需要安装的 kubectl 版本 --- v1.xx.x [default: latest]: "
read kubectl_version
[ -z "$kubectl_version" ] && kubectl_version="$(curl -# https://storage.googleapis.com/kubernetes-release/release/stable.txt)"

if [ $(uname) == "Darwin" ]; then
    current_system_type="darwin"
elif [ $(expr substr $(uname -s) 1 5) == "Linux" ]; then   
    current_system_type="linux"
elif [ $(expr substr $(uname -s) 1 10) == "MINGW32_NT" ]; then    
    log_err "目前还没有支持 windows ~~~"
else
    log_err "没找到你的系统是什么"
    exit 1
fi

# variable
script_dir=$(cd $(dirname $0) && pwd)

# init
if [ ! -d ~/.kube ] ; then
    mkdir ~/.kube
fi

## 判断当前 shell 是 zsh 还是 bash
log_info "当前系统使用的\033[33m shell \033[0m是\033[31m ${SHELL} \033[0m"
if [ "${SHELL}" = "/bin/zsh" ]; then
    current_shell_path=~/.zshrc
else
    current_shell_path=~/.bashrc
fi

# Install kubectl
# https://kubernetes.io/docs/tasks/tools/install-kubectl/
log_info "正在下载 \033[36m${kubectl_version}\033[0m 版本的\033[31m kubectl \033[0m"
installed_version=$(command -v kubectl > /dev/null && kubectl version --client --short | sed -En 's/.*(v.*)/\1/p' || echo '')
if [[ ! "${kubectl_version}" == "${installed_version}" ]] ; then
    curl -# -LO https://storage.googleapis.com/kubernetes-release/release/"${kubectl_version}"/bin/"${current_system_type}"/amd64/kubectl -o /usr/local/bin/kubectl
    chmod +x /usr/local/bin/kubectl
else
    log_info "kubectl already at latest version ${kubectl_version}"
fi

function print_aliases() {
cat <<EOF
Kubernetes commands:
   k        kubectl
   kg       kubectl get
   kd       kubectl describe
   ka       kubectl apply -f
   klo      kubectl logs -f [--tail=200]
   kere     kubectl explain --recursive
   kp       kube-prompt         
Kubernetes plugins:
   k krew   kubectl plugin manager
Find more information on xxx
EOF
}

# 设置命令补全和别名
log_info "配置\033[31m kubectl \033[0m命令自动补全"

if [ "${SHELL}" = "/bin/zsh" ]; then
    complete -F __start_kubectl k
    source <(kubectl completion zsh)
    echo "[[ $commands[kubectl] ]] && source <(kubectl completion zsh)" >> "${current_shell_path}"
else
    complete -F __start_kubectl k
    source <(kubectl completion bash) 
    echo "source <(kubectl completion bash)" >> "${current_shell_path}"
fi

log_info "配置\033[31m kubectl \033[0m别名"
cat>>"${current_shell_path}"<<EOF
alias k='kubectl'
alias klo='kubectl logs -f'
alias kg='kubectl get'
alias kd='kubectl describe'
alias ka='kubectl apply -f'
alias kere='kubectl explain --recursive'
alias kp='kube-prompt'

alias kube='echo "$(print_aliases)"'
EOF

# 安装 krew 并配置环境变量
log_info "正在下载\033[31m krew \033[0m二进制安装文件"
curl -# -L -O https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz

log_info "正在安装\033[31m krew \033[0m ..." 
tar zxf krew.tar.gz
KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/')"
KREW=./krew-"${current_system_type}"_amd64
"$KREW" install krew
echo "export PATH=\${PATH}:\${HOME}/.krew/bin" >> "${current_shell_path}"

# 安装 kube-prompt
log_info "正在下载\033[31m kube-prompt v1.0.11 版本 [amd64]\033[0m"
curl -# -L -O https://github.com/c-bata/kube-prompt/releases/download/v1.0.11/kube-prompt_v1.0.11_"${current_system_type_type}"_amd64.zip
unzip kube-prompt_v1.0.11_"${current_system_type_type}"_amd64.zip
chmod +x kube-prompt
sudo mv ./kube-prompt /usr/local/bin/kube-prompt

# 安装 kube-ps1
log_info "正在下载\033[31m kube-ps1 \033[0m"
curl -# -L https://raw.githubusercontent.com/jonmosco/kube-ps1/master/kube-ps1.sh -o "${HOME}"/kube-ps1.sh
chmod +x "${HOME}"/kube-ps1.sh

if [ "${SHELL}" = "/bin/zsh" ]; then
    cat>>"${current_shell_path}"<<EOF
source ${HOME}/kube-ps1.sh
PROMPT='\$(kube_ps1)'$PROMPT
EOF
else
    cat>>"${current_shell_path}"<<EOF
source ${HOME}/kube-ps1.sh
PS1='[\u@\h \W \$(kube_ps1)]\$ '
EOF
fi

# source 
source "${current_shell_path}"

# krew update & install
log_info "krew update ..."
kubectl krew update

log_info "krew install ctx / ns ... (可能会有点慢，下载的资源在国外服务器，耐心等待下)"
kubectl krew install ctx ns

# clean
# rm -f "${HOME}"/{krew-v0.4.0.tar.gz,krew-v0.4.0.yaml}
shopt -s extglob
rm -f !(install.sh)
shopt -u extglob

# Done
log_info "Done !!!"
