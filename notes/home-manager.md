# Home-Manager

And all the tips and tricks I wish I knew when I was using it.

## Activations

They're super cool! They let you run any old bash script you want in them, which is epic.

The first not-so-intended thing I used them to do was clone my neovim config repo into place.
This is relatively simple to do, but since my nvim config was private I needed to have it use git-credential-manager, which means I need to give the activation access to my PATH, so it can find gcm.
That was just a simple export like you'd see in a .bashrc file, and then that worked.
My nvim technically is technically now separate from my nix config, and I have to keep it up to date manually, but that's perfectly fine for me, and now it gets auto-cloned in a proper spot so yay!

The main thing I use activations for, though, is to hot-reload my ghostty and neovim themes when I `home switch`.
This was lowkey a massive pain to do, which is why I'm writing this.
I used nix-colors to auto-generate themes for nvim and ghostty, and home-manager did a great job of putting those generated files where they needed to be.
The problem is that I would have to manually refresh my ghostty (terrible I know) and that refreshing nvim just straight up didn't work.

The reason refreshing nvim didn't work is because it caches everything, so the colorsheme gets cached as the old, bad one.
I found a number of theoretical ways around this, but the only real way I found was to delete the file found in ~/.cache/nvim/luac/.
After deleting that, the colorsheme would change just fine, but I still had to manually refresh.
That's when I found out about [neovim's rpc server](https://neovim.io/doc/user/remote.html).
Basically, whenever you start nvim it starts an rpc server which allows it to be controlled via the `nvim --server [...] --remote[...]` command.
You can manually controll where it is listening with a `--listen [server]` arg at startup, but I don't really want to alias everything to include args.
If a `--listen` arg is not given, it will start listening on `/run/user/[uid]/nvim.[...]`.
Using this, I crafted the brilliant plan to create an activation that: 1. Deletes the colorsheme cache and 2. sends a command to all active nvim processes to refresh their colorshemes.
This worked great! As long as none of the greps failed. Grepping was required to filter down the /run/user/uid/ dir and find the exact colorsheme luac file.
I tore my hair out trying to figure out why home-manager would just randomly exit when it got to my nvim activation.
Eventually I figured out it was because the home-manager activation bash script had `pipefail` set, so any grep that didn't match would cause a failure, and immediately cease all activation.
This was especially annoying, since normall shells don't have pipefail set, so what exited with zero in my shell would exit with 1 in the script.
Moral of the story is "learn bash scripting before really doing home-manager activations".

Ghostty's hot-reloading was much easier.
I am using hyprland, so I decided to use the `hyprctl` cli to send a "reload config" keystroke to every ghostty window.
The problem is that using the sendshortcut [dispatcher](https://wiki.hyprland.org/Configuring/Dispatchers/) only matches the first window found, so specifying class:ghostty* wasn't enough.
The solution I came up with was to list all windows in JSON via `hyprctl clients -j`, and pipe that guy into jq to filter down to ghostty windows.
Then, still using jq, just spit out the pids, and then xarg those guys into hyprctl again to sendshortcut.
Thay one was easy money, and my first time using jq which I now know is an absolutely beautiful tool.

