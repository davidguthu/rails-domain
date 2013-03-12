class Object
  def domain_object?
    respond_to?(:persistence_object)
  end

  def has_domain_class?
    Object.class_exists?("#{RailsDomain.domain_namespace}::#{self.class.to_s}")
  end

  def domain_class
    Object.deep_const_get("#{RailsDomain.domain_namespace}::#{self.class.to_s}")
  end

  def self.deep_const_get(const)
    if Symbol === const
      const = const.to_s
    else
      const = const.to_str.dup
    end
    const.split(/::/).inject(Object) { |mod, name| mod.const_get(name) }
  end

  def self.class_exists?(class_name)
    klass = deep_const_get(class_name)
    return klass.is_a?(Class) && class_name == klass.to_s # make sure we retrieved a class with the same name/namespace
  rescue NameError
    return false
  end
end
