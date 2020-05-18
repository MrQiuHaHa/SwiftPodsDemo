#!/bin/bash

# 创建modulemap文件，接收一个后缀为.framework的路经
function mk_map(){
    framework=$1
    framework_name=`basename $framework .framework`

    # 确保该路径为framework
    if [[ $framework =~ ".framework\$" ]]; then
        return
    fi

    if [ ! -d $framework/Modules ]; then
        mkdir $framework/Modules
    fi

    # 确保没有已存在的module.modulemap，因为有些OC的第三方也自己上传module.modulemap
    if [ -f $framework/Modules/module.modulemap ]; then
        return
    fi
    echo "framework module $framework_name {" >> $framework/Modules/module.modulemap
    if [ -f  $framework/Headers/$framework_name-umbrella.h ]; then
        echo "    umbrella header \"$framework_name-umbrella.h\"" >> $framework/Modules/module.modulemap
    else
        filelist=`ls $framework/Headers`
        for file in $filelist ; do
            echo "    header \"$file\"" >> $framework/Modules/module.modulemap
        done
    fi
    echo "    export *" >> $framework/Modules/module.modulemap
    echo "}" >> $framework/Modules/module.modulemap
}


for path in $* ; do
    echo $*
    for framework in `find $path -name "*.framework"`; do
        mk_map $framework
    done
done

echo "Append modulemap done"
