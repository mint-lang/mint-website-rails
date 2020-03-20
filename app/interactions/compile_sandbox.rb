class CompileSandbox < ActiveInteraction::Base
  string :content

  def execute
    js, error =
      Aw.fork! do
        Dir.mktmpdir do |dir|
          Dir.chdir dir do
            executable =
              Rails.root.join 'vendor', 'executables', 'mint'

            relative_executable =
              Pathname.new(executable).relative_path_from(Pathname.new(dir))

            mint_json =
              {"name" => "test", "source-directories" => ["."]}.to_json

            File.write('mint.json', mint_json)
            File.write('Main.mint', content)

            Open3.popen3("#{relative_executable} compile --output output.js") do |stdin, stdout, stderr|
              error = stdout.read
              output = File.join(dir, 'output.js')

              if File.exists?(output)
                [File.read(output), nil]
              else
                [nil, error]
              end
            end
          end
        end
      end

    if js
      <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title></title>
      </head>
      <body>
        <script>
          window.onmessage = () => {
            window.location.reload()
          }
        </script>
        <script type="text/javascript">
          #{js};
          Mint.embed()
        </script>
      </body>
      </html>
      HTML
    else
      <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title></title>
      </head>
      <body style="background: #282c34;color:#EEE;font-size:14px;">
        <script>
          window.onmessage = () => {
            window.location.reload()
          }
        </script>
        <pre>#{Ansi::To::Html.new(CGI::escapeHTML(error)).to_html(:xterm)}</pre>
      </body>
      </html>
      HTML
    end
  end
end
