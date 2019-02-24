#!/usr/bin/env fish

#####
# Uploads the given audio file to the mvc ftp server for hosting on the website
# The audio file to upload will come from a queue directory
####

echo "upload-version"

function uploadFile
# the local path to the file we're uploading
  set localPath $argv[1]

# The size of the file we're uploading
  set fsize (stat --printf="%s" $localPath)

# pieces of the url we're uploading to
  set remoteHost "ftp.mvcmarietta.net"

# name of the file we're uploading to
  set remotePathName "/"(date +%Y)"/"(basename -s ".mp*" $localPath | sed -e 's/-/./g')".mp*"

# the full url of the file we've uploaded
  set linkURL "https://mvcmarietta.net"$remotePathName

  if set -q dryRun
    set recipients "noah.harvey247@gmail.com"
  else
    set recipients "mike@frumosity.com" "noah.harvey247@gmail.com"
  end

# compress file
#   if test $fsize -gt 25000000
#     set tempPath (string replace ".mp3" ".out.mp3" $localPath)
#     echo "compressing "$localPath" using "$tempPath
#     if not set -q dryRun
#       ffmpeg -i $localPath -b:a 64k $tempPath
#     end
#     mv $tempPath $localPath
#   else
#     echo "skipping compression..."
#   end

# upload file
  echo "Uploading " $localPath " -> " $remotePathName

  if not set -q dryRun
    ncftpput -v -T ".tmp" -u noah@mvcmarietta.net -p ballsignfan -P 21 -C $remoteHost $localPath $remotePathName
    or exit
  end

# send email notifications
  echo "sending emails to: " $recipients

  set subject "MVC Audio Upload Complete - "(date +%F)

  set body "Audio file upload complete at" $remoteHost""$remotePathName "\nLink URI at:" {$linkURL}

  echo -e "Subject:" $subject "\n"$body | sendmail $recipients
  or exit
end

#the queue dir to pull files from
# queue/file -> upload -> mv queue/file published/file
set queueDir "/data/church_audio/new"
set publishDir "/data/church_audio/published"
set files (ls $queueDir)

if test (count $files) -lt 1
  echo "no files to upload"
else
  for file in $files
    set file $queueDir"/"$file
    uploadFile $file
    if not set -q dryRun
      mv $file $publishDir"/"(basename $file)
    end
  end
end
