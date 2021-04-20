class CompileSandbox < ActiveInteraction::Base
  string :content

  def execute
    body =
      {
        files: [
          {
            contents: content,
            path: 'Main.mint'
          }
        ]
      }.to_json

    Faraday
      .post('https://mint-sandbox-compiler.herokuapp.com/compile', body, 'Content-Type' => 'application/json')
      .body
  end
end
