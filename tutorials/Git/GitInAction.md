# Git实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# git-tutorial

git-tutorial


# 一、Git简介

	一个可以管理和追踪软件代码或其他类似内容的不同版本的工具，通常称为：版本控制系统（VCS），或者源代码管理器（SCM），或者修订控制系统（RCS）。
	
	全局信息追踪器：Global Information Tracker：Git

## 1.1 安装Git之后，使用之前需要进行的Git配置

```bash
[emon@emon ~]$ git config --global user.name "emon"
[emon@emon ~]$ git config --global user.email "liming20110711@163.com"
[emon@emon ~]$ git config --list
user.name=emon
user.email=liming20110711@163.com
```



# 二、Git服务器

- Git服务器分类
  - 公共服务器
    - GitHub - https://github.com
    - 码云 - https://gitee.com/
    - Coding - https://coding.net
  - 私有服务器
    - 私人搭建的Git服务器

## 2.1 搭建Git私有服务器

1. 创建`git`用户，用来运行`git`服务

   **特殊说明：不要修改用户的默认目录，否则会影响SSH公钥登录，哪怕各级文件权限一致，也会影响**

   创建`git`用户：

   ```bash
   [emon@emon ~]$ sudo useradd -c "Git User" git
   ```

   修改`git`用户密码：

   ```bash
   [emon@emon ~]$ sudo passwd git
   ```

2. 导入客户端SSH公钥

   ```bash
   [emon@emon ~]$ ssh-copy-id git@39.107.97.197
   ```

3. 创建裸仓库

   ```bash
   [emon@emon ~]$ ssh git@39.107.97.197 "git init --bare empty.git"
   Initialized empty Git repository in /home/git/empty.git/
   ```

4. 克隆裸仓库（也称远程仓库）

   ```bash
   [emon@emon ~]$ cd /usr/local/src/git-repository/
   [emon@emon git-repository]$ git clone git@39.107.97.197:/home/git/empty.git
   Cloning into 'empty'...
   warning: You appear to have cloned an empty repository.
   ```

5. 禁用`git`用户SSH登录

   ```bash
   [emon@emon git-repository]$ cd
   [emon@emon ~]$ sudo usermod -s /usr/bin/git-shell git
   ```

- 特殊说明

  - 禁用SSH登录后，有如下影响

    - 无法`ssh git@39.107.97.197`登录了
    - 无法`ssh git@39.107.97.197 "git init --bare empty.git"`命令创建裸仓库了
    - 无法`ssh-copy-id git@39.107.97.197`拷贝公钥到`git`用户了

  - 如何创建裸仓库与拷贝SSH公钥？

    - 使用root用户创建裸仓库

      ```bash
      [root@emon ~]# cd /home/git/
      [root@emon git]# git init --bare simple.git
      Initialized empty Git repository in /home/git/simple.git/
      [root@emon git]# chown -R git:git simple.git
      ```

    - 使用root用户直接编辑

      ```bash
      [root@emon git]# vim .ssh/authorized_keys 
      ```

      ​

# 三、Git仓库

- Git仓库分类
  - 裸仓库
    - 用来搭建Git私有服务器时用到
  - 开发仓库
    - 本地仓库
      - 在用户本地创建的仓库
    - 远程仓库
      - 比如在GitHub上的仓库

## 3.1 如果先创建了本地仓库

1. 创建本地仓库

   关键命令： `git init`

   ```bash
   [emon@emon ~]$ cd /usr/local/src/git-repository/
   [emon@emon git-repository]$ mkdir emonnote
   [emon@emon git-repository]$ cd emonnote/
   [emon@emon emonnote]$ git init
   Initialized empty Git repository in /usr/local/src/git-repository/emonnote/.git/
   ```

2. 创建远程仓库

   以GitHub为例，创建如图所示：

   ![new-repository-1.png](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Git/images/new-repository-1.png)

   获得仓库地址：`git@github.com:Rushing0711/emonnote.git`

3. 推送本地仓库到远程仓库

   ```bash
   [emon@emon emonnote]$ git remote add origin git@github.com:Rushing0711/emonnote.git
   [emon@emon emonnote]$ git push -u origin master
   ```

- 命令解释：
  - `git push -u origin master`： -u表示--set-upstream，用于指定上游（远程仓库）。

