#!/bin/bash

#set -x
SONG_DATABASE_DIR=$(dirname ${BASH_SOURCE[0]})
SONG_DATABASE_FILE="$SONG_DATABASE_DIR/songs.json.bz2"
SONG_DIR="$SONG_DATABASE_DIR/songs"
SONG_DATABASE=songs

function CheckPrequistes() {
  local -i rc=0
  
  type bzcat 2>&1 > /dev/null
  rc=$(($rc+$?))
  [ $rc -eq 1 ] && echo "bzcat is required"
  type jq 2>&1 > /dev/null
  rc=$(($rc+$?))
  [ $rc -gt 1 ] && echo "jq is required"
  [ $rc -gt 1 ] && exit 2
}

function SplitJSON() {
  local dest_dir=$1
  mkdir -p "$dest_dir" 2>&1 > /dev/null
  if [ $? -eq 0 ]
  then
    while read line; do export count=$((count+1)) ; echo $line > $(echo "$dest_dir/$(printf "songs-%05d" $count)").json ; done
  fi
}

function ReadJSON() {
  local json_file=$1
  bzcat "$json_file" | jq -c -M '.[]' 
}

function CreateDatabase() {
  local database=$1
  http PUT "http://localhost:5984/$database"
}

function PostJSON() {
  typeset database=$1
  typeset dir=$2
  for file in $(ls -1 "$dir")
  do
    http POST "http://localhost:5984/$database"  mimeType='application/json' content=@"$dir/$file"
  done
}

CleanUp() {
  typeset dest_dir=$1
  /bin/rm -rf "$dest_dir"
}

Main() {

  CheckPrequistes

  ReadJSON "$SONG_DATABASE_FILE" | SplitJSON "$SONG_DIR"

  CreateDatabase "$SONG_DATABASE"

  PostJSON "$SONG_DATABASE" "$SONG_DIR"

  CleanUp "$SONG_DIR"
}

Main $*

