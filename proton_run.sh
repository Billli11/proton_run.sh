#!/bin/sh

commandsplitstring="---"

##############
#--Function--#
##############

function print_help()
{
        echo "$1" >&2
        cat >&2 << EOL
Usage:	Add path_to_script/${0##*/} [exe ...|winecfg] $commandsplitstring %command% to Launch option.
The exe use relative path from game common folder or absolute path.
The exe use relative path from game  folder ,absolute path or C:\.
EOL
        exit $2
}

function index_match()
{
        local array=($1)
        local match=$2
        local index=""
        local index=1
        for arg in "${array[@]}"
        do
                if [[ "$arg" = *"$match" ]]
                then
                        echo $index
                        return
                fi
                index=$(($index+1))
        done
}

##############
#----Main----#
##############

argumentlist=("$@")

argumentsplit=$(IFS=$'\n'; index_match "${argumentlist[*]}" "$commandsplitstring")
if [ -z ${argumentsplit:+x} ]
then
        print_help "$commandsplitstring Not Found." "1"
fi


shargument=("${argumentlist[@]:0:$(($argumentsplit-1))}")
commandlist=("${argumentlist[@]:$argumentsplit}")

protonindex=$(IFS=$'\n'; index_match "${commandlist[*]}" "proton")
if [ -z ${protonindex:+x} ]
then
        print_help "Proton Not Found." "1"
fi
protonindex=$(($protonindex+1))

protonrun=("${commandlist[@]:0:$protonindex}")
gameexe=("${commandlist[@]:$protonindex}")

winestart='C:\windows\system32\start.exe'

winecmd=('c:\windows\system32\cmd.exe' '/c')

startexe=()
for arg in "${shargument[@]}"
do
        case $arg in
                winecfg)
                        startexe+=("$winestart" 'C:\windows\system32\winecfg.exe' "&")
                        ;;
                *.exe)
                        if [ "${arg#/}" != "$arg" ] || [ "${arg#C:}" != "$arg" ]
                        then
                                startexe+=("$startexe" "${arg//\//\\}" "&")
                        else
                                startexe+=("$startexe" "${STEAM_COMPAT_INSTALL_PATH//\//\\}\\${arg//\//\\}" "&")
                        fi
                        ;;
        esac
done

cmdrun=("${startexe[@]}" "${gameexe[@]}")
run=("${protonrun[@]}" "${winecmd[@]}" "${cmdrun[@]}")

echo =======================================
echo =======================================
echo =======================================
printf "%s log\n\n---cmdrun---" "${0##*/}"
printf "%s\n" "${cmdrun[@]}"
printf "\n---run---\n\n"
printf "%s\n" "${run[@]}"
echo =======================================
echo =======================================
echo =======================================

#"${protonrun[@]}" 'C:\windows\system32\cmd.exe' '/c' "${cmdrun[@]}"
"${run[@]}"
