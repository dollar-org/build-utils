#!/bin/bash -eu
cd $(dirname $0)

part1Hex=$(echo $1 | cut -c1-4)
part2Hex=$(echo $1 | cut -c5-8)
part3Hex=$(echo $1 | cut -c9-12)

part1Dec=$((16#${part1Hex}))
part2Dec=$((16#${part2Hex}))
part3Dec=$((16#${part3Hex}))

adverbsLength=$(wc -l < ./adverbs.txt)
adjsLength=$(wc -l < ./adjectives.txt)
nounsLength=$(wc -l < ./nouns.txt)

echo $(sed -n $((part1Dec % adverbsLength))p ./adverbs.txt)-$(sed -n $((part2Dec % adjsLength))p ./adjectives.txt)-$(sed -n $((part3Dec % nounsLength))p ./nouns.txt)


