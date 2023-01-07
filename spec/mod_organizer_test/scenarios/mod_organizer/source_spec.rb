describe ModOrganizer::Source do

  let(:source) { mod_organizer.mod(name: 'TestMod').sources.first }

  context 'with a source from nexus_mods' do

    before do
      setup_mo
      setup_mod
    end

    it 'returns the NexusMods mod id' do
      expect(source.nexus_mod_id).to be 1337
    end

    it 'returns the NexusMods file id' do
      expect(source.nexus_file_id).to be 666
    end

    it 'returns the source file name' do
      expect(source.file_name).to eq 'TestMod-v1.7z'
    end

    it 'returns the source type' do
      expect(source.type).to be :nexus_mods
    end

    it 'returns the download info of the source' do
      FileUtils.mkdir_p("#{instance_dir}/downloads")
      downloaded_file = "#{instance_dir}/downloads/TestMod-v1.7z"
      File.write(downloaded_file, 'TestMod v1 downloaded content')
      expect(source.download.downloaded_file_path).to eq downloaded_file
    end

    it 'returns no download info of the source if the downloaded file is missing' do
      expect(source.download).to be_nil
    end

  end

  context 'with an unknown source' do

    before do
      setup_mo
      setup_mod
      File.unlink("#{instance_dir}/mods/TestMod/meta.ini")
    end

    it 'returns no NexusMods mod id' do
      expect(source.nexus_mod_id).to be_nil
    end

    it 'returns no NexusMods file id' do
      expect(source.nexus_file_id).to be_nil
    end

    it 'returns no source file name' do
      expect(source.file_name).to be_nil
    end

    it 'returns the source type' do
      expect(source.type).to be :unknown
    end

    it 'returns no download info of the source' do
      expect(source.download).to be_nil
    end

  end

end
