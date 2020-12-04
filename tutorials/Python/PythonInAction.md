# Python

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、Python安装

请参考 [Python安装](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Linux/LinuxInAction.md)



# 二、安装包管理工具Conda

1. 安装包下载地址

`Miniconda`： https://docs.conda.io/en/latest/miniconda.html#linux-installers

安装教程： https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html

```bash
[emon@emon ~]$ wget -cP /usr/local/src/ https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
```

2. 安装

```bash
[emon@emon ~]$ bash /usr/local/src/Miniconda3-latest-Linux-x86_64.sh 
```

根据提示安装，一些关键信息如下：

配置安装位置，默认是 `/home/emon/miniconda3`，使用默认，直接回车。

> Miniconda3 will now be installed into this location:
> /home/emon/miniconda3
>
>   - Press ENTER to confirm the location
>   - Press CTRL-C to abort the installation
>   - Or specify a different location below
>
> [/home/emon/miniconda3] >>> 

是否要初始化，这里选择 `yes`

> Do you wish the installer to initialize Miniconda3
> by running conda init? [yes|no]
> [no] >>> 

初始化后，在 `/home/emon/.bashrc` 会添加一些conda的配置。

3、安装后配置

安装完成后，重新登录才生效！

>==> For changes to take effect, close and re-open your current shell. <==
>
>If you'd prefer that conda's base environment not be activated on startup, 
>   set the auto_activate_base parameter to false: 
>
>conda config --set auto_activate_base false

如果不需要启动就切换到base，可以配置如下：

```bash
# 配置后会保存在文件 [emon@emon ~]$ vim .condarc 中
[emon@emon ~]$ conda config --set auto_activate_base false
[emon@emon ~]$ conda config --show|grep activate
auto_activate_base: False
```

4、更新

```bash
[emon@emon ~]$ conda update conda
```

5、卸载

删除即可：

```bash
[emon@emon ~]$ rm -rf ~/miniconda3/
```

删除环境配置：

```bash
# 打开文件，并删除如下部分
[emon@emon ~]$ vim ~/.bashrc
```

```bash
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/emon/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/emon/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/emon/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/emon/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
```

删除其他可能创建的conda隐藏文件或文件夹：

```bash
[emon@emon ~]$ rm -rf ~/.condarc ~/.conda ~/.continuum
```

6、配置

- 查看配置帮助

```bash
[emon@emon ~]$ conda config -h
```

- 查看所有配置

```bash
[emon@emon ~]$ conda config --show
```

- 配置国内源

```bash
[emon@emon ~]$ conda config --set show_channel_urls yes
[emon@emon ~]$ conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
[emon@emon ~]$ conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
[emon@emon ~]$ conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
[emon@emon ~]$ conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/
```

- 查看配置

```bash
[emon@emon ~]$ conda config --show-sources
==> /home/emon/.condarc <==
auto_activate_base: False
channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
  - defaults
show_channel_urls: true
```

- 删除配置源

```bash
[emon@emon ~]$ conda config --remove channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
[emon@emon ~]$ conda config --remove channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
[emon@emon ~]$ conda config --remove channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
[emon@emon ~]$ conda config --remove channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/
```



7、conda命令

| 命令                                                      | 说明                                 |
| --------------------------------------------------------- | ------------------------------------ |
| conda info                                                | 查看conda信息                        |
| conda-env list 或者 conda info --envs 或者 conda env list | 查看已有虚拟环境                     |
| which python                                              | 进入虚拟环境后，最好检查下当前环境   |
| conda list                                                | 查看环境下已有的安装包               |
| conda create -n py39 python=3.9                           | 创建名称为 py39 的虚拟环境           |
| conda remove -n py39 --all                                | 删除py39虚拟环境                     |
| conda activate py39                                       | 激活py39虚拟环境                     |
| conda deactivate                                          | 退出虚拟环境                         |
| conda create -n py39latest --clone py39                   | 将py39重命名为py39latest             |
| conda remove -n py39 --all                                | 再删除py39虚拟环境，达到重命名的效果 |
| conda install <pkg>                                       | 安装包                               |
| conda uninstall <pkg>                                     | 卸载包                               |
| conda update conda <pkg>                                  | 更新包                               |
| conda update --all                                        | 更新所有包                           |



# 安装其他包

## 1、安装Scrapy

1. 安装

```bash
[emon@emon ~]$ conda install scrapy
或者指定安装渠道：
[emon@emon ~]$ conda install -c conda-forge scrapy
```

2. 验证

- 查看命令

```bash
[emon@emon ~]$ scrapy
Scrapy 2.4.0 - no active project
```

- 执行简单shell

```bash
[emon@emon ~]$ scrapy shell 'http://www.huiba123.com'
```



## 三、python3.3以后自带的venv环境管理工具

| 命令                         | 说明         |
| ---------------------------- | ------------ |
| python3 -m venv env_name     | 创建虚拟环境 |
| source env_name/bin/activate | 激活环境     |
| deactivate                   | 退出环境     |

