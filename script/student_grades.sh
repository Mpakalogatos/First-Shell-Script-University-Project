#!/bin/bash

#If the user didnt input directory in command line display message
if [ -z "$1" ]; then
	echo "Please input a directory in command line"
	exit 1
fi

#If the directory doesnt exist display message
if [ ! -d "$1" ]; then
	echo "Please input the correc t name of the directory"
	exit 1
fi

#Create "grades.txt" in desktop and have it as a variable
GradesFile=~/Desktop/grades.txt

#If file GradesFile already exists, then delete it
if [ -e "$GradesFile" ]; then	
	echo "File for grades already exists. Removing file and creating new one"
	rm "$GradesFile" 
fi

#Create grade.txt
touch "$GradesFile" || { echo "Failed GradesFile creation."; exit 1; }

cd "$1" || { echo "Failed redirecting to directory"; exit 1; }	#Change path to the directory given and if something went wrong, then exit

#Go through all student directories to process data
for studentsdir in student_*; do 
	echo "Starting process in $studentsdir"
	#If directory exists. Proceed
	if [ -d "$studentsdir" ]; then
		#Check If required files exist
		if [ -f "$studentsdir/report.txt" ] && [ -f "$studentsdir/project1.c" ] && [ -f "$studentsdir/project2.c" ]; then	#If every file exist in directory then proceed
			StudentName=$(awk '{print $1}' "$studentsdir/report.txt")	#Use 'awk' to take the first word of the file AKA Name
			StudentID=$(awk '{print $2}' "$studentsdir/report.txt") #Use 'awk' to take the second word of the file AKA ID
			
			#Initialize variables for grades
			Project1Grade=0
			Project2Grade=0
			
			#Take the output of project1 and 2 and store them in variables
			gcc -o proj1 "$studentsdir/project1.c"
		
			Project1Output="$("./proj1")"	#Take output of C file for project 1 grade
			
			gcc -o proj2 "$studentsdir/project2.c"

			Project2Output="$("./proj2")"	#Take output of C file for project 2 grade
			
			if [ "$Project1Output" -eq 20 ]; then	#If Project1Output is equal to 20 then make Project1Grade 30
				Project1Grade=30
			else
				Project1Grade=0
			fi
			
			if [ "$Project2Output" -eq 10 ]; then	#If Project2Output is equal to 10 then make Project2Grade 70
				Project2Grade=70
			else
				Project2Grade=0
			fi
				
			#Calculate the total grade
			
			TotalGrade=$((Project1Grade + Project2Grade))	#Addition of project1 and 2 for total grade
		
			echo "$StudentName $StudentID project1: $Project1Grade project2: $Project2Grade total_grade: $TotalGrade" >> "$GradesFile"	#Echo the output and redirect it in the grades.txt
		fi
	fi
done

#Ask user to input if they want to organize files
read -p "Do you want to organise files with student info in a directory? (yes/no): " organisechoice

#Check user's choice
if [ "$organisechoice" == "yes" ]; then
    OrganisedDir=~/Desktop/organised	#Define the destination directory for organised projects

    if [ -d "$OrganisedDir" ]; then	#Check if the directory already exists
    	echo "Directory for organising projects already exists. Removing directory and creating new one"
        rm -r "$OrganisedDir" || { echo "Failed removing 'OrganisedDir'."; exit 1; }
    fi
		
    mkdir -p "$OrganisedDir" || { echo "Failed creating 'OrganisedDir'."; exit 1; }	#Create the directory

    for studentsdir in student*; do	#For loop to go through student directories
        if [ -d "$studentsdir" ]; then
        	#Check If required files exist
            if [ -f "$studentsdir/project1.c" ] && [ -f "$studentsdir/project2.c" ]; then
            	#Take Name and ID from report.txt
                StudentName=$(awk '{print $1}' "$studentsdir/report.txt")
                StudentID=$(awk '{print $2}' "$studentsdir/report.txt")

		#Copy project files to the organised directory
                cp "$studentsdir/project1.c" "$OrganisedDir/${StudentName}_${StudentID}_project1.c"
                cp "$studentsdir/project2.c" "$OrganisedDir/${StudentName}_${StudentID}_project2.c"
            fi
        fi
    done
else
	#If user says no then exit program
    echo "Files won't be organised"
    exit 0
fi
