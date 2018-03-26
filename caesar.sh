#!/usr/bin/env bash

# chmod +x caesar.sh
# ./caesar.sh

_usage() {
	echo "Usage: ./caesar.sh [OPTIONS]
	-e, --encrypt: 		Encrypt plaintext
	-d, --decrypt: 		Decrypt ciphertext
	-k, --key:     		Key for encryption or decryption
	-b, --bruteforce: 	Brute-force ciphertext without key
	-h, --help:    		Print command-line usage"

	exit 0
}

_error() {
	echo "$@"
	exit 1
}

_isvalid() {
	re='^[[:alnum:][:space:][:punct:]]*$'
	if [[ "${1}" =~ $re ]]; then
		return 0
	fi
	return 1
}

_isnumber() {
	re='^[0-9]+$'
	if [[ ${1} =~ $re ]]; then
		if [[ ${1} -ge 1 || ${1} -le 25 ]]; then
			return 0
		fi
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

	for (( i=0; i<${#messages}; i++ )); do
		c=${messages:$i:1}
		if [[ ! "${c}" =~ ^[[:alpha:]]*$ ]]; then
			printf "${c}"
			continue
		fi

		_ord ${c}
		v=$?

		if [[ ${v} -ge 65 && ${v} -le 90 ]]; then
			v=$(((${v}-65+${key}) % 26 + 65))
			_chr ${v}
		elif [[ ${v} -ge 97 && ${v} -le 122 ]]; then
			v=$(((${v}-97+${key}) % 26 + 97))
			_chr ${v}
		fi
	done
	echo ""
}

_decrypt() {
	messages=${1}
	key=${2}

	for (( i=0; i<${#messages}; i++ )); do
		c=${messages:$i:1}
		if [[ ! "${c}" =~ ^[[:alpha:]]*$ ]]; then
			printf "${c}"
			continue
		fi

		_ord ${c}
		v=$?

		if [[ ${v} -ge 65 && ${v} -le 90 ]]; then
			v=$((${v}-65))
			if [[ ${v} -lt ${key} ]]; then
				bonus=26
			else
				bonus=0
			fi
			v=$(((${v}+${bonus}-${key}) % 26 + 65))
			_chr ${v}
		elif [[ ${v} -ge 97 && ${v} -le 122 ]]; then
			v=$((${v}-97))
			if [[ $v -lt ${key} ]]; then
				bonus=26
			else
				bonus=0
			fi
			v=$(((${v}+${bonus}-${key}) % 26 + 97))
			_chr ${v}
		fi
	done
	echo ""
}

if [[ $# -lt 1 ]]; then
	_usage
fi

if [[ $# -gt 4 ]]; then
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
			_isnumber ${4}
			if [[ $? -eq 1 ]]; then
				_error "Invalid Key. Key must be a number and 1<=k<=25"
			fi

			printf "Plaintext:\t${2}\n"
			printf "Ciphertext:\t"
			_encrypt "${2}" ${4}
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
			_isnumber ${4}
			if [[ $? -eq 1 ]]; then
				_error "Invalid Key. Key must be a number and 1<=k<=25"
			fi
			
			printf "Ciphertext:\t${2}\n"
			printf "Plaintext:\t"
			_decrypt "${2}" ${4}		
		elif [[ "${3}" == "-b" || "${3}" == "--bruteforce" ]]; then
			printf "Ciphertext:\t\t${2}\n"
			for i in `seq 1 25`; do
				printf "Plaintext (key=${i}):\t"
				_decrypt "${2}" ${i}
			done
		fi
		;;
	*)
		_error "Invalid Options Errors!!!"
		;;
esac