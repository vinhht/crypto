#!/usr/bin/env bash

# chmod +x vigenere.sh
# ./vigenere.sh

_usage() {
	echo "Usage: ./vigenere.sh [OPTIONS]
	-e, --encrypt: 		Encrypt plaintext
	-d, --decrypt: 		Decrypt ciphertext
	-k, --key:    		Key for encryption or decryption
	-h, --help:  		Print command-line usage"

	exit 0
}

_error() {
	echo "$@"
	exit 1
}

_isvalid() {
	re='^[[:alnum:][:space:][:punct:]]*$'
	if [[ "${1}" =~ ${re} ]]; then
		return 0
	fi
	return 1
}

_chr() {
	printf "\\$(printf '%03o' "$1")"
}

_ord() {
	return $(LC_CTYPE=C printf '%d' "'$1")
}

_encrypt() {
	messages=${1}
	key=${2}
	length_key=${#key}
	j=0
	
	for (( i=0; i<${#messages}; i++ )); do
		c=${messages:$i:1}
		if [[ ! "${c}" =~ ^[[:alpha:]]*$ ]]; then
			printf "${c}"
			continue
		fi

		_ord ${c}
		v=$?

		k=$((${j}%${length_key}))
		_ord "${key:${k}:1}"
		
		offset=$?
		if [[ ${offset} -le 90 ]]; then
			offset=$((${offset}-65))
		else
			offset=$((${offset}-97))
		fi

		if [[ ${v} -ge 65 && ${v} -le 90 ]]; then
			v=$(((${v}-65+${offset}) % 26 + 65))
			_chr ${v}
		elif [[ ${v} -ge 97 && ${v} -le 122 ]]; then
			v=$(((${v}-97+${offset}) % 26 + 97))
			_chr ${v}
		fi

		j=$((${j}+1))
	done
	echo ""
}

_decrypt() {
	messages=${1}
	key=${2}
	length_key=${#key}
	j=0

	for (( i=0; i<${#messages}; i++ )); do
		c=${messages:$i:1}
		if [[ ! "${c}" =~ ^[[:alpha:]]*$ ]]; then
			printf "${c}"
			continue
		fi

		_ord ${c}
		v=$?

		k=$((${j}%${length_key}))
		_ord "${key:${k}:1}"
		
		offset=$?
		if [[ ${offset} -le 90 ]]; then
			offset=$((${offset}-65))
		else
			offset=$((${offset}-97))
		fi

		if [[ ${v} -ge 65 && ${v} -le 90 ]]; then
			v=$((${v}-65))
			if [[ ${v} -lt ${offset} ]]; then
				bonus=26
			else
				bonus=0
			fi
			v=$(((${v}+${bonus}-${offset}) % 26 + 65))
			_chr ${v}
		elif [[ ${v} -ge 97 && ${v} -le 122 ]]; then
			v=$((${v}-97))
			if [[ $v -lt ${offset} ]]; then
				bonus=26
			else
				bonus=0
			fi
			v=$(((${v}+${bonus}-${offset}) % 26 + 97))
			_chr ${v}
		fi

		j=$((${j}+1))
	done
	echo ""
}

if [[ $# -lt 1 ]]; then
	_usage
fi

if [[ $# -ne 4 ]]; then
	_error "Invalid Input Errors!!!"
fi

opt1="${1}"

case ${opt1} in
	"--help"|"-h")
		_usage
		;;
	"--encrypt"|"-e")
		_isvalid ${2}
		if [[ $? -eq 1 ]]; then
			_error "Message must be [A-Za-z], space, punct..."
		fi

		if [[ "${3}" == "-k" || "${3}" == "--key" ]]; then
			printf "Plaintext:\t${2}\n"
			printf "Ciphertext:\t"
			_encrypt "${2}" "${4}"
		else
			_error "Invalid Input Errors!!!"
		fi
		;;
	"--decrypt"|"-d")
		_isvalid ${2}
		if [[ $? -eq 1 ]]; then
			_error "Message must be [A-Za-z], space, punct..."
		fi

		if [[ "${3}" == "-k" || "${3}" == "--key" ]]; then
			printf "Ciphertext:\t${2}\n"
			printf "Plaintext:\t"
			_decrypt "${2}" "${4}"
		else
			_error "Invalid Input Errors!!!"
		fi
		;;
	*)
		_error "Invalid Options Errors!!!"
		;;
esac