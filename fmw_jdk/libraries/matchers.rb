if defined?(ChefSpec)
  def install_fmw_jdk_jdk(message)
    ChefSpec::Matchers::ResourceMatcher.new(:fmw_jdk_jdk, :install, message)
  end

  def configure_fmw_jdk_rng_service(message)
    ChefSpec::Matchers::ResourceMatcher.new(:fmw_jdk_rng_service, :configure, message)
  end
end
