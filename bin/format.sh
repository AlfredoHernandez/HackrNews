#!/bin/bash

git diff --name-only | grep "\.swift" | while read filename; do
	./bin/swiftformat "$filename";
done
