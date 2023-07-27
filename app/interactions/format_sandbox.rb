class FormatSandbox < ActiveInteraction::Base
  object :sandbox, class: Sandbox

  def execute
    body =
      {
        files: [
          {
            contents: sandbox.content,
            path: 'Main.mint'
          }
        ]
      }.to_json

    url =
      {
        "0.16.1" => 'https://mint-sandbox-compiler.herokuapp.com/format',
        "0.17.0" => 'https://mint-sandbox-0170.szikszai.co/format',
        "0.18.0" => 'https://mint-sandbox-0180.szikszai.co/format'
      }

    response =
      Faraday
        .post(url[sandbox.mint_version], body, 'Content-Type' => 'application/json')
        .body

    result =
      JSON.parse(response)

    sandbox.update_attribute(:content, result['files'][0]['contents'])
  end
end
