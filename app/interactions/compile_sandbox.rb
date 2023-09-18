class CompileSandbox < ActiveInteraction::Base
  string :mint_version
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

    url =
      {
        "0.16.1" => 'https://mint-sandbox-compiler.herokuapp.com/compile',
        "0.17.0" => 'https://mint-sandbox-0170.szikszai.co/compile',
        "0.18.0" => 'https://mint-sandbox-0180.szikszai.co/compile',
        "0.19.0" => 'https://mint-sandbox-0190.szikszai.co/compile'
      }

    Faraday
      .post(url[mint_version], body, 'Content-Type' => 'application/json')
      .body
  end
end
