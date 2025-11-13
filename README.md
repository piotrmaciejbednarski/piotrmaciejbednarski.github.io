# Piotr Bednarski's blog

Source code of this website is licensed under the [MIT License](LICENSE).

## Acknowledgments
This website is built using [Jekyll](https://jekyllrb.com/) and the [Tekknolagi](https://github.com/tekknolagi/tekknolagi.github.com) theme created by [Max Bernstein](https://bernsteinbear.com/).

## macOS Ruby setup

1. Install Homebrew if you do not have it yet: <https://brew.sh>.
2. Install the Ruby toolchain:

	```bash
	brew install rbenv ruby-build
	rbenv install 3.3.5
	rbenv global 3.3.5
	echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
	exec $SHELL
	gem install bundler
	```

3. Each new terminal automatically loads Ruby 3.3.5; run `ruby -v` to confirm before working on the site.

## Local development

1. Make sure you have Ruby and Bundler available (`gem install bundler` if needed).
2. Install the dependencies:

	```bash
	bundle install
	```

3. Launch the local server (includes incremental rebuilds and livereload by default):

	```bash
	bundle exec jekyll serve
	```

4. Open the site at http://127.0.0.1:4000/ (or the URL printed in the terminal).

If you update gems later, rerun `bundle install` to keep the lockfile in sync.