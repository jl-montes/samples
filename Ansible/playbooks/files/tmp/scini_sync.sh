#!/bin/bash
###############################################################################
# A utility script that contains functions to synchronize a local scini
# cache/repository with a remote repository. Meaning these utils are used both 
# by the scini service to fetch the module for the current kernel, and by the
# scini repository to sync itself with another repository.
###############################################################################

#Scream if we try to substitute an undefined variable
set -u

DEBUGGING=
MODULE_NAME=scini.ko

# legal config options list
CONFIG_OPTS=(repo_address 
             repo_user 
             repo_password
             local_dir
             sync_pattern
             user_private_rsa_key
             repo_public_rsa_key
             emc_public_gpg_key
             module_sigcheck)

MY_NAME=$(basename ${BASH_SOURCE[0]})
CONFIG_FILE=$(dirname ${BASH_SOURCE[0]})/scini_sync.conf
LOG_FILE=$(dirname ${BASH_SOURCE[0]})/scini_sync.log

###############################################################################
function bail_out() {
    echo $1 | tee -a ${LOG_FILE}
    echo "${MY_NAME} END - $(date)" | tee ${LOG_FILE}
    exit 1
}

###############################################################################
function debug_msg() {
    if [ ! -z $DEBUGGING ]; then
        log_msg ${@}
    fi
}

###############################################################################
function log_msg() {
    local the_message=${@}

    echo $the_message | tee $LOG_FILE
}

###############################################################################
function read_config_file() {

    local conf_file=$1
    local legal_opt

    local cur_line
    local cur_opt
    local cur_val

    [ -f $conf_file ] || bail_out "Error opening config file: $conf_file"

    while true; do

        read cur_line || break

        # Remove comments, spaces & dangerous chars.
        cur_line=$(echo $cur_line | sed 's/#.*//g' | tr -d ' ;\\\\')

        cur_opt=$(echo $cur_line | awk -F= '{ print $1 }')
        cur_val=$(echo $cur_line | awk -F= '{ print $2 }')

        debug_msg "CUR_OPT: $cur_opt"
        debug_msg "CUR_VAL: $cur_val"

        for legal_opt in ${CONFIG_OPTS[@]}; do

           debug_msg "LEGAL: $legal_opt"

           if [ "$legal_opt" = "$cur_opt" ]; then
               debug_msg "Doing : $cur_opt=$cur_val"
               eval $cur_opt=$cur_val
               break
           fi
        done
    done < $conf_file

    return 0
}

###############################################################################
function print_usage_and_bail() {
    cat << EOF

Usage: ${MY_NAME} [-c <CONF_FILE>] <command> <cmd_args>

  Available commands:

  * retrieve <Distro>/<scaleio_ver>/<kernel_name>
      Will attept to retrieve the given kernel object from the configured 
      repository.

      Example: 
      ${MY_NAME} retrieve Ubuntu/1.32.0.30/3.16.0-45-generic

  * sync
      Will synchronize the local kernel objects cache with the configured 
      repository using the configured sync pattern.

EOF
    bail_out ""
}


