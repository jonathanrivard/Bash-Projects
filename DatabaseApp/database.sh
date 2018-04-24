#!/bin/bash
#MIT License 
#Copyright (c) 2018 Jonathan Michael Rivard
#v0.3.0

#This is simple script to control a database of people and their user information
#This was my first bash script, I made it as a project to fully imerse myself in the language

#Global Varibles
searchString="default" #Is used in getId and search
selectedId="00000" #Select ID, Used in multiple functions
exitString="" #Used to know if a select is to exited

#Paths (Change these to where...)
repPath=infoFolder/rep.txt #The repository.txt is stored
infoPath=infoFolder/info/ #The folder you want to contain the files

function getId { #Get ID using search string from search function. Set it to selectedId
  selectedId=$(cat $repPath | grep $searchString | cut -f 3 -d ' ' )
}

function search { #Get search string for getId function
  clear #Clear select
  echo Enter Search Term:
  read searchString #Get and store string to search

  clear #Clear search term question
  getId #Set selectedId
  
  #Select varibles
  selectedOption=''
  selectOptions=''
  selectPlace='' #Holder to make cutting input more condensed

  for option in $selectedId #For each id gotten from getId(the repository)
  do
    selectPlace="$(cat -n $infoPath$option | grep '1\t' | cut -f 2)" #Get name
    selectOptions="$selectOptions $(echo $selectPlace | cut -f 1 -d ' ')_$(echo $selectPlace | cut -f 2 -d ' ')" #Format name
  done

  selectOptions="$selectOptions Back" #Add back to selectOptions

  select selected in $selectOptions
  do
    if [[ $selected == 'Back' ]]
    then
      clear
      exitString='break'
      break
    
    fi
    if [[ $exitString == 'break' ]]
    then
      exitString=''
      break
    elif [[ $exitString == '' ]]
    then
      selectedOption=$(echo $selectedId | cut -f $REPLY -d ' ') #Set selectedOption equal to only the reply
      selectedId=$selectedOption #Update selectedId
      clear #Clear select
      displayInfo
      displayInfoLoop
      break
    fi
  done

  
}

function displayInfo { #Displays selected Id's info
  #Display varibles
  name=""
  date=""
  username=""
  password=""

  #Get and cut from the file to set all the display varibles; uses a \t(tab) to make sure it selects the line
  name=$(cat -n $infoPath$selectedId | grep '1\t' | cut -f 2)
  date=$(cat -n $infoPath$selectedId | grep '2\t' | cut -f 2)
  username=$(cat -n $infoPath$selectedId | grep '3\t' | cut -f 2)
  password=$(cat -n $infoPath$selectedId | grep '4\t' | cut -f 2)

  #Display
  echo "ID: $selectedId"
  echo "Name: $name"
  echo "Date of Birth: $date"
  echo "Username: $username"
  echo "Password: $password"
  echo #Newline

}

function displayInfoLoop { #Functionality and select menu for displaying after searched person select
  #Select varibles
  selectedOption=''
  selectOptions='Edit Delete Back'

  select selected in $selectOptions
  do
    if [[ $selected == 'Edit' ]]
    then
      clear
      displayInfo
      editFile
      exitString='continue'
      break
    elif [[ $selected == 'Delete' ]]
    then
      deleteIdFile
      clear
      exitString='break' #Break into sof
      break
    elif [[ $selected == 'Back'  ]]
    then
      clear
      exitString='break' #Break into sof
      break
    else
      clear
      displayInfo
      exitString='continue' #Stay in loop
      break
    fi
  done

  if [[ $exitString == 'continue' ]]
  then
    exitString=''
    displayInfoLoop
  elif [[ $exitString == 'break' ]]
  then
    exitString=''
    break
  else
    clear
    echo "Exit String was set wrong in InfoDisplayLoop"
    exit 0
  fi
}

