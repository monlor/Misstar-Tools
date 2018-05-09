path=/mnt/c/Users/monlor/Documents/Misstar-Tools/appstore
cd $path
ls | grep -v images | grep -v update.sh | grep -v push.sh | while read line
do
	cd $line/
	ls | grep -v "\." | while read line
	do
		[ "$line" = "etc" ] && tar zcvf misstar.mt etc/ && continue
		tar zcvf $line.mt $line/
	done
	cd $path
done