## 3.2 如果先创建了远程仓库

1. 创建远程仓库

   以GitHub为例，创建如图所示：

   ![new-repository-2.png](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Git/images/new-repository-2.png)

   获得仓库地址：`git@github.com:Rushing0711/emonnote.git`

2. 克隆远程仓库到本地

   ```bash
   [emon@emon ~]$ cd /usr/local/src/git-repository/
   [emon@emon git-repository]$ git clone git@github.com:Rushing0711/emonnote.git
   Cloning into 'emonnote'...
   remote: Counting objects: 5, done.
   remote: Compressing objects: 100% (5/5), done.
   remote: Total 5 (delta 0), reused 0 (delta 0), pack-reused 0
   Receiving objects: 100% (5/5), 4.78 KiB | 4.78 MiB/s, done.
   ```

   ​

# 四、Git文件管理

## 4.1 添加和提交文件

- 添加指定文件

```shell
git add <filename>
```

- 添加指定目录所有文件

```shell
git add <directory>
```

- 添加当前目录所有文件

```shell
git add .
# 或者
git add *
```

- 提交新增文件

```shell
git add <filename>
git commit -m "<message>"
```

- 提交已经存在，但是修改过的文件

```shell
git commit -am "<message>"
```

- 修改上一条提交信息

```shell
# 该命令打开提交信息编辑窗口，你可以修改提交信息；--no-edit标记会修复提交但不会打开提交信息编辑窗口。
git commit --amend [--no-edit]
```

- 提交远程仓库

```shell
git push <远程主机名> <本地主机名>:<远程分支名>
```



## 4.2 合并更新

- 从远程仓库拉取

```shell
git pull <远程主机> <远程分支>:<本地分支>
```

- 从远端拉取最新代码，并合并到分支中

```shell
# 取回origin主机的next分支，与本地的master分支合并
git pull origin next:master
```

- 如果远程分支是与当前分支合并，则冒号后面的部分可以省略

```shell
git pull origin next
```

- `pull`的含义是先拉取更新，再与本地分支进行合并，是一个自动的过程，也可以手动实现

```shell
# 拉取更新
git fetch origin
# 合并更新
git merge origin/next
```

- 如果本地分支与远程分支建立了一种追踪关系，比如`git clone`时，所有本地分支默认与远程主机的同名分支建立了追踪关系，也就是说，本地的`master`分支自动`追踪`远程分支`origin/master`分支。此时，可以省略远程分支名

```shell
git pull origin
```



## 4.3 查看状态

### 4.3.1 `git status`

- 查看当前分支的状态

```shell
git status
```

- 以简单形式，查看当前分支的状态

```shel
git status -s
```

- 一个简单的查看忽略文件的方法

```shell
git status --ignored
```



## 4.4 文件还原与暂存

对于已经修改的文件，想要放弃当前的修改，还原为之前的状态：

```shell
git checkout <filename>
```

而如果不是想放弃当前的修改，只是想暂存起来，去处理一些比较紧急的事情，之后还是需要继续操作，那就需要stash命令：

- 暂存

```shell
# 保存当前修改，回退到修改之前，此时git diff HEAD查看工作区与暂存区以及最新提交的比较结果无差别
# 如果不带save -a message，只暂存原有文件之上的修改，不会包含新增文件
git stash [save [-a] [<message>]]
```

- 显示已暂存列表

```shell
git stash list
stash@{0}: WIP on develop: e218dc5 tutorial update 20180415-10
```

- 恢复暂存区

```shell
# 执行后，会从stash list删除
git stash pop stash@{id}
# 执行后，不会从stash list删除
git stash apply stash@{id}
```

- 删除暂存区

```shell
# 如果不加stash编号，默认删除最新的编号为0的那个暂存
git stash drop <stash@{id}>
```

- 清除暂存区

```shell
# 清除所有的stash
git stash clear
```



# 五、Git分支

- 查看本地分支

```shell
# 结果中带有星号标识的分支，是当前分支
git branch
```

- 查看远程分支

```shell
git branch -r
```

- 查看本地和远程所有的分支

```shell
git branch -a
```

- 查看本地和远程所有的分支，包含详细信息

```shell
git branch -a -vv
```

