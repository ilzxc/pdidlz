coffee -c -b -o build src/*
browserify build/00*.js -o build/main.js
# uglifyjs build/main.js > build/main.min.js