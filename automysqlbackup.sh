#!/bin/bash
#
# MySQL Backup Script
# VER. 2.5.1 - http://sourceforge.net/projects/automysqlbackup/
# Copyright (c) 2002-2003 wipe_out@lycos.co.uk
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#=====================================================================
#=====================================================================
# Set the following variables to your system needs
# (Detailed instructions below variables)
#=====================================================================
#set -x

while getopts "c:" optname
do
	case "$optname" in
		"c")
			CONFIGFILE="$OPTARG"
			;;
	esac
done

if [ -z "$CONFIGFILE" ]; then
	CONFIGFILE="/etc/automysqlbackup/automysqlbackup.conf"
fi

if [ -r ${CONFIGFILE} ]; then
	# Read the configfile if it's existing and readable
	source ${CONFIGFILE}
else
	echo "No config file found, please pass one to the command."
	exit
fi

#=====================================================================
# Backup Rotation..
#=====================================================================
#
# Daily Backups are rotated weekly..
# Weekly Backups are run by default on Saturday Morning when
# cron.daily scripts are run...Can be changed with DOWEEKLY setting..
# Weekly Backups are rotated on a 5 week cycle..
# Monthly Backups are run on the 1st of the month..
# Monthly Backups are rotated on a 5 month cycle...
# It may be a good idea to copy Monthly backups offline or to another
# server..
#
#=====================================================================
# Please Note!!
#=====================================================================
#
# I take no resposibility for any data loss or corruption when using
# this script..
# This script will not help in the event of a hard drive crash. If a 
# copy of the backup has not be stored offline or on another PC..
# You should copy your backups offline regularly for best protection.
#
# Happy backing up...
#
#=====================================================================
# Restoring
#=====================================================================
# Firstly you will need to uncompress the backup file.
# eg.
# gunzip file.gz (or bunzip2 file.bz2)
#
# Next you will need to use the mysql client to restore the DB from the
# sql file.
# eg.
# mysql --user=username --pass=password --host=dbserver database < /path/file.sql
# or
# mysql --user=username --pass=password --host=dbserver -e "source /path/file.sql" database
#
# NOTE: Make sure you use "<" and not ">" in the above command because
# you are piping the file.sql to mysql and not the other way around.
#
# Lets hope you never have to use this.. :)
#
#=====================================================================
# Change Log
#=====================================================================
#
# VER 2.5.1-01 - (2010-07-06)
#     - Fixed pathname bug item #3025849 (by Johannes Kolter)
# VER 2.5.1 - (2010-07-04)
#     - Added support for default and optional config file (by Johannes Kolter)
#     - Rotating after backup was successful whith find(1) (by Johannes Kolter)
#     - Implementation of Variables containing full path to binaries to
#       avoid possibly confusion with aliases or builtins. (by Johannes Kolter)
#     - Fixed bug where weekly backups were not being rotated.
#       Added rotation of 5 monthly backups
#       Now all old backups are deleted, not only the most recent one
#       (inspired by oleg@bintime.com)
#     - Use Debian special-file to access database (by Johannes Kolter)
#     - Fixed bug ID: 1438565
#       Moved IO redirection to a place before decicions are made and actions are taken.
#       (inspired by Derk Bernhardt)
#     - Fixed bug ID: #3000316 (reported by Sascha Feldhorst)
#     - Fixed bug ID: #1529458 (reported by Natalie ( njwood ))
#     - Fixed bug ID: #1548919 (reported by Piotr Kuczynski)
# VER 2.5 - (2006-01-15)
#		Added support for setting MAXIMUM_PACKET_SIZE and SOCKET parameters (suggested by Yvo van Doorn)
# VER 2.4 - (2006-01-23)
#    Fixed bug where weekly backups were not being rotated. (Fix by wolf02)
#    Added hour an min to backup filename for the case where backups are taken multiple
#    times in a day. NOTE This is not complete support for mutiple executions of the script
#    in a single day.
#    Added MAILCONTENT="quiet" option, see docs for details. (requested by snowsam)
#    Updated path statment for compatibility with OSX.
#    Added "LATEST" to additionally store the last backup to a standard location. (request by Grant29)
# VER 2.3 - (2005-11-07)
#    Better error handling and notification of errors (a long time coming)
#    Compression on Backup server to MySQL server communications. 
# VER 2.2 - (2004-12-05)
#    Changed from using depricated "-N" to "--skip-column-names".
#    Added ability to have compressed backup's emailed out. (code from Thomas Heiserowski)
#    Added maximum attachment size setting.
# VER 2.1 - (2004-11-04)
#    Fixed a bug in daily rotation when not using gzip compression. (Fix by Rob Rosenfeld)
# VER 2.0 - (2004-07-28)
#    Switched to using IO redirection instead of pipeing the output to the logfile.
#    Added choice of compression of backups being gzip of bzip2.
#    Switched to using functions to facilitate more functionality.
#    Added option of either gzip or bzip2 compression. 
# VER 1.10 - (2004-07-17)
#    Another fix for spaces in the paths (fix by Thomas von Eyben)
#    Fixed bug when using PREBACKUP and POSTBACKUP commands containing many arguments.
# VER 1.9 - (2004-05-25)
#    Small bug fix to handle spaces in LOGFILE path which contains spaces (reported by Thomas von Eyben)
#    Updated docs to mention that Log email can be sent to multiple email addresses.
# VER 1.8 - (2004-05-01)
#    Added option to make backups restorable to alternate database names
#    meaning that a copy of the database can be created (Based on patch by Rene Hoffmann)
#    Seperated options into standard and advanced.
#    Removed " from single file dump DBMANES because it caused an error but
#    this means that if DB's have spaces in the name they will not dump when SEPDIR=no.
#    Added -p option to mkdir commands to create multiple subdirs without error.
#    Added disk usage and location to the bottom of the backup report.
# VER 1.7 - (2004-04-22)
#    Fixed an issue where weelky backups would only work correctly if server
#    locale was set to English (issue reported by Tom Ingberg)
#    used "eval" for "rm" commands to try and resolve rotation issues.
#    Changed name of status log so multiple scripts can be run at the same time.
# VER 1.6 - (2004-03-14)
#   Added PREBACKUP and POSTBACKUP command functions. (patch by markpustjens)
#   Added support for backing up DB's with Spaces in the name.
#   (patch by markpustjens)
# VER 1.5 - (2004-02-24)
#   Added the ability to exclude DB's when the "all" option is used.
#   (Patch by kampftitan)
# VER 1.4 - (2004-02-02)
#   Project moved to Sourceforge.net
# VER 1.3 - (2003-09-25)
#   Added support for backing up "all" databases on the server without
#    having to list each one seperately in the configuration.
#   Added DB restore instructions.
# VER 1.2 - (2003-03-16)
#   Added server name to the backup log so logs from multiple servers
#   can be easily identified.
# VER 1.1 - (2003-03-13)
#   Small Bug fix in monthly report. (Thanks Stoyanski)
#   Added option to email log to any email address. (Inspired by Stoyanski)
#   Changed Standard file name to .sh extention.
#   Option are set using yes and no rather than 1 or 0.
# VER 1.0 - (2003-01-30)
#   Added the ability to have all databases backup to a single dump
#   file or seperate directory and file for each database.
#   Output is better for log keeping.
# VER 0.6 - (2003-01-22)
#   Bug fix for daily directory (Added in VER 0.5) rotation.
# VER 0.5 - (2003-01-20)
#   Added "daily" directory for daily backups for neatness (suggestion by Jason)
#   Added DBHOST option to allow backing up a remote server (Suggestion by Jason)
#   Added "--quote-names" option to mysqldump command.
#   Bug fix for handling the last and first of the year week rotation.
# VER 0.4 - (2002-11-06)
#   Added the abaility for the script to create its own directory structure.
# VER 0.3 - (2002-10-01)
#   Changed Naming of Weekly backups so they will show in order.
# VER 0.2 - (2002-09-27)
#   Corrected weekly rotation logic to handle weeks 0 - 10 
# VER 0.1 - (2002-09-21)
#   Initial Release
#
#=====================================================================
#=====================================================================
#=====================================================================
#
# Should not need to be modified from here down!!
#
#=====================================================================
#=====================================================================
#=====================================================================
#
# Full pathname to binaries to avoid problems with aliases and builtins etc.
#
WHICH="`which which`"
AWK="`${WHICH} gawk`"
LOGGER="`${WHICH} logger`"
ECHO="`${WHICH} echo`"
CAT="`${WHICH} cat`"
BASENAME="`${WHICH} basename`"
DATEC="`${WHICH} date`"
DU="`${WHICH} du`"
EXPR="`${WHICH} expr`"
FIND="`${WHICH} find`"
RM="`${WHICH} rm`"
MYSQL="`${WHICH} mysql`"
MYSQLDUMP="`${WHICH} mysqldump`"
GZIP="`${WHICH} gzip`"
BZIP2="`${WHICH} bzip2`"
CP="`${WHICH} cp`"
HOSTNAMEC="`${WHICH} hostname`"
SED="`${WHICH} sed`"
GREP="`${WHICH} grep`"

