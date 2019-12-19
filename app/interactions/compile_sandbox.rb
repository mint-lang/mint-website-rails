class CompileSandbox < ActiveInteraction::Base
  object :sandbox, class: Sandbox

  def execute
    compiled =
      Redis.current.hget('sandboxes', sandbox.id)

    unless compiled
      compiled =
        compile

      Redis.current.hset('sandboxes', sandbox.id, compiled)
    end

    compiled.html_safe
  end

  def compile
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
            File.write('Main.mint', sandbox.content)

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

    html =
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

    html
  end
end
