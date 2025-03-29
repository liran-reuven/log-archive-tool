#!/bin/bash

# Sources {{{
config_file="config.sh"
config_colors_file="config_colors.sh"

# Check if config file exist
if [ -f $config_file ];
then
    source $config_file
fi

# Check if color config file exist
if [ -f $config_colors_file ];
then
    source $config_colors_file
fi # }}}

# Functions {{{ 
setup_config() {
    echo -e "Config file not found or missing values. Let's set it up.\n"
    
    read -p "Enter log archive directory: " log_archive_dir
    read -p "Enter max log file size (e.g., 100M, 1G): " max_log_size
    read -p "Enter retention period (days): " retention_days
    read -p "Enter log file to compress: " log_comp_file
    echo -e "Choose a compression format:"
    echo "1) gzip (.gz)"
    echo "2) bzip2 (.bz2)"
    echo "3) xz (.xz)"
    echo "4) zip (.zip)"
    echo "5) tar.gz (.tar.gz)"
    echo "6) tar.bz2 (.tar.bz2)"
    echo "7) tar.xz (.tar.xz)"
    echo "8) zstd (.zst)"
    read -p "Enter a number (1-8): " choice

    # Map user choice to compression command # {{{
    case "$choice" in
        1) comp_cmd="gzip" ext=".gz" ;;
        2) comp_cmd="bzip2" ext=".bz2" ;;
        3) comp_cmd="xz" ext=".xz" ;;
        4) comp_cmd="zip" ext=".zip" ;;
        5) comp_cmd="tar -czf" ext=".tar.gz" ;;
        6) comp_cmd="tar -cjf" ext=".tar.bz2" ;;
        7) comp_cmd="tar -cJf" ext=".tar.xz" ;;
        8) comp_cmd="zstd" ext=".zst" ;;
        *) echo "Invalidd choice!"; exit 1 ;;
    esac # }}} 

    cat <<EOL > "$config_file"
log_archive_dir="$log_archive_dir"
max_log_size="$max_log_size"
retention_days="$retention_days"
log_comp_file="$log_comp_file"
choice=$choice
comp_cmd="$comp_cmd"
ext="$ext"
EOL

    echo -e "\n[INFO] Configuration saved to $config_file"
} # }}}

# Hello {{{
clear
echo -e "$(figlet LogShrinker)\n" # }}}

# Check the settings to compression {{{
if [[ -z "$max_log_size" || -z "$log_archive_dir" || -z "$retention_days" || -z "$comp_cmd" || -z "$log_comp_file" ]];
then
    setup_config
    source "$config_file"
else
    echo "Using config:"
    echo "Max Log Size: $max_log_size"
    echo "Log Archive Dir: $log_archive_dir"
    echo "Target log file: $log_comp_file"
    echo -e "Compression Type: $comp_cmd ($ext)\n"
fi # }}}  

# Check if archive directory exsits {{{
echo -e "[INFO] Check if archive directory exists"
if [ ! -d "$log_archive_dir" ];
then
    echo "[INFO] Archive directory does not exist. Creating it now..."
    mkdir -p "$log_archive_dir"
    echo "[INFO] Archive directory created: $log_archive_dir"
else
    echo "[INFO] Archive directory already exists: $log_archive_dir"
fi # }}}

# Check if the log file exists {{{
echo "[INFO] Check if the file exists"
if [ ! -f $log_comp_file ];
then
    echo "[ERROR] File does not exist!"
    exit 1
else
    echo "[INFO] File $( basename $log_comp_file ) exists"
fi # }}}

# Get the size of the file {{{
echo "[INFO] Check file size"
file_size=$(du -k "$log_comp_file" | cut -f1)
echo -e "[INFO] The file size is: $(du -hk "$log_comp_file" | cut -f1)" # }}}

# Compress the log file {{{
echo "[INFO] Check if need to compress the log file"
if [ $file_size -ge "$max_log_size" ];
then
    echo "[INFO] The file need to be compress..."
    echo "[INFO] Compressing $log_comp_file to $log_archive_dir"
    compressed_file="${log_comp_file}${ext}"
    if [[ "$choice" -ge 5 && "$choice" -le 7 ]];
    then
        $comp_cmd "$compressed_file" "$log_comp_file"
    else
        $comp_cmd "$log_comp_file"
    fi
    echo "[INFO] Compressed file created: $compressed_file"
else
    echo "[INFO] The file is light"
    exit 2
fi # }}}
