require 'csv'
require 'fileutils'
require 'json'
require 'logger'
require 'memoist'
require 'tmpdir'
require 'inifile'
require 'mod_organizer/download'
require 'mod_organizer/mod'
require 'mod_organizer/utils'

# Handle a ModOrganizer installation: mods, esps, load order.
# No concept of Merges.
# No concept of what is actually present in the game directory (except already installed masters/plugins and load order).
class ModOrganizer

  extend Memoist

  # String: The game path
  attr_reader :game_path

  # String: The downloads dir
  attr_reader :downloads_dir

  # Constructor
  #
  # Parameters::
  # * *mo_dir* (String): Mod Organizer installation directory
  # * *instance_name* (String or nil): Mod Organizer instance name, or nil in case of a portable installation. [default: nil]
  # * *logger* (Logger): The logger to be used for log messages [default: Logger.new(STDOUT)]
  def initialize(
    mo_dir,
    instance_name: nil,
    logger: Logger.new($stdout)
  )
    @mo_dir = mo_dir.gsub('\\', '/')
    @mo_instance_dir = instance_name.nil? ? @mo_dir : "#{ENV.fetch('LOCALAPPDATA')}/ModOrganizer/#{instance_name}"
    @logger = logger
    # Read MO ini file
    mo_ini_file = "#{@mo_instance_dir}/ModOrganizer.ini"
    raise "Missing ModOrganizer configuration file #{mo_ini_file}" unless File.exist?(mo_ini_file)

    mo_ini = IniFile.load(mo_ini_file)
    @selected_profile = mo_ini['General']['selected_profile']
    @selected_profile = ::Regexp.last_match(1) if @selected_profile =~ /^@ByteArray\((.+)\)$/
    @game_path = mo_ini['General']['gamePath'].gsub('\\', '/')
    @game_path = ::Regexp.last_match(1) if @game_path =~ /^@ByteArray\((.+)\)$/
    @profiles_dir = (mo_ini['Settings']['profiles_directory'] || "#{@mo_instance_dir}/profiles").gsub('\\', '/')
    @mods_dir = (mo_ini['Settings']['mod_directory'] || "#{@mo_instance_dir}/mods").gsub('\\', '/')
    @overwrite_dir = (mo_ini['Settings']['overwrite_directory'] || "#{@mo_instance_dir}/overwrite").gsub('\\', '/')
    @downloads_dir = (mo_ini['Settings']['download_directory'] || "#{@mo_instance_dir}/downloads").gsub('\\', '/')
    @logger.debug "Selected profile: #{@selected_profile}"
    @logger.debug "Mods directory: #{@mods_dir}"
    @logger.debug "Downloads directory: #{@downloads_dir}"
    @logger.debug "Game path: #{@game_path}"
  end

  # Run an instance of ModOrganizer
  def run
    Dir.chdir(@mo_dir) do
      system 'ModOrganizer.exe'
    end
  end

  # Get the list of mod names
  #
  # Result::
  # * Array<String>: List of mods
  def mod_names
    files_glob("#{@mods_dir}/*").map { |mod_dir| File.directory?(mod_dir) ? File.basename(mod_dir) : nil }.compact
  end
  memoize :mod_names

  # Retrieve a mod
  #
  # Parameters::
  # * *name* (String): The mod name
  # Result::
  # * Mod or nil: The mod, or nil if the mod is unknown
  def mod(name:)
    mod_dir = "#{@mods_dir}/#{name}"
    File.exist?(mod_dir) ? Mod.new(self, mod_dir) : nil
  end
  memoize :mod

  # Get the ordered MO mods list, sorted from the first being loaded to the last (so opposite from the internal MO file)
  #
  # Result::
  # * Array<String>: Sorted list of mod names
  def mods_list
    modlist.map { |mod_name, _enabled| mod_name }
  end
  memoize :mods_list

  # Return the list of enabled mods
  #
  # Result::
  # * Array<String>: Enabled mods
  def enabled_mods
    cached_enabled_mods = []
    modlist.each do |(mod_name, mod_enabled)|
      cached_enabled_mods << mod_name if mod_enabled
    end
    cached_enabled_mods
  end
  memoize :enabled_mods

  # Get the categories
  #
  # Result::
  # * Hash<Integer, String>: For each category ID, the corresponding category name
  def categories
    categories_file = "#{@mo_dir}/categories.dat"
    categories_file = "#{__dir__}/default_categories.dat" unless File.exist?(categories_file)
    CSV.read(categories_file, col_sep: '|').to_h { |cat_id, title, _nexus_ids, _parent_id| [cat_id.to_i, title] }
  end
  memoize :categories

  # Return a downloaded info of file if it exists
  #
  # Parameters::
  # * *file_name* (String): The base file name for which we want the download info
  # Result::
  # * Download: The downloaded information
  def download(file_name:)
    downloaded_file = "#{@downloads_dir}/#{file_name}"
    File.exist?(downloaded_file) ? Download.new(self, file_name) : nil
  end
  memoize :download

  private

  include Utils

  # Get the ordered MO mods list, sorted from the first being loaded to the last (so opposite from the internal MO file)
  #
  # Result::
  # * Array<[String, Boolean]>: Sorted list of mod names with their enabled flag
  def modlist
    cached_mods_list = []
    File.read("#{@profiles_dir}/#{@selected_profile}/modlist.txt").split("\n").each do |line|
      cached_mods_list << [::Regexp.last_match(2), ::Regexp.last_match(1) == '+'] if line =~ /^([+-])(.+)$/
    end
    cached_mods_list.reverse
  end
  memoize :modlist

end
