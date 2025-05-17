# Setting Credentials

Was a pain. 


All I wanted was to be able to clone private git repos over https, and that took way too long, but I learned a ton and just wanted to write it down real quick.

## What is going on with git??

Git has shockingly bad documentation imo.

To get git to use a credential manager you have to set the `credential.helper` parameter.
This defines the name of an executable that git will use to help it with credentials.
Uppon writing this, I found [page1](https://git-scm.com/doc/credential-helpers), which makes me look like a fool for not knowing this, but I swear this is not well understood I saw a forum post of a nix user not really knowing why they set helper to manager.

Anyway what originally tipped me off was [page2](https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage), which describes how credential.helper is just setting a path to an executable. That was eye-opening.

You can go with whatever you want, but the seemingly most-official one is git-credential-manager. To use it, set `credential.helper` to "manager" so it will search for git-credential-manager according to the table in page2.

This is where Github's documentation ([page3](https://aka.ms/gcmcore-linuxcredstores)) is actually kind of helpful.
Basically gcm can use a bunch of different ways to store/encrypt your credentials after you do stuff like oath.
Page3 does a great job of summarizing those options, and I chose one that is apparently a huge pain in the @$$:

## GNOME Keyring

An evil program.

What's not so evil though is freedesktop created this standard called secret-service protocol, where apps you run can talk to some random background app that keeps track of and encrypts your secrets.

So, if you set "secretservice" as `credential.credentialStore` for git, git will try to talk to whatever background app is currently providing the "org.freedesktop.secrets" service when it needs to do credential stuff.


Gnome keyring is one of several apps that can provide this service, and it's just a daemon that runs in the background.
If you chose a different provider it would also provide the same "org.freedesktop.secrets" service and git/any app would be none the wiser.


Also, from my understanding, libsecret is usually required because it's a library that applications can use to communicate to the secret service. so it's just like a middleman to reduce boilerplate/code duplication (no way! he just described every library!).
Still probably install it.


Ok but libsecret aside, how do we get gnome keyring to work?

Gnome keyring has to be unlocked at login (so that apps can actually read/write to secrets) and then the daemon has to be started, which usually happens as your window manager starts up.
To unlock it, you can add a line to these things called pam modules as per [page4](https://wiki.archlinux.org/title/GNOME/Keyring#PAM_step).
Still don't fully understand them, but they seem to just do stuff at login/when you run commands so good enough for me!
Then you need to run `gnome-keyring-daemon` in the background and all is well!

Ok so not that complicated but this was a pain, plus I had to do it on nix.

## NixOs-specific

I'm assuming you are using home-manager.

To install git with gcm you need to install it from gitAndTools.
You can't just use normal git.
This is from one of my files that home-manager imports:
```nix
programs.git = {
  enable = true;

  package = pkgs.gitAndTools.gitFull;
  extraConfig.credential.helper = "manager";
  extraConfig.credential.credentialStore = "secretservice";
}
```

For gnome-keyring there are 2 settings:


1: In a normal nixos config module you have to hit:
```nix
services.gnome.gnome-keyring.enable = true;
```
This will install it, and will configure the "login" pam module to unlock the keyring.
If this is not working, check /etc/pam.d/[YOUR DISPLAY MANAGER'S NAME] and make sure it uses the login pam module.
If it's not, you may need to look into: `security.pam.services.[DM NAME].enableGnomeKeyring = true;`
I'm pretty sure I saw stuff saying greetd needed this.

2: In your home-manager setup you have to hit:
```nix
services.gnome-keyring.enable = true;
```
This will start the daemon and basically nothing else.
It might install it idk.
I did this and I did not need to add an additional line to my hyprland config or some rc file or whatever like I saw some suggestions for online. Those might be worth a try tho.



