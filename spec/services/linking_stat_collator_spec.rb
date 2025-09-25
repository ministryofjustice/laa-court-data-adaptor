RSpec.describe LinkingStatCollator do
  subject(:data) { described_class.call(date_from, date_to) }

  let(:date_from) { Date.new(2025, 9, 7) }
  let(:date_to) { Date.new(2025, 9, 13) }

  it "shows stats for the current range" do
    # Linked on the first day of the range
    LaaReference.create!(defendant_id: SecureRandom.uuid, maat_reference: "1234567", user_name: "abcde",
                         created_at: Time.zone.local(2025, 9, 7, 10, 0, 0), linked: true)

    # Linked on the last day of the range
    LaaReference.create!(defendant_id: SecureRandom.uuid, maat_reference: "2345678", user_name: "abcde",
                         created_at: Time.zone.local(2025, 9, 13, 10, 0, 0), linked: true)

    # Linked outside the range
    LaaReference.create!(defendant_id: SecureRandom.uuid, maat_reference: "3456789", user_name: "abcde",
                         created_at: Time.zone.local(2025, 9, 14, 10, 0, 0), linked: true)

    # Created inside the range and unlinked
    LaaReference.create!(defendant_id: SecureRandom.uuid, maat_reference: "4567890", user_name: "abcde",
                         created_at: Time.zone.local(2025, 9, 12, 10, 0, 0), linked: false,
                         unlink_reason_code: 7, unlink_other_reason_text: "Some reason")

    expect(data[:current_range]).to eq(
      date_from: date_from,
      date_to: date_to,
      linked: 3,
      other_unlink_reasons: ["Some reason"],
      unlink_reason_codes: { 7 => 1 },
      unlinked: 1,
    )
  end

  it "shows trends for previous ranges" do
    # Linked on the first day of the range
    LaaReference.create!(defendant_id: SecureRandom.uuid, maat_reference: "1234567", user_name: "abcde",
                         created_at: Time.zone.local(2025, 9, 7, 10, 0, 0), linked: true)

    # Linked the day before the current range
    LaaReference.create!(defendant_id: SecureRandom.uuid, maat_reference: "2345678", user_name: "abcde",
                         created_at: Time.zone.local(2025, 9, 6, 10, 0, 0), linked: true)

    # Linked a week before the current range and unlinked
    LaaReference.create!(defendant_id: SecureRandom.uuid, maat_reference: "3456789", user_name: "abcde",
                         created_at: Time.zone.local(2025, 8, 31, 10, 0, 0), linked: false,
                         unlink_reason_code: 1)

    # Linked 8 days before the current range
    LaaReference.create!(defendant_id: SecureRandom.uuid, maat_reference: "4567890", user_name: "abcde",
                         created_at: Time.zone.local(2025, 8, 30, 10, 0, 0), linked: true)

    expect(data[:previous_ranges]).to eq(
      [
        { date_from: Date.new(2025, 8, 31),
          date_to: Date.new(2025, 9, 6),
          linked: 1,
          unlinked: 0 },
        { date_from: Date.new(2025, 8, 24),
          date_to: Date.new(2025, 8, 30),
          linked: 2,
          unlinked: 1 },
      ],
    )
  end
end
