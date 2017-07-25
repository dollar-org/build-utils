#!/bin/bash -eux
cd $(dirname $0)
dict=${2:-shortwords}

part1Hex=$(echo $1 | cut -c1-4)
part2Hex=$(echo $1 | cut -c5-8)
part3Hex=$(echo $1 | cut -c9-12)

part1Dec=$((16#${part1Hex}))
part2Dec=$((16#${part2Hex}))
part3Dec=$((16#${part3Hex}))

firstLength=$(wc -l < ./$dict/first.txt)
adjsLength=$(wc -l < ./$dict/middle.txt)
lastLength=$(wc -l < ./$dict/last.txt)

echo $(sed -n $((part1Dec % firstLength - 1))p ./$dict/first.txt)-$(sed -n $((part2Dec % adjsLength -1 ))p ./$dict/middle.txt)-$(sed -n $((part3Dec % lastLength - 1 ))p ./$dict/last.txt) | tr -cd '[:print:]'