- 图表形式查看分支

```shell
git log --graph
```

- 创建分支

```shell
git branch feature/x
```

- 切换分支

```shell
git checkout feature/x
```

- 创建并切换分支

```shell
git checkout -b feature/x
```

- 切换回上一个分支

```shell
# 连字符 - 代替分支名，表示上一个分支
git checkout - 
```

- 合并分支

```shell
# 合并分支，并保留日志
git merge --no-ff feature/x
```

- 删除分支

```shell
git branch -d <branchname>
```

- 删除分支，覆盖Git的安全检查

```shell
git branch -D <branchname>
```

- 删除远程分支

```shell
# 删除远端的<branchname>分支
git push origin :<branchname>
# 等同于
git push origin --delete develop
```

- 合并分支的另一种方式

```shell
# 与git merge不同，git rebase不会生成新的节点
git rebase <branchname>
```

- 查看两个分支的差异，develop有但master没有的

```bash
git log develop ^master
```

- 查看两个分支的差异，master有但develop没有的

```bash
git log master ^develop
```

- 查看两个分支的差异，列出develop比master多提交的内容

```bash
git log master..develop
```

- 查看两个分支的差异，不知道谁提交多，谁提交少，只是想知道差别

```bash
git log --left-right master...develop
```



# 六、Git标签

Git管理两种基本的标签类型，通常称为`轻量级（lightweight)`和`带附注的（annotated）`标签。

- 轻量级标签

> 轻量级标签只是一个提交对象的引用，通常被版本库视为私有的。这些标签并不在版本库里创建永久对象。

- 带标注的标签

> 带标注的标签则更加充实，并且会创建一个对象。它包含你提供的一条信息，并且看根据RFC 4880来使用GnuPG秘钥进行数字签名。

Git在命名一个提交的时候，对轻量级的标签和带标注的标签同等对待。不过，默认情况下，很多Git命令只对带标注的标签起作用，因为他们被认为是 **永久** 对象。



- 创建标签

```shell
git tag -a v1.0.0 -m "add tag" [branchname]
```

- 推送到远程仓库

```shell
git push origin v1.0.0
```

- 推送所有标签

```shell
git push origin --tags
```



# 七、其他

## 7.1 Git命令帮助文档的使用

- 为了方便起见，每个git子命令的文档都可以通过使用如下方式查看：
  - `man git subcommand` 【推荐】
  - `git help subcommand` 【推荐】
  - `git --help subcommand` 
  - `git subcommand --help`



## 7.2 Git的配置文件

- Git支持不同层次的配置文件，按照优先级递减的顺序
  - `.git/config`：版本库特定的配置，可以通过--local选项修改，是默认选项。这些设置拥有最高优先级。
    - `--file <filename>`，该选项默认替换`--local`，可以通过`--system`和`--global`替换，来指定各级别配置文件的位置。
  - `/.gitconfig`：用户特定的配置，可以用--global选项修改。
    - Windows下是`%USERPROFILE%/.gitconfig`文件，Linux下是用户宿主目录下`$HOME/.gitconfig`文件。
  - `/etc/gitconfig`：这是系统范围的配置，如果你有它的UNIX文件写权限，你就可以用`--system`选项修改它了。
    - 根据实际的安装情况，这个系统设置文件可能在其他位置（也许在`/usr/local/etc/gitconfig`），也可能完全不存在。


## 7.3 常规配置

- 设置姓名和邮箱地址

```shell
git config --global user.name "[username]"
git config --global user.email "[useremail]"
```

- 设置禁止CRLF的自动转换

windows中的换行符为CRLF，而在linux下的换行符为LF，所以在执行add.时出现提示：

**warning: LF will be replaced by CRLF in .editorconfig.**

```shell
git config --global core.autocrlf false // 禁用自动转换
```

- 提高命令输出的可读性

```shell
git config --global color.ui auto
```

- 设置日志图示以及单行显示

```shell
git config --global alias.show-graph 'log --graph --abbrev-commit --pretty=oneline'
# 推荐如下形式
git config --global alias.show-graph 'log --graph --oneline --decorate --all'
# 又是一个棒棒的配置
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset - %C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit"
# 查看最后一次提交
git config --global alias.last "log -1"
```

- 查看配置

