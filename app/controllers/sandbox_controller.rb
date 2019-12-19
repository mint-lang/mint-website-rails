class SandboxController < ApplicationController
  AS_JSON = {include: { user: { only: %i[id nickname image]}}}
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
      sandbox.update!({
        content: params[:content],
        title: params[:title]
      }.compact)

      render json: sandbox.as_json(AS_JSON)
    end
  end

  def format
    with_sandbox do |user, sandbox|
      FormatSandbox.run sandbox: sandbox

      render json: sandbox.as_json(AS_JSON)
    end
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

  def create
    with_user do |user|
      sandbox =
        Sandbox.create!(
          id: SecureRandom.urlsafe_base64(10),
          title: 'My Sandbox',
          content: "",
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
      outcome =
        CompileSandbox.run sandbox: sandbox

      render html: outcome.result
    else
      render plain: '', status: 404
    end
  end

  protected

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
