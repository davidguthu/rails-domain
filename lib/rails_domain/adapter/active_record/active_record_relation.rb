module ActiveRecord
  class Relation
    # TODO: find some way to separate this implementation from the internals of activerecord.
    def to_a
      @records = logging_query_plan do
        exec_queries
      end
      @records =  @records.map{|x| x.has_domain_class? ? x.domain_class.new(x) : x }
    end
  end
end