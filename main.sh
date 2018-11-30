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

function gxrid {
    line=`script -c "$1" | grep X-Request-ID | xargs -0 printf "%q"`
    line=${line#*[33m}
    line=${line%%\'*}
    echo $line
}

# init tsk
key=`gkey "tsk -k eremeykin@gmail.com"`
echo "Initial key:" $key

# init task 1
tsk -s 1 -k $key
rm -rf ~/"-r"
key=`gkey "tsk -s 1 -k $key -c"`
echo "Task 1  key:" $key

# init task 2
tsk -s 2 -k $key
cat /var/log/loggen/*.log | extr
key=`gkey "tsk -s 2 -k $key -c"`
echo "Task 2  key:" $key

# init task 3
tsk -s 3 -k $key
pid=`ps -a | grep sigproc`
pid=${pid% pts*}
echo $pid

while [ ! -f '/var/log/challenge/done.key' ]
do
    kill -s SIGUSR1 $pid && kill -s SIGUSR2 $pid && kill -s SIGINT $pid
done

ln -s /var/log/challenge/done.key
key=`gkey "tsk -s 3 -k $key -c"`
echo "Task 3  key:" $key

# init task 4
# set -x
# tsk -s 4 -k $key
# xrid=`gxrid "tsk -s 4 -k $key"`
# echo $xrid 
# cred=`curl localhost:9182/task1 -H "X-Request-ID:$xrid" -v 2>&1 | grep X-Credentials:`
# echo $cred
# cred=${cred#*:}
# echo $cred
# curl -L localhost:9182/task2 -d "credentials=$cred;" -v


