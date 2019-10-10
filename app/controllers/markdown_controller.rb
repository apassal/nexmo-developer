class MarkdownController < ApplicationController
  before_action :require_locale, only: :show
  before_action :set_language
  before_action :set_navigation
  before_action :set_product
  before_action :set_tracking_cookie

  def show
    redirect = Redirector.find(request.path.sub("/#{@language}", ''))
    return redirect_to redirect if redirect

    if path_is_folder?
      @frontmatter, @content = content_from_folder
    else
      @frontmatter, @content = content_from_file
    end

    @sidenav = Sidenav.new(
      namespace: params[:namespace],
      language: @language,
      request_path: request.path,
      navigation: @navigation,
      code_language: params[:code_language],
      product: @product
    )

    if !Rails.env.development? && @frontmatter['wip']
      @show_feedback = false
      render 'wip', layout: 'documentation'
    else
      render layout: 'documentation'
    end
  end

  def api
    redirect = Redirector.find(request.path.sub("/#{@language}", ''))
    if redirect
      redirect_to redirect
    else
      render_not_found
    end
  end

  private

  def set_navigation
    @navigation = :documentation
  end

  def set_product
    @product = params[:product]
  end

  def set_tracking_cookie
    helpers.dashboard_cookie(params[:product])
  end

  def document
    @document ||= File.read(
      DocFinder.find(
        root: root_folder,
        document: params[:document],
        language: @language,
        product: params[:product],
        code_language: params[:code_language]
      )
    )
  end

  def root_folder
    if params[:namespace].present?
      "app/views/#{params[:namespace]}"
    else
      '_documentation'
    end
  end

  def require_locale
    return if params[:namespace]
    return if params[:locale]

    redirect_to url_for(
      document: params[:document],
      controller: :markdown,
      action: :show,
      locale: I18n.locale,
      only_path: true,
      product: params[:product]
    ), status: :moved_permanently
  end

  def path_is_folder?
    folder_config_path
  rescue DocFinder::MissingDoc
    false
  end

  def folder_config_path
    DocFinder.find(
      root: root_folder,
      document: "#{params[:document]}/.config.yml",
      language: @language,
      product: params[:product],
      code_language: params[:code_language]
    )
  end

  def content_from_folder
    frontmatter = YAML.safe_load(File.read(folder_config_path))
    path = folder_config_path.chomp('/.config.yml')

    @document_title = frontmatter['meta_title'] || frontmatter['title']

    content = MarkdownPipeline.new({
      code_language: @code_language,
      current_user: current_user,
    }).call(<<~HEREDOC
      <h1>#{@document_title}</h1>

      ```tabbed_folder
      source: #{path}
      ```
    HEREDOC
           )

    [frontmatter, content]
  end

  def content_from_file
    frontmatter = YAML.safe_load(document)

    raise Errno::ENOENT if frontmatter['redirect']

    content = MarkdownPipeline.new({
      code_language: @code_language,
      current_user: current_user,
      language: @language,
    }).call(document)

    [frontmatter, content]
  end
end
