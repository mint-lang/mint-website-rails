class ScreenshotJob < ApplicationJob
  include SuckerPunch::Job

  def perform(sandbox)
    file = screenshot(sandbox)

  	sandbox.screenshot.attach(io: file,  filename: 'screenshot.jpg')
    sandbox.save!

    File.delete(file)
  end

  def screenshot(sandbox)
    browser = Ferrum::Browser.new(window_size: [600,300])
    browser.goto("http://localhost:3001/sandbox/#{sandbox.id}/preview")
    browser.screenshot(path: sandbox.id + '.jpg')

    File.new(sandbox.id + '.jpg')
  end
end