```shell
git config --list
```



## 7.4 日志查看

- 常规的提交日志

```shell
git log
```

- 只显示提交信息的第一行

```shell
git log --pretty=short
```

- 只显示指定目录、文件的日志

```shell
git log README.md
```

- 显示文件的改动

```shell
git log -p README.md
```

- 查看最后一次提交

```shell
git log -n 1
```

- 查看最近一次提交所有更改过的文件

```shell
git log -n 1 --stat
```

- 查看最近一次提交所有更改的细节

```shell
git log -n 1 -p
```



## 7.5 查看文件区别

- 未加入暂存区，查看工作区与暂存区的差别

```shell
git diff [文件]
```

- 加入暂存区后，查看工作区与最新提交的差别

```shell
# 该命令还可以查看工作区与暂存区的差别，包含git diff的结果
git diff HEAD
```



## 7.6 版本回退

`git reset`是版本回退的基本命令，根据后面参数的不同，回退的形式也不同。

- 尚未使用`git add`添加到仓库的文件，想要使得他回退到编辑之前

```bash
git checkout -- <file name>
```

- 如何只回退某一个文件到指定<commit id>

```shell
git checkout <commit id> <absolute_file_path>
```

- 已经使用`git add`添加到仓库的文件，想要使得他回退到`git add`之前

```shell
# HEAD表示为当前的版本
git reset HEAD <file name>
```

- 对于每次的log记录，想回退到某一个log记录的时候，并且保留当前所做的修改

```shell
git reset <commit id>
```

- 对于已经`git commit`的提交，对于每次的log记录，想回退到某一个log记录的时候，并且**放弃**之后的修改

```
git reset --hard <commit id>
```

- 对于已经`git commit`的提交，对于每次的log记录，想要回退到某一个log记录的时候，并且**保留**之后的修改

```bash
git reset --soft <commit id>
```

- 回退到上一个版本

```shell
git reset --hard HEAD^
```

- 回退到之前第n个版本

```shell
# n表示之前第n个版本
git reset --hard HEAD~n
```

- 回退后放弃回退

如果在回退以后又想再回到之前的版本，`git reflog`可以查看所有分支的所有操作记录（包括commit和reset的操作），包括一家被删除的commit记录，`git log`则无法查看到已经删除了的commit记录。

```shell
# 查看之前的<commit id>
git reflog
# 放弃回退
git reset <commit id>
```

## 7.7 设置忽略文件

Git管理的项目，可以在仓库中添加`.gitignore`文件，配置需要忽略管理的文件或者目录。



## 7.8 定位问题

### 7.8.1 定位负责人

- 查看文件的每个部分是谁修改的

```shell
git blame <filename>
```



### 7.8.2 定位错误日志

Git提供了二分查找的概念，来帮助确定一个有关Bug的版本。

#### 使用演示：

- 第一步：启用二分查找

```shell
git bisect start
```

- 第二步：标记一个好的版本

```shell
git bisect good <tag|commit id>
```

- 第三步：标记一个坏的版本

```shell
# 注意，这里标记Bug版本后，后面会提示还有多少版本需要测试，大概需要多少步骤；并且还会切换到二分位置
git bisect bad <tag|commit id>
Bisecting: 7 revisions left to test after this (roughly 3 steps)
[67ec0234ab82b6821efef2d32b1091f6d560cb08] fix conflict
```

至此，Git已经自动为我们切换到下一个二分位置，并显示大概需要多少步骤可以定位到错误提交。

- 第四步：执行测试，查看当前自动切换到的二分位置是否有Bug

```shell
# do some test or check
```

- 第五步：如果有Bug，标记bad，否则，标记good；继续二分定位

```shell
# 这里不需要指定<commit id>，只需要第二步和第三步指定一个good位置和一个bad位置即可
git bisect <good|bad>
```

- 第六步：重复第四步和第五步的操作，直到找到Bug版本位置

#### 小技巧：

- 如果对版本标记错了，把good写成了bad或者相反，需要重新开始二分定位

```shell
# 如果不带<commit id>，会退出bisect，并切换到git bisect start之前的位置；
# 否则，会退出bisect，并切换到<commit id>指定的位置。
git bisect reset [<commit id>]
```

- 查看`git bisect`标记操作日志

