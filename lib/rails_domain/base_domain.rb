require 'active_model'

module RailsDomain
  class BaseDomain
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::MassAssignmentSecurity

    attr_reader :persistence_object
    class_attribute :persistence_class

    def to_model
      @persistence_object
    end

    def id
      @persistence_object.id
    end

    def initialize(object_or_attributes)
      if object_or_attributes.is_a?(Hash) || object_or_attributes.nil?
        @persistence_object = persistence_class.new object_or_attributes
      else
        @persistence_object = object_or_attributes
      end
      domain_wrap_associations
    end

    def self.find(id)
      new(persistence_class.find(id))
    end

    def self.create(*args)
      new persistence_class.create(*args)
    end

    private

    # Creates methods that wrap the collections found on the @persistence_object, returns domain objects if present
    # otherwise it passes through the AR object. Why not use method_missing here? - PERFORMANCE
    def domain_wrap_associations(&post_process)
      return if self.persistence_class.nil?  # I hate this - test concern bleeding in here.

      class << self
        self.superclass.persistence_class.reflect_on_all_associations.map{|a| a.name}.each do |association_name|
          define_method(association_name) do |*args, &block|
            wrap_objects(self.persistence_object.public_send(association_name, *args, &block))
          end

          define_method("#{association_name}=") do |value|
            self.persistence_object.public_send("#{association_name}=", unwrap_objects(value))
          end

          define_method("#{association_name}<<") do |value|
            self.persistence_object.public_send("#{association_name}<<", unwrap_objects(value))
          end

        end
      end
    end

    def wrap_objects(object_or_objects)
      if object_or_objects.is_a?(Array)
        object_or_objects.map{|ar| wrap_object(ar) }     # need to get the appropriate domain class
      else
        wrap_object(object_or_objects)
      end
    end

    # TODO: cache the const calls put mapping in instance var
    def wrap_object(object)
      class_name = "#{RailsDomain.domain_namespace}::#{object.class.to_s}"
      if Object.class_exists?(class_name)
        klass = Object.deep_const_get(class_name)
        klass.new(object)
      else
        object
      end
    end

    def unwrap_objects(object_or_objects)
      if object_or_objects.is_a?(Array)
        object_or_objects.map{|o| unwrap_object(o)}
      else
        unwrap_object(object_or_objects)
      end
    end

    def unwrap_object(object)
      object.domain_object? ? object.persistence_object : object
    end

    # retrieves the persistence class by convention or registry
    def self.persistence_class
      @persistence_class ||= ImplementationProvider.get(self.to_s).nil? ? ImplementationProvider.get(self.superclass.to_s) :
          ImplementationProvider.get(self.to_s)
    end

    def respond_to?(method)
      return true if self.respond_to?(method) || self.persistence_object.respond_to?(method)
      super(method)
    end

    def method_missing(method, *args, &block)
      if @persistence_object.respond_to?(method, *args, &block)
        @persistence_object.public_send(method, *args, &block)
      else
        super
      end
    end

    def self.method_missing(method, *args, &block)
      if persistence_class.respond_to?(method)
        # define the method so we dont hit method missing a second time.
        define_method(method) do |*args, &block|
          persistence_class.public_send(method, *args, *block)
        end
        persistence_class.public_send(method, *args, &block)
      else
        super(method, *args, &block)
      end
    end

  end
end
