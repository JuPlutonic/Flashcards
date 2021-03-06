require "rails_helper"
require "helpers"

describe "login_logout process and links vision", type: :feature do 
  before :each do
  user_deck_and_card_create
  end
  it "user login must be successfull" do
    visit new_session_path
    fill_in I18n.t('email_here'), with: @user.email
    fill_in I18n.t('password_here'), with: "password"
    click_button I18n.t('submit')
    expect(page).to have_content I18n.t("login_successful")
  end
  it "user logout must be successfull" do
    login(@user)
    visit "trainer"
    click_link I18n.t("logout_link")
    expect(page).to have_content I18n.t("logout_successful")
  end
  it "unloggined_user must have sign_up link" do
    visit "home"
    expect(page).to have_content I18n.t("sign_up_link")
  end
  it "unloggined_user must have sign_in link" do
    visit "home"
    expect(page).to have_content I18n.t("login_link")
  end
  it "unlogined_user must not have my_page link" do
  	visit "home"
    expect(page).not_to have_content I18n.t("my_page")
  end
  it "logined user must have my_page link" do
    login(@user)
    visit "trainer"
    expect(page).to have_content I18n.t("my_page")
  end
  it "logined user must have clickable link edit_my_page" do
    login(@user)
    visit "trainer"
    click_link I18n.t("edit_user_link")
    expect(page).to have_content I18n.t("email_here")
  end
  it "logined user must have clickeble link to my_profile" do
    login(@user)
    visit "trainer"
    click_link I18n.t("my_page")
    expect(page).to have_content @user.email
  end
  it "user email must be shown in my_page after login" do
    login(@user)
    click_link I18n.t("my_page")
    expect(page).to have_content @user.email
  end
  it "user login must be case insensitive" do
    @user.email = "SOMEEMAIL@mail.ru"
    login(@user)
    expect(page).to have_content I18n.t("my_page")  #only logined in user have my_page link
  end
end