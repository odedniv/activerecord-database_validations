module ActiveRecord::DatabaseValidations::Validations
  def validates_database
    validates_database_not_null
    validates_database_unique
    validates_database_foreign_key
  end

  NOT_NULL_IGNORED = ['created_at', 'updated_at']
  def validates_database_not_null(options = {})
    columns.reject(&:null).each do |column|
      next if NOT_NULL_IGNORED.include?(column.name)
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
    indexes.select(&:unique).each do |index|
      validates_uniqueness_of(index.columns[-1], **options, scope: index.columns[0...-1], if: -> { index.columns.none? { |c| self[c].nil? } })
    end
  end

  def validates_database_foreign_key(options = {})
    foreign_keys.each do |foreign_key|
      model = Class.new(ActiveRecord::Base) do
        self.table_name = foreign_key.to_table
      end
      validate do
        if not self[foreign_key.column].nil? and not model.where(foreign_key.primary_key => self[foreign_key.column]).exists?
          errors.add(foreign_key.column, options[:message] || :inclusion)
        end
      end
    end
  end
end

ActiveRecord::Base.extend ActiveRecord::DatabaseValidations::Validations
