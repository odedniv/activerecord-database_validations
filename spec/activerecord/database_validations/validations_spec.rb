require 'spec_helper'

ActiveRecord::Base.establish_connection(DATABASE_ADAPTERS.first)

class Dummy < ActiveRecord::Base
  validates_database
end

describe ActiveRecord::DatabaseValidations::Validations do
  let(:older_dummy) { Dummy.new(not_null_integer: 0, not_null_string: "") }
  let(:dummy) { Dummy.new(not_null_integer: 0, not_null_string: "") }

  shared_examples_for :validations do
    describe "::validates_database_not_null" do
      context "primary key" do
        before { dummy.tap(&:save!).assign_attributes(id: nil) } # can't set new primary key to nil
        let!(:result) { dummy.valid? }
        specify { expect(result).to be false }
        specify { expect(dummy.errors.messages).to eq(id: [I18n.t("errors.messages.blank")]) }
      end

      context "integer" do
        before { dummy.assign_attributes(not_null_integer: nil) }
        let!(:result) { dummy.valid? }
        specify { expect(result).to be false }
        specify { expect(dummy.errors.messages).to eq(not_null_integer: [I18n.t("errors.messages.blank")]) }
      end

      context "string" do
        before { dummy.assign_attributes(not_null_string: nil) }
        let!(:result) { dummy.valid? }
        specify { expect(result).to be false }
        specify { expect(dummy.errors.messages).to eq(not_null_string: [I18n.t("errors.messages.blank")]) }
      end
    end

    describe "::validates_database_unique" do
      context "primary key" do
        before { dummy.assign_attributes(id: older_dummy.tap(&:save!).id) }
        let!(:result) { dummy.valid? }
        specify { expect(result).to be false }
        specify { expect(dummy.errors.messages).to eq(id: [I18n.t("errors.messages.taken")]) }
      end

      context "single" do
        context "integer" do
          before { older_dummy.update!(unique_single_integer: 1) }
          before { dummy.assign_attributes(unique_single_integer: 1) }
          let!(:result) { dummy.valid? }
          specify { expect(result).to be false }
          specify { expect(dummy.errors.messages).to eq(unique_single_integer: [I18n.t("errors.messages.taken")]) }
        end

        context "string" do
          before { older_dummy.update!(unique_single_string: 1) }
          before { dummy.assign_attributes(unique_single_string: 1) }
          let!(:result) { dummy.valid? }
          specify { expect(result).to be false }
          specify { expect(dummy.errors.messages).to eq(unique_single_string: [I18n.t("errors.messages.taken")]) }
        end
      end

      context "multiple" do
        context "integer" do
          before { older_dummy.update!(unique_multiple_integer1: 1, unique_multiple_integer2: 2) }
          before { dummy.assign_attributes(unique_multiple_integer1: 1, unique_multiple_integer2: 2) }
          let!(:result) { dummy.valid? }
          specify { expect(result).to be false }
          specify { expect(dummy.errors.messages).to eq(unique_multiple_integer2: [I18n.t("errors.messages.taken")]) }
        end

        context "string" do
          before { older_dummy.update!(unique_multiple_string1: 1, unique_multiple_string2: 2) }
          before { dummy.assign_attributes(unique_multiple_string1: 1, unique_multiple_string2: 2) }
          let!(:result) { dummy.valid? }
          specify { expect(result).to be false }
          specify { expect(dummy.errors.messages).to eq(unique_multiple_string2: [I18n.t("errors.messages.taken")]) }
        end

        context "primary nil" do
          before { older_dummy.update!(unique_multiple_integer1: nil, unique_multiple_integer2: 2) }
          before { dummy.assign_attributes(unique_multiple_integer1: nil, unique_multiple_integer2: 2) }
          let!(:result) { dummy.valid? }
          specify { expect(result).to be true }
        end

        context "secondary nil" do
          before { older_dummy.update!(unique_multiple_integer1: 1, unique_multiple_integer2: nil) }
          before { dummy.assign_attributes(unique_multiple_integer1: 1, unique_multiple_integer2: nil) }
          let!(:result) { dummy.valid? }
          specify { expect(result).to be true }
        end
      end
    end

    describe "::validates_database_foreign_key" do
      before { dummy.assign_attributes(foreign_key: -1) }
      let!(:result) { dummy.valid? }
      specify { expect(result).to be false }
      specify { expect(dummy.errors.messages).to eq(foreign_key: [I18n.t("errors.messages.inclusion")]) }
    end
  end

  it_behaves_like :validations
end
