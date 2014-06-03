Quick start
-----
### Install Ruby
#### In Debian
```bash
aptitude install ruby ruby-dev
```

### Install the [travis gem](https://github.com/travis-ci/travis.rb)

```bash
gem install travis -v 1.6.11 --no-rdoc --no-ri --user-install
```

### Login into travis

```bash
travis login --auto
```

### Run the script
```bash
./travis-cancel-duplicates.rb
```
