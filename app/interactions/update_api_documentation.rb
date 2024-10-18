require 'open-uri'
require 'pathname'
require 'zip'
require 'open3'

Zip.warn_invalid_date = false

class UpdateApiDocumentation < ActiveInteraction::Base
  string :semver

  def execute
    extract do |dir|
      version
        .update(
          documentation: compile_documentation(dir),
          mint_json: mint_json(dir),
          readme: readme(dir))
    end
  end

  def version
    @version ||=
      Package.find_by(repository: 'mint-lang/core').versions.first
  end

  def readme(dir)
    filename =
      Dir.glob("#{dir}/readme.*", File::FNM_CASEFOLD).first

    if filename
      File.read(filename)
    else
      ''
    end
  end

  def compile_documentation(dir)
    executable =
      Rails.root.join 'vendor', 'executables', 'mint'

    relative_executable =
      Pathname.new(executable).relative_path_from(Pathname.new("#{dir}/core"))

    Dir.chdir "#{dir}/core" do
      begin
        Open3.popen3("#{relative_executable} docs generate") do |stdin, stdout, stderr|
          stdout.read
          stderr.read
          JSON.parse(File.read('docs.json'))
        end
      rescue StandardError, SystemExit => error
        puts error
        {}
      end
    end
  end

  def extract
    Dir.mktmpdir do |dir|
      Zip::File.open_buffer(archive) do |zip_file|
        puts "Extracting archive to: #{dir}..."

        zip_file.each do |entry|
          # Remove the package-name-version root directory
          path =
            entry.name.split('/')[1..-1].join('/')

          entry.extract(File.join(dir, path))
        end
      end

      yield dir
    end
  end


  def mint_json(dir)
    path =
      File.join(dir, 'core', 'mint.json')

    JSON.parse(File.read(path))
  rescue StandardError => error
    puts error
    {}
  end

  def archive
    puts "Downloading archive from: #{archive_path}..."

    @archive ||= Net::HTTP.get(URI.parse(archive_path))
  end

  def archive_path
    "https://codeload.github.com/mint-lang/mint/zip/#{semver}"
  end
end
