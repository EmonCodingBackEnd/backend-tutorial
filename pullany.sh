#!/bin/bash
echo -e "\e[1;44m\e[1;36m====================================================================================================\e[0m"
echo -e "\e[1;44m\e[1;33m您输入的路径为 $*\e[0m"
echo -e "\e[1;44m\e[1;36m====================================================================================================\e[0m"
FAILURE_TIMES=0 # 全局变量，表示更新是否成功，如果失败，表示失败的次数
WORKSPACE_END="WORKSPACE_END"
for WORKSPACE in `echo $* $WORKSPACE_END|sed -n 's/ /\n/gp'|sed '/^$/d'`
do
	if [ $WORKSPACE = $WORKSPACE_END ]; then
		if [ $FAILURE_TIMES -ne 0 ]; then
			echo -e "\e[1;33m>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\e[0m"
			echo -e "\e[1;33m>>>>>>>>>>>>>>>>>>>更新错误发生[\e[1;31m`printf "%-6s $FAILURE_TIMES"`\e[1;33m]次<<<<<<<<<<<<<<<<<<<\e[0m"
			echo -e "\e[1;33m<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
		else
			echo -e "\e[1;32m>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\e[0m"
			echo -e "\e[1;32m>>>>>>>>>>>>>>>>>>更新完成,开始快乐的工作吧!<<<<<<<<<<<<<<<<<<\e[0m"
			echo -e "\e[1;32m<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
		fi
		exit 0
	else
		echo -e "\e[1;36m遍历目录 $WORKSPACE\e[0m"
		for PROJECT in `find ${WORKSPACE} -name ".git"`
		do
			CURRENT_PROJECT=`echo $PROJECT|sed 's/.git$//'`
			if [[ $CURRENT_PROJECT =~ "node_module" ]]; then
				echo -e "\e[1;44m\e[1;31m跳过目录 $CURRENT_PROJECT\e[0m"
				continue
			fi

			cd $CURRENT_PROJECT
			CURRENT_BRANCH=`git branch -l|grep "*"|sed 's/* //'`
			echo -en "\e[1;36m\n当前项目路径=[\e[1;32m`pwd`\e[1;36m] 当前分支=[\e[1;32m$CURRENT_BRANCH\e[1;36m]\e[0m\n"
			echo -e "\e[1;34m当前项目分支列表:\e[0m"
			echo -e "\e[1;35m==================================================\e[0m"
			git branch -a
			echo -e "\e[1;35m==================================================\e[0m"
			for BRANCH in `git branch -r|grep -v "HEAD"|sed 's/origin\///'`
			do
				echo -e "\e[1;35m切换到分支 [\e[1;32m$BRANCH\e[1;35m] 进行更新...\e[0m"
				git checkout $BRANCH
				# echo -e "\e[1;33m切换分支【\e[1;32m$?\e[1;33m】\e[0m"
				if [ $? -ne 0 ]; then
					let FAILURE_TIMES++
					TEMP_CURRENT_BRANCH=`git branch -l|grep "*"|sed 's/* //'`
					echo -e "\e[1;33m切换到分支[\e[1;32m$BRANCH\e[1;33m]失败,当前分支[\e[1;32m$TEMP_CURRENT_BRANCH\e[1;33m]\e[0m"
				else
					git pull
					# echo -e "\e[1;33m更新分支【\e[1;32m$?\e[1;33m】\e[0m"
					if [ $? -ne 0 ]; then
						let FAILURE_TIMES++
						echo -e "\e[1;33m更新分支[\e[1;32m$BRANCH\e[1;33m]失败\e[0m"
					fi
				fi
			done
			echo -e "\e[1;35m复原分支=[$CURRENT_BRANCH]\e[0m"
			git checkout $CURRENT_BRANCH
		done
	fi
done
