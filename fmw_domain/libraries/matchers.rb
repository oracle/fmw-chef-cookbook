if defined?(ChefSpec)
  def execute_fmw_domain_wlst(message)
    ChefSpec::Matchers::ResourceMatcher.new(:fmw_domain_wlst, :execute, message)
  end
  def configure_fmw_domain_nodemanager_service(message)
    ChefSpec::Matchers::ResourceMatcher.new(:fmw_domain_nodemanager_service, :configure, message)
  end
  def start_fmw_domain_adminserver(message)
    ChefSpec::Matchers::ResourceMatcher.new(:fmw_domain_adminserver, :start, message)
  end
  def stop_fmw_domain_adminserver(message)
    ChefSpec::Matchers::ResourceMatcher.new(:fmw_domain_adminserver, :stop, message)
  end
  def restart_fmw_domain_adminserver(message)
    ChefSpec::Matchers::ResourceMatcher.new(:fmw_domain_adminserver, :restart, message)
  end
end

