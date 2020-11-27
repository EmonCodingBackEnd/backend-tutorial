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

