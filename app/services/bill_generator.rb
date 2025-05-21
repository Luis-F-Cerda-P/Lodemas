require "selenium-webdriver"
require "fileutils"

class BillGenerator
  def initialize(order:, download_dir:)
    @order = order
    @download_dir = download_dir
    FileUtils.mkdir_p(@download_dir)
  end

  def generate!
    setup_driver

    begin
      perform_steps
      find_pdf!
    ensure
      @driver.quit
    end
  end

  private

  def setup_driver
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile["browser.download.folderList"] = 2
    profile["permissions.default.geo"] = 2
    profile["browser.download.dir"] = @download_dir.to_s
    profile["browser.helperApps.neverAsk.saveToDisk"] = "application/pdf"
    profile["pdfjs.disabled"] = true


    options = Selenium::WebDriver::Firefox::Options.new
    options.profile = profile
    options.add_argument("--headless")
    options.log_level = :trace

    @driver = Selenium::WebDriver.for :firefox, options: options
    @wait = Selenium::WebDriver::Wait.new(timeout: 200)
  end

  def perform_steps
    @driver.get("https://eboleta.sii.cl/")
    @driver.manage.window.resize_to(1494, 692)

    # Wait and login
    wait_until { @driver.find_element(name: "rut").displayed? }
    tax_account = @order.user.tax_accounts.first
    rut = tax_account.rut
    password = tax_account.password

    @driver.find_element(name: "rut").send_keys(rut)
    @driver.find_element(id: "inputPass").send_keys(password)

    wait_until { @driver.find_elements(css: ".transparencia").empty? }
    sleep 3
    @driver.find_element(id: "bt_ingresar").click

    # Wait for overlay to clear
    wait_until { @driver.find_element(css: ".v-overlay__scrim").displayed? }
    sleep 3
    wait_until { @driver.find_elements(css: ".v-overlay__scrim").none?(&:displayed?) }
    sleep 5

    dropdown = wait_until { el = @driver.find_element(css: ".v-select__selections"); el if el.displayed? && el.enabled? }
    sleep 5
    dropdown.click
    sleep 3

    # Select company
    item = @driver.find_element(:xpath, "//*[contains(text(), '77.268.185-2 PETPORIUM SPA')]")
    item.click

    # Simulate numeric pad entry
    simulate_digit_entry(@order.billable_amount.to_s) # You may replace this with dynamic logic

    sleep 5
    emitir_buttons = @driver.find_elements(css: "button.v-btn.success")
    first_emitir = emitir_buttons.find { |b| b.text.strip == "EMITIR" && b.displayed? && b.enabled? }
    sleep 3
    first_emitir.click

    second_emitir = @wait.until do
      emitir_buttons = @driver.find_elements(css: "button.v-btn.success")
      emitir_buttons.find { |b| b.text.strip == "EMITIR" && b.displayed? && b != first_emitir }
    end

    sleep 3

    second_emitir.click

    sleep 3

    descargar_link = @wait.until do
      @driver.find_elements(css: "a.v-btn.success").find { |link| link.text.strip.upcase.include?("DESCARGAR") }
    end

    sleep 3
    descargar_link.click

    wait_for_download_to_finish
  end

  def simulate_digit_entry(number_string)
    buttons = @driver.find_elements(css: "button.v-btn.green.lighten-4")
    digit_map = buttons.index_by { |b| b.text.strip }

    number_string.each_char do |digit|
      btn = digit_map[digit]
      raise "Button for digit #{digit} not found" unless btn

      btn.click
      sleep 0.3
    end
  end

  def wait_for_download_to_finish
    timeout = 20
    start = Time.now

    loop do
      break if Dir.glob("#{@download_dir}/*.part").empty? && !Dir.glob("#{@download_dir}/*.pdf").empty?
      raise "PDF download timed out" if Time.now - start > timeout

      sleep 0.5
    end
  end

  def find_pdf!
    pdf_path = Dir.glob(File.join(@download_dir, "*.pdf")).first
    raise "PDF not found in #{@download_dir}" unless pdf_path

    pdf_path
  end

  def wait_until(&block)
    @wait.until(&block)
  end
end
