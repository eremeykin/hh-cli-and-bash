#!/usr/bin/env bash
function suudo {
    echo "123" | sudo -S >> /dev/null 2>&1 -- sh -c "$1"
}

function wrfile {
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

if [ -z ${1+x} ]; 
    then 
        echo "email argument is required"
        exit 1
fi

email=$1
attemps="25"

# init tsk
key=`gkey "tsk -k $email"`
echo " Initial key:" $key

# init task 1
tsk -s 1 -k $key  >> /dev/null 2>&1
rm -rf ~/"-r"
key=`gkey "tsk -s 1 -k $key -c"`
echo "Task 1-c key:" $key

# init task 2
tsk -s 2 -k $key  >> /dev/null 2>&1
>&2 echo "Please, wait 2-3 mins, task 2 is long"
cat /var/log/loggen/*.log | wrfile
key=`gkey "tsk -s 2 -k $key -c"`
echo "Task 2-c key:" $key

# init task 3
tsk -s 3 -k $key >> /dev/null 2>&1
sleep 2
count="0"
while [ ! -f '/var/log/challenge/done.key' ]
do
    pid=`ps -a | grep sigproc`
    pid=${pid% pts*}
    kill -s SIGUSR1 $pid && kill -s SIGUSR2 $pid && kill -s SIGINT $pid
    count=$(expr $count + 1)
    if [ $count -gt $attemps ] 
        then    
        >&2 echo "Too many attemps, exit 13"
        exit 13
    fi
done

kill -9 $pid >> /dev/null 2>&1

ln -s /var/log/challenge/done.key
key=`gkey "tsk -s 3 -k $key -c"`
echo "Task 3-c key:" $key

# init task 4
tsk -s 4 -k $key 2>/tmp/tmp.txt 1>/tmp/tmp.txt
sleep 2
xrid=`cat  /tmp/tmp.txt | grep -oP "header to \K(.*)" --color=never`

num="1"
count="0"
while [ $num -lt  2 ]
do 
    # >&2 echo 'attemp'
    cred=`curl localhost:9182/task1 -H "X-Request-ID:$xrid" -v 2>&1 | grep X-Credentials:`
    cred=${cred#*: }
    cred=${cred//[$'\t\r\n ']}
    curl -L localhost:9182/task2 -d "credentials=$cred;" -v >> /dev/null 2>&1
    num=`curl -L localhost:9182/task2 -d "credentials=$cred" -vv 2>&1 | grep POST | wc -l`
    count=$(expr $count + 1)
    if [ $count -gt $attemps ] 
        then    
        >&2 echo "Too many attemps, exit 13"
        exit 13
    fi
done

curl -X DELETE localhost:9182/task3/$(expr $num - 1)  >> /dev/null 2>&1
key=`gkey "tsk -s 4 -k $key -c"`
echo "Task 4-c key:" $key
