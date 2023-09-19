#!/bin/bash

#
#    Find infected Wordpress files
#

# Vars

wppath=/var/www/hygeanps.com


# Function

find_and_store_files() {    
    local files_to_delete=()

    while IFS= read -r -d $'\0' file; do
        files_to_delete+=("$file")
    done < <(find "$1" -type f "$2")

    if [ ${#files_to_delete[@]} -eq 0 ]; then
        echo "No files matching criteria were found in $1."
    else
        echo "Files matching criteria in $1:"
        for file in "${files_to_delete[@]}"; do
            echo "$file"
        done
    fi
}


# Main

echo "Searching for PHP files in upload folder..."
find_and_store_files "$wppath/wp-content/uploads" "-name \"*.php\""

echo "Searching for common backdoors functions..."
find_and_store_files "$wppath" "-name '*.php' -print0 | xargs -0 egrep -i \"(mail|fsockopen|pfsockopen|stream\_socket\_client|exec|system|passthru|eval|base64_decode)\""

echo "Searching for scripts hidden in image-files.."
find_and_store_files "$wppath"/wp-content/uploads "-iname '*.jpg' | xargs grep -i php"

echo "Searching for files with iframes"
find_and_store_files "$wppath" "-name '*.php'| grep -i '<iframe'"
