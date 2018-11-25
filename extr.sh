function extr {
    regex="\[404\]\s[0-9]+\s:([0-9]+)\s(.*)\s=([0-9]+)"

    while read line
    do
        if [[ $line =~ $regex ]]
        then
            permissions="${BASH_REMATCH[1]}"
            path="${BASH_REMATCH[2]}"
            size="${BASH_REMATCH[3]}"
            echo "${permissions}"
            echo "${path}"
            echo "${size}"
        else
            continue
        fi
    done < "${1:-/dev/stdin}"
}