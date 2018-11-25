function wrfile {
    for ((i=1; i<=$1; i++)); do
      printf '0%.0s' >> $2
    done
}
