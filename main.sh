function suudo {
    echo "123" | sudo -S 1>/tmp/fakenull 2>/tmp/fakenull -- sh -c "$1"
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
            # echo $path
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

function gxrid {
    line=`$1 | grep X-Request-ID | xargs -0 printf "%q"`
    line=${line#*[33m}
    line=${line%%\'*}
    echo $line
}

# init tsk
key=`gkey "tsk -k eremeykin@gmail.com"`
echo " Initial key:" $key

# init task 1
tsk -s 1 -k $key  2>/tmp/fakenull 1>/tmp/fakenull
rm -rf ~/"-r"
key=`gkey "tsk -s 1 -k $key -c"`
echo "Task 1-c key:" $key

# init task 2
tsk -s 2 -k $key  2>/tmp/fakenull 1>/tmp/fakenull
echo "Please, wait 2-3 mins, task 2 is long"
cat /var/log/loggen/*.log | extr
key=`gkey "tsk -s 2 -k $key -c"`
echo "Task 2-c key:" $key

# init task 3
# set -x
tsk -s 3 -k $key 2>/tmp/fakenull 1>/tmp/fakenull
sleep 2
count="0"
# set -x
while [ ! -f '/var/log/challenge/done.key' ]
do
    pid=`ps -a | grep sigproc`
    pid=${pid% pts*}
    kill -s SIGUSR1 $pid && kill -s SIGUSR2 $pid && kill -s SIGINT $pid
    count=$(expr $count + 1)
    if [ $count -gt 10 ] 
        then    
        echo "Too many attemps, exit 13"
        exit 13
    fi
done

kill -9 $pid 2>/tmp/fakenull 1>/tmp/fakenull

ln -s /var/log/challenge/done.key
key=`gkey "tsk -s 3 -k $key -c"`
echo "Task 3-c key:" $key

# init task 4
tsk -s 4 -k $key 2>/tmp/tmp.txt 1>/tmp/tmp.txt
xrid=`cat  /tmp/tmp.txt | grep -oP "header to \K(.*)" --color=never`

num="1"
while [ $num -lt  2 ]
do 
    cred=`curl localhost:9182/task1 -H "X-Request-ID:$xrid" -v 2>&1 | grep X-Credentials:`
    cred=${cred#*: }
    cred=${cred//[$'\t\r\n ']}
    curl -L localhost:9182/task2 -d "credentials=$cred;" -v 2>/tmp/fakenull 1>/tmp/fakenull
    num=`curl -L localhost:9182/task2 -d "credentials=$cred" -vv 2>&1 | grep POST | wc -l`
done

curl -X DELETE localhost:9182/task3/$(expr $num - 1)  2>/tmp/fakenull 1>/tmp/fakenull
key=`gkey "tsk -s 4 -k $key -c"`
echo "Task 4-c key:" $key

