require 'spec_helper'
require 'active_record'
require 'db/adapters'

I18n.backend.store_translations :en, inbox: {
  errors: {
    messages: {
      blank: "BLANK",
      taken: "TAKEN",
      inclusion: "INCLUSION",
    },
  },
}

class Dummy < ActiveRecord::Base
end

describe Activerecord::HandleStatementInvalid do
  let(:older_dummy) { Dummy.new(not_null_integer: 0, not_null_string: "") }
  subject(:dummy) { Dummy.new(not_null_integer: 0, not_null_string: "") }

  shared_examples_for :handle_statement_invalid do
    context "not null" do
      context "primary key" do
        let!(:result) { dummy.tap(&:save!).update_attributes(id: nil) } # can't set new primary key to nil
        specify { expect(result).to be false }
        its(:errors) { should contain_exactly(id: ["BLANK"]) }
      end

      context "integer" do
        let!(:result) { dummy.update_attributes(not_null_integer: nil) }
        specify { expect(result).to be false }
        its(:errors) { should contain_exactly(not_null_integer: ["BLANK"]) }
      end

      context "string" do
        let!(:result) { dummy.update_attributes(not_null_string: nil) }
        specify { expect(result).to be false }
        its(:errors) { should contain_exactly(not_null_string: ["BLANK"]) }
      end
    end

    context "unique" do
      context "primary key" do
        let!(:result) { dummy.update_attributes(id: older_dummy.tap(&:save!).id) }
        specify { expect(result).to be false }
        its(:errors) { should contain_exactly(id: ["TAKEN"]) }
      end

      context "single" do
        context "integer" do
          before { older_dummy.update_attributes!(unique_single_integer: 1) }
          let!(:result) { dummy.update_attributes(unique_single_integer: 1) }
          specify { expect(result).to be false }
          its(:errors) { should contain_exactly(unique_single_integer: ["TAKEN"]) }
        end

        context "string" do
          before { older_dummy.update_attributes!(unique_single_string: 1) }
          let!(:result) { dummy.update_attributes(unique_single_string: 1) }
          specify { expect(result).to be false }
          its(:errors) { should contain_exactly(unique_single_string: ["TAKEN"]) }
        end
      end

      context "multiple" do
        context "integer" do
          before { older_dummy.update_attributes!(unique_multiple_integer1: 1, unique_multiple_integer2: 2) }
          let!(:result) { dummy.update_attributes(unique_multiple_integer1: 1, unique_multiple_integer2: 2) }
          specify { expect(result).to be false }
          its(:errors) { should contain_exactly(unique_multiple_integer1: ["TAKEN"]) }
        end

        context "string" do
          before { older_dummy.update_attributes!(unique_multiple_string1: 1, unique_multiple_string2: 2) }
          let!(:result) { dummy.update_attributes(unique_multiple_string1: 1, unique_multiple_string2: 2) }
          specify { expect(result).to be false }
          its(:errors) { should contain_exactly(unique_multiple_string1: ["TAKEN"]) }
        end
      end
    end

    context "foreign key" do
      let!(:result) { dummy.update_attributes(foreign_key: -1) }
      specify { expect(result).to be false }
      its(:errors) { should contain_exactly(foreign_key: ["INCLUSION"]) }
    end
  end

  DATABASE_ADAPTERS.each do |database_adapter_config|
    context database_adapter_config[:adapter] do
      before { ActiveRecord::Base.establish_connection(database_adapter_config) }

      context "new record" do
        it_behaves_like :handle_statement_invalid
      end

      context "existing record" do
        before { dummy.save! }
        it_behaves_like :handle_statement_invalid
      end
    end
  end
end
