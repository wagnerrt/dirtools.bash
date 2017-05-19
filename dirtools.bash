#!/bin/bash

declare -a __dirlist

function _dload
{
	dbfile=~/.dirtools.db
	if [ -f "${dbfile}" ]
	then
		if [ ! -r "${dbfile}" ]
		then
			echo "o arquivo \"${dbfile}\" nao pode ser lido."
		else
			__dirlist=()
			exec 4< "${dbfile}"
			ifs="${IFS}"
			IFS="
"
			let "n=0"
			while read linha <&4
			do
				__dirlist[ ${n} ]="${linha}"
				let "++n"
			done
			exec 4<&-
			IFS="$ifs"
		fi
	fi
}

function _dsave
{
	dbfile=~/.dirtools.db
	tempfile=${dbfile}.tmp
	rm -f "${tempfile}" 2>&1 > /dev/null
	for ((n = 0, q = ${#__dirlist[@]}; n < q; ++n ))
	do
		echo "${__dirlist[ ${n} ]}" >> "${tempfile}"
	done
	rm -f "${dbfile}" 2>&1 > /dev/null
	if [ -f "${tempfile}" ]
	then
		mv "${tempfile}" "${dbfile}"
	fi
}

function _dadd
{
	cnt=0
	while [ "${#}" -ge "1" ]
	do
		__dirlist=("${__dirlist[@]}" "${1}")
		llen=${#__dirlist[@]}
		let "llast = llen - 1"
		echo "${llast}: \"${1}\""

		if [ ! -e "${1}" ]
		then
			echo "advertencia: ${1} nao existe."
		else
			if [ ! -d "${1}" ]
			then
				echo "advertencia: ${1} nao e' diretorio"
			else
				if [ ! -x "${1}" ]
				then
					echo "advertencia: ${1} nao possui permissao de execucao"
				fi
			fi
		fi

		shift
		let "++cnt"
	done
	if [ "${cnt}" -gt 0 ]
	then
		_dsave
	fi
}

function dsort
{
	dbfile=~/.dirtools.db
	tmpfile=/tmp/dirtool.db.${$}

	sort < ${dbfile} > ${tmpfile}
	rm -f "${dbfile}"
	mv "${tmpfile}" "${dbfile}"
	_dload
}

function dvi
{
	vi ~/.dirtools.db
	_dload
}

function dadd
{
	if [ "${#}" -ge "1" ]
	then
		_dadd "${@}"
	else
		_dadd "`pwd`"
	fi
}

function dls
{
	for ((n = 0, q = ${#__dirlist[@]}; n < q; ++n ))
	do
		echo "${n}: \"${__dirlist[ ${n} ]}\""
	done
}

function _dchoose
{
	maxop=${#__dirlist[@]}
	op=$maxop
	while [ "${op}" -lt 0 -o "${op}" -ge "${maxop}" ]
	do
		dls
		echo -n "?> "
		read op
		if [ -z "${op}" ]
		then
			return "${maxop}"
		fi
	done
	return "${op}"
}

function _dgo
{
	if [ "${#}" -eq "1" ]
	then
		if [ "${1}" -ge "0" -a "${1}" -lt "${#__dirlist[@]}" ]
		then
#			if [ -d "${__dirlist[ ${1} ]}" -a -x "${__dirlist[ ${1} ]}" ]
#			then
				cd "${__dirlist[ ${1} ]}"
#			fi
		fi
	fi
	pwd
}

function dgo
{
	if [ "${#}" -eq "1" ]
	then
		_dgo "${1}"
	else
		_dchoose
		_dgo "$?"
	fi
}

function _ddel
{
	local unset_used

	tmpfile=/tmp/dirtools.del.${$}
	rm -f "${tmpfile}" 2>&1 > /dev/null
	while [ "${#}" -ge "1" ]
	do
		if [ "${1}" -ge "0" -a "${1}" -lt "${#__dirlist[@]}" ]
		then
			echo "${1}" >> "$tmpfile"
		fi
		shift
	done

	if [ ! -f "${tmpfile}" ]
	then
        return
	fi

	sort -nr < "${tmpfile}" > "${tmpfile}.rsort"

	exec 5< "${tmpfile}.rsort"

	unset_used=0
	while read item <&5
	do
		if [ "${item}" -ge "0" -a "${item}" -lt "${#__dirlist[@]}" ]
		then
			unset __dirlist[${item}]
			unset_used=1
		fi
		shift
	done
	exec 5<&-

	rm -f "${tmpfile}" "${tmpfile}.rsort"

	if [ "${unset_used}" -ne "0" ]
	then
		__dirlist=("${__dirlist[@]}")
		_dsave
	fi
}

function ddel
{
	if [ "${#}" -ge "1" ]
	then
		_ddel "${@}"
	else
		_dchoose
		_ddel "$?"
	fi
}

function drm
{
    ddel "${@}"
}

function dgrep
{
	dls | grep "${@}"
}

function dhelp
{
    echo "
dirtools.bash - ferramentas de auxilio 'a navegacao de diretorios

dsort        ordena a lista de preferidos
dvi          vi a lista de preferidos com o Editor 'vi'
dadd [args]  adiciona "{args}" ou o corrente 'a lista de preferidos
dls          imprime a lista indexada de preferidos
dgo [idx]    posiciona no preferido indexado ou o escolhido via menu
drm [idx]    apaga o preferido indexado ou o escolhido via menu
ddel [idx]   alias para drm
dgrep {ereg} procura nos preferidos com egrep
dhelp        mostra essa ajuda"
}

_dload

