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

    response =
      Faraday
        .post('https://mint-sandbox-compiler.herokuapp.com/format', body, 'Content-Type' => 'application/json')
        .body

    result =
      JSON.parse(response)

    sandbox.update_attribute(:content, result['files'][0]['contents'])
  end
end
