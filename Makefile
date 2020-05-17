.PHONY: build-linux build-max run
build-linux:
	elm make --output=docs/index.html src/Main.elm
	sed -i 's:<head>:<head><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0,user-scalable=0"/>:' docs/index.html

build-mac:
	elm make --output=docs/index.html src/Main.elm
	sed -i '' 's:<head>:<head><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0,user-scalable=0"/>:' docs/index.html

run:
	elm-app start
