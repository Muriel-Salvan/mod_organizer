require 'inifile'
require 'memoist'
require 'mod_organizer/source'
require 'mod_organizer/utils'

class ModOrganizer

  # Object storing information about a mod a giving a lazy API on it to save resources (API calls, IO reading, files parsing, esp/bsa exploration...)
  # A mod is an entry in ModOrganizer list.
  class Mod

    extend Memoist

    # String: Mod's name
    attr_reader :name

    # Constructor
    #
    # Parameters::
    # * *mod_organizer* (ModOrganizer): The Mod Organizer instance this mod has been instantiated for
    # * *mod_path* (String): Directory containing the mod information
    def initialize(mod_organizer, mod_path)
      @mod_organizer = mod_organizer
      @path = mod_path
      @name = File.basename(@path)
    end

    # Is this mod enabled in Mod Organizer?
    #
    # Result::
    # * Boolean: Is this mod enabled in Mod Organizer?
    def enabled?
      @mod_organizer.enabled_mods.include?(@name)
    end

    # Return the list of ModOrganizer categories this mod belongs to
    #
    # Result::
    # * Array<String>: List of MO categories
    def categories
      meta_ini['General']['category'].to_s.split(',').map do |cat_id|
        cat_int = Integer(cat_id)
        cat_int.positive? ? @mod_organizer.categories[cat_int] : nil
      end.compact
    end

    # Return the list of plugins this mod is containing.
    # Cache it.
    #
    # Result::
    # * Array<String>: List of plugins belonging to this mod
    def plugins
      (
        files_glob("#{@path}/*.esm") +
        files_glob("#{@path}/*.esp") +
        files_glob("#{@path}/*.esl")
      ).map { |file_name| File.basename(file_name).downcase }
    end
    memoize :plugins

    # Return the list of sources this mod belongs to
    #
    # Result::
    # * Array<Source>: List of source information
    def sources
      nbr_sources = meta_ini['installedFiles']['size'] || 1
      nbr_sources.times.map do |install_idx|
        Source.new(
          @mod_organizer,
          nexus_mod_id: meta_ini['installedFiles']["#{install_idx + 1}\\modid"],
          nexus_file_id: meta_ini['installedFiles']["#{install_idx + 1}\\fileid"],
          file_name: install_idx == nbr_sources - 1 ? meta_ini['General']['installationFile'] : nil
        )
      end
    end
    memoize :sources

    # The mod's URL
    #
    # Result::
    # * String or nil: The mod's URL, or nil if none
    def url
      ini_url = meta_ini['General']['url']
      ini_url.nil? || ini_url.empty? ? nil : ini_url
    end

    private

    include Utils

    # Return the mod's meta ini file.
    # Cache it for performance.
    #
    # Result::
    # * Hash: The mod's meta ini content (can be empty of no meta)
    def meta_ini
      ini_file = "#{@path}/meta.ini"
      File.exist?(ini_file) ? IniFile.load(ini_file) : IniFile.new(content: '')
    end
    memoize :meta_ini

  end

end
