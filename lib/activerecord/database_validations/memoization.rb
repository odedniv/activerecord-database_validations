module ActiveRecord::DatabaseValidations::Memoization
  def indexes
    @indexes ||= connection.indexes(table_name)
  end

  def foreign_keys
    @foreign_keys ||= connection.foreign_keys(table_name)
  end
end

ActiveRecord::Base.extend ActiveRecord::DatabaseValidations::Memoization
