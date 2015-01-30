module Blame
  module Userstamp
    def self.included(base)
      base.alias_method_chain :create, :userstamps
      base.alias_method_chain :update, :userstamps

      base.class_attribute :record_userstamps, :instance_writer => false
      base.record_userstamps = true

      base.class_attribute :created_userstamp_column, :instance_writer => false
      base.created_userstamp_column = :created_by

      base.class_attribute :updated_userstamp_column, :instance_writer => false
      base.updated_userstamp_column = :updated_by
    end

    private

    def userstamp_object
      User.current_user
    end

    def create_with_userstamps
      if record_userstamps && userstamp_object
        write_attribute(created_userstamp_column, userstamp_object.id) if respond_to?(created_userstamp_column)
        write_attribute(updated_userstamp_column, userstamp_object.id) if respond_to?(updated_userstamp_column)
      end
      create_without_userstamps
    end

    def update_with_userstamps(*args)
      if record_userstamps && userstamp_object && (!partial_updates? || changed?)
        write_attribute(updated_userstamp_column, userstamp_object.id) if respond_to?(updated_userstamp_column)
      end
      update_without_userstamps
    end

  end

  module UserstampMigrationHelper
    def userstamps
      column ActiveRecord::Base.created_userstamp_column, :integer
      column ActiveRecord::Base.updated_userstamp_column, :integer
    end
  end

end

ActiveRecord::Base.send :include, Blame::Userstamp
ActiveRecord::ConnectionAdapters::TableDefinition.send :include, Blame::UserstampMigrationHelper
