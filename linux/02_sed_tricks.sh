# Deleting a line that matches a pattern. The example below scans through a file and removes every line that has "creating" in it, pipes out to new file:

sed '/creating/d' wassample > wassample_cleaner

# Same thing, only edit file in place with -i switch:

sed -i  '/creating/d' wassample

# #Delete all empty lines:

sed -i '/^$/d' /tmp/data.txt

# Delete a range of lines (uses vi)

vi +'8664,8905d' +wq wassample

# Delete a range of lines

sed -i <start>,<end>d <filename>
