### 下载 [kubectl](https://kubernetes.io/zh/docs/tasks/tools/install-kubectl/) (二选一)
(目前我们集群均为 1.17.x 版本)  
- 拷贝方式
  ```
  cp kubectl-1.17.9 /usr/local/bin/kubectl
  chmod +x /usr/local/bin/kubectl
  ```

- 下载方式  
指定版本为 v1.17.9 的 kubectl 
  ```
  #macos
  curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.17.9/bin/darwin/amd64/kubectl
  #linux
  curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.19.0/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
  ```

### 配置 kubeconfig 到 .kube 目录
- 直接拷贝运维人员准备的 kubeconfig  
  ```
  mkdir ~/.kube
  cp kubeconfig ~/.kube/config
  ```

### 设置命令补全和别名，根据自己使用的是 bash 还是 zsh 进行设置
- 设置命令补全
  - zsh
    ```
    if [ $commands[kubectl] ]; then
      source <(kubectl completion zsh)
    fi
    ```
  - bash
    ```
    if [ $commands[kubectl] ]; then
      source <(kubectl completion bash)
    fi
    ```

- 设置 alias kubectl，更新自己的 `.bashrc` or `.zshrc` 文件
  ```
  alias k='kubectl'
  alias klo='kubectl logs -f --tail=200'
  alias kg='kubectl get'
  alias kd='kubectl describe'
  alias kere='kubectl explain --recursive'
  alias kp='kube-prompt'
  ```

### 安装 kubectl plugin 管理工具 [krew](https://krew.sigs.k8s.io/docs/user-guide/setup/install/) (二选一)
- 直接使用拉取好的二进制安装文件
  ```
  ./krew-darwin_amd64 install krew
  ```

- 下载 krew-install 安装最新的 krew
  ```bash
  set -x; cd "$(mktemp -d)" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" &&
  tar zxvf krew.tar.gz &&
  KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/')" &&
  "$KREW" install krew
  ```

- 添加到 PATH 环境变量，更新自己的 `.bashrc` or `.zshrc` 文件，添加以下一列信息
  ```
  export PATH="${PATH}:${HOME}/.krew/bin"
  ```

- source !!!
  ```
  source ~/.zshrc 
  or 
  source ~/.bashrc
  ```

- 安装基本插件
  ```
  kubectl krew install ns ctx 
  ```

### 安装 [kube-prompt](https://github.com/c-bata/kube-prompt) (二选一)
`kube-prompt` 提供交互式会话下的命令提示、自动补全等功能
- 下载方式  
  ```
  #macos
  wget https://github.com/c-bata/kube-prompt/releases/download/v1.0.10/kube-prompt_v1.0.10_darwin_amd64.zip
  unzip kube-prompt_v1.0.10_darwin_amd64.zip
  chmod +x kube-prompt
  sudo mv ./kube-prompt /usr/local/bin/kube-prompt

  #linux
  wget https://github.com/c-bata/kube-prompt/releases/download/v1.0.10/kube-prompt_v1.0.10_linux_amd64.zip
  unzip kube-prompt_v1.0.10_linux_amd64.zip
  chmod +x kube-prompt
  sudo mv ./kube-prompt /usr/local/bin/kube-prompt
  ```

- 拷贝方式
  ```
  mv ./kube-prompt-v1.0.10 /usr/local/bin/kube-prompt
  chmod +x /usr/local/bin/kube-prompt
  ```

