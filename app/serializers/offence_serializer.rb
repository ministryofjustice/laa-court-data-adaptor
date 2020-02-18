# frozen_string_literal: true

class OffenceSerializer
  include FastJsonapi::ObjectSerializer
  set_type :offences

  attributes :offence_code_order_index, :order_index, :offence_title, :offence_legislation, :wording, :arrest_date,
             :charge_date, :date_of_information, :mode_of_trial, :start_date, :end_date, :proceeding_concluded, :application_reference,
             :status_id, :status_code, :status_description, :status_date, :effective_start_date, :effective_end_date
end
