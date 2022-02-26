# Sally Neptune vs The Monocronies

This is a small game I made for ToyBox Jam 3: https://itch.io/jam/toy-box-jam-3/entries

If you want to play it, you can visit the link above. This repo is used for deploying the game on your own system. 

## Requirements
You will need pico-8 to build and play this game. You can get it here: https://www.lexaloffle.com/pico-8.php

## Instructions
You can simply run sallyneptune.p8 to play the game in pico8. If you want to export a cart that in-lines all of the code, do:
```
EXPORT SALLY.P8.PNG
```

### Mapping
I use a separate spritesheet for mapping, so that the map memory is easier to look at. At the command line, run:
```
IMPORT TILES.PNG
```
You will be able to understand the map memory easily if you look at it with this spritesheet loaded. Make sure to import MAINIMG.PNG before playing again.

