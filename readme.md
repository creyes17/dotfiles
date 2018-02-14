This is my cloud backup of my personal configuration files. Use at your own risk.

To install ohmyzsh, go to http://ohmyz.sh/ and follow the instructions.

To set up the global gitignore file, run the following command from the root directory of this repo

    git config --global core.excludesfile ./.gitignore_global

I reference my own file system(s) here, so you'll likely need to make some edits if you want it to work for you as well.

Make sure to separately download the following vim bundles. The sym links expect these to be located at $THIS-DIRECTORY/../../

	
    valloric/YouCompleteMe
    gberenfield/cljfold.vim
    Shutnik/jshint2.vim
    chumakd/perlomni.vim
    kien/rainbow_parentheses.vim
    scrooloose/syntastic
    guns/vim-clojure-static
    tpope/vim-fireplace
    pangloss/vim-javascript

Make sure to install YouCompleteMe using the instructions here: https://github.com/Valloric/YouCompleteMe#full-installation-guide

There is an install.sh script that is a work in progress. Use at your own risk, but it should hopefully get your environment setup on a new machine.
