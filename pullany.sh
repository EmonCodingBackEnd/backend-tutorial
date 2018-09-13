#!/bin/bash
echo -e "\e[1;44m\e[1;36m====================================================================================================\e[0m"
echo -e "\e[1;44m\e[1;33m您输入的路径为 $*\e[0m"
echo -e "\e[1;44m\e[1;36m====================================================================================================\e[0m"
WORKSPACE_END="WORKSPACE_END"
for WORKSPACE in `echo $* $WORKSPACE_END|sed -n 's/ /\n/gp'|sed '/^$/d'`
do
	if [ $WORKSPACE = $WORKSPACE_END ]; then
		echo -e "\e[1;32m更新完成,开始快乐的工作吧!\e[0m"
		exit 0
	else
		echo -e "\e[1;36m遍历目录 $WORKSPACE\e[0m"
		for PROJECT in `find ${WORKSPACE} -name ".git"`
		do
			CURRENT_PROJECT=`echo $PROJECT|sed 's/.git$//'`
			cd $CURRENT_PROJECT
			CURRENT_BRANCH=`git branch -l|grep "*"|sed 's/* //'`
			echo -en "\e[1;31m\n当前项目路径=[`pwd`] 当前分支=[$CURRENT_BRANCH]\e[0m"
			echo -e "\e[1;34m当前项目分支列表:\e[0m"
			echo -e "\e[1;35m==================================================\e[0m"
			git branch -a
			echo -e "\e[1;35m==================================================\e[0m"
			for BRANCH in `git branch -r|grep -v "HEAD"|sed 's/origin\///'`
			do
				echo -e "\e[1;35m切换到分支 $BRANCH 进行更新...\e[0m"
				git checkout $BRANCH
				git pull
			done
			echo -e "\e[1;31m复原分支=[$CURRENT_BRANCH]\e[0m"
			git checkout $CURRENT_BRANCH
		done
	fi
done