function get_debian_pw() {
	if [ -r /etc/mysql/debian.cnf ]; then
		eval $(${AWK} '
			! user && /^[[:space:]]*user[[:space:]]*=[[:space:]]*/ {
				print "USERNAME=" gensub(/.+[[:space:]]+([^[:space:]]+)[[:space:]]*$/, "\\1", "1"); user++
			}
			! pass && /^[[:space:]]*password[[:space:]]*=[[:space:]]*/ {
				print "PASSWORD=" gensub(/.+[[:space:]]+([^[:space:]]+)[[:space:]]*$/, "\\1", "1"); pass++
			}' /etc/mysql/debian.cnf
		)
	else
		${LOGGER} "${PROGNAME}: File \"/etc/mysql/debian.cnf\" not found."
		exit 1
	fi
}

[ "x${USERNAME}" = "xdebian" -a "x${PASSWORD}" = "x" ] && get_debian_pw 

export LC_ALL=C
PROGNAME=`${BASENAME} $0`
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/mysql/bin 
DATE=`${DATEC} +%Y-%m-%d_%Hh%Mm`				# Datestamp e.g 2002-09-21
DOW=`${DATEC} +%A`							# Day of the week e.g. Monday
DNOW=`${DATEC} +%u`						# Day number of the week 1 to 7 where 1 represents Monday
DOM=`${DATEC} +%d`							# Date of the Month e.g. 27
M=`${DATEC} +%B`							# Month e.g January
W=`${DATEC} +%V`							# Week Number e.g 37
VER=2.5.1									# Version Number
LOGFILE=${BACKUPDIR}/${DBHOST}-`${DATEC} +%N`.log		# Logfile Name
LOGERR=${BACKUPDIR}/ERRORS_${DBHOST}-`${DATEC} +%N`.log		# Logfile Name
BACKUPFILES=""
OPT="--quote-names --opt"			# OPT string for use with mysqldump ( see man mysqldump )

