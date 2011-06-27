#!/bin/bash

PATH="/opt/local/bin:${PATH}"

S3CMD="`which s3cmd`"

if [ -z "$S3CMD" ]; then
	echo "s3cmd command not found."
	exit 1
fi

BUCKET="s3://<bucketname>"
BUCKETFOLDER=""

# Test is seperate DB backups are required
if [ "${SEPDIR}" = "yes" ]; then
	# Monthly Full Backup of all Databases
	if [ ${DOM} = "01" ]; then
		for MDB in ${MDBNAMES}
		do
			FILE="monthly/${MDB}/${MDB}_${DATE}.${M}.${MDB}.sql${SUFFIX}"
			${S3CMD} put "${BACKUPDIR}/${FILE}" "${BUCKET}${BUCKETFOLDER}/${FILE}"
		done
	fi

	for DB in ${DBNAMES}
	do
		# Prepare ${DB} for using
		DB="`${ECHO} ${DB} | ${SED} 's/%/ /g'`"

		# Weekly Backup
		if [ ${DNOW} = ${DOWEEKLY} ]; then
			FILE="weekly/${DB}/${DB}_week.${W}.${DATE}.sql${SUFFIX}"
			${S3CMD} put "${BACKUPDIR}/${FILE}" "${BUCKET}${BUCKETFOLDER}/${FILE}"
		# Daily Backup
		else
			FILE="daily/${DB}/${DB}_${DATE}.${DOW}.sql${SUFFIX}"
			echo "Uploading daily ${FILE}"
			${S3CMD} put "${BACKUPDIR}/${FILE}" "${BUCKET}${BUCKETFOLDER}/${FILE}"
		fi
	done
else # One backup file for all DBs
	# Monthly Full Backup of all Databases
	if [ ${DOM} = "01" ]; then
		FILE="monthly/${DATE}.${M}.all-databases.sql${SUFFIX}"
		${S3CMD} put "${BACKUPDIR}/${FILE}" "${BUCKET}${BUCKETFOLDER}/${FILE}"
	fi

	# Weekly Backup
	if [ ${DNOW} = ${DOWEEKLY} ]; then
		FILE="weekly/week.${W}.${DATE}.sql${SUFFIX}"
		${S3CMD} put "${BACKUPDIR}/${FILE}" "${BUCKET}${BUCKETFOLDER}/${FILE}"
		
	# Daily Backup
	else
		FILE="daily/${DATE}.${DOW}.sql${SUFFIX}"
		${S3CMD} put "${BACKUPDIR}/${FILE}" "${BUCKET}${BUCKETFOLDER}/${FILE}"
	fi
fi

exit 0