```shell
git bisect log
```



# 八、Git Flow——以发布为中心的开发模式

## 8.1 git flow的工作流程

	当在团队开发中使用版本控制系统时，商定一个统一的工作流程是至关重要的。

![git-flow.png](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Git/images/git-flow.png)

### 8.1.1 流程分支解析

| 名称    | 解释                                                         |
| ------- | ------------------------------------------------------------ |
| master  | 主分支，保存发布版本；不能直接在这个分支修改代码。           |
| develop | 开发分支，项目初始化时，基于master创建的分支；包含所有要发布到下一个Release的代码。 |
| feature | 功能分支，开发新功能时，基于develop创建的分支；功能完成后要合并到develop分支。 |
| release | 预发布分支，需要发布时，基于develop创建的分支；创建后可能有bugfixes，发布后合并到master和develop分支。 |
| hotfix  | 热修复分支，产品发布后，如果有bug需要基于master分支创建该分支；完成后要合并到master和develop分支。 |

#### master分支：

![git-flow-master.png](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Git/images/git-flow-master.png)

- Git主分支的名字，默认叫做`master`。该分支是自动建立，版本库初始化后，默认就是在主分支。

- 所有在`master`分支上的`commit`，应该是`tag`。

#### develop分支：

- `develop`分支基于`master`分支创建。


- 主分支只用来发布重大版本，日常开发应该在另一条分支上完成。我们把开发用的分支，叫做`develop`。
- 创建`develop`分支

```shell
git checkout -b develop master
git push -u origin develop
```



#### feature分支：

![git-flow-feature.png](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Git/images/git-flow-feature.png)