# Create required directories
if [ ! -e "${BACKUPDIR}" ]		# Check Backup Directory exists.
	then
	mkdir -p "${BACKUPDIR}"
fi

if [ ! -e "${BACKUPDIR}/daily" ]		# Check Daily Directory exists.
	then
	mkdir -p "${BACKUPDIR}/daily"
fi

if [ ! -e "${BACKUPDIR}/weekly" ]		# Check Weekly Directory exists.
	then
	mkdir -p "${BACKUPDIR}/weekly"
fi

if [ ! -e "${BACKUPDIR}/monthly" ]	# Check Monthly Directory exists.
	then
	mkdir -p "${BACKUPDIR}/monthly"
fi

if [ "${LATEST}" = "yes" ]
then
	if [ ! -e "${BACKUPDIR}/latest" ]	# Check Latest Directory exists.
	then
		mkdir -p "${BACKUPDIR}/latest"
	fi
eval ${RM} -fv "${BACKUPDIR}/latest/*"
fi



# IO redirection for logging.
touch ${LOGFILE}
exec 6>&1           # Link file descriptor #6 with stdout.
                    # Saves stdout.
exec > ${LOGFILE}     # stdout replaced with file ${LOGFILE}.
touch ${LOGERR}
exec 7>&2           # Link file descriptor #7 with stderr.
                    # Saves stderr.
exec 2> ${LOGERR}     # stderr replaced with file ${LOGERR}.


# Add --compress mysqldump option to ${OPT}
if [ "${COMMCOMP}" = "yes" ];
	then
		OPT="${OPT} --compress"
	fi