###############################################################################
function parse_repo_address() {
    repo_protocol=${repo_address%%:*}

    case $repo_protocol in
        ftp|sftp)
            repo_url=${repo_address#*://}
            repo_dir=/${repo_url#*/}
            repo_url=${repo_url%%/*}

            debug_msg "repo_url $repo_url"
            ;;
        file)
            repo_dir=${repo_address#*:/}
            ;;
        *)
            bail_out \
              "Unrecognized protocol prefix in repo_address $repo_address."
            ;;
    esac

    debug_msg "repo_protocol $repo_protocol"
    debug_msg "repo_dir $repo_dir"
}

###############################################################################
function verify_config_option() {
    local the_opt=$1
    local error_arg=$2
    local option=$3

    local path_name
    
    if eval [ \"\${${the_opt}:+ok}\" != \"ok\" ]; then
        bail_out "Error (${error_arg}): Option ${the_opt} must be set."
    else
        #Option is set, now perform additional checks
        if [ "${option}" != "normal" ]; then
            eval path_name=\${${the_opt}}
        fi

        if [ "${option}" = "file" ] && [ ! -f ${path_name} ]; then
            bail_out "Error (${error_arg}): File ${path_name} must exist."
        elif [ "${option}" = "dir" ] && 
            ! mkdir -p ${path_name} > /dev/null 2>&1; then
            bail_out "Error (${error_arg}): Cannot create/access directory ${path_name}."
        fi
    fi
}

###############################################################################
function verify_ftp_if_needed() {
    if [ "$repo_protocol" = "ftp" ]; then
        if ! which ftp >> ${LOG_FILE} 2>&1; then
            bail_out "Error: ftp client program not found."
        fi
        
        verify_config_option "repo_user" "ftp" "normal"
        verify_config_option "repo_password" "ftp" "normal"

    elif [ "$repo_protocol" = "sftp" ]; then
        if ! which sftp >> ${LOG_FILE} 2>&1; then
            bail_out "Error: sftp client program not found."
        fi

        verify_config_option "user_private_rsa_key" "sftp" "file"
        verify_config_option "repo_public_rsa_key" "sftp" "file"
    fi
}

###############################################################################
function verify_gpg() {
    local gpg_ok=0

    verify_config_option "emc_public_gpg_key" "gpg" "file"

    if ! which gpg > /dev/null; then
        log_msg "Error: gpg software not found!"
        log_msg "       will not be able to verify driver signatures."
    elif gpg --import $emc_public_gpg_key >/dev/null; then
        log_msg "EMC GPG key successfully imported."
        gpg_ok=1
    else
        log_msg "Error: Could not import public GPG key from $emc_public_gpg_key."
        log_msg "       will not be able to verify driver signatures."
    fi

    if [ $gpg_ok -eq 0 ]; then
        bail_out "Aborting operation."
    fi
}
###############################################################################
function set_some_default_configs() {
    module_sigcheck=0
    sync_pattern=".*"
}

###############################################################################
function verify_configs() {

    parse_repo_address

    verify_config_option "local_dir" "local" "dir"

    verify_ftp_if_needed

    if [ $module_sigcheck -ne 0 ]; then
        verify_gpg
    fi
}

###############################################################################
function prepare_netrc() {
    clear_netrc
    set_netrc
}

###############################################################################
function clear_netrc() {

    if [ -f ~/.netrc ]; then
        sed -i /--==SCINI_REPO_BEGIN==--/,/--==SCINI_REPO_END==--/d ~/.netrc
    fi
}

###############################################################################
function set_netrc() {

cat << EOF >> ~/.netrc
machine --==SCINI_REPO_BEGIN==--
machine ${repo_url}
user ${repo_user}
password ${repo_password}
machine --==SCINI_REPO_END==--
EOF

}

###############################################################################
function make_ftp_retr_batchfile() {

    local file_type=$1

    local file_to_fetch

    if [ "${file_type}" = "module" ]; then
        file_to_fetch=${MODULE_NAME}
    elif [ "${file_type}" = "signature" ]; then
        file_to_fetch=${MODULE_NAME}.sig
    else
        bail_out "${FUNCNAME[0]}: Unexpected file_type parameter!"
    fi

cat << EOF > ${ftp_batchfile}
binary
lcd ${local_dir}/${versions_path}
get ${repo_dir}/${versions_path}/${file_to_fetch}
quit
EOF

}

###############################################################################
function do_retrieve() {
    local versions_path=$1
    local oper_result=0
    local signature_ok=0
    local stuck_job


    log_msg "Retrieving ${versions_path}/${MODULE_NAME}..."

    mkdir -p ${local_dir}/${versions_path} >> ${LOG_FILE}

    case $repo_protocol in
        sftp)
            #Module
            sftp -oUserKnownHostsFile=${repo_public_rsa_key} \
                 -oStrictHostKeyChecking=no \
                 -oIdentityFile=${user_private_rsa_key} \
                 ${repo_user}@${repo_url}:/${repo_dir}/${versions_path}/${MODULE_NAME} \
                 ${local_dir}/${versions_path} >> ${LOG_FILE} 2>&1

            oper_result=$?

            #Signature file (if needed)
            if [ $module_sigcheck -ne 0 ]; then
                sftp -oUserKnownHostsFile=${repo_public_rsa_key} \
                     -oStrictHostKeyChecking=yes \
                     -oIdentityFile=${user_private_rsa_key} \
                     ${repo_user}@${repo_url}:/${repo_dir}/${versions_path}/${MODULE_NAME}.sig \
                     ${local_dir}/${versions_path} >> ${LOG_FILE} 2>&1

                (( oper_result = oper_result + $? ))
            fi
            ;;

        ftp)
            prepare_netrc

            #Module
            make_ftp_retr_batchfile "module"

            debug_msg "$(cat ${ftp_batchfile})"

            # We run ftp in background so that we will not get prompted
            # if something is incorrect in the batchfile. (e.g. user/password)
            ftp ${repo_url} < ${ftp_batchfile} >> ${LOG_FILE} 2>&1 &
            wait

            #check if we got stuck somewhere (password prompt, etc)
            stuck_job=$(jobs | grep ftp | grep Stopped | 
                        sed 's/\[\(.*\)\].*/\1/')

            if [ -n "$stuck_job" ]; then
                oper_result=1
                kill %$stuck_job
            fi

            #Signature file (if needed)
            if [ $module_sigcheck -ne 0 ]; then
                make_ftp_retr_batchfile "signature"
                debug_msg "$(cat ${ftp_batchfile})"

                # We run ftp in background so that we will not get prompted
                # if something is incorrect in the batchfile. (e.g. user/password)
                ftp ${repo_url} < ${ftp_batchfile} >> ${LOG_FILE} 2>&1 &
                wait

                #check if we got stuck somewhere (password prompt, etc)
                stuck_job=$(jobs | grep ftp | grep Stopped | 
                            sed 's/\[\(.*\)\].*/\1/')

                if [ -n "$stuck_job" ]; then
                    oper_result=1
                    kill %$stuck_job
                fi
            fi
            ;;

        file)
            cp ${repo_dir}/${versions_path}/${MODULE_NAME} \
               ${local_dir}/${versions_path}/

            oper_result=$?

            if [ $module_sigcheck -ne 0 ]; then
                cp ${repo_dir}/${versions_path}/${MODULE_NAME}.sig \
                   ${local_dir}/${versions_path}/

                (( oper_result = oper_result + $? ))
            fi
            ;;
        *)
            bail_out \
              "Unknown protocol $repo_protocol"
            ;;
    esac

    # Validate GPG signature here
    if [ $module_sigcheck -ne 0 ]; then
        if [ -f ${local_dir}/${versions_path}/${MODULE_NAME}.sig ]; then
            log_msg "Error: Signature file ${local_dir}/${versions_path}/${MODULE_NAME}.sig not found"
        elif gpg --verify ${local_dir}/${versions_path}/${MODULE_NAME}.sig; then
            log_msg "Module signature verified."
            signature_ok=1
        fi

        if [ $signature_ok -ne 1 ]; then
            oper_result=1
            log_msg "Signature verification failure!!! Deleting suspicious module."
            rm ${local_dir}/${versions_path}/${MODULE_NAME} > /dev/null 2>&1
        fi
    fi

    return $oper_result
}

