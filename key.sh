#!/usr/bin/env bash

# chmod +x key.sh
# ./key.sh

for (( i=0; i<256; i++ )); do
    b=$(printf '%#x' ${i})    
    r=$(xortool crypto01.jpg -l 6 -c ${b})

    if [[ ${r} = *"Found 1"* ]]; then
        echo ${r} 
        exit 0
    else
        echo "${r}" | sed -n '2p'
    fi 
done
