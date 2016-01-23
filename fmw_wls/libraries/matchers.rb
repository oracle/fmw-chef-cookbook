if defined?(ChefSpec)
  def install_fmw_wls_wls(message)
    ChefSpec::Matchers::ResourceMatcher.new(:fmw_wls_wls, :install, message)
  end
end
