module RailsDomain
  class ImplementationProvider

    @settings = {}
    def self.setup(&block)
      block.call(self)
    end

    def self.get(i)
      get_implementation(i)
    end

    def self.set(k, v)
      @settings[k] = v
    end

    private
    def self.find_active_record_class(m)
      if class_exists?(strip_preceding_namespace(m))
        strip_preceding_namespace(m)
      else
        nil
      end
    end

    def self.strip_preceding_namespace(m)
      m.sub("#{RailsDomain.domain_namespace}::",'')
    end

    def self.get_implementation(key)
      if @settings[key] != nil
        @settings[key].to_s.camelize.constantize
      else
        ar_class = find_active_record_class(key)
        if ar_class != nil
          @settings[key] = ar_class.to_s
          ar_class.to_s.constantize
        else
          nil
        end
      end
    end

  end
end
