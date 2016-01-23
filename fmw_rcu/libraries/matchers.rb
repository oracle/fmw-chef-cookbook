if defined?(ChefSpec)
  def create_fmw_rcu_repository(message)
    ChefSpec::Matchers::ResourceMatcher.new(:fmw_rcu_repository, :create, message)
  end
end
