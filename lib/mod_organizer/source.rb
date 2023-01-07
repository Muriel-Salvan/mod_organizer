class ModOrganizer

  # Object storing information about the source of a mod and giving a lazy API on it to save resources
  # A mod source is something (a file from NexusMods, a manual download...) that has provided content for the mod.
  class Source

    # Integer or nil: NexusMods mod ID, or nil if none
    attr_reader :nexus_mod_id

    # Integer or nil: NexusMods file ID, or nil if none
    attr_reader :nexus_file_id

    # String or nil: File name for this source, or nil if none
    attr_reader :file_name

    # Constructor
    #
    # Parameters::
    # * *mod_organizer* (ModOrganizer): The Mod Organizer instance this mod has been instantiated for
    # * *nexus_mod_id* (Integer): Corresponding Nexus mod id, or 0 or nil if none
    # * *nexus_file_id* (Integer): Corresponding Nexus mod file id, or 0 or nil if none
    # * *file_name* (String): File name that provided content to this mod, or nil if none
    def initialize(
      mod_organizer,
      nexus_mod_id:,
      nexus_file_id:,
      file_name:
    )
      @mod_organizer = mod_organizer
      @nexus_mod_id = nexus_mod_id.nil? || nexus_mod_id.zero? ? nil : nexus_mod_id
      @nexus_file_id = nexus_file_id.nil? || nexus_file_id.zero? ? nil : nexus_file_id
      @file_name = file_name
    end

    # The type of source
    #
    # Result::
    # * Symbol: The source's type. Can be:
    #   * nexus_mods: Content downloaded from NexusMods
    #   * unknown: Unknown source
    def type
      @nexus_mod_id ? :nexus_mods : :unknown
    end

    # Get the download info corresponding to this source, or nil if none.
    #
    # Result::
    # * Download or nil: Download info, or nil if none
    def download
      @file_name ? @mod_organizer.download(file_name: @file_name) : nil
    end

  end

end
