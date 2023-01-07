require 'memoist'

class ModOrganizer

  # Object storing information about a downloaded file and giving a lazy API on it to save resources
  class Download

    extend Memoist

    # Constructor
    #
    # Parameters::
    # * *mod_organizer* (ModOrganizer): The Mod Organizer instance this mod has been instantiated for
    # * *file_name* (String): The file name for this download
    def initialize(mod_organizer, file_name)
      @mod_organizer = mod_organizer
      @file_name = file_name
    end

    # Full downloaded file path
    #
    # Result::
    # * String or nil: Full downloaded file path, or nil if does not exist
    def downloaded_file_path
      full_path = "#{@mod_organizer.downloads_dir}/#{@file_name}"
      File.exist?(full_path) ? full_path : nil
    end

    # Download date of the source
    #
    # Result::
    # * Time or nil: Download date of this source, or nil if no file
    def downloaded_date
      file_path = downloaded_file_path
      file_path ? File.mtime(file_path).utc : nil
    end

    # NexusMods file name
    #
    # Result::
    # * String:: Original file name from NexusMods
    def nexus_file_name
      meta_ini['General']['name']
    end

    # NexusMods mod ID
    #
    # Result::
    # * Integer:: Mod ID from NexusMods
    def nexus_mod_id
      meta_ini['General']['modID']
    end

    # NexusMods file ID
    #
    # Result::
    # * Integer:: File ID from NexusMods
    def nexus_file_id
      meta_ini['General']['fileID']
    end

    private

    # Return the mod's meta ini file.
    # Cache it for performance.
    #
    # Result::
    # * Hash: The mod's meta ini content
    def meta_ini
      IniFile.load("#{@mod_organizer.downloads_dir}/#{@file_name}.meta")
    end
    memoize :meta_ini

  end

end
