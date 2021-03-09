module UrlForHelper
  def url_for(options = nil)
    case options
    when String
      options
    when Hash
      super({only_path: view_only_path}.merge(options))
    when ActionController::Parameters
      super({only_path: view_only_path}.merge(options.to_h))
    when Array
      components = options.dup
      opts = components.extract_options!
      super([components, {only_path: view_only_path}.merge(opts)])
    else
      super([options, {only_path: view_only_path}])
    end
  end
end