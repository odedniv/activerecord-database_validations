module ActiveRecord::DatabaseValidations::Validations
  def validates_database
    validates_database_not_null
    validates_database_unique
    validates_database_foreign_key
  end

  def validates_database_not_null(options = {})
    columns.reject(&:null).each do |column|
      validation = proc do
        if self[column.name].nil?
          errors.add(column.name, options[:message] || :blank)
        end
      end

      if column.extra == 'auto_increment'
        validate(on: :update, &validation)
      else
        validate(&validation)
      end
    end
  end

  def validates_database_unique(options = {})
    validates_uniqueness_of(primary_key, **options, allow_nil: true) if primary_key
    connection.indexes(table_name).select(&:unique).each do |index|
      validates_uniqueness_of(index.columns[0], **options, scope: index.columns[1..-1], allow_nil: true)
    end
  end

  def validates_database_foreign_key(options = {})
    connection.foreign_keys(table_name).each do |foreign_key|
      model = Class.new(ActiveRecord::Base) do
        self.table_name = foreign_key.to_table
      end
      validate do
        if not self[foreign_key.options[:column]].nil? and not model.where(foreign_key.options[:primary_key] => self[foreign_key.options[:column]]).exists?
          errors.add(foreign_key.options[:column], options[:message] || :inclusion)
        end
      end
    end
  end
end

ActiveRecord::Base.extend ActiveRecord::DatabaseValidations::Validations
