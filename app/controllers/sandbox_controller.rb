class SandboxController < ApplicationController
  AS_JSON = {only: %i[id title content created_at updated_at user_id mint_version], include: { user: { only: %i[id nickname image]}}}
  skip_before_action :verify_authenticity_token

  def login
    user =
      User.find_or_create_by(
        nickname: auth_hash[:info][:nickname],
        uid: auth_hash[:uid])

    user.update(image: auth_hash[:info][:image])

    session[:id] = user.id

    redirect_to ENV['SANDBOX_URL']
  end

  def logout
    session[:id] = nil
    render plain: ''
  end

  def user
    with_user do |user|
      render json: user.as_json
    end
  end

  def update
    with_sandbox do |user, sandbox|
      UpdateSandbox.run mint_version: params[:mintVersion],
                        content: params[:content],
                        title: params[:title],
                        sandbox: sandbox

      render json: sandbox.as_json(AS_JSON)
    end
  end

  def format
    with_sandbox do |user, sandbox|
      FormatSandbox.run sandbox: sandbox

      render json: sandbox.as_json(AS_JSON)
    end
  end

  def recent
    sandboxes =
      Sandbox
        .includes(:user)
        .order(updated_at: :desc)
        .limit(20)
        .as_json(AS_JSON)

    render json: sandboxes
  end

  def index
    with_user do |user|
      sandboxes =
         Sandbox
          .where(user_id: user.id)
          .includes(:user)
          .sort_by(&:title)
          .as_json(AS_JSON)

      render json: sandboxes
    end
  end

  DEFAULT_SANDBOX =
    <<~EOS
    component Main {
      fun render : Html {
        <div>"Hello World!"</div>
      }
    }
    EOS

  DEFAULT_HTML =
    CompileSandbox.run!(content: DEFAULT_SANDBOX, mint_version: '0.17.0')

  def create
    with_user do |user|
      sandbox =
        Sandbox.create!(
          id: SecureRandom.urlsafe_base64(10),
          content: DEFAULT_SANDBOX,
          mint_version: '0.17.0',
          title: 'My Sandbox',
          html: DEFAULT_HTML,
          user: user)

      render json: sandbox.as_json(AS_JSON), status: 201
    end
  end

  def destroy
    with_sandbox do |user, sandbox|
      sandbox.destroy!

      render json: sandbox.as_json(AS_JSON), status: 200
    end
  end

  def show
    sandbox =
      Sandbox.find_by_id(params[:id])

    if sandbox
      render json: sandbox.as_json(AS_JSON), status: 200
    else
      render plain: '', status: 404
    end
  end

  def fork
    with_user do |user|
      sandbox =
        Sandbox.find_by_id(params[:id])

      if sandbox
        forked =
          Sandbox.create!(
            id: SecureRandom.urlsafe_base64(10),
            content: sandbox.content,
            title: sandbox.title,
            html: sandbox.html,
            user: user)

        render json: forked.as_json(AS_JSON), status: 200
      else
        render plain: '', status: 404
      end
    end
  end

  def preview
    response.headers.delete "X-Frame-Options"

    sandbox =
      Sandbox.find_by_id(params[:id])

    if sandbox
      render html: sandbox.html.to_s.html_safe
    else
      render plain: '', status: 404
    end
  end

  def screenshot
    sandbox =
      Sandbox.find_by_id(params[:id])

    if sandbox
      url = url_for(sandbox.screenshot)

      if url
        redirect_to url
      else
        render plain: '', status: 404
      end
    else
      render plain: '', status: 404
    end
  end

  protected

  def url_for(object)
    return unless object.attached?
    Rails.application.routes.url_helpers.url_for(object)
  end

  def with_sandbox
    with_user do |user|
      sandbox =
        user.sandboxes.find_by_id(params[:id])

      if sandbox
        yield user, sandbox
      else
        render plain: '', status: 403
      end
    end
  end

  def with_user
    user = User.find_by_id(session[:id])

    if user
      yield user
    else
      render plain: '', status: 401
    end
  end

  def auth_hash
    request.env['omniauth.auth']
  end
end
