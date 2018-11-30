function suudo {
    echo "123" | sudo -S -- sh -c "$1"
}

function extr {
    regex="\[404\]\s[0-9]+\s:([0-9]+)\s(.*)\s=([0-9]+)"

    while read line
    do
        if [[ $line =~ $regex ]]
        then
            perm="${BASH_REMATCH[1]}"
            path="${BASH_REMATCH[2]}"
            size="${BASH_REMATCH[3]}"
            if [ -f $path ]; then
                continue;
            fi
            echo $path
            suudo "fallocate -l $size $path"
            suudo "chmod $perm $path"
        else
            continue
        fi
    done < "${1:-/dev/stdin}"
}

function gkey {
    line=`script -c "$1" | grep Key: | xargs -0 printf "%q"`
    line=${line#*[33m}
    line=${line%%\'*}
    echo $line
}

# init tsk
key=`gkey "tsk -k eremeykin@gmail.com"`
echo "Initial key:" $key

# init task 1
script -c "tsk -s 1 -k $key" > /dev/null
rm -rf ~/"-r"
key=`gkey "tsk -s 1 -k $key -c"`
echo "Task 1  key:" $key

# init task 2
script -c "tsk -s 2 -k $key" > /dev/null
cat /var/log/loggen/*.log | extr
key=`gkey "tsk -s 2 -k $key -c"`
echo "Task 2  key:" $key
