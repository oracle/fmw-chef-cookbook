if defined?(ChefSpec)
  def extract_fmw_opatch_fmw_extract(message)
    ChefSpec::Matchers::ResourceMatcher.new(:fmw_opatch_fmw_extract, :extract, message)
  end

  def apply_fmw_opatch_opatch(message)
    ChefSpec::Matchers::ResourceMatcher.new(:fmw_opatch_opatch, :apply, message)
  end
end
