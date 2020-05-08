This is my cloud backup of my personal configuration files. Use at your own risk.

To install ohmyzsh, go to http://ohmyz.sh/ and follow the instructions.

To set up the global gitignore file, run the following command from the root directory of this repo

    git config --global core.excludesfile ./.gitignore_global

Relies on the following other git repositories (included as submodules)
	
    chrisbra/csv.vim
    chumakd/perlomni.vim
    ctrlpvim/ctrlp.vim
    fatih/vim-go
    gberenfield/cljfold.vim
    guns/vim-clojure-static
    JamshedVesuna/vim-markdown-preview
    kien/rainbow_parentheses.vim
    kward/shunit2
    ludovicchabant/vim-gutentags
    mxw/vim-jsx
    pangloss/vim-javascript
    scrooloose/syntastic
    Shutnik/jshint2.vim
    tpope/vim-fireplace
    valloric/YouCompleteMe

Make sure to install YouCompleteMe using the instructions here: https://github.com/Valloric/YouCompleteMe#full-installation-guide. I recommend using Valloric's install.py script.

There is an install.sh script that is a work in progress. Use at your own risk, but it should hopefully get your environment setup on a new machine.

Known issues with install.sh:

* Lein profiles installs with my name and email. You should update profiles.clj with your own name and email.
* Relies on a number of script dependencies. Run with `install.sh -h` to see the usage statement and all of the dependencies

Issues installing YouCompleteMe

* "Failed to build watchdog module."
    * Not sure how to fix. Here's the [full installation guide](https://github.com/ycm-core/YouCompleteMe/wiki/Full-Installation-Guide).
    * Got clangd installled via [these instructions](https://clangd.llvm.org/installation.html).
        * Also updated vimrc with recommended changes for YCM
    * Tried installing clangd using `brew install llvm` (that's "Lima Lima Victor Mike")
    * I guess the problem was somehow that the watchdog submodule of the ycmd submodule was being un-initialized?
        * Following the steps in the full installation guide worked, and then I tried install.py again and that worked too.
