# ddoublemoo
Perl script to download a random bar from RapGenius and output it to cowsay.

### Usage ###
`./ddoublemoo.pl` - spawn a cowsay with a random bar from the Newham General himself, D Double E.
`./ddoublemoo.pl "[artist name]"` - spawn a cowsay with a random bar from any given artist, for example `./ddoublemoo.pl skepta` will have the cow spit a Skepta bar.

### Arguments ###
Ddoublemoo is compatible with the normal cowsay arguments that chang ethe appearance of our beloved ASCII cow - for example, `./ddoublemoo.pl -s` will make the cow look stoned, and `./ddoublemoo.pl -t` will make it look tired.

It's possible to have the cow spit fire through a whole song by using the argument `--fire`. For example, `./ddoublemoo.pl --fire "danny brown"` will have the cow go through an entire Danny Brown tune.

Support has also been added for voice - adding the argument `--say` will get either *espeak* (on Linux) or *say* (on OS X) to vocalise the bar.

### Dependencies ###
Requires cowsay and wget on both OS X and Linux - for OS X, these are installable via brew - `brew install cowsay` and `brew install wget`.

For Linux, additional *espeak* package needed, which can be downloaded via your package manager.
