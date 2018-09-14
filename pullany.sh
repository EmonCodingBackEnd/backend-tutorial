#!/bin/bash
echo -e "\e[1;44m\e[1;36m====================================================================================================\e[0m"
echo -e "\e[1;44m\e[1;33m您输入的路径为 $*\e[0m"
echo -e "\e[1;44m\e[1;36m====================================================================================================\e[0m"
FAILURE_ARY=()
FAILURE_TIMES=0 # 全局变量，表示更新是否成功，如果失败，表示失败的次数
WORKSPACE_END="WORKSPACE_END"
for WORKSPACE in `echo $* $WORKSPACE_END|sed -n 's/ /\n/gp'|sed '/^$/d'`
do
	if [ $WORKSPACE = $WORKSPACE_END ]; then
		if [ $FAILURE_TIMES -ne 0 ]; then
			echo -e "\e[1;31m>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\e[0m"
			echo -e "\e[1;31m>>>>>>>>>>>>>>>>>>>更新错误发生[\e[1;5;32m  `printf "%-3s" $FAILURE_TIMES`\e[0;1;31m]次<<<<<<<<<<<<<<<<<<<\e[0m"
			for (( i=1; i<=${#FAILURE_ARY[@]}; i++))
			do
		     		echo -e "\e[1;31m`printf "%-3s" $i、`${FAILURE_ARY[i-1]}\e[0m"
			done
			echo -e "\e[1;31m<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\e[0m"
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
				if [ $? -ne 0 ]; then
					TEMP_CURRENT_BRANCH=`git branch -l|grep "*"|sed 's/* //'` # 获取当前分支
					FAILURE_ARY[FAILURE_TIMES]="项目[$CURRENT_PROJECT]分支[$TEMP_CURRENT_BRANCH]切换到[$BRANCH]分支失败"
					let FAILURE_TIMES++
					echo -e "\e[1;4;5;33m切换到分支[\e[1;32m$BRANCH\e[1;33m]失败,当前分支[\e[1;32m$TEMP_CURRENT_BRANCH\e[1;33m]\e[0m"
				else
					git pull
					if [ $? -ne 0 ]; then
						FAILURE_ARY[FAILURE_TIMES]="项目[$CURRENT_PROJECT]分支[$BRANCH]更新失败"
						let FAILURE_TIMES++
						echo -e "\e[1;4;5;33m更新分支[\e[1;32m$BRANCH\e[1;33m]失败\e[0m"
					fi
				fi
			done
			echo -e "\e[1;35m复原分支=[$CURRENT_BRANCH]\e[0m"
			git checkout $CURRENT_BRANCH
		done
	fi
done
