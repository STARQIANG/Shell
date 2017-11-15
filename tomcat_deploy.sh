#!/bin/bash
export JAVA_HOME=/opt/jdk
NOW_DATA=`date +'%Y-%m-%d %H:%M.%S'`
TOMCAT_DIR=/opt/tomcat
JENKINS_DIR=/root/deploy/lms
BAK_DIR=/root/backup/lms
TOMCAT_PID=`ps -ef |grep tomcat |grep -w $TOMCAT_DIR|grep -v 'grep'|awk '{print $2}'`
WAR_DIR=/opt/tomcat/webapps

echo "当前时间为$NOW_DATA"

echo "正在关闭TomCat服务，PID进程号为$TOMCAT_PID"

$TOMCAT_DIR/bin/shutdown.sh &>/dev/null

[ -n "$TOMCAT_PID" ] && kill -9 $TOMCAT_PID

echo "$TOMCAT_DIR服务已关闭..."
#=============备份war包============#
cd $WAR_DIR
mkdir -p $BAK_DIR
mv  $WAR_DIR/*.war $BAK_DIR/`date +%Y%m%d`.war

rm -rf $WAR_DIR/*

mv  $JENKINS_DIR/*.war $WAR_DIR/ROOT.war


echo "清理缓存...."
sleep 2

cd $TOMCAT_DIR;rm -rf work
rm -rf $TOMCAT_DIR/logs/*


sync

echo "war包已拷贝完成，正在启动服务...."

/$TOMCAT_DIR/bin/startup.sh  &>/dev/null
PID=`ps -ef |grep tomcat |grep -w $TOMCAT_DIR|grep -v 'grep'|awk '{print $2}'`
echo "服务已启动，TomCat服务PID进程号为$PID"
sleep 25
echo "请查看服务启动日志........."

tail -n 100 $TOMCAT_DIR/logs/catalina.out
