#!/usr/bin/env bash
dir=$(dirname "$0") # directory of this script
for i in $(seq 1 20); do
  cmd="$dir/run.sh"
  echo $cmd && eval $cmd
  cmd="mv $dir/scenarios/scs-2020-aireys-inlet/plans.xml $dir/plans-$i.xml"
  echo $cmd && eval $cmd
  cmd="gzip -9 $dir/plans-$i.xml"
  echo $cmd && eval $cmd
done
