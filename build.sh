#! /bin/bash

rm -rf ./dist
rm -rf ./stage

cp -R site ./dist
cp icon/icon*.png dist

# Build 
unzip ltld.zip -d stage
cd stage
cat compiler.js parser.js processor.js program.js routine.js runner.js token.js tokenizer.js transpiler.js microengine.js > engine.js
cd ..
npx esbuild --minify stage/engine.js --outfile=./dist/engine.min.js
cp -R stage/sprites dist
cp -R stage/assets dist
cp daily/*.json dist/assets

sed -n '/<script id="code" type="text\/x-microscript">/,/<\/script>/p' stage/index.html > stage/app.ms  
# sed -e '/{{ app }}/{r stage/app.ms}' dist/index.html

# Teardown
# rm -rf ./stage

ls -la dist
cat stage/app.ms | pbcopy

echo "------------------------------------------------------"
echo "dist folder created."
echo ""
echo "App code copied to the clipboard with:"
echo "  cat stage/app.ms | pbcopy"
echo "Copy and paste dist/app.ms into index.html {{ app }}:"

