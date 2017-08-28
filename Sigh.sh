#!/bin/bash

echo "==================#Check if fastlane is installed or no==================="

if type [ fastlane >/dev/null 2>&1 ] 
	then
        echo "Fastlane  is present" 
    
    else 
    	echo "Do you want to install fastlane? (yes or no?)"
        read want

        case $want in
        	yes)
        	 sudo gem install fastlane

            echo "Installation complete"
            ;;
          no)
            echo "Hard luck. Install manually later if you want."
            exit 1
            ;;
            *) echo "wrong input"
            ;;
esac
fi

echo "Enter your IPA (location or name) to be resigned."
read IPA

echo "Enter location of mobile povision"
read location 

echo "Enter your signing identity name(iPhone dev: blah blah blah)"
read name

fastlane sigh resign "$IPA" --signing_identity "$name" -p ""$location""

 
