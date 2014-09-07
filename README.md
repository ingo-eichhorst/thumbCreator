thumbCreator
============

The script takes screenshots of the first movie in subdirectories of the current directory


Version 0.2.1 - change log
============
1. XML creation in the root folder and in the thumb folder for indexing


Version 0.2.0 - change log
============

1. backquote syntax (improvement)
changed syntax from "startDir=`pwd`" to "startDir=$(pwd)"
acceleration is expected

2. mkdir (improvement)
create only a thumb folder if it does not already exists 

3. variable names (improvement)
changed variable shema from camelCase to underscore_case
reason: someone very experienced told me and http://programmers.stackexchange.com/questions/27264/naming-conventions-camelcase-versus-underscore-case-what-are-your-thoughts-ab

4. Changed folder-name (improvement)
changed thumb folder from "thumb" to "thumbs_<<resultion>>" this allows to run the script again if another resolution is needed.

5. output Messages (improvement)
display messages and descriptions in the terminal
do not display output from avconv and ls

6. path (improvement)
changed <<cd $path>> to <<cd "${path}">>
Reason: path could be with spaces




open/ issues
============

ToDo: time handling with date instead of awk
ToDo:
		Config
		ich hab beinahe überall drin:
		ME=$(basename $0)
		ME_DIR=$(dirname $0)
		[11:19:12] Christian Hartmann: und dann später:
		# read config file if exists
		ME_CONF=${ME_DIR}/config/${ME}.conf
		[ -f ${ME_CONF} ] && source ${ME_CONF}
		dann wird bei dir aus:  ### Configuration ###  ... das:   ### Default Configuration ###
		default soll/muss sein
		aber konfigurationen können auch wirklich konfiguriert werden


ToDo
		stil
		auch noch guter stil:
		xsltproc=$(which xsltproc)
		und:
		if [ -z "$xsltproc" ]
		then
		  echo "ERROR: xsltproc not available" >&2
		  exit 9
		fi


