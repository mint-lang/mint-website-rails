class UpdateSandbox < ActiveInteraction::Base
  object :sandbox, class: Sandbox

  string :mint_version, default: nil
  string :content, default: nil
  string :title, default: nil

  def execute
    sandbox.update!({
      mint_version: mint_version,
      content: content,
      title: title,
      html: html,
    }.compact)

    ScreenshotJob.perform_later(sandbox)
  end

  def html
    @html ||= CompileSandbox.run! content: content, mint_version: mint_version || sandbox.mint_version
  end
end
