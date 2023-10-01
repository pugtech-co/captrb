#!/bin/bash

# Loop 10 times
for i in {1..10}
do
  # Echo a different note into the Ruby script
  echo "This is note $i" | ./bin/captrb
done

