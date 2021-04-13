echo -e "#####################################\n Rem Migrate Corrupted Zip Fixer\n#####################################\n"
echo -ne "\nEnter the file \e[1;91mlocation\e[0m to extract data from eg. /home/user/FolderName\n---> "
read loc
echo -e "\nEnter \e[1;91mBackup Zip name: \e[0m"
read fol
mkdir $fol
touch ./$fol/fileList.txt

######################## Writing backupName to rawList  ############################

echo -e "\n=================\n/sdcard/Migrate/$fol\n=================\n\n" > ./$fol/rawList.txt

######################## Writing Contacts and Messages Backup ######################

ls -1 $loc | grep "vcf" | awk '{print "/"$0}' >> ./$fol/rawList.txt
ls -1 $loc | grep "sms.db" | awk '{print "/"$0}' >> ./$fol/rawList.txt
ls -1 $loc | grep "calls.db" | awk '{print "/"$0}' >> ./$fol/rawList.txt

######################## Writing into Package-data file ############################

echo -e "backup_name $fol\ntimestamp 2021.04.12_10.06.34\ndevice santoni\nsdk 30\ncpu_abi arm64-v8a\ndata_required_size 380126\nsystem_required_size 0\nzip_expected_size 337995\nmigrate_version Migrate-GPE_4.0_release" > ./$fol/package-data.txt

######################## Checking if the required files exist ######################

while [ 1 ]
do
	count=0
	echo -e "\n\e[1;91mEnter package name or "n" to stop\e[0m"
	read pack
	[ "$pack" == "n" ] && break;
	if [ -e "$loc/$pack.app" ];
	then 
		echo -e "$pack.app--> \e[1;92mOK\e[0m"
	else
		echo -e "$pack.app--> \e[1;91mNOT OK\e[0m"
		count=1
	fi

	if [ -e "$loc/$pack.tar.gz" ];
	then
		echo -e "$pack.tar.gz--> \e[1;92mOK\e[0m"
	else
                echo -e "$pack.tar.gz--> \e[1;91mNOT OK\e[0m"
		count=1
        fi

	if [ -e "$loc/$pack.perm" ];
        then
                echo -e "$pack.perm--> \e[1;92mOK\e[0m"
        else
                echo -e "$pack.perm--> \e[1;91mNOT OK\e[0m"
		count=1
        fi

	if [ -e "$loc/$pack.png" ];
        then
                echo -e "$pack.png--> \e[1;92mOK\e[0m"
        else
                echo -e "$pack.png--> \e[1;91mNOT OK\e[0m"
		count=1
        fi

	if [ -e "$loc/$pack.json" ];
        then
                echo -e "$pack.json--> \e[1;92mOK\e[0m"
        else
                echo -e "$pack.json--> \e[1;91mNOT OK\e[0m"
		count=1
        fi
############################### Copying files from Corrupted Location to Fixing location ###############

	if [ $count == 0 ]; then
		cp -ir $loc/{$pack.app,$pack.tar.gz,$pack.perm,$pack.png,$pack.json}  ./$fol/

		###### Writing .app, .tar.gz, .png, .json, .perm into fileList and rawList file ##############

		echo -e "$pack.app\n$pack.tar.gz\n$pack.perm\n$pack.png\n$pack.json" >> ./$fol/fileList.txt
        echo -e "/$pack.perm\n/$pack.png\n/$pack.json\n$(ls -1 "./$fol/$pack.app" | awk -v var="/$pack" '{print var".app/"$0}')\n/$pack.tar.gz\n" >> ./$fol/rawList.txt
	else
		echo -e "Skipped\n"
	fi

done

######################## Writing Contacts Backup and Messages Backup into fileList file #################

ls -1 $loc | grep "vcf"  >> ./$fol/fileList.txt
ls -1 $loc | grep "sms.db"  >> ./$fol/fileList.txt
ls -1 $loc | grep "calls.db"  >> ./$fol/fileList.txt

##################### Writing the file to be included in rawList file ####################

echo -e "/fileList.txt\n/package-data.txt\n/rawList.txt\n" >> ./$fol/rawList.txt

############### Checking if zip package installed and Compressing all the files into zip #############

[ $(dpkg -s zip | wc -l) -lt 1 ] && yes | sudo apt install zip 
cd ./$fol/ ; zip -r $fol.zip * ; mv $fol.zip ../ ; cd ../

########### Cleaning UP ###################
rm -r $fol

echo -e "\n\e[1;91mDone!\e[0"







	

