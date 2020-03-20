class UpdateSandbox < ActiveInteraction::Base
  object :sandbox, class: Sandbox

  string :content, default: nil
  string :title, default: nil

  def execute
    sandbox.update!({
      content: content,
      title: title,
      html: html,
    }.compact)

    ScreenshotJob.perform_later(sandbox)
  end

  def html
    @html ||= CompileSandbox.run! content: content
  end
end
