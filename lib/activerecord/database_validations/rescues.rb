module ActiveRecord::DatabaseValidations::Rescues
  def self.included(base)
    base.around_save :rescue_database_not_null
    base.around_save :rescue_database_unique
    base.around_save :rescue_database_foreign_key
  end

  NOT_NULL_PATTERNS = [
    /^Mysql2::Error: Column '(.+?)' cannot be null:/,
    /^Mysql2::Error: Field '(.+?)' doesn't have a default value:/,
    /^PG::NotNullViolation: ERROR:  null value in column "(.+?)" violates not-null constraint\nDETAIL:/,
  ]
  def rescue_database_not_null
    begin
      yield
    rescue ActiveRecord::StatementInvalid => e
      if NOT_NULL_PATTERNS.any? { |p| e.message =~ p }
        column_name = $1
        errors.add(column_name, :blank)
        raise ActiveRecord::RecordInvalid.new(self)
      else
        raise
      end
    end
  end

  UNIQUE_PATTERNS_BY_COLUMN = [
    /^PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint ".+?"\nDETAIL:  Key \((?:.+?, )*(.+?)\)=\(.+?\) already exists\./,
  ]
  UNIQUE_PATTERNS_BY_INDEX = [
    /^Mysql2::Error: Duplicate entry '.+?' for key '(.+?)':/,
  ]
  PRIMARY_INDEXES = [
    'PRIMARY',
  ]
  def rescue_database_unique
    self.class.indexes if UNIQUE_PATTERNS_BY_INDEX.any? # load the indexes not inside a failed transaction (eg. PG::InFailedSqlTransaction)
    begin
      yield
    rescue ActiveRecord::RecordNotUnique => e
      column_name = if UNIQUE_PATTERNS_BY_COLUMN.any? { |p| e.message =~ p }
                      $1
                    elsif UNIQUE_PATTERNS_BY_INDEX.any? { |p| e.message =~ p }
                      if PRIMARY_INDEXES.include?($1)
                        self.class.primary_key
                      else
                        index = self.class.indexes.find { |i| i.name == $1 }
                        raise if index.nil?
                        index.columns[-1]
                      end
                    else
                      raise
                    end
      errors.add(column_name, :taken)
      raise ActiveRecord::RecordInvalid.new(self)
    end
  end

  FOREIGN_KEY_PATTERNS_BY_COLUMN = [
    /^Mysql2::Error: Cannot add or update a child row: a foreign key constraint fails \(`.+?`\.`.+?`, CONSTRAINT `.+?` FOREIGN KEY \(`(.+?)`\) REFERENCES `.+?` \(`.+?`\)(?: ON [A-Z ]+)?\):/,
    /^PG::ForeignKeyViolation: ERROR:  insert or update on table ".+?" violates foreign key constraint ".+?"\nDETAIL:  Key \((.+?)\)=\(.+?\) is not present in table ".+?"\.\n:/,
  ]
  FOREIGN_KEY_PATTERNS_BY_FOREIGN_KEY = [
  ]
  def rescue_database_foreign_key
    self.class.foreign_keys if FOREIGN_KEY_PATTERNS_BY_FOREIGN_KEY.any? # load he foreign keys not inside a failing transaction (eg. PG::InFailedSqlTransaction)
    begin
      yield
    rescue ActiveRecord::InvalidForeignKey => e
      column_name = if FOREIGN_KEY_PATTERNS_BY_COLUMN.any? { |p| e.message =~ p }
                      $1
                    elsif FOREIGN_KEY_PATTERNS_BY_FOREIGN_KEY.any? { |p| e.message =~ p }
                      foreign_key = self.class.foreign_keys.find { |i| i.name == $1 }
                      raise if foreign_key.nil?
                      foreign_key.column
                    else
                      raise
                    end
      errors.add(column_name, :inclusion)
      raise ActiveRecord::RecordInvalid.new(self)
    end
  end
end

class ActiveRecord::Base
  include ActiveRecord::DatabaseValidations::Rescues
end
