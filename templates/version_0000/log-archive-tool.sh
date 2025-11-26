#!/bin/bash

clear

log_tool_file=/var/log/log_archive_tool.log

# Functions {{{

# Check if file exist {{{
check_file_exist() {
    local file="$1"
    if [ -f "$file" ];
    then
        source "$file"
        log_message "[INFO] The file is exist $(basename $file)" >> /var/log/log_archive_tool.log
    else
        log_message "[ERROR] Can't find $(basename $file)" >> /var/log/log_archive_tool.log
    fi
}  # }}} 

# Update config.sh  {{{
setup_config() { 
    echo -e "Config file not found or missing values. Let's set it up.\n"
    
    read -p "Enter log archive directory: " log_archive_dir
    read -p "Enter max log file size (e.g., 100M, 1G): " max_log_size
    read -p "Enter retention period (days): " retention_days
    read -p "Enter log file to compress: " log_comp_file
    echo -e "Choose a compression format:"
    echo "[1] gzip      (.gz)"
    echo "[2] bzip2     (.bz2)"
    echo "[3] xz        (.xz)"
    echo "[4] zip       (.zip)"
    echo "[5] tar.gz    (.tar.gz)"
    echo "[6] tar.bz2   (.tar.bz2)"
    echo "[7] tar.xz    (.tar.xz)"
    echo "[8] zstd      (.zst)"
    read -p "Enter a number (1-8): " choice
    echo

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

    log_message_e "[INFO] Configuration saved to $config_file"
} # }}}

# Log message {{{
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
 } 

log_message_e() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
 }

log_message_file_convert() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$log_file"
 } # }}}

# }}}

# Check if the user provided a directory {{{
if [ -z "$1" ];
then
    echo "Usage: $0 <log-directory>"
    exit 1
fi 

log_dir="$1" # }}}

# Check for log tool file {{{ 
if [ ! -f "$log_tool_file" ];
then
    touch "$log_tool_file" || { printf "Failed to create log file!\n" >&2; exit 1; }
    log_message_e "[ERROR] Log file not found. Was created at '/var/log'" >> /var/log/log_archive_tool.log
else
    printf "$(log_message) Log file exists: %s\n" "$log_tool_file" >> /var/log/log_archive_tool.log
fi # }}}

# Sources {{{

config_file="./config/config.sh"
config_colors_file="./config/config_colors.sh"

# Check if config file exist
check_file_exist $config_file

# Check if color config file exist
check_file_exist $config_colors_file # }}}

# Hello {{{
clear
echo -e "$(figlet LogShrinker)\n" # }}}

# Valid the log directory {{{

if [ ! -d "$log_dir" ];
then
    log_message "[ERROR] Log directory '$log_dir' does not exist."
    exit 1
fi # }}}
    
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
log_message_e "[INFO] Check if archive directory exists" >> /var/log/log_archive_tool.log
if [ ! -d "$log_archive_dir" ];
then
    log_message "[INFO] Archive directory does not exist. Creating it now..." >> /var/log/log_archive_tool.log
    mkdir -p "$log_archive_dir"
    log_message "[INFO] Archive directory created: $log_archive_dir" >> /var/log/log_archive_tool.log
else
    log_message "[INFO] Archive directory already exists: $log_archive_dir" >> /var/log/log_archive_tool.log
fi # }}}

# Check if the log file exists {{{
log_message "[INFO] Check if the file exists" >> /var/log/log_archive_tool.log
if [ ! -f $log_comp_file ];
then
    log_message "[ERROR] File does not exist!" >> /var/log/log_archive_tool.log
    exit 1
else
    log_message "[INFO] File $( basename $log_comp_file ) exists" >> /var/log/log_archive_tool.log
fi # }}}

# Get the size of the file {{{
log_message "[INFO] Check file size" >> /var/log/log_archive_tool.log
log_size=$(du -k "$log_comp_file" | cut -f1)
log_message_e "[INFO] The file size is: $log_size" >> /var/log/log_archive_tool.log # }}}

# Generate a timestamped archive filename {{{
timestamp=$(date '+%Y%m%d_%H%M%S')
archive_file="$backup_dir/$( basename $log_comp_file | cut -d '.' -f 1)_${timestamp}${ext}" # }}}

# Compress the log file {{{
log_message "[INFO] Check if need to compress the log file" >> /var/log/log_archive_tool.log
if [ $log_size -ge "$max_log_size" ];
then
    log_message "[INFO] The file need to be compress..." >> /var/log/log_archive_tool.log
    log_message "[INFO] Compressing $log_comp_file to $log_archive_dir" >> /var/log/log_archive_tool.log
    compressed_file="${log_comp_file}${ext}"
    if [[ "$choice" -ge 5 && "$choice" -le 7 ]];
    then
        $comp_cmd "$compressed_file" "$log_comp_file"
        if [ $? -eq 0 ];
        then
            log_message "[SUCCESS] Archived '$log_dir' to '$archive_file'." >> /var/log/log_archive_tool.log
        else
            log_message "[ERROR] Failed to archive '$log_dir'." >> /var/log/log_archive_tool.log
            exit 1
        fi
    else
        $comp_cmd "$log_comp_file"
        if [ $? -eq 0 ];
        then
            log_message "[SUCCESS] Archived '$log_dir' to '$archive_file'." >> /var/log/log_archive_tool.log
        else
            log_message "[ERROR] Failed to archive '$log_dir'." >> /var/log/log_archive_tool.log
            exit 1
        fi
    fi
    log_message "[INFO] Compressed file created: $compressed_file" >> /var/log/log_archive_tool.log
else
    log_message "[INFO] The file is below the maximum size $log_size/"$max_log_size"[M]. No need to archive." >> /var/log/log_archive_tool.log
    exit 2
fi # }}}
