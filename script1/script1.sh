#!/bin/bash
clear

read -p $'What file do you want to read?\nCommand: ' file

clear

read -p $'Whats the plan?\n[1] Create or change user\n[2] Delete a user with the same name?\nCommand: ' select

for line in $(cat $file)
do

	username=`echo $line | cut -d : -f1`
	group=`echo $line | cut -d : -f2`
	password=`echo $line | cut -d : -f3`
	shell=`echo $line | cut -d : -f4`
	ssl_password=`openssl passwd -1 $password`
	echo "- User: $username\n- Group: $group\n- Password: $password\n- Shell: $shell"

	case $select in
		1) if [[ `grep $username /etc/passwd` ]]
		then
		       	read -e -p "Make changes to the user ( $username )?\n[Y] - Yes\n[N] - No\nCommand: " change_user
			if [[ "$change_user" =~ ^([yY])$ ]]
			then
				read -p "Change password ( $username )?\n[Y] - Yes\n[N] - No\nCommand: " change_password
				if [[ "$change_password" =~ ^([yY])$ ]]
				then
					usermod -p $ssl_password $username
					echo -e "$username - Password changes!"
				fi
				read -p "Change group ( $username )?\n[Y] - Yes\n[N] -No\nCommand: " change_group
				if [[ "$change_group" =~ ^([yY])$ ]]
				then
					current_group=`groups $username | cut -d " " -f2`
					if [[ $current_group != $group ]]
					then
						usermod -g $group $username
						echo -e "$username - Group changes!\nNew group: $group"
					else
						echo -e "$username - Already in the group $group"
					fi
				fi
				read -p "Change shell ( $username )?\n[Y] - Yes\n[N] - No\nCommand: " change_shell
				if [[ "$change_shell" =~ ^([yY]$ ]]
				then
					current_shell=`grep $username /etc/passwd | cut -d : -f4`
					if [[ $change_shell != $shell ]]
					then
						usermod -s $shell $username
						echo -e "$username - Shell changes!\nNew shell: $shell"
					else
						echo -e "$username - Already  in the shell $shell"
					fi
				fi
			fi
		else
			groupadd -f $group;
			useradd $username -p $ssl_password -g $group -s $shell;
			echo -e "$username - added group $group"
		fi;;
	2) if [[ `grep $username /etc/passwd` ]]
	then
		userdel -r $username
		echo -e "$username - Deleted."
	fi;;
esac
done
