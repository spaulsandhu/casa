require "rails_helper"

RSpec.describe "admin editing admin users", type: :system do
  let(:admin) { create :casa_admin }

  before { sign_in admin }

  context "with valid data" do
    it "can successfully edit user email and display name" do
      expected_email = "root@casa.com"
      expected_display_name = "Root Admin"

      visit edit_casa_admin_path(admin)

      fill_in "Email", with: expected_email
      fill_in "Display name", with: expected_display_name

      click_on "Update"

      admin.reload

      expect(page).to have_text "Admin was successfully updated."
      expect(admin.email).to eq expected_email
      expect(admin.display_name).to eq expected_display_name
    end
  end

  context "with invalid data" do
    it "shows error message for empty email" do
      visit edit_casa_admin_path(admin)

      fill_in "Email", with: ""
      fill_in "Display name", with: ""

      click_on "Update"

      expect(page).to have_text "Email can't be blank"
      expect(page).to have_text "Display name can't be blank"
    end
  end
end