###############################################################################
function make_ftp_ls_batchfile() {

cat << EOF > $ftp_batchfile
nlist ${repo_dir}/*/*/*/* -
quit
EOF

}

###############################################################################
function make_sftp_ls_batchfile() {

cat << EOF > $ftp_batchfile
ls ${repo_dir}/*/*/*/* -
quit
EOF

}

###############################################################################
function make_listfile() {

    local oper_result=0
    local stuck_job

    case $repo_protocol in
        sftp)
            make_sftp_ls_batchfile

            debug_msg "$(cat ${ftp_batchfile})"

            sftp -b ${ftp_batchfile} \
                 -oUserKnownHostsFile=${repo_public_rsa_key} \
                 -oStrictHostKeyChecking=yes \
                 -oIdentityFile=${user_private_rsa_key} \
                 ${repo_user}@${repo_url} | \
              grep $MODULE_NAME | grep $sync_pattern > $repo_listfile

            oper_result=$?
            ;;
        ftp)
            prepare_netrc
            make_ftp_ls_batchfile

            debug_msg "$(cat ${ftp_batchfile})"

            # We run ftp in background so that we will not get prompted
            # if something is incorrect in the batchfile. (e.g. user/password)
            ftp ${repo_url} < ${ftp_batchfile} | \
              grep $MODULE_NAME | grep $sync_pattern > $repo_listfile &
            wait

            #check if we got stuck somewhere (password prompt, etc)
            stuck_job=$(jobs | grep ftp | grep Stopped | 
                        sed 's/\[\(.*\)\].*/\1/')

            if [ -n "$stuck_job" ]; then
                oper_result=1
                kill %$stuck_job
            fi
            ;;

        file)
            find ${repo_dir} -name ${MODULE_NAME}  | \
              grep $sync_pattern > $repo_listfile

            oper_result=$?
            ;;

        *)
            bail_out \
              "Unknown protocol $repo_protocol"
            ;;
    esac

    return $oper_result
}

###############################################################################
function do_sync() {
    local cur_path
    local cur_reldir
    local oper_result

    make_listfile
    oper_result=$?

    if [ $oper_result -eq 0 ]; then
        while read cur_path; do
            cur_reldir=${cur_path#${repo_dir}}
            cur_reldir=${cur_reldir%/${MODULE_NAME}}

            debug_msg "CUR PATH: $cur_path"
            debug_msg "CUR RELDIR: $cur_reldir"

            do_retrieve ${cur_reldir}

            oper_result=$?

        done < $repo_listfile
    else
        bail_out "Error retrieving modules list from the repository."
    fi

    return $oper_result
}

###############################################################################
# MAIN SCRIPT
###############################################################################
log_msg "${MY_NAME} START - $(date)"

if [ ${#@} -eq 0 ]; then
    print_usage_and_bail
fi

# Process and shift options
while true; do
    if [ $1 = "-c" ]; then
        shift
        CONFIG_FILE=$1
        shift
    elif [ $1 = "-l" ]; then
        shift
        LOG_FILE=$1
        shift
    else
        break
    fi
done

set_some_default_configs
read_config_file $CONFIG_FILE
verify_configs

ftp_batchfile=$(mktemp /tmp/scini_repo_batch.XXXXXX)
repo_listfile=$(mktemp /tmp/scini_repo_list.XXXXXX)

case $1 in
    retrieve)
        [ ${#@} -eq 2 ] || print_usage_and_bail
        do_retrieve $2
        oper_result=$?
        ;;
    sync)
        do_sync
        oper_result=$?
        ;;
    *)
        print_usage_and_bail
        ;;
esac

log_msg "${MY_NAME} END - $(date)"
exit $oper_result




