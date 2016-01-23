if defined?(ChefSpec)
  def extract_fmw_inst_fmw_extract(message)
    ChefSpec::Matchers::ResourceMatcher.new(:fmw_inst_fmw_extract, :extract, message)
  end

  def install_fmw_inst_fmw_install(message)
    ChefSpec::Matchers::ResourceMatcher.new(:fmw_inst_fmw_install, :install, message)
  end

end
