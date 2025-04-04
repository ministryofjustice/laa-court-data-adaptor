class CourtApplicationMaatLinkCreatorWorker
  include Sidekiq::Worker

  def perform(request_id, subject_id, user_name, maat_reference)
    Current.set(request_id:) do
      CourtApplicationMaatLinkCreator.call(subject_id, user_name, maat_reference)
    end
  end
end
