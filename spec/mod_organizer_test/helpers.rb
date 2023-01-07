require 'fileutils'
require 'logger'
require 'mod_organizer'

module ModOrganizerTest

  module Helpers

    # ModOrganizer: The ModOrganizer instance that has been setup
    attr_reader :mod_organizer

    # String: The instance directory that has been setup
    attr_reader :instance_dir

    # Prepare a ModOrganizer instance directory
    # The directory path is stored in an instance variable named @instance_dir.
    #
    # Parameters::
    # * *ini* (Hash< Symbol, Hash<Symbol, String> >): Content of the ini file to overwrite default values [default: {}]
    # * *instance_name* (String or nil): The instance name to be used to mock a shared installation, or nil for a portable installation [default: nil]
    def setup_instance_dir(ini: {}, instance_name: nil)
      @instance_dir = "#{Dir.tmpdir}/ModOrganizerTest/ModOrganizer/#{instance_name || 'PortableInstance'}"
      FileUtils.rm_rf(@instance_dir)
      FileUtils.mkdir_p(@instance_dir)
      IniFile.new(
        content: {
          General: {
            gamePath: 'C:/path/to/game',
            selected_profile: 'Default'
          },
          Settings: {
            log_level: '1'
          }
        }.merge(ini) do |_section, default_properties, overwrite_properties|
          default_properties.merge(overwrite_properties)
        end
      ).write(filename: "#{@instance_dir}/ModOrganizer.ini")
    end

    # Setup an instance of ModOrganizer setup on an instance directory.
    # It uses the variable @instance_name to eventually setup a shared installation.
    # The instance is stored in an instance variable named @mod_organizer.
    #
    # Parameters::
    # * *ini* (Hash< Symbol, Hash<Symbol, String> >): Content of the ini file to overwrite default values [default: {}]
    def setup_mo(ini: {})
      setup_instance_dir(ini:, instance_name: @instance_name)
      mo_logger = StringIO.new
      ENV['LOCALAPPDATA'] = "#{Dir.tmpdir}/ModOrganizerTest"
      @mod_organizer = ModOrganizer.new(@instance_dir, instance_name: @instance_name, logger: Logger.new(mo_logger))
    end

    # Setup a mod in the default mods folder.
    # Prerequisite: instance_dir has to be setup previously with setup_instance_dir.
    #
    # Parameters::
    # * *ini* (Hash< Symbol, Hash<Symbol, String> >): Content of the meta ini file to overwrite default values [default: {}]
    # * *mod_name* (String): The mod name [default: 'TestMod']
    # Result::
    # * String: The mod directory
    def setup_mod(ini: {}, mod_name: 'TestMod')
      mod_dir = "#{instance_dir}/mods/#{mod_name}"
      FileUtils.mkdir_p(mod_dir)
      IniFile.new(
        content: {
          General: {
            category: '2,',
            url: 'https://test-mod.url',
            installationFile: 'TestMod-v1.7z'
          },
          installedFiles: {
            size: '1',
            '1\\modid': '1337',
            '1\\fileid': '666'
          }
        }.merge(ini) do |_section, default_properties, overwrite_properties|
          default_properties.merge(overwrite_properties)
        end
      ).write(filename: "#{mod_dir}/meta.ini")
      mod_dir
    end

    # Setup a download in the default downloads folder.
    # Prerequisite: instance_dir has to be setup previously with setup_instance_dir.
    #
    # Parameters::
    # * *ini* (Hash< Symbol, Hash<Symbol, String> >): Content of the meta ini file to overwrite default values [default: {}]
    # * *file_name* (String): The downloaded file name [default: 'TestMod-v1.7z']
    # Result::
    # * String: The downloads directory
    def setup_download(ini: {}, file_name: 'TestMod-v1.7z')
      downloads_dir = "#{instance_dir}/downloads"
      FileUtils.mkdir_p(downloads_dir)
      IniFile.new(
        content: {
          General: {
            name: 'Test Mod file',
            modID: '1107',
            fileID: '42'
          }
        }.merge(ini) do |_section, default_properties, overwrite_properties|
          default_properties.merge(overwrite_properties)
        end
      ).write(filename: "#{downloads_dir}/#{file_name}.meta")
      File.write("#{downloads_dir}/#{file_name}", "#{file_name} downloaded content")
      downloads_dir
    end

  end

end

RSpec.configure do |config|
  config.include ModOrganizerTest::Helpers
end