# Add --max_allowed_packet=... mysqldump option to ${OPT}
if [ "${MAX_ALLOWED_PACKET}" ];
	then
		OPT="${OPT} --max_allowed_packet=${MAX_ALLOWED_PACKET}"
	fi

# Functions

# Database dump function
dbdump () {
${MYSQLDUMP} --user=${USERNAME} --password=${PASSWORD} --host=${DBHOST} ${OPT} ${1} > ${2}
return $?
}

# Compression function plus latest copy
SUFFIX=""
compression () {
if [ "${COMP}" = "gzip" ]; then
	${GZIP} -f "${1}"
	${ECHO}
	${ECHO} Backup Information for "${1}"
	${GZIP} -l "${1}.gz"
	SUFFIX=".gz"
elif [ "${COMP}" = "bzip2" ]; then
	${ECHO} Compression information for "${1}.bz2"
	${BZIP2} -f -v ${1} 2>&1
	SUFFIX=".bz2"
else
	${ECHO} "No compression option set, check advanced settings"
fi
if [ "${LATEST}" = "yes" ]; then
	${CP} ${1}${SUFFIX} "${BACKUPDIR}/latest/"
fi	
return 0
}


# Run command before we begin
if [ "${PREBACKUP}" ]
	then
	${ECHO} ======================================================================
	${ECHO} "Prebackup command output."
	${ECHO}
	eval ${PREBACKUP}
	${ECHO}
	${ECHO} ======================================================================
	${ECHO}
fi


if [ "${SEPDIR}" = "yes" ]; then # Check if CREATE DATABSE should be included in Dump
	if [ "${CREATE_DATABASE}" = "no" ]; then
		OPT="${OPT} --no-create-db"
	else
		OPT="${OPT} --databases"
	fi
else
	OPT="${OPT} --databases"
fi

# Hostname for LOG information
if [ "${DBHOST}" = "localhost" ]; then
	HOST=`${HOSTNAMEC}`
	if [ "${SOCKET}" ]; then
		OPT="${OPT} --socket=${SOCKET}"
	fi
else
	HOST=${DBHOST}
fi

# If backing up all DBs on the server
if [ "${DBNAMES}" = "all" ]; then
        DBNAMES="`${MYSQL} --user=${USERNAME} --password=${PASSWORD} --host=${DBHOST} --batch --skip-column-names -e "show databases"| ${SED} 's/ /%/g'`"

	# If DBs are excluded
	for exclude in ${DBEXCLUDE}
	do
		DBNAMES=`${ECHO} ${DBNAMES} | ${SED} "s/\b${exclude}\b//g"`
	done

        MDBNAMES=${DBNAMES}
fi
	
${ECHO} ======================================================================
${ECHO} AutoMySQLBackup VER ${VER}
${ECHO} http://sourceforge.net/projects/automysqlbackup/
${ECHO} 
${ECHO} Backup of Database Server - ${HOST}
${ECHO} ======================================================================