- `feature`分支基于`develop`分支创建。
- `feature`分支完成后，必须合并到`develop`分支，合并后一般会删除`feature`分支，但也可以保留。
- 创建`feature`分支，命名规则： feature-* 或者 feature/*

```shell
git checkout -b feature/x develop
# [可选项]提交分支到远程仓库
git push -u origin feature/x
```

- 开发完成后，将功能分支合并到`develop`分支，并删除功能分支

```shell
# 更新develop分支
git pull origin develop
# 切换到develop分支
git checkout develop
# 合并新开发的功能分支
git merge --no-ff feature/x
# 提交远程仓库
git push origin develop

# 删除新开发的功能分支
git branch -d feature/x
# [可选项]如果功能分支提交到远程仓库，可以如下删除
git push origin --delete feature/x
```

#### release分支：

![git-flow-release.png](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Git/images/git-flow-release.png)

- `release`分支基于`develop`分支创建。
- 正式版发布之前（即合并到`master`分支之前），我们需要一个预发布的版本进行测试，就是`release`了。
- 创建的`release`分支，可以进行测试和bug修复，但不应该从`develop`分支上合并新的更新了。
- 创建一个预发布分支，命名规则： release-* 或者 release/* 

```shell
git checkout -b release/1.0.0 develop
# [可选项]提交分支到远程仓库
git push -u origin release/1.0.0
```

- 预发布结束以后，必须合并到`develop`和`master`分支，并在`master`上打一个`tag`。

```shell
git checkout master
git merge --no-ff release/1.0.0
# 提交远程仓库
git push

# 更新develop分支
git pull origin develop
git checkout develop
git merge --no-ff release/1.0.0
# 提交远程仓库
git push

# 删除预发布分支
git branch -d release/1.0.0
# [可选项]如果预发布分支提交到远程仓库，可以如下删除
git push origin --delete release/1.0.0

# 对合并生成的新节点，做一个标签
git tag -a v1.0.0 master
git push --tags
```

#### hotfix分支：

![git-flow-hotfix.png](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Git/images/git-flow-hotfix.png)

- `hotfix`分支基于`master`分支创建。
- 创建一个热修复分支，命名规则： hotfix-* 或者 hotfix/* 

```shell
git checkout -b hotfix/1.0.1 master
# [可选项]提交分支到远程仓库
git push -u origin hotfix/1.0.1
```

- 完成热修复分支后，必须合并到`develop`和`master`分支，并在`master`上打一个`tag`。

```shell
git checkout master
git merge --no-ff hotfix/1.0.1
# 提交远程仓库
git push

# 更新develop分支
git pull origin develop
git checkout develop
git merge --no-ff hotfix/1.0.1
# 提交远程仓库
git push

# 删除热修复分支
git branch -d hotfix/1.0.1
# [可选项]如果热修复分支提交到远程仓库，可以如下删除
git push origin --delete hotfix/1.0.1

# 对合并生成的新节点，做一个标签
git tag -a v1.0.1 master
git push --tags
```



## 8.2 git flow的辅助工具

荷兰程序员Vincent Driessen曾发表了一篇博客，让一个分支策略广为人知，那就是`A succesful Git branching model`。

### 8.2.1 安装git flow

项目地址： https://github.com/nvie/gitflow

安装指南： https://github.com/nvie/gitflow/wiki/Installation

1. 下载

```shell
[emon@emon ~]$ cd /usr/local/src/
[emon@emon src]$ curl -OL https://raw.github.com/nvie/gitflow/develop/contrib/gitflow-installer.sh
[emon@emon src]$ chmod +x gitflow-installer.sh
```

2. 执行安装

```shell
[emon@emon src]$ ./gitflow-installer.sh 
```

- 脚本解释：
  - 可通过`INSTALL_PREFIX=~/bin ./gitflow-installer.sh`形式指定安装目录

### 8.2.2 使用git flow

#### 初始化：

```shell
$ git flow init

Which branch should be used for bringing forth production releases?
   - develop
   - master
Branch name for production releases: [master]

Which branch should be used for integration of the "next release"?
   - develop
Branch name for "next release" development: [develop]

How to name your supporting branch prefixes?
Feature branches? [feature/]
Bugfix branches? [bugfix/]
Release branches? [release/]
Hotfix branches? [hotfix/]
Support branches? [support/]
Version tag prefix? []
Hooks and filters directory? [D:/Job/JobResource/IdeaProjects/Idea2017/git-tutorial/.git/hooks]
```

#### 特性：

- 为即将发布的版本开发新功能特性时创建特性分支，该分支通常只存在开发者的库中。
- 增加新特性，该操作创建了一个基于`develop`的特性分支，并切换到这个分支之下。

```shell
git flow feature start x
```

- 完成新特性
  - 合并`feature`分支到`develop`分支
  - 删除`feature`分支
  - 切换到`develop`分支

```shell
git flow feature finish x
```



- 发布新特性

```shell
git flow feature publish x
```

- 获取一个发布的新特性

```shell
git flow feature pull origin x
```

- 跟踪分支

```shell
git flow feature track x
```

#### 预发布分支：

- 支持一个新的用于生产环境的发布版本。
- 允许修正`bugfix`小问题，并为发布版本准备元数据。
- 创建`release`版本，它从`develop`分支开始创建一个`release`分支。

```shell
git flow release start 1.0.0 [BASE]
```

命令解释：[BASE]可以是`develop`分支下的`sha-1 hash`值，代表提交记录。

- 创建`release`分支后立即发布允许其他用户向这个`release`分支提交内容是个明智的做法。

```shell
git flow release publish 1.0.0
```

- 获取远程`release`

```shell
git flow release pull origin releasename
```

- 你也可以通过命令跟踪

```shell
git flow release track releasename
```

- 完成`release`	版本
  - 合并`release`分支到`master`分支
  - 用`release`分支名打`tag`
  - 合并`release`分支到`develop`分支
  - 移除`release`分支

```shell
git flow release finish 1.0.0
```

#### 紧急修复：

- 紧急修复来自这样的需求：生成环境的版本处于一个不预期状态，需要立即修正。
- 有可能是需要修正`master`分支上某个`tag`标记的生产版本。
- 创建`hotfix`分支，基于`master`分支

```shell
git flow hotfix start 1.0.1 [BASENAME]
```

其中，1.0.1标记着修正版本。[BASENAME]为finish release时填写的版本号。

- 完成`hotfix`分支
  - 代码归并回`develop`和`master`分支。
  - 相应地，`master`分支打上修正版本的`tag`。
  - 删除`hotfix`分支

```shell
git flow hotfix finish 1.0.1
```

### 8.2.3 git flow命令合集

![git-flow-commands.png](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Git/images/git-flow-commands.png)

# 九、GitHub Flow——以部署为中心的开发模式

