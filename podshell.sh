#!/bin/bash

FINDKEY="\.version"
complete=false

while [ $complete == false ]
do
    # 给用户提示
    echo -e "请输入需要的操作命令（Version 1.0）："
    echo -e "1：修改Pod后，在本地进行更新，以便在Example中进行测试"
    echo -e "2：开发完成，本地验证，检测Podspec的正确性"
    echo -e "3：本地验证成功，发布Pod到私有仓库"
    read COMMAND

    if [ $COMMAND == "1" ]; then
        cd ./Example
	if [ -f "Podfile.lock" ]; then 
		rm Podfile.lock
	fi
	pod install
        cd ../
        complete=true
    elif [ $COMMAND == "2" ]; then
        pod lib lint --sources=YMSpecs,master --use-libraries --verbose --allow-warnings
        complete=true
    elif [ $COMMAND == "3" ]; then

        if branch=$(git symbolic-ref --short -q HEAD)
        then
            git push origin $branch
        fi


        PODSPEC=$(find . -type f -name "*.podspec")

        while read line
        do
            name=`echo $line|awk -F '=' '{print $1}'`
            result=$(echo $name | grep "${FINDKEY}")
			#echo $result
            if [[ "$result" != "" ]]
            then
                value=`echo $line|awk -F '=' '{print $2}'`
                length=`expr ${#value} - 2`
                version=`echo $value|cut -c 2-$length`
                # echo $version
                TAGMESSAGE=`git log -1 --pretty=format:'%s' --abbrev-commit | awk -F ':' '{print $2}'`
                # echo $TAGMESSAGE
                git tag -a $version -m "$TAGMESSAGE"
                git push --tags
            fi
        done < $PODSPEC

        pod repo push YMSpecs $PODSPEC --sources=YMSpecs,master --verbose --allow-warnings
        complete=true
    else
        complete=false
    fi
done
