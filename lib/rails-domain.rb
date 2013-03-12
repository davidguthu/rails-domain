module RailsDomain
  def self.domain_namespace=(new_domain_namespace)
    @domain_namespace = new_domain_namespace
  end

  def self.domain_namespace
    @domain_namespace ||= 'Domain'
  end

  def self.map_domain_class(ar_class, domain_class)
    ImplementationProvider.set(ar_class,domain_class)
  end

  def self.configure
    yield self
  end
end

require 'rails_domain/implementation_provider'
require 'rails_domain/adapter/active_record/active_record_relation' if defined? ActiveRecord::Relation
require 'rails_domain/core_ext/object'
require 'rails_domain/base_domain'




