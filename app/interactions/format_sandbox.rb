class FormatSandbox < ActiveInteraction::Base
  object :sandbox, class: Sandbox

	def execute
    result =
      Aw.fork! do
        Dir.mktmpdir do |dir|
          begin
            executable =
              Rails.root.join 'vendor', 'executables', 'mint'

            relative_executable =
              Pathname.new(executable).relative_path_from(Pathname.new(dir))

            Dir.chdir dir do
              mint_json =
                {"name" => "test", "source-directories" => ["."]}.to_json

              File.write('mint.json', mint_json)
              File.write('Main.mint', sandbox.content)

              Open3.popen3("#{relative_executable} format Main.mint") do |stdin, stdout, stderr|
                puts stdout.read
                File.read(File.join(dir, "Main.mint"))
              end
            end
          rescue
            sandbox.content
          end
        end
      end

    sandbox.update_attribute(:content, result)
	end
end
