# Mod Organizer

Simple Ruby API letting you handle an instance of [Mod Organizer](https://www.nexusmods.com/skyrimspecialedition/mods/6194).

## Install

Via gem

``` bash
$ gem install mod_organizer
```

Via a Gemfile

``` ruby
$ gem 'mod_organizer'
```

## Usage

``` ruby
require 'mod_organizer'

mod_organizer = ModOrganizer.new('C:/Program Files/Mod Organizer')
mod_organizer.mod_names.each do |mod_name|
  puts "Mod #{mod_name} has #{mod_organizer.mod(mod_name:).plugins.size} plugins"
end
```

In case your ModOrganizer instance is not installed as portable, then you have to specify the instance name:
``` ruby
mod_organizer = ModOrganizer.new('C:/Program Files/Mod Organizer', instance_name: 'MyInstance')
```

## Change log

Please see [CHANGELOG](CHANGELOG.md) for more information on what has changed recently.

## Testing

Automated tests are done using rspec.

Do execute them, first install development dependencies:

```bash
bundle install
```

Then execute rspec

```bash
bundle exec rspec
```

## Contributing

Any contribution is welcome:
* Fork the github project and create pull requests.
* Report bugs by creating tickets.
* Suggest improvements and new features by creating tickets.

## Credits

- [Muriel Salvan][link-author]

## License

The BSD License. Please see [License File](LICENSE.md) for more information.