function editFile {
  #Select varibles
  selectedOption=''
  selectOptions='Name Date_of_Birth Username Password Back'
  input=''
  line=''
  tempId=00000
  beforeName=''

  select selected in $selectOptions
  do
    if [[ $selected == 'Name' ]]
    then
      clear
      displayInfo
      echo
      echo -n Name:
      read input
      line=$(cat -n $infoPath$selectedId | grep '1\t' | cut -f 1)
      beforeName=$(cat -n $infoPath$selectedId | grep '1\t' | cut -f 2 | cut -f 1,3 -d ' ')
      sed -i '' "${line}s/.*/$input/" $infoPath$selectedId 
      tempId=$(cat $repPath | grep $beforeName | cut -f 3 -d ' ')
      line=$(cat -n $repPath | grep $beforeName | cut -f 1)
      sed -i '' "${line}s/.*/$input $tempId/" $repPath
      exitString='continue'
      break
    elif [[ $selected == 'Date_of_Birth' ]]
    then
      clear
      displayInfo
      echo
      echo -n Date of Birth:
      read input
      line=$(cat -n $infoPath$selectedId | grep '2\t' | cut -f 1)
      sed -i '' "${line}s/.*/$input/" $infoPath$selectedId 
      exitString='continue'
      break
    elif [[ $selected == 'Username' ]]
    then
      clear
      displayInfo
      echo
      echo -n Username:
      read input
      line=$(cat -n $infoPath$selectedId | grep '3\t' | cut -f 1)
      sed -i '' "${line}s/.*/$input/" $infoPath$selectedId 
      exitString='continue'
      break
    elif [[ $selected == 'Password' ]]
    then
      clear
      displayInfo
      echo
      echo -n Password:
      read input
      line=$(cat -n $infoPath$selectedId | grep '4\t' | cut -f 1)
      sed -i '' "${line}s/.*/$input/" $infoPath$selectedId 
      exitString='continue'
      break
    elif [[ $selected == 'Back'  ]]
    then
      clear
      exitString='break' #Break into sof
      break
    else
      clear
      displayInfo
      exitString='continue' #Stay in loop
      break
    fi
  done

  if [[ $exitString == 'continue' ]]
  then
    clear
    exitString=''
    displayInfo
    editFile
  elif [[ $exitString == 'break' ]]
  then
    clear
    exitString=''
    displayInfo
  else
    clear
    echo "Exit String was set wrong in InfoDisplayLoop"
    exit 0
  fi
}

function deleteIdFile { #Find and delete line in repository and file in info folder
  rm $infoPath$selectedId #Delete selected ID
  lineToDelete=$(cat -n $repPath | grep $selectedId | cut -f 1)
  sed -i '' -e "${lineToDelete}d" $repPath
  updateNumberOfIds
}

function updateNumberOfIds { #Update the number of ids in the rep
  numberToUpdate=$(cat $repPath | grep 'numberofids' | cut -f 3 -d ' ') #Get the current number to search for the replacement
  numberToOut=00000 #Replaacment number varible
  lineCount=$(wc -l < $repPath) #Lines in the rep
  numberToOut=$(($lineCount-2)) #Subtract the the count and default lines
  sed -i '' -e "1s/$numberToUpdate/$numberToOut/" $repPath #Search and replace in the first line
}

function addPerson { #Add person to rep and create file
  #Varibles
  firstName=""
  lastName=""
  date=""
  username=""
  password=""
  outString="" #String to print to rep
  totalIds=$(grep 'numberofids' $repPath | cut -f 3 -d ' ') #Get the number of total ids
  totalIds=$(($totalIds+1)) #Make sure to use the NEXT id
  newId=00000 #Varible to hold our new id
  counter=1 #Counter for while loop to create our new id
  numOfChars=${#totalIds}

  updateNumberOfIds #so we know what id to give it in the rep
  clear
  echo 'Add a Person(Write in all lowercase)'
  echo -n First Name:
  read firstName
  echo -n Last Name:
  read lastName
  echo -n Date of Birth:
  read date
  echo -n Username:
  read username
  echo -n Password:
  read password

  newId=$totalIds #Set our placeholder to the current number of ids
  while [ $counter -le $((5-$numOfChars)) ] #While loop to add zeros infront of our id to fit a five character slot
  do
    ((counter++))
    newId=0$newId #Add a zero infront of it
  done

  outString=$"$firstName $lastName $newId" #Combine all varibles into a string
  echo $outString >> $repPath #Append output to rep
  
  touch "$infoPath$newId"
  echo "$firstName $lastName" >> "$infoPath$newId"
  echo "$date" >> "$infoPath$newId"
  echo "$username" >> "$infoPath$newId"
  echo "$password" >> "$infoPath$newId"

  updateNumberOfIds #Update out number ids because we just added one
  clear
  echo "$firstName $lastName Added with the ID: $newId"
  echo
  echo -n "Press enter to continue..."
  read
  #Loop restarted after this
}

function sof { #stands for select options function
  #Varibles
  selectedOption=''
  selectOptions='Search Add_Person Quit'
  PS3='Select: '
  
  select selected in $selectOptions
  do
    if [[ $selected == 'Search' ]]
    then
      search
      clear
    elif [[ $selected == 'Quit' ]]
    then
      clear
      exit 0 #Stop Program 
    elif [[ $selected == 'Add_Person'  ]]
    then
      addPerson
      clear
    else
      clear
      echo Not a valid option.
    fi

    break #Break out so it can be called again below to redisplay the menu
  done
}

#Start
clear
while true; do sof; done #Loop
