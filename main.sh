tsk -k eremeykin@gmail.com

# task 1
tsk -s 1 -k MTplcmVtZXlraW5AZ21haWwuY29tOjE1NDMwNzMzOTczMDBiOGY0Mw==
rm -rf ~/"-r"
tsk -s 1 -k MTplcmVtZXlraW5AZ21haWwuY29tOjE1NDMwNzMzOTczMDBiOGY0Mw== -c

# task2
tsk -s 2 -k MjplcmVtZXlraW5AZ21haWwuY29tOjE1NDMwNzM4MzQ5NmE3ZDEyZA==

sudo su

function extr {
    regex="\[404\]\s[0-9]+\s:([0-9]+)\s(.*)\s=([0-9]+)"

    while read line
    do
        if [[ $line =~ $regex ]]
        then
            perm="${BASH_REMATCH[1]}"
            path="${BASH_REMATCH[2]}"
            size="${BASH_REMATCH[3]}"
            echo $line
            echo wrfile $size $path
            read -p "Press enter to continue"
            wrfile $size $path
            echo chmod $perm $path
            sudo -p123 chmod $perm $path
        else
            continue
        fi
    done < "${1:-/dev/stdin}"
}

function wrfile {
    echo -n '' > $2
    for ((i=1; i<=$1; i++)); do
      printf '0%.0s' >> $2
    done
}

cat /var/log/loggen/*.log | extr

exit

tsk -s 2 -k MjplcmVtZXlraW5AZ21haWwuY29tOjE1NDMwNzM4MzQ5NmE3ZDEyZA== -c

tsk -s 3 -k MzplcmVtZXlraW5AZ21haWwuY29tOjE1NDMzNDYxNzhmMzljOWU2Yg==

kill -s SIGUSR1 26367 && kill -s SIGUSR2 26367 && kill -s SIGINT 26367
#               pid                      pid                     pid
ln -s /var/log/challenge/done.key
tsk -s 3 -k MzplcmVtZXlraW5AZ21haWwuY29tOjE1NDMzNDYxNzhmMzljOWU2Yg== -c

tsk -s 4 -k NDplcmVtZXlraW5AZ21haWwuY29tOjE1NDMzNDY1NjZiMmEzMzg2NA==

curl localhost:9182/task1 -H "X-Request-ID:%252FPJ1tDdFjL1WkH2GQ0tVtT0wGJ3GejDp" -v
curl -L localhost:9182/task2 -d "credentials=zbnBG2eIY7TmfcSYQltyZlJVrSkqyPLk;" -v
# follow redirect

curl -L localhost:9182/task2 -d "credentials=zbnBG2eIY7TmfcSYQltyZlJVrSkqyPLk;" -v 2>&1  | grep POST | wc -l

curl -X "DELETE" localhost:9182/task3/22 -v

tsk -s 4 -k NDplcmVtZXlraW5AZ21haWwuY29tOjE1NDMzNDY1NjZiMmEzMzg2NA== -c









