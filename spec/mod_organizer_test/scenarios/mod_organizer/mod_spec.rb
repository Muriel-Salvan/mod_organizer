describe ModOrganizer::Mod do

  let(:mod) { mod_organizer.mod(name: 'TestMod') }
  let(:mod_dir) { "#{instance_dir}/mods/TestMod" }

  context 'with a simple mod' do

    before do
      setup_mo
      setup_mod
    end

    it 'returns the mod name' do
      expect(mod.name).to eq 'TestMod'
    end

    it 'returns the mod enabled flag when enabled' do
      FileUtils.mkdir_p("#{instance_dir}/profiles/Default")
      File.write(
        "#{instance_dir}/profiles/Default/modlist.txt",
        <<~EO_MOD_LIST
          +TestMod
        EO_MOD_LIST
      )
      expect(mod.enabled?).to be(true)
    end

    it 'returns the mod enabled flag when disabled' do
      FileUtils.mkdir_p("#{instance_dir}/profiles/Default")
      File.write(
        "#{instance_dir}/profiles/Default/modlist.txt",
        <<~EO_MOD_LIST
          -TestMod
        EO_MOD_LIST
      )
      expect(mod.enabled?).to be(false)
    end

    it 'returns the mod categories' do
      expect(mod.categories).to eq %w[Armour]
    end

    it 'returns no plugins for mods having no plugins' do
      expect(mod.plugins).to eq []
    end

    it 'returns plugins from the mod\'s root directory' do
      File.write("#{mod_dir}/plugin1.esm", 'Plugin1 esm content')
      File.write("#{mod_dir}/plugin2.esp", 'Plugin2 esp content')
      File.write("#{mod_dir}/plugin3.esl", 'Plugin3 esl content')
      File.write("#{mod_dir}/other_file.txt", 'Other file content')
      FileUtils.mkdir_p("#{mod_dir}/others")
      File.write("#{mod_dir}/others/plugin4.esp", 'Plugin4 esp content')
      expect(mod.plugins.sort).to eq %w[
        plugin1.esm
        plugin2.esp
        plugin3.esl
      ]
    end

    it 'returns plugins in lower case' do
      File.write("#{mod_dir}/PlUgIn1.EsM", 'Plugin1 esm content')
      expect(mod.plugins).to eq %w[plugin1.esm]
    end

    it 'caches plugins being returned' do
      File.write("#{mod_dir}/plugin1.esm", 'Plugin1 esm content')
      expect(mod.plugins).to eq %w[plugin1.esm]
      File.unlink("#{mod_dir}/plugin1.esm")
      expect(mod.plugins).to eq %w[plugin1.esm]
    end

    it 'returns the mod source' do
      sources = mod.sources
      expect(sources.size).to be 1
      expect(sources.first.type).to be :nexus_mods
      expect(sources.first.nexus_mod_id).to be 1337
      expect(sources.first.nexus_file_id).to be 666
      expect(sources.first.file_name).to eq 'TestMod-v1.7z'
    end

    it 'caches the returned the mod source' do
      expect(mod.sources.first.nexus_mod_id).to be 1337
      setup_mod(ini: { installedFiles: { '1\\modid': '1107' } })
      expect(mod.sources.first.nexus_mod_id).to be 1337
    end

    it 'returns the mod URL' do
      expect(mod.url).to eq 'https://test-mod.url'
    end

  end

  context 'with a mod having no ini file' do

    before do
      setup_mo
      setup_mod
      File.unlink("#{mod_dir}/meta.ini")
    end

    it 'returns the mod name' do
      expect(mod.name).to eq 'TestMod'
    end

    it 'returns the mod enabled flag when enabled' do
      FileUtils.mkdir_p("#{instance_dir}/profiles/Default")
      File.write(
        "#{instance_dir}/profiles/Default/modlist.txt",
        <<~EO_MOD_LIST
          +TestMod
        EO_MOD_LIST
      )
      expect(mod.enabled?).to be(true)
    end

    it 'returns the mod enabled flag when disabled' do
      FileUtils.mkdir_p("#{instance_dir}/profiles/Default")
      File.write(
        "#{instance_dir}/profiles/Default/modlist.txt",
        <<~EO_MOD_LIST
          -TestMod
        EO_MOD_LIST
      )
      expect(mod.enabled?).to be(false)
    end

    it 'returns no mod categories' do
      expect(mod.categories).to eq []
    end

    it 'returns an unknown mod source' do
      sources = mod.sources
      expect(sources.size).to be 1
      expect(sources.first.type).to be :unknown
      expect(sources.first.nexus_mod_id).to be_nil
      expect(sources.first.nexus_file_id).to be_nil
      expect(sources.first.file_name).to be_nil
    end

    it 'returns no mod URL' do
      expect(mod.url).to be_nil
    end

  end

  context 'with a mod having several sources' do

    before do
      setup_mo
      setup_mod(
        ini: {
          installedFiles: {
            size: '3',
            '1\\modid': '100',
            '1\\fileid': '200',
            '2\\modid': '101',
            '2\\fileid': '201',
            '3\\modid': '102',
            '3\\fileid': '202'
          }
        }
      )
    end

    it 'returns several sources' do
      expect(mod.sources.map.with_index { |source, idx| [idx, source.nexus_mod_id, source.nexus_file_id] }.sort).to eq [
        [0, 100, 200],
        [1, 101, 201],
        [2, 102, 202]
      ]
    end

    it 'associates the downloaded file name to the last source only' do
      expect(mod.sources.map.with_index { |source, idx| [idx, source.file_name] }.sort).to eq [
        [0, nil],
        [1, nil],
        [2, 'TestMod-v1.7z']
      ]
    end

  end

end