# Test is seperate DB backups are required
${ECHO} Backup Start Time `${DATEC}`
${ECHO} ======================================================================
if [ "${SEPDIR}" = "yes" ]; then
	# Monthly Full Backup of all Databases
	if [ ${DOM} = "01" ]; then
		for MDB in ${MDBNAMES}
		do
 
			 # Prepare ${DB} for using
		        MDB="`${ECHO} ${MDB} | ${SED} 's/%/ /g'`"

			if [ ! -e "${BACKUPDIR}/monthly/${MDB}" ]		# Check Monthly DB Directory exists.
			then
				mkdir -p "${BACKUPDIR}/monthly/${MDB}"
			fi
			${ECHO} Monthly Backup of ${MDB}...
				dbdump "${MDB}" "${BACKUPDIR}/monthly/${MDB}/${MDB}_${DATE}.${M}.${MDB}.sql"
				[ $? -eq 0 ] && {
					${ECHO} "Rotating 5 month backups for ${MDB}"
					${FIND} "${BACKUPDIR}/monthly/${MDB}" -mtime +150 -type f -exec ${RM} -v {} \; 
				}
				compression "${BACKUPDIR}/monthly/${MDB}/${MDB}_${DATE}.${M}.${MDB}.sql"
				BACKUPFILES="${BACKUPFILES} ${BACKUPDIR}/monthly/${MDB}/${MDB}_${DATE}.${M}.${MDB}.sql${SUFFIX}"
			${ECHO} ----------------------------------------------------------------------
		done
	fi

	for DB in ${DBNAMES}
	do
	# Prepare ${DB} for using
	DB="`${ECHO} ${DB} | ${SED} 's/%/ /g'`"
	
	# Create Seperate directory for each DB
	if [ ! -e "${BACKUPDIR}/daily/${DB}" ]		# Check Daily DB Directory exists.
		then
		mkdir -p "${BACKUPDIR}/daily/${DB}"
	fi
	
	if [ ! -e "${BACKUPDIR}/weekly/${DB}" ]		# Check Weekly DB Directory exists.
		then
		mkdir -p "${BACKUPDIR}/weekly/${DB}"
	fi
	
	# Weekly Backup
	if [ ${DNOW} = ${DOWEEKLY} ]; then
		${ECHO} Weekly Backup of Database \( ${DB} \)
		${ECHO}
			dbdump "${DB}" "${BACKUPDIR}/weekly/${DB}/${DB}_week.${W}.${DATE}.sql"
			[ $? -eq 0 ] && {
				${ECHO} Rotating 5 weeks Backups...
				${FIND} "${BACKUPDIR}/weekly/${DB}" -mtime +35 -type f -exec ${RM} -v {} \; 
			}
			compression "${BACKUPDIR}/weekly/${DB}/${DB}_week.${W}.${DATE}.sql"
			BACKUPFILES="${BACKUPFILES} ${BACKUPDIR}/weekly/${DB}/${DB}_week.${W}.${DATE}.sql${SUFFIX}"
		${ECHO} ----------------------------------------------------------------------
	
	# Daily Backup
	else
		${ECHO} Daily Backup of Database \( ${DB} \)
		${ECHO}
			dbdump "${DB}" "${BACKUPDIR}/daily/${DB}/${DB}_${DATE}.${DOW}.sql"
			[ $? -eq 0 ] && {
				${ECHO} Rotating last weeks Backup...
				${FIND} "${BACKUPDIR}/daily/${DB}" -mtime +6 -type f -exec ${RM} -v {} \; 
			}
			compression "${BACKUPDIR}/daily/${DB}/${DB}_${DATE}.${DOW}.sql"
			BACKUPFILES="${BACKUPFILES} ${BACKUPDIR}/daily/${DB}/${DB}_${DATE}.${DOW}.sql${SUFFIX}"
		${ECHO} ----------------------------------------------------------------------
	fi
	done


else # One backup file for all DBs
	# Monthly Full Backup of all Databases
	if [ ${DOM} = "01" ]; then
		${ECHO} Monthly full Backup of \( ${MDBNAMES} \)...
			dbdump "${MDBNAMES}" "${BACKUPDIR}/monthly/${DATE}.${M}.all-databases.sql"
			[ $? -eq 0 ] && {
				${ECHO} "Rotating 5 month backups."
				${FIND} "${BACKUPDIR}/monthly" -mtime +150 -type f -exec ${RM} -v {} \; 
			}
			compression "${BACKUPDIR}/monthly/${DATE}.${M}.all-databases.sql"
			BACKUPFILES="${BACKUPFILES} ${BACKUPDIR}/monthly/${DATE}.${M}.all-databases.sql${SUFFIX}"
		${ECHO} ----------------------------------------------------------------------
	fi

	# Weekly Backup
	if [ ${DNOW} = ${DOWEEKLY} ]; then
		${ECHO} Weekly Backup of Databases \( ${DBNAMES} \)
		${ECHO}
		${ECHO}
			dbdump "${DBNAMES}" "${BACKUPDIR}/weekly/week.${W}.${DATE}.sql"
			[ $? -eq 0 ] && {
				${ECHO} Rotating 5 weeks Backups...
				${FIND} "${BACKUPDIR}/weekly/" -mtime +35 -type f -exec ${RM} -v {} \; 
			}
			compression "${BACKUPDIR}/weekly/week.${W}.${DATE}.sql"
			BACKUPFILES="${BACKUPFILES} ${BACKUPDIR}/weekly/week.${W}.${DATE}.sql${SUFFIX}"
		${ECHO} ----------------------------------------------------------------------
		
	# Daily Backup
	else
		${ECHO} Daily Backup of Databases \( ${DBNAMES} \)
		${ECHO}
		${ECHO}
			dbdump "${DBNAMES}" "${BACKUPDIR}/daily/${DATE}.${DOW}.sql"
			[ $? -eq 0 ] && {
				${ECHO} Rotating last weeks Backup...
				${FIND} "${BACKUPDIR}/daily" -mtime +6 -type f -exec ${RM} -v {} \; 
			}
			compression "${BACKUPDIR}/daily/${DATE}.${DOW}.sql"
			BACKUPFILES="${BACKUPFILES} ${BACKUPDIR}/daily/${DATE}.${DOW}.sql${SUFFIX}"
		${ECHO} ----------------------------------------------------------------------
	fi
