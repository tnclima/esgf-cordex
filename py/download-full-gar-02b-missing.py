# download from liu.se servers requires wget scripts
# -> create scripts automatically (and run them manually later in bash)

# run all wget scripts manually using e.g. the following in a shell

for f in *.sh; do
  bash "$f"
done
