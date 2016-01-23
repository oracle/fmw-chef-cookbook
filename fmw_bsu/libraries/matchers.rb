if defined?(ChefSpec)
  def install_fmw_bsu_bsu(message)
    ChefSpec::Matchers::ResourceMatcher.new(:fmw_bsu_bsu, :install, message)
  end

  def remove_fmw_bsu_bsu(message)
    ChefSpec::Matchers::ResourceMatcher.new(:fmw_bsu_bsu, :remove, message)
  end

end
