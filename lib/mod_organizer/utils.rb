class ModOrganizer

  # Module giving some helpers to various ModOrganizer classes
  module Utils

    # Return all files matching a glob.
    # Handle special characters correctly.
    # Don't return . and ..
    #
    # Parameters::
    # * *glob* (String): The glob
    # Result::
    # * Array<String>: The list of files matching the glob
    def files_glob(glob)
      Dir.glob(glob.gsub('[', '\\[').gsub(']', '\\]'), File::FNM_DOTMATCH).select do |file|
        basename = File.basename(file)
        basename != '.' && basename != '..'
      end
    end

  end

end
