require 'time'

describe ModOrganizer::Download do

  let(:download) { mod_organizer.mod(name: 'TestMod').sources.first.download }
  let(:download_dir) { "#{instance_dir}/downloads" }
  let(:downloaded_file) { "#{instance_dir}/downloads/TestMod-v1.7z" }

  before do
    setup_mo
    setup_mod
    setup_download
  end

  it 'returns the downloaded file path' do
    expect(download.downloaded_file_path).to eq downloaded_file
  end

  it 'returns the downloaded file date' do
    file_date = Time.parse('2023-01-05 10:20:30 UTC')
    File.utime(File.atime(downloaded_file), file_date, downloaded_file)
    expect(download.downloaded_date).to eq file_date
  end

  it 'returns the NexusMods file name' do
    expect(download.nexus_file_name).to eq 'Test Mod file'
  end

  it 'caches the returned NexusMods file name' do
    expect(download.nexus_file_name).to eq 'Test Mod file'
    setup_download(ini: { General: { name: 'Alternative Test Mod file' } })
    expect(download.nexus_file_name).to eq 'Test Mod file'
  end

  it 'returns the NexusMods mod id' do
    expect(download.nexus_mod_id).to eq 1107
  end

  it 'caches the returned NexusMods mod id' do
    expect(download.nexus_mod_id).to eq 1107
    setup_download(ini: { General: { modID: '666' } })
    expect(download.nexus_mod_id).to eq 1107
  end

  it 'returns the NexusMods file id' do
    expect(download.nexus_file_id).to eq 42
  end

  it 'caches the returned NexusMods file id' do
    expect(download.nexus_file_id).to eq 42
    setup_download(ini: { General: { fileID: '666' } })
    expect(download.nexus_file_id).to eq 42
  end

end
