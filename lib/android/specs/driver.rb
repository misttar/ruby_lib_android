# encoding: utf-8

describe 'driver' do
  t 'load_appium_txt' do
    # __FILE__ is '(eval)' so use env var set by the Rakefile
    path = ENV['APPIUM_TXT']
    puts "appium.txt path in test is: #{path}"
    load_appium_txt file: path, verbose: true
    apk_name = File.basename(ENV['APP_PATH'])
    assert_equal apk_name, 'api.apk'
  end

  describe 'Appium::Driver attributes' do
    # attr_reader :default_wait, :app_path, :app_name, :selendroid,
    #            :app_package, :app_activity, :app_wait_activity,
    #            :sauce_username, :sauce_access_key, :port, :os, :debug
    t 'default_wait attr' do
      set_wait 1
      default_wait.must_equal 1
      set_wait # restore default
    end

    t 'app_path attr' do
      apk_name = File.basename app_path
      apk_name.must_equal 'api.apk'
    end

    # Only used for Sauce Labs
    t 'app_name attr' do
      app_name.must_be_nil
    end

    t 'device attr' do
      device.must_equal :android
    end

    t 'app_package attr' do
      app_package.must_equal 'com.example.android.apis'
    end

    t 'app_activity attr' do
      app_activity.must_equal '.ApiDemos'
    end

    t 'app_wait_activity attr' do
      app_wait_activity.must_equal '.ApiDemos'
    end

    t 'sauce_username attr' do
      sauce_username.must_be_nil
    end

    t 'sauce_access_key attr' do
      sauce_access_key.must_be_nil
    end

    t 'port attr' do
      port.must_equal 4723
    end

    t 'debug attr' do
      debug.must_equal true
    end
  end

  describe 'Appium::Driver' do
    t '@@loaded' do
      loaded = $driver.class.class_variable_get :@@loaded
      loaded.must_equal true
    end

    t '$driver.class' do
      $driver.class.must_equal Appium::Driver
    end
  end

  describe 'methods' do
    t 'status' do
      status.keys.sort.must_equal %w(sessionId status value)
    end

    t 'server_version' do
      server_version.must_match /(\d+)\.(\d+).(\d+)/
    end

    def expected_android_capabilities
      {:compressXml => false,
       :platform => 'LINUX',
       :version => '4.2',
       :device => 'Android',
       :name => 'Ruby Console Android Appium',
       :'app-package' => 'com.example.android.apis',
       :'app-activity' => '.ApiDemos',
       :'app-wait-activity' => '.ApiDemos',
       :fastClear => true,
       :app => 'api.apk'}
    end

    t 'capabilities' do
      exp = expected_android_capabilities

      act = capabilities
      act[:app] = File.basename act[:app]
      act.must_equal exp
    end

=begin
  Skip:
    ios_capabilities # save for iOS tests
    absolute_app_path # tested already by starting the driver for this test
    server_url # sauce labs only
=end
    t 'restart' do
      set_wait 1 # ensure wait is 1 before we restart.
      restart
      mobile(:currentActivity).must_equal '.ApiDemos'
    end

    t 'driver' do
      driver.browser.must_equal :Android
    end

=begin
  Skip:
    screenshot   # this is slow and already tested by Appium
    driver_quit  # tested by restart
    start_driver # tested by restart
    no_wait  # posts value to server, it's not stored locally
    set_wait # posts value to server, it's not stored locally
=end
    t 'default_wait' do
      default_wait.must_equal 1
    end

    # returns true unless an error is raised
    t 'exists' do
      exists(0, 0) { true }.must_equal true
      exists(0, 0) { raise 'error' }.must_equal false
    end

    # any script
    t 'execute_script' do
      execute_script('mobile: currentActivity').must_equal '.ApiDemos'
    end

    # any mobile method
    t 'mobile' do
      mobile(:currentActivity).must_equal '.ApiDemos'
    end

    # any elements
    t 'find_elements' do
      find_elements(:tag_name, :text).length.must_equal 12
    end

    # any element
    t 'find_element' do
      find_element(:tag_name, :text).class.must_equal Selenium::WebDriver::Element
    end

    # Skip: x # x is only used in Pry
  end
end