fi

${ECHO} Backup End `${DATEC}`
${ECHO} ======================================================================
${ECHO} Total disk space used for backup storage..
${ECHO} Size - Location
${ECHO} `${DU} -hs "${BACKUPDIR}"`
${ECHO}
${ECHO} ======================================================================
${ECHO} If you find AutoMySQLBackup valuable please make a donation at
${ECHO} http://sourceforge.net/project/project_donations.php?group_id=101066
${ECHO} ======================================================================

# Run command when we're done
if [ "${POSTBACKUP}" ]
	then
	${ECHO} ======================================================================
	${ECHO} "Postbackup command output."
	${ECHO}
	eval ${POSTBACKUP}
	${ECHO}
	${ECHO} ======================================================================
fi

#Clean up IO redirection
exec 1>&6 6>&-      # Restore stdout and close file descriptor #6.
exec 2>&7 7>&-      # Restore stdout and close file descriptor #7.

if [ "${MAILCONTENT}" = "files" ]
then
	if [ -s "${LOGERR}" ]
	then
		# Include error log if is larger than zero.
		BACKUPFILES="${BACKUPFILES} ${LOGERR}"
		ERRORNOTE="WARNING: Error Reported - "
	fi
	#Get backup size
	ATTSIZE=`${DU} -c ${BACKUPFILES} | ${GREP} "[[:digit:][:space:]]total$" |${SED} s/\s*total//`
	if [ ${MAXATTSIZE} -ge ${ATTSIZE} ]
	then
		BACKUPFILES=`${ECHO} "${BACKUPFILES}" | ${SED} -e "s# # -a #g"`	#enable multiple attachments
		mutt -s "${ERRORNOTE} MySQL Backup Log and SQL Files for ${HOST} - ${DATE}" ${BACKUPFILES} ${MAILADDR} < ${LOGFILE}		#send via mutt
	else
		${CAT} "${LOGFILE}" | mail -s "WARNING! - MySQL Backup exceeds set maximum attachment size on ${HOST} - ${DATE}" ${MAILADDR}
	fi
elif [ "${MAILCONTENT}" = "log" ]
then
	${CAT} "${LOGFILE}" | mail -s "MySQL Backup Log for ${HOST} - ${DATE}" ${MAILADDR}
	if [ -s "${LOGERR}" ]
		then
			${CAT} "${LOGERR}" | mail -s "ERRORS REPORTED: MySQL Backup error Log for ${HOST} - ${DATE}" ${MAILADDR}
	fi	
elif [ "${MAILCONTENT}" = "quiet" ]
then
	if [ -s "${LOGERR}" ]
		then
			${CAT} "${LOGERR}" | mail -s "ERRORS REPORTED: MySQL Backup error Log for ${HOST} - ${DATE}" ${MAILADDR}
			${CAT} "${LOGFILE}" | mail -s "MySQL Backup Log for ${HOST} - ${DATE}" ${MAILADDR}
	fi
else
	if [ -s "${LOGERR}" ]
		then
			${CAT} "${LOGFILE}"
			${ECHO}
			${ECHO} "###### WARNING ######"
			${ECHO} "Errors reported during AutoMySQLBackup execution.. Backup failed"
			${ECHO} "Error log below.."
			${CAT} "${LOGERR}"
	else
		${CAT} "${LOGFILE}"
	fi	
fi

if [ -s "${LOGERR}" ]
	then
		STATUS=1
	else
		STATUS=0
fi

# Clean up Logfile
eval ${RM} -f "${LOGFILE}"
eval ${RM} -f "${LOGERR}"

exit ${STATUS}
