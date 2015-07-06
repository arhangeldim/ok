#!/bin/bash
# PNG optimization using pngquant
# Usage ./optim -i <input_dir> -o <out_dir> -r <raw_files> -q / -m


GNU_DATE="/usr/local/opt/coreutils/libexec/gnubin/date +%s%3N"

#POSIX
OPTIND=1  # Reset in case getopts has been used previously in the shell.


input_dir="."
output_dir="png_output"
raw_dir="png_raw"
optimizer=0 #pngquant
raw_dir_size=0
COUNT=0

# copy & rename all input images
prepare_data() {
    echo "Preparing images..."
    iter=0
    for f in $input_dir/*
        do
            #echo $f
            cp $f "$raw_dir/image_$iter"
            iter=$((iter + 1))
    done
    raw_dir_size=$(du -ks $raw_dir | cut -f1)
    echo "Done, $((iter - 1)) files moved to $raw_dir"
    COUNT=$((iter - 1))
}

# arg1 - quality (-s1 ... -s10)
compress_pngquant() {

    echo "pngquant compressing..."
    quality=$1 # pngquant compressing quality
    iter=0
    mkdir -p "$output_dir/q$quality" # diff dirs for quality
    printf "Compressing with quality: $1\noutput: $output_dir/q$quality\n"

    START=$($GNU_DATE)
    for i in $(seq 0 $COUNT); do
        pngquant "$quality" -f -o "$output_dir/q$quality/image_$i" $raw_dir/image_$i;
    done

    STOP=$($GNU_DATE)

    output_dir_size=$(du -ks $output_dir/q$quality/ | cut -f1)
    compressed=$(awk "BEGIN {printf \"%.2f\", ${output_dir_size}/${raw_dir_size}}")
    elapsed=$((STOP-START))
    printf "RESULT: $raw_dir_size KB -> $output_dir_size KB was compressed on $compressed \n"
    printf "$COUNT files were processen in $elapsed ms\n"
}

# arg1 - quality (10-100)
compress_median() {
    echo "posterizing..."
    quality=$1 # pngquant compressing quality
    iter=0
    mkdir -p "$output_dir/m$quality" # diff dirs for quality
    printf "Compressing with quality: $1\noutput: $output_dir/m$quality\n"

    START=$($GNU_DATE)
    for i in $(seq 0 $COUNT); do
        ./posterize -b -d -Q $quality $raw_dir/image_$i $output_dir/m$quality/image_$i
    done

    STOP=$($GNU_DATE)

    output_dir_size=$(du -ks $output_dir/m$quality/ | cut -f1)
    compressed=$(awk "BEGIN {printf \"%.2f\", ${output_dir_size}/${raw_dir_size}}")
    elapsed=$((STOP-START))
    printf "RESULT: $raw_dir_size KB -> $output_dir_size KB was compressed on $compressed \n"
    printf "$COUNT files were processen in $elapsed ms\n"

}

start() {
    echo "Started"
    prepare_data

    case $optimizer in
        0)
            compress_pngquant "-s3"
            compress_pngquant "-s10"
            ;;
        1)
            compress_median "80";;
    esac

}

show_help() {
    echo "Usage ./run -i <input_dir> <-q|-m>"
}

if [ "$#" -le 2 ]; then
    show_help
    exit
fi

while getopts "h?:i:o:r:qm" opt
do
    case $opt in
        h|\?)
            show_help
            exit 0;;
        i)
            input_dir=$OPTARG;;
        o)
            output_dir=$OPTARG;;
        r)
            raw_dir=$OPTARG;;
        q)
            optimizer=0;;
        m)
            optimizer=1;; # add to PATH

    esac
done
shift $((OPTIND-1))

echo "in: $input_dir, out: $output_dir, raw: $raw_dir"
echo "optimizer: $optimizer"

start
