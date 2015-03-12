require 'spec_helper'

class Dummy < ActiveRecord::Base
end

describe ActiveRecord::DatabaseValidations::Rescues do
  let(:older_dummy) { Dummy.new(not_null_integer: 0, not_null_string: "") }
  let(:dummy) { Dummy.new(not_null_integer: 0, not_null_string: "") }

  shared_examples_for :rescues do
    describe "#rescue_database_not_null" do
      context "primary key" do
        let!(:result) { dummy.tap(&:save!).update_attributes(id: nil) } # can't set new primary key to nil
        specify { expect(result).to be false }
        specify { expect(dummy.errors.messages).to eq(id: [I18n.t("errors.messages.blank")]) }
      end

      context "integer" do
        let!(:result) { dummy.update_attributes(not_null_integer: nil) }
        specify { expect(result).to be false }
        specify { expect(dummy.errors.messages).to eq(not_null_integer: [I18n.t("errors.messages.blank")]) }
      end

      context "string" do
        let!(:result) { dummy.update_attributes(not_null_string: nil) }
        specify { expect(result).to be false }
        specify { expect(dummy.errors.messages).to eq(not_null_string: [I18n.t("errors.messages.blank")]) }
      end
    end

    describe "#rescue_database_unique" do
      context "primary key" do
        let!(:result) { dummy.update_attributes(id: older_dummy.tap(&:save!).id) }
        specify { expect(result).to be false }
        specify { expect(dummy.errors.messages).to eq(id: [I18n.t("errors.messages.taken")]) }
      end

      context "single" do
        context "integer" do
          before { older_dummy.update_attributes!(unique_single_integer: 1) }
          let!(:result) { dummy.update_attributes(unique_single_integer: 1) }
          specify { expect(result).to be false }
          specify { expect(dummy.errors.messages).to eq(unique_single_integer: [I18n.t("errors.messages.taken")]) }
        end

        context "string" do
          before { older_dummy.update_attributes!(unique_single_string: 1) }
          let!(:result) { dummy.update_attributes(unique_single_string: 1) }
          specify { expect(result).to be false }
          specify { expect(dummy.errors.messages).to eq(unique_single_string: [I18n.t("errors.messages.taken")]) }
        end
      end

      context "multiple" do
        context "integer" do
          before { older_dummy.update_attributes!(unique_multiple_integer1: 1, unique_multiple_integer2: 2) }
          let!(:result) { dummy.update_attributes(unique_multiple_integer1: 1, unique_multiple_integer2: 2) }
          specify { expect(result).to be false }
          specify { expect(dummy.errors.messages).to eq(unique_multiple_integer1: [I18n.t("errors.messages.taken")]) }
        end

        context "string" do
          before { older_dummy.update_attributes!(unique_multiple_string1: 1, unique_multiple_string2: 2) }
          let!(:result) { dummy.update_attributes(unique_multiple_string1: 1, unique_multiple_string2: 2) }
          specify { expect(result).to be false }
          specify { expect(dummy.errors.messages).to eq(unique_multiple_string1: [I18n.t("errors.messages.taken")]) }
        end
      end
    end

    describe "#rescue_database_foreign_key" do
      let!(:result) { dummy.update_attributes(foreign_key: -1) }
      specify { expect(result).to be false }
      specify { expect(dummy.errors.messages).to eq(foreign_key: [I18n.t("errors.messages.inclusion")]) }
    end
  end

  DATABASE_ADAPTERS.each do |database_adapter_config|
    context database_adapter_config[:adapter] do
      # using :all to make DatabaseCleaner come after us
      before(:all) { ActiveRecord::Base.establish_connection(database_adapter_config) }

      context "new record" do
        it_behaves_like :rescues
      end

      context "existing record" do
        before { dummy.save! }
        it_behaves_like :rescues
      end
    end
  end
end